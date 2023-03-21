import "package:isar/isar.dart";
import "package:mapplet/src/common/extensions.dart";
import "package:mapplet/src/database/depot_stats.dart";
import "package:mapplet/src/database/models/region_model.dart";
import "package:mapplet/src/database/models/tile_model.dart";
import "package:mapplet/src/depot/depot_config.dart";
import "package:quiver/iterables.dart";

class DepotDatabase {
  DepotDatabase._(this.config);

  late Isar db;
  late Isar tempDb;
  final DepotConfiguration config;

  final List<Future<void>> _isolates = List.empty(growable: true);

  /// Initialize Isar instance and a temp instance with the given config
  static Future<DepotDatabase> open(DepotConfiguration config) async {
    var data = DepotDatabase._(config);

    data.db = await Isar.open(
      [TileModelSchema, RegionModelSchema],
      name: config.id,
      inspector: config.debugIsarConsole,
      maxSizeMiB: config.maxSizeMib,
    );

    data.tempDb = await Isar.open(
      [TileModelSchema],
      name: "${config.id}_temp",
      inspector: config.debugIsarConsole,
      maxSizeMiB: config.maxSizeMib,
    );

    await data.tempDb.writeTxn(() => data.tempDb.clear());
    return data;
  }

  Future<bool> close({bool deleteFromDisk = false}) async {
    return await db.close(deleteFromDisk: deleteFromDisk) || await tempDb.close(deleteFromDisk: deleteFromDisk);
  }

  /// write the region with the given tiles. Return the id of the written region or null
  /// If a tile already exists it modify the links field only
  Future<int?> writeRegion(String regionId, List<TileModel> tileModels) async {
    if (tileModels.isEmpty) return null;
    var tileList = await _generateTiles(tileModels);
    var region = RegionModel(regionId: regionId)..tiles.addAll(tileList);

    var part = partition(tileList, _computeBatchSize(tileList.length));

    return await db.writeTxn(() async {
      int res = await db.regionModels.put(region);
      await Future.wait(List.generate(part.length, (index) => db.tileModels.putAll(part.elementAt(index))));
      await region.tiles.save();
      return res;
    });
  }

  Future<bool> deleteRegion(String regionId) async {
    var res = await db.regionModels.get(regionId.toIsarHash());

    List<int> deleteList = List.empty(growable: true);
    List<TileModel> pushList = List.empty(growable: true);
    if (res == null) return false;
    for (final tile in res.tiles) {
      if (tile.links > 1) {
        pushList.add(TileModel.internal(tile.url, tile.bytes, tile.links - 1));
      } else {
        deleteList.add(tile.id);
      }
    }
    var deletePart = partition(deleteList, _computeBatchSize(deleteList.length));
    var insertPart = partition(pushList, _computeBatchSize(pushList.length));
    return await db.writeTxn(() async {
      await Future.wait(List.generate(insertPart.length, (index) => db.tileModels.putAll(insertPart.elementAt(index))));
      await Future.wait(List.generate(deletePart.length, (index) => db.tileModels.deleteAll(deletePart.elementAt(index))));
      return await db.regionModels.delete(regionId.toIsarHash());
    });
  }

  Future<void> cleanTx() {
    _isolates.clear();
    return tempDb.writeTxn(() => tempDb.clear());
  }

  Future<void> batchWriteTx(List<TileModel> tileModels) async {
    Future<void> isolatedTx() async {
      var tiles = await _generateTiles(tileModels);
      await tempDb.writeTxn(() async => tempDb.tileModels.putAll(tiles));
    }

    _isolates.add(isolatedTx());
  }

  Future<bool> commitRegionTx(String regionId) async {
    await Future.wait(_isolates);
    _isolates.clear();
    var tiles = await tempDb.tileModels.where().findAll();
    if (await writeRegion(regionId, tiles) != null) {
      tempDb.writeTxn(() => tempDb.clear());
      return true;
    }
    return false;
  }

  Future<List<TileModel>> getRegionTiles(String regionId) async {
    List<TileModel> list = List.empty(growable: true);

    var res = await db.regionModels.get(regionId.toIsarHash());
    if (res == null) {
      return list;
    }
    list.addAll(res.tiles);
    return list;
  }

  Future<Iterable<TileModel?>> getTilesByUrl(Iterable<String> urls) => db.tileModels.getAll(urls.map((e) => e.toIsarHash()).toList());

  Future<TileModel?> getSingleTileByUrl(String url) => db.tileModels.get(url.toIsarHash());

  Future<Iterable<RegionModel>> getAllRegions() => db.regionModels.where().findAll();

  Future<bool> hasRegion(String regionId) async {
    var res = await db.regionModels.get(regionId.toIsarHash());
    if (res == null) return false;
    return true;
  }

  Future<bool> hasTiles(String url) async {
    var res = await db.tileModels.get(url.toIsarHash());
    if (res == null) return false;
    return true;
  }

  Future<DepotStats> getStats() async {
    var res = await Future.wait([
      db.getSize(),
      db.tileModels.getSize(),
      db.regionModels.getSize(),
      db.tileModels.count(),
      db.regionModels.count(),
    ]);

    return DepotStats(
      byteSize: res[0],
      tilesBytesSize: res[1],
      regionsBytesSize: res[2],
      tilesCount: res[3],
      regionCount: res[4],
    );
  }

  int _computeBatchSize(int tiles) => max([
        4,
        tiles ~/ min([(tiles ~/ 50) + 1, 32])!
      ])!;

  Future<List<TileModel>> _generateTiles(List<TileModel> tileModels) async {
    List<TileModel> list = List.empty(growable: true);
    var res = await db.tileModels.getAll(tileModels.map((e) => e.id).toList());
    for (int i = 0; i < tileModels.length; i++) {
      var model = tileModels[i];
      list.add(TileModel.internal(model.url, model.bytes, res[i] != null ? res[i]!.links + 1 : 1));
    }
    return list;
  }
}

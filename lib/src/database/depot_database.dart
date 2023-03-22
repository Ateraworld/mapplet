import "package:isar/isar.dart";
import "package:mapplet/src/common/extensions.dart";
import "package:mapplet/src/database/depot_stats.dart";
import "package:mapplet/src/database/models/region_model.dart";
import "package:mapplet/src/database/models/tile_model.dart";
import "package:mapplet/src/depot/depot_config.dart";
import "package:quiver/iterables.dart";

/// The depot database of **Mapplet**.
///
/// Create an **Isar** istance with [DepotConfiguration.id] as name and [DepotConfiguration.maxSizeMib] as max size.
///
/// Create also a temp instances for the batch writing.
class DepotDatabase {
  DepotDatabase._(this.config);

  late Isar db;
  late Isar tempDb;
  final DepotConfiguration config;

  final List<Future<void>> _isolates = List.empty(growable: true);

  /// Initialize **Isar**'s instance and temp instance with the given [DepotConfiguration]
  ///
  /// Returns the instance of the created class
  static Future<DepotDatabase> open(DepotConfiguration config) async {
    var data = DepotDatabase._(config);

    data.db = await Isar.open(
      [TileModelSchema, RegionModelSchema],
      name: config.id,
      inspector: config.debugIsarConsole,
      maxSizeMiB: config.maxSizeMiB,
    );

    data.tempDb = await Isar.open(
      [TileModelSchema],
      name: "${config.id}_temp",
      inspector: config.debugIsarConsole,
      maxSizeMiB: config.maxSizeMiB,
    );

    await data.tempDb.writeTxn(() => data.tempDb.clear());
    return data;
  }

  /// Close **Isar**'s instances
  ///
  /// If [deleteFromDisk] is `true`, delete all data
  Future<bool> close({bool deleteFromDisk = false}) async {
    return await db.close(deleteFromDisk: deleteFromDisk) || await tempDb.close(deleteFromDisk: deleteFromDisk);
  }

  /// Add a single tile to the database
  ///
  /// Does not link any region to the current tile, but allows future fetch operations to detect that the tile is already present
  Future<void> writeSingleTile(TileModel tile) => db.writeTxn(
        () => db.tileModels
            .put(TileModel(url: tile.url, bytes: tile.bytes, links: 0, timestamp: DateTime.now().toUtc().millisecondsSinceEpoch)),
      );

  /// Write the given [regionId] and [tileModels] to the db
  ///
  /// Returns the `id` of the written region or `null`
  ///
  /// If a region already exist, this function increment the [links] of the tile
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

  /// Delete the given [regionId] from the db
  ///
  /// Returns `true` if the region has been deleted, `false` otherwise
  ///
  /// Linked tiles will be deleted only if they have one [links], otherwise the link count will be decremented
  Future<bool> deleteRegion(String regionId) async {
    var res = await db.regionModels.get(regionId.toIsarHash());

    List<int> deleteList = List.empty(growable: true);
    List<TileModel> pushList = List.empty(growable: true);
    if (res == null) return false;
    for (final tile in res.tiles) {
      if (tile.links > 1) {
        pushList.add(
          TileModel(url: tile.url, bytes: tile.bytes, links: tile.links - 1, timestamp: DateTime.now().toUtc().millisecondsSinceEpoch),
        );
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

  /// Clean the temp db to reset the transaction
  Future<void> cleanTx() {
    _isolates.clear();
    return tempDb.writeTxn(() => tempDb.clear());
  }

  /// Runs a [Future] function to write a batch of the transaction
  Future<void> batchWriteTx(List<TileModel> tileModels) async {
    Future<void> isolatedTx() async {
      var tiles = await _generateTiles(tileModels);
      await tempDb.writeTxn(() async => tempDb.tileModels.putAll(tiles));
    }

    _isolates.add(isolatedTx());
  }

  /// Commit all data in the db to complete the transaction
  ///
  /// First wait for all [batchWriteTx] to be completed
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

  /// Returns `Iterable<TileModel>` linked with the given [regionId] contained in the db
  Future<Iterable<TileModel>> getRegionTiles(String regionId) async {
    List<TileModel> list = List.empty(growable: true);

    var res = await db.regionModels.get(regionId.toIsarHash());
    if (res == null) {
      return list;
    }
    list.addAll(res.tiles);
    return list;
  }

  /// Returns the `Iterable<TileModel>` contained in the db, that match the given [urls]
  ///
  /// Returns the `TileModel` if it is present, or `null` otherwise
  Future<Iterable<TileModel?>> getTilesByUrl(Iterable<String> urls) => db.tileModels.getAll(urls.map((e) => e.toIsarHash()).toList());

  /// Returns the `Iterable<TileModel>` contained in the db, that match the given [url]
  ///
  /// Returns the `TileModel` if it is present, or `null` otherwise
  Future<TileModel?> getSingleTileByUrl(String url) => db.tileModels.get(url.toIsarHash());

  /// Returns all the [RegionModel] contained in the db
  Future<Iterable<RegionModel>> getAllRegions() => db.regionModels.where().findAll();

  /// Returns `true` if the given [regionId] region is present in the db
  Future<bool> hasRegion(String regionId) async {
    var res = await db.regionModels.get(regionId.toIsarHash());
    if (res == null) return false;
    return true;
  }

  /// Returns `true` if the given [url] tile is present in the db
  Future<bool> hasTiles(String url) async {
    var res = await db.tileModels.get(url.toIsarHash());
    if (res == null) return false;
    return true;
  }

  /// Returns the [DepotStats] of the db
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

  /// Generate the list of [TileModel] with the current [links] number
  Future<List<TileModel>> _generateTiles(List<TileModel> tileModels) async {
    List<TileModel> list = List.empty(growable: true);
    var res = await db.tileModels.getAll(tileModels.map((e) => e.id).toList());
    for (int i = 0; i < tileModels.length; i++) {
      var model = tileModels[i];
      list.add(
        TileModel(
          url: model.url,
          bytes: model.bytes,
          links: res[i] != null ? res[i]!.links + 1 : 1,
          timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );
    }
    return list;
  }
}

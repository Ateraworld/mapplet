import "package:flutter/foundation.dart";
import "package:isar/isar.dart";
import "package:mapplet/src/common/extensions.dart";
import "package:mapplet/src/database/depot_stats.dart";
import "package:mapplet/src/database/models/region_model.dart";
import "package:mapplet/src/database/models/tile_model.dart";
import "package:mapplet/src/depot/depot_config.dart";
import "package:meta/meta.dart";
import "package:queue/queue.dart";

/// The depot database of **Mapplet**.
///
/// Create an **Isar** istance with [DepotConfiguration.id] as name and [DepotConfiguration.maxSizeMib] as max size.
///
/// Create also a temp instances for the batch writing.
@internal
class DepotDatabase {
  DepotDatabase._(this.config);

  late Isar db;
  final DepotConfiguration config;

  final List<Future<void>> _batchWriters = List.empty(growable: true);
  late final Queue _writeQueue = Queue(parallel: config.parallelBatchWriters);
  final List<int> _batchesIds = List<int>.empty(growable: true);

  static Future<bool> _commitRegionIsolate(List<Object> args) async {
    var config = args[0] as DepotConfiguration;
    var regionId = args[1] as String;
    var ids = args[2] as List<int>;

    var db = Isar.openSync(
      [TileModelSchema, RegionModelSchema],
      directory: config.directory,
      name: config.id,
      inspector: false,
      maxSizeMiB: config.maxSizeMiB,
    );

    List<TileModel> tileList = List.empty(growable: true);
    var storedRegion = db.regionModels.getSync(regionId.toIsarHash());
    if (storedRegion != null) return true;

    var res = db.tileModels.getAllSync(ids);
    for (int i = 0; i < res.length; i++) {
      var model = res[i];
      if (model == null) continue;
      tileList.add(
        TileModel(
          url: model.url,
          bytes: model.bytes,
          links: model.links + 1,
        ),
      );
    }
    var region = RegionModel(regionId: regionId)..tiles.addAll(tileList);
    db.writeTxnSync(() {
      db.tileModels.putAllSync(tileList);
      db.regionModels.putSync(region);
    });
    await db.writeTxn(() async => await region.tiles.save());

    return true;
  }

  static Future<bool> _deleteRegionIsolate(List<Object> args) async {
    var config = args[0] as DepotConfiguration;
    var regionId = args[1] as String;

    var db = Isar.openSync(
      [TileModelSchema, RegionModelSchema],
      directory: config.directory,
      name: config.id,
      inspector: false,
      maxSizeMiB: config.maxSizeMiB,
    );
    var res = db.regionModels.getSync(regionId.toIsarHash());

    List<int> deleteList = List.empty(growable: true);
    List<TileModel> pushList = List.empty(growable: true);
    if (res == null) return false;
    for (final tile in res.tiles) {
      if (tile.links > 1) {
        pushList.add(
          TileModel(
            url: tile.url,
            bytes: tile.bytes,
            links: tile.links - 1,
          ),
        );
      } else {
        deleteList.add(tile.id);
      }
    }
    return db.writeTxnSync(() {
      db.tileModels.deleteAllSync(deleteList);
      db.tileModels.putAllSync(pushList);
      return db.regionModels.deleteSync(regionId.toIsarHash());
    });
  }

  /// Initialize **Isar**'s instance and temp instance with the given [DepotConfiguration]
  ///
  /// Returns the instance of the created class
  static Future<DepotDatabase> open(DepotConfiguration config) async {
    var data = DepotDatabase._(config);
    data.db = await Isar.open(
      [TileModelSchema, RegionModelSchema],
      name: config.id,
      directory: config.directory,
      inspector: config.debugIsarConsole,
      maxSizeMiB: config.maxSizeMiB,
    );

    Future<void> cleanupUnlinked() async {
      var unlinked = await data.db.tileModels.where().filter().linksEqualTo(0).findAll();
      await data.db.writeTxn(
        () async => await data.db.tileModels.deleteAll(unlinked.map((e) => e.id).toList()),
      );
    }

    if (config.cleanUnlinkedTilesOnInit) {
      var cleanup = cleanupUnlinked();
      if (config.awaitUnlinkedTileClenOnInit) {
        await cleanup;
      }
    }
    return data;
  }

  /// Close **Isar**'s instances
  ///
  /// If [deleteFromDisk] is `true`, delete all data
  Future<bool> close({bool deleteFromDisk = false}) => db.close(deleteFromDisk: deleteFromDisk);

  /// Add a single tile to the database
  ///
  /// Does not link any region to the current tile if it is new, but allows future fetch operations to detect that the tile is already present
  Future<void> writeSingleTile(TileModel tile) async {
    var stored = await db.tileModels.get(tile.id);
    await db.writeTxn(
      () => db.tileModels.put(
        TileModel(
          url: tile.url,
          bytes: tile.bytes,
          links: stored != null ? stored.links : 0,
        ),
      ),
    );
  }

  /// Delete the given [regionId] from the db
  ///
  /// Returns `true` if the region has been deleted, `false` otherwise
  ///
  /// Linked tiles will be deleted only if they have one [links], otherwise the link count is decremented
  Future<bool> deleteRegion(String regionId) => compute(_deleteRegionIsolate, [config, regionId]);

  /// Clean the temporary internal files generated by call of [enqueueBatchWriteTx], preparing for future transactions
  Future<void> cleanTemp({bool purgeUnlinkedTiles = true}) async {
    _batchWriters.clear();
    _batchesIds.clear();
    if (purgeUnlinkedTiles) {
      var unlinked = await db.tileModels.where().filter().linksEqualTo(0).findAll();
      await db.writeTxn(
        () async => await db.tileModels.deleteAll(unlinked.map((e) => e.id).toList()),
      );
    }
  }

  /// Runs a [Future] function to write a batch of the transaction
  Future<void> enqueueBatchWriteTx(List<TileModel> tileModels) async {
    Future<void> batchWriteTx(List<TileModel> tileModels) async {
      List<TileModel> list = List.empty(growable: true);
      var res = await db.tileModels.getAll(tileModels.map((e) => e.id).toList());
      for (int i = 0; i < tileModels.length; i++) {
        var model = tileModels[i];
        list.add(
          TileModel(
            url: model.url,
            bytes: model.bytes,
            links: res[i] != null ? res[i]!.links : 0,
          ),
        );
        _batchesIds.add(model.id);
      }
      await db.writeTxn(() async => db.tileModels.putAll(list));
    }

    return _writeQueue.add(() => batchWriteTx(tileModels));
  }

  /// Commit all data passed with subsequent calls to [enqueueBatchWriteTx] in the db and attempt to complete the transaction
  ///
  /// First wait for all [enqueueBatchWriteTx] to be completed, then executes the commit transaction on a separate `Isolate`
  Future<bool> commitRegionTx(String regionId) async {
    await _writeQueue.onComplete;
    //await Future.wait(_batchWriters);
    _batchWriters.clear();
    return await compute(_commitRegionIsolate, [config, regionId, _batchesIds]);
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
}

import "dart:async";

import "package:flutter_map/flutter_map.dart";
import "package:mapplet/src/common/extensions.dart";
import "package:mapplet/src/database/depot_database.dart";
import "package:mapplet/src/database/depot_stats.dart";
import "package:mapplet/src/database/models/region_model.dart";
import "package:mapplet/src/database/models/tile_model.dart";
import "package:mapplet/src/depot/depot_config.dart";
import "package:mapplet/src/depot/fetch_operation.dart";
import "package:mapplet/src/providers/map_tile_provider.dart";
import "package:meta/meta.dart";

class Depot {
  Depot._(this.config);

  final DepotConfiguration config;
  late final DepotDatabase _db;

  @internal
  static Future<Depot> open(DepotConfiguration config) async {
    var db = Depot._(config);
    db._db = await DepotDatabase.open(config);
    return db;
  }

  Future<void> close({bool deleteFromDisk = false}) => _db.close(deleteFromDisk: deleteFromDisk);

  Future<TileModel?> getTile(String url) => _db.getSingleTileByUrl(url);

  Future<bool> hasRegion(String regionId) => _db.hasRegion(regionId);

  Future<DepotStats> getStats() => _db.getStats();

  Future<Iterable<RegionModel>> getRegions() => _db.getAllRegions();

  Future<FetchOperation?> depotRegion(String regionId, LatLngBounds bounds) async {
    var layer = TileLayer(
      urlTemplate: config.urlTemplate,
      minZoom: config.minZoom,
      maxZoom: config.maxZoom,
    );
    var provider = getTileProvider();
    return FetchOperation(
      regionId: regionId,
      urls: bounds.coords(config.minZoom.round(), config.maxZoom.round()).map((e) => provider.getTileUrl(e, layer)),
      config: config,
      db: _db,
    );
  }

  MappletTileProvider getTileProvider() => MappletTileProvider(this);

  Future<bool> dropRegion(String regionId) => _db.deleteRegion(regionId);
}

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

/// Provides the interface to perform operations to manipulate offline map sections called regions
class Depot {
  Depot._(this.config);

  /// The configuration of the [Depot]
  final DepotConfiguration config;
  late final DepotDatabase _db;

  /// Open a [Depot] instance and the relative database
  @internal
  static Future<Depot> open(DepotConfiguration config) async {
    var db = Depot._(config);
    db._db = await DepotDatabase.open(config);
    return db;
  }

  /// Do not access the database directly outside **Mapplet**!
  @internal
  DepotDatabase get db => _db;

  /// Close the instance and the database
  ///
  /// Delete also the database from disk with [deleteFromDisk]
  Future<void> close({bool deleteFromDisk = false}) =>
      _db.close(deleteFromDisk: deleteFromDisk);

  /// Get a tile by its url from the current [Depot], `null` if not found
  Future<TileModel?> getTile(String url) => _db.getSingleTileByUrl(url);

  /// Whether a certain region is stored
  Future<bool> hasRegion(String regionId) => _db.hasRegion(regionId);

  /// Get the [DepotStats] of this instance
  Future<DepotStats> getStats() => _db.getStats();

  /// Get all the regions stored in this instance
  Future<Iterable<RegionModel>> getRegions() => _db.getAllRegions();

  /// Store a map
  ///
  /// The [regionId] identifies the id with which it will be possible to access the region.
  /// The [bounds] define the area to store. The class [LatLngBoundsExtensions] has useful methods to handle the creation of this boundaries
  FetchOperation depositRegion(String regionId, LatLngBounds bounds) {
    var layer = TileLayer(
      urlTemplate: config.urlTemplate,
      minZoom: config.minZoom,
      maxZoom: config.maxZoom,
    );
    var provider = getTileProvider();
    return FetchOperation(
      regionId: regionId,
      urls: bounds
          .coords(config.minZoom.round(), config.maxZoom.round())
          .map((e) => provider.getTileUrl(e, layer)),
      config: config,
      db: _db,
    );
  }

  /// Gets the [MappletTileProvider] to use in the **flutter_map** plugin
  MappletTileProvider getTileProvider() => MappletTileProvider(this);

  /// Delete the region identified by its id from the database
  Future<bool> dropRegion(String regionId) => _db.deleteRegion(regionId);
}

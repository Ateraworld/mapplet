class DepotConfiguration {
  DepotConfiguration({
    required this.id,
    required this.urlTemplate,
    required this.minZoom,
    required this.maxZoom,
    required this.directory,
    this.parallelBatchWriters = 8,
    this.fetchTileAttempts = 4,
    this.fetchMaxHeapSizeMiB = 256,
    this.fetchMaxWorkers = 24,
    this.maxSizeMiB = 2048,
    this.cleanUnlinkedTilesOnInit = true,
    this.awaitUnlinkedTileClenOnInit = true,
    this.debugIsarConsole = false,
    this.tilesStoreEvictPeriod,
    this.fetchTileTimeout,
  });

  /// Base directory for the depot
  ///
  /// It is recommended to use the package `path_provider` to request a standard directory available in all platforms:
  ///
  /// ```dart
  /// var dir = await getApplicationDocumentsDirectory();
  /// var path = dir.path;
  /// ```
  final String directory;

  /// Maximum number of concurrent writers on the database during the fetch operation
  ///
  /// Writers write the fetched batches on the db while [fetchMaxWorkers] fetch the tiles form the web
  final int parallelBatchWriters;

  /// After the following period has passed, update the tiles while fetching the tiles
  final Duration? tilesStoreEvictPeriod;

  /// Maximum zoom to use when storing offline maps
  ///
  /// The greater the gap between [maxZoom] and [minZoom], the heavier the offline map will be
  final double maxZoom;

  /// Minimum zoom to use when storing offline maps
  ///
  /// The greater the gap between [maxZoom] and [minZoom], the heavier the offline map will be
  final double minZoom;

  /// Identifies the [Depot] that is associated with this configuration
  final String id;

  /// Template of the map endpoint
  final String urlTemplate;

  /// If `true`, run **Isar** in debug mode with the possibility to access its webapp on the browser
  ///
  /// This defaults to `false` when building in [kReleaseMode]
  final bool debugIsarConsole;

  /// Maximum size in MiB of the [Depot]
  final int maxSizeMiB;

  /// Clean all tiles not linked to any region on [Mapplet.initialize]
  final bool cleanUnlinkedTilesOnInit;

  /// If [cleanUnlinkedTilesOnInit] is true and this is`true`, [Mapplet.initialize] awaits the cleanup of unlinked tiles on startup, otherwise it is run in the background
  final bool awaitUnlinkedTileClenOnInit;

  /// Timeout duration for the fetch operation from the web for each single tile
  ///
  /// Defaults to 5 seconds
  final Duration? fetchTileTimeout;

  /// Maximum number of attempts when trying to fetch a tile from the web
  final int fetchTileAttempts;

  /// Maximum number of parallel workers to use when fetching a region
  ///
  /// Workers are dedicated to fetching the tiles from the web, while [parallelBatchWriters] write the fetched batches on the db
  final int fetchMaxWorkers;

  /// Maximum size specified in MiB to occupy in the heap during the fetch operation
  ///
  /// Decreasing this will allow to target older devices and emulators with a smaller heap size at the cost of performing more batched writes on the database more frequently with consequent slower fetching operations
  final int fetchMaxHeapSizeMiB;
}

class DepotConfiguration {
  DepotConfiguration({
    required this.id,
    required this.urlTemplate,
    required this.minZoom,
    required this.maxZoom,
    this.ignoredQueryParams,
    this.fetchTileAttempts = 4,
    this.fetchMaxHeapSizeMiB = 256,
    this.fetchMaxWorkers = 24,
    this.maxSizeMiB = 2048,
    this.maxTempSizeMiB = 128,
    this.debugIsarConsole = false,
    this.tilesStoreEvictPeriod,
    this.fetchTileTimeout,
  });

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

  /// Specifies a group of regular expressions that defines what query parameters in the [urlTemplate] must not be ignored
  ///
  /// Since **Mapplet** uses the url to identify tiles, having same url with different query parameters will result in multiple tiles being stored indipendently
  Iterable<RegExp>? ignoredQueryParams;

  /// Template of the map endpoint
  final String urlTemplate;

  /// If `true`, run **Isar** in debug mode with the possibility to access its webapp on the browser
  ///
  /// This defaults to `false` when building in [kReleaseMode]
  final bool debugIsarConsole;

  /// Maximum size in MiB of the [Depot]
  final int maxSizeMiB;

  /// Maximum size in MiB of the *temp_database* associated with the [Depot]
  ///
  /// The *temp_database* is used internally by **Mapplet** to allow batched writes into the database when fetching a region. The *temp_database* is used to ensure clear abort operations and prevent involontary corrupted data.
  ///
  /// Intuitively set this parameters to the __size in MiB of the largest region map that you plan on fetching__
  ///
  /// _Adjusting this parameters may result in errors and exceptions if the region that is being fetched is greater than the specified size_
  final int maxTempSizeMiB;

  /// Timeout duration for the fetch operation from the web for each single tile
  ///
  /// Defaults to 5 seconds
  final Duration? fetchTileTimeout;

  /// Maximum number of attempts when trying to fetch a tile from the web
  final int fetchTileAttempts;

  /// Maximum number of parallel workers to use when fetching a region
  final int fetchMaxWorkers;

  /// Maximum size specified in MiB to occupy in the heap during the fetch operation
  ///
  /// Decreasing this will allow to target older devices and emulators with a smaller heap size at the cost of performing more batched writes on the database more frequently with consequent slower fetching operations
  final int fetchMaxHeapSizeMiB;
}

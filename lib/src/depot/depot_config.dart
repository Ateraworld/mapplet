class DepotConfiguration {
  DepotConfiguration({
    required this.id,
    required this.urlTemplate,
    required this.minZoom,
    required this.maxZoom,
    this.ignoredQueryParams,
    this.fetchTileAttempts = 4,
    this.fetchMaxHeapSizeMib = 128,
    this.fetchMaxWorkers = 32,
    this.maxSizeMib = 2048,
    this.maxTempSizeMib = 128,
    this.debugIsarConsole = false,
    Duration? fetchTileTimeout,
  }) : fetchTileTimeout = fetchTileTimeout ??= const Duration(seconds: 5);
  final double maxZoom;

  final double minZoom;
  final String id;

  Iterable<RegExp>? ignoredQueryParams;
  final String urlTemplate;
  final bool debugIsarConsole;
  final int maxSizeMib;
  final int maxTempSizeMib;

  final Duration fetchTileTimeout;
  final int fetchTileAttempts;
  final int fetchMaxWorkers;
  final int fetchMaxHeapSizeMib;
}

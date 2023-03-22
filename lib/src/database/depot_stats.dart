/// Statistics for the [Depot]
class DepotStats {
  DepotStats({
    this.byteSize = 0,
    this.tilesBytesSize = 0,
    this.regionsBytesSize = 0,
    this.tilesCount = 0,
    this.regionCount = 0,
  });

  /// Size of the depot in bytes
  final int byteSize;

  /// Size of all the tiles in bytes
  final int tilesBytesSize;

  /// The number of stored tiles
  final int tilesCount;

  /// Size of the all the regions in bytes
  final int regionsBytesSize;

  /// The number of stored regions
  final int regionCount;
}

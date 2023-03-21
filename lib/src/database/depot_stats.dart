class DepotStats {
  DepotStats({
    this.byteSize = 0,
    this.tilesBytesSize = 0,
    this.regionsBytesSize = 0,
    this.tilesCount = 0,
    this.regionCount = 0,
  });
  final int byteSize;
  final int tilesBytesSize;
  final int tilesCount;
  final int regionsBytesSize;
  final int regionCount;
}

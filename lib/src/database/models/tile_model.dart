import "package:isar/isar.dart";
import "package:mapplet/src/common/extensions.dart";
import "package:meta/meta.dart";

part "tile_model.g.dart";

@collection
class TileModel {
  TileModel({
    required this.url,
    required this.bytes,
    this.links = 1,
  });

  factory TileModel.factory(String url, List<byte> bytes) {
    return TileModel(url: url, bytes: bytes);
  }
  @internal
  factory TileModel.internal(String url, List<byte> bytes, int links) {
    return TileModel(url: url, bytes: bytes, links: links);
  }

  Id get id => url.toIsarHash();

  final String url;

  final int links;
  final List<byte> bytes;
}

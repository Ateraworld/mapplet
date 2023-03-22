import "package:isar/isar.dart";
import "package:mapplet/src/common/extensions.dart";
import "package:meta/meta.dart";

part "tile_model.g.dart";

@collection
class TileModel {
  /// Use [TileModel.factory] to create new tiles
  @internal
  TileModel({
    required this.url,
    required this.bytes,
    this.links = 1,
  }) : timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;

  factory TileModel.factory(String url, List<byte> bytes) {
    return TileModel(
      url: url,
      bytes: bytes,
    );
  }

  Id get id => url.toIsarHash();

  final String url;
  final int timestamp;
  final int links;
  final List<byte> bytes;
}

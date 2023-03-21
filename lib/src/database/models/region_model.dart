import "package:isar/isar.dart";
import "package:mapplet/src/common/extensions.dart";
import "package:mapplet/src/database/models/tile_model.dart";

part "region_model.g.dart";

@collection
class RegionModel {
  RegionModel({
    required this.regionId,
  });

  Id get id => regionId.toIsarHash();

  final String regionId;

  final tiles = IsarLinks<TileModel>();
}

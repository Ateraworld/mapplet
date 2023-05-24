import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:mapplet/src/depot/depot.dart";
import "package:mapplet/src/providers/tile_image_provider.dart";
import "package:meta/meta.dart";

/// Tile provider for **Mapplet**
///
/// Uses the [MappletTileImageProvider] to fetch the tile
class MappletTileProvider extends TileProvider {
  @internal
  MappletTileProvider(this.depot);
  final Depot depot;

  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) =>
      MappletTileImageProvider(depot: depot, options: options, coords: coordinates);
}

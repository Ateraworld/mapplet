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

  String _ignoreQueryParams(String url) {
    if (!url.contains("?") || depot.config.ignoredQueryParams == null || depot.config.ignoredQueryParams!.isEmpty) return url;

    var splits = url.split("?");
    String query = splits[1];
    for (final r in depot.config.ignoredQueryParams!) {
      query = query.replaceAll(r, "");
    }
    return "${splits[0]}?$query";
  }

  @override
  String getTileUrl(Coords<num> coords, TileLayer options) => _ignoreQueryParams(super.getTileUrl(coords, options));

  @override
  ImageProvider<Object> getImage(Coords<num> coords, TileLayer options) =>
      MappletTileImageProvider(depot: depot, options: options, coords: coords);
}

import "dart:math";

import "package:flutter_map/flutter_map.dart";
import "package:geolocator/geolocator.dart";
import "package:latlong2/latlong.dart";
import "package:meta/meta.dart";

extension DbHashExtensions on String {
  @internal
  int toIsarHash() {
    var hash = 0xcbf29ce484222325;

    var i = 0;
    while (i < length) {
      final codeUnit = codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }
}

extension LatLngBoundsExtensions on LatLngBounds {
  /// Get the coordinates for the current [LatLngBounds] at the provided zoom levels
  List<TileCoordinates> coords(
    int minZoom,
    int maxZoom, {
    num tileSize = 256,
    Crs? crs,
  }) {
    crs ??= const Epsg3857();
    CustomPoint<double> tileSizePoint = CustomPoint(tileSize.toDouble(), tileSize.toDouble());

    int size = 0;
    for (int zoom = 0; zoom < (maxZoom - (minZoom - 1)); zoom++) {
      final zoomLevel = minZoom + zoom;
      final nwPoint = crs.latLngToPoint(northWest, zoomLevel.toDouble()).unscaleBy(tileSizePoint).floor();
      final sePoint = crs.latLngToPoint(southEast, zoomLevel.toDouble()).unscaleBy(tileSizePoint).ceil() - const CustomPoint(1, 1);
      size += (sePoint.x - (nwPoint.x - 1)) * (sePoint.y - (nwPoint.y - 1));
    }

    List<TileCoordinates> coordinates = List.generate(size, (index) => const TileCoordinates(0, 0, 0), growable: false);

    int index = 0;
    for (int zoom = 0; zoom < (maxZoom - (minZoom - 1)); zoom++) {
      final zoomLevel = minZoom + zoom;
      final nwPoint = crs.latLngToPoint(northWest, zoomLevel.toDouble()).unscaleBy(tileSizePoint).floor();
      final sePoint = crs.latLngToPoint(southEast, zoomLevel.toDouble()).unscaleBy(tileSizePoint).ceil() - const CustomPoint(1, 1);
      final xSize = sePoint.x - (nwPoint.x - 1);
      final ySize = sePoint.y - (nwPoint.y - 1);
      for (int x = 0; x < xSize; x++) {
        for (int y = 0; y < ySize; y++) {
          coordinates[index++] = TileCoordinates(nwPoint.x + x, nwPoint.y + y, zoomLevel);
        }
      }
    }
    return coordinates;
  }

  /// Create a [LatLngBounds] specifying its center and the distance from center
  ///
  /// The result is a square region with half size equal to [deltaKm]
  static LatLngBounds fromDelta(LatLng center, double deltaKm) {
    var nw = _getPointFromDelta(center, -deltaKm, deltaKm);
    var ne = _getPointFromDelta(center, deltaKm, deltaKm);
    var sw = _getPointFromDelta(center, -deltaKm, -deltaKm);
    var se = _getPointFromDelta(center, deltaKm, -deltaKm);
    return LatLngBounds.fromPoints([nw, ne, sw, se]);
  }

  static LatLng _getPointFromDelta(LatLng point, double dx, double dy) {
    const earthRadiusKm = 6378.137;
    const toRad = 180 / pi;
    var newX = point.latitude + ((dx / earthRadiusKm) * toRad);
    var newY = point.longitude + (((dy / earthRadiusKm) * toRad) / cos(point.latitude * (1 / toRad)));
    return LatLng(newX, newY);
  }
}

extension PositionExtensions on Position {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension IntExtensions on int {
  double byteToMib() => this / 1048576;
  int mibToByte() => this * 1048576;
}

extension LatLngExtensions on LatLng {
  /// Returns the distance in meters
  double metersFrom(LatLng other) {
    const earthRadius = 6378137.0;
    var toRad = pi / 180;
    var dLat = (latitude - other.latitude) * toRad;
    var dLon = (longitude - other.longitude) * toRad;
    var sLat = sin(dLat / 2);
    var sLon = sin(dLon / 2);
    var a = sLat * sLat + sLon * sLon * cos(other.latitude * toRad) * cos(latitude * toRad);
    var c = 2 * asin(sqrt(a));
    return c * earthRadius;
  }
}

extension ListLatLngExtensions on List<LatLng> {
  /// Returns the center of mass of the list of points
  LatLng center() {
    double lat = 0;
    double lng = 0;
    for (final point in this) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / length, lng / length);
  }

  /// Returns the maximum distance in kilometers between any two points
  double maxDistanceKm() {
    double dist = 0;
    for (final first in this) {
      for (final second in this) {
        var current = first.metersFrom(second) / 1000;
        if (current > dist) {
          dist = current;
        }
      }
    }
    return dist;
  }
}

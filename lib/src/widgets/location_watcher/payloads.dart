import "package:latlong2/latlong.dart";

class PositionPayload {
  PositionPayload({required this.position, required this.accuracy});
  final LatLng position;
  final double accuracy;
}

class DirectionPayload {
  DirectionPayload({required this.direction, required this.accuracy});
  final double direction;
  final double accuracy;
}

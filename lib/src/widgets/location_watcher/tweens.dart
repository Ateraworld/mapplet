import "package:flutter/material.dart";
import "package:latlong2/latlong.dart";
import "package:mapplet/src/widgets/location_watcher/payloads.dart";

class PositionPayloadTween extends Tween<PositionPayload> {
  PositionPayloadTween({
    required super.begin,
    required super.end,
  });

  @override
  PositionPayload lerp(double t) {
    final begin = this.begin!;
    final end = this.end!;
    var latTween = Tween<double>(begin: begin.position.latitude, end: end.position.latitude);
    var longTween = Tween<double>(begin: begin.position.longitude, end: end.position.longitude);
    var accTween = Tween<double>(begin: begin.accuracy, end: end.accuracy);
    return PositionPayload(
      position: LatLng(latTween.transform(t), longTween.transform(t)),
      accuracy: accTween.transform(t),
    );
  }
}

double _lerp(double begin, double end, double t) => begin + (end - begin) * t;

double _invert(double value) => (value + 180) % 360;

double _circularLerpDegrees(double begin, double end, double t) {
  const circ = 360;
  begin = begin % circ;
  end = end % circ;
  final cmp = (end - begin).abs().compareTo(circ / 2);
  final hasCrossed = cmp == 1 || (cmp == 0 && begin != end && begin >= circ / 2);
  if (hasCrossed) {
    return _invert(_lerp(_invert(begin), _invert(end), t));
  } else {
    return _lerp(begin, end, t);
  }
}

class DirectionPayloadTween extends Tween<DirectionPayload> {
  DirectionPayloadTween({
    required super.begin,
    required super.end,
  });

  @override
  DirectionPayload lerp(double t) {
    final begin = this.begin!;
    final end = this.end!;
    final accTween = Tween(begin: begin.accuracy, end: end.accuracy);
    return DirectionPayload(
      direction: _circularLerpDegrees(begin.direction, end.direction, t),
      accuracy: accTween.transform(t),
    );
  }
}

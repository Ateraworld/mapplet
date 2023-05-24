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

class DirectionPayloadTween extends Tween<DirectionPayload> {
  DirectionPayloadTween({
    required super.begin,
    required super.end,
  });

  @override
  DirectionPayload lerp(double t) {
    final begin = this.begin!;
    final end = this.end!;
    var dirTween = Tween<double>(begin: begin.direction, end: end.direction);
    var accTween = Tween<double>(begin: begin.accuracy, end: end.accuracy);
    return DirectionPayload(
      direction: dirTween.transform(t),
      accuracy: accTween.transform(t),
    );
  }
}

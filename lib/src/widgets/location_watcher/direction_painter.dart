import "dart:math";
import "package:flutter/material.dart";

class DirectionPainter extends CustomPainter {
  DirectionPainter({
    required this.color,
    this.opacities,
    required this.direction,
    required this.angle,
  });
  final List<double>? opacities;
  final Color color;
  final double direction;
  final double angle;

  double radians(double angle) => 0.01745329252 * angle;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius);
    var opList = opacities ?? [1.0, 0.75, 0.5, 0.25, 0];
    canvas.drawArc(
      rect,
      pi * 3 / 2 + radians(direction) - radians(angle),
      radians(angle),
      true,
      Paint()
        ..shader = RadialGradient(colors: List.generate(opList.length, (index) => color.withOpacity(color.opacity * opList[index])))
            .createShader(rect),
    );
  }

  @override
  bool shouldRepaint(DirectionPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.direction != direction || oldDelegate.angle != angle;
}

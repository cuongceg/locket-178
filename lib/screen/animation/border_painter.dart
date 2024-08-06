import 'dart:math';
import 'package:flutter/material.dart';

class BorderPainter extends CustomPainter {
  final double currentState;

  BorderPainter({required this.currentState});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {

    double strokeWidth = 4;
    Rect rect = const Offset(0,0) & Size(size.width, size.height);

    var paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startAngle = pi / 2;
    double sweepAmount = currentState * pi;

    canvas.drawArc(rect, startAngle, sweepAmount, false, paint);
    canvas.drawArc(rect, startAngle, -sweepAmount, false, paint);
  }

}
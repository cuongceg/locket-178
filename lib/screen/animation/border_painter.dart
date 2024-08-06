import 'package:flutter/material.dart';

class BorderPainter extends CustomPainter {
  final double controller;

  BorderPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height; // For path shortage
    double sw = size.width;  // For path shortage
    double line = 30.0;  // Length of the animated line
    double c1 = controller * 2; // Controller value for top and left border.
    double c2 = controller >= 0.5 ? (controller - 0.5) * 2 : 0; // Controller value for bottom and right border.

    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path top = Path()
      ..moveTo(10, 0)
      ..lineTo(sw * c1 + line >= sw ? sw : sw * c1 + line, 0);

    Path left = Path()
      ..lineTo(0, sh * c1 + line >= sh ? sh : sh * c1 + line);

    Path right = Path()
      ..moveTo(sw,0)
      ..lineTo(
          sw,
          sh * c2 + line > sh
              ? sh
              : sw * c1 + line >= sw
              ? sw * c1 + line - sw
              : sh * c2);

    Path bottom =  Path()
      ..moveTo(0, sh)
      ..lineTo(
          sw * c2 + line > sw
              ? sw
              : sh * c1 + line >= sh
              ? sh * c1 + line - sh
              : sw * c2, sh);



    canvas.drawPath(top, paint);
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
    canvas.drawPath(bottom, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}
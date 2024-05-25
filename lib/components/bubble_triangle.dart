import 'package:flutter/material.dart';

class BubbleTriangle extends CustomPainter {
  BubbleTriangle({
    Key? key,
    required this.comparePathWidth,
  });

  final double comparePathWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    double triangleH = 20;
    double triangleW = 10.0;
    final double width = size.width;
    final double height = size.height;

    final Path trianglePath = Path()
      ..moveTo(width / comparePathWidth - triangleW / 0.4, 7)
      ..lineTo(width / comparePathWidth, triangleH - 35)
      ..lineTo(width / comparePathWidth + triangleW / 0.4, 7)
      ..lineTo(width / comparePathWidth - triangleW / 2, 7);
    canvas.drawPath(trianglePath, paint);
    final BorderRadius borderRadius = BorderRadius.circular(15);
    final Rect rect = Rect.fromLTRB(0, 0, width, height);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

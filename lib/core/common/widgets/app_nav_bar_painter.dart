import 'package:flutter/material.dart';

class AppNavBarPainter extends CustomPainter {
  final int selectedIndex;

  AppNavBarPainter({required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double itemWidth = size.width / 4;
    double centerX = (selectedIndex * itemWidth) + (itemWidth / 2);

    double barHeight = 65;
    double barTop = 20;

    RRect outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(15, barTop, size.width - 30, barHeight),
      const Radius.circular(35),
    );

    Path barPath = Path()..addRRect(outerRRect);

    Path hole = Path();
    double holeWidth = 45;
    double holeDepth = 15;

    hole.moveTo(centerX - holeWidth - 10, barTop);
    hole.quadraticBezierTo(
        centerX - holeWidth, barTop,
        centerX - 25, barTop + holeDepth
    );
    hole.arcToPoint(
      Offset(centerX + 25, barTop + holeDepth),
      radius: const Radius.circular(30),
      clockwise: false,
    );
    hole.quadraticBezierTo(
        centerX + holeWidth, barTop,
        centerX + holeWidth + 10, barTop
    );
    hole.close();

    Path finalPath = Path.combine(PathOperation.difference, barPath, hole);

    canvas.drawShadow(finalPath, Colors.black.withValues(alpha: 0.15), 10, true);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant AppNavBarPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex;
}
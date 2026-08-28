
import 'package:flutter/material.dart';

class AppTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from bottom-left
    path.moveTo(0, size.height);

    // Line to top-left
    path.lineTo(0, 40); // where the curve starts

    // Draw the convex arc at the top
    path.quadraticBezierTo(
      size.width / 2,
      -10, // control point (pulls curve upward)
      size.width,
      40, // end point (top-right)
    );

    // Line to bottom-right
    path.lineTo(size.width, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

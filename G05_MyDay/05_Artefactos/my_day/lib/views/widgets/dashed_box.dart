import 'package:flutter/material.dart';

/// Caixa com contorno tracejado (ex.: "Adicionar mais fotografias").
/// O Flutter não tem contorno tracejado pronto, por isso desenhamo-lo
/// com um CustomPainter: percorremos o contorno e desenhamos traços.
class DashedBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;
  final Widget child;

  const DashedBox({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: radius, color: color),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;

  _DashedBorderPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final border = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));

    const double dash = 6;
    const double gap = 4;
    for (final metric in border.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

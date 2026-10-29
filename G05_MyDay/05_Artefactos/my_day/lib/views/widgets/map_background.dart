import 'package:flutter/material.dart';

/// Mapa desenhado à mão, a imitar o do Figma (ruas, parques e rio).
/// Não é um mapa real: sem bibliotecas externas não há mapas com GPS.
/// As coordenadas usam o ecrã de 390 de largura do Figma.
class MapBackground extends StatelessWidget {
  const MapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MapPainter(), size: Size.infinite);
  }
}

class _MapPainter extends CustomPainter {
  static const Color land = Color(0xFFECEEE6);
  static const Color park = Color(0xFFD5E6CC);
  static const Color water = Color(0xFFC9DCEB);
  static const Color road = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    // Ajusta o desenho à largura do ecrã (o Figma tem 390).
    final double scale = size.width / 390;
    canvas.scale(scale);
    final double height = size.height / scale;

    // Terra
    canvas.drawRect(Rect.fromLTWH(0, 0, 390, height), Paint()..color = land);

    // Parques
    final parkPaint = Paint()..color = park;
    canvas.drawOval(Rect.fromCenter(center: const Offset(295, 235), width: 140, height: 90), parkPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(70, 415), width: 100, height: 60), parkPaint);

    // Ruas principais (largas) e secundárias (estreitas)
    final mainRoad = Paint()
      ..color = road
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final smallRoad = Paint()
      ..color = road
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(118, -10), const Offset(185, 610), mainRoad);
    canvas.drawLine(const Offset(-10, 178), const Offset(400, 262), mainRoad);

    canvas.drawLine(const Offset(48, -10), const Offset(52, 610), smallRoad);
    canvas.drawLine(const Offset(212, 100), const Offset(214, 610), smallRoad);
    canvas.drawLine(const Offset(-10, 320), const Offset(400, 316), smallRoad);
    canvas.drawLine(const Offset(-10, 470), const Offset(400, 384), smallRoad);
    canvas.drawLine(const Offset(262, -10), const Offset(355, 610), smallRoad);

    // Rio em baixo, com a margem ondulada (desenhado por cima das ruas)
    final river = Path()
      ..moveTo(0, 612)
      ..quadraticBezierTo(100, 596, 200, 606)
      ..quadraticBezierTo(300, 616, 390, 600)
      ..lineTo(390, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(river, Paint()..color = water);
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}

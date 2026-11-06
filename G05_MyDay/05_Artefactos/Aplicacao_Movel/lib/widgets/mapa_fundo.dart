import 'package:flutter/material.dart';

class MapaFundo extends StatelessWidget {
  const MapaFundo({super.key});

  @override
  Widget build(BuildContext context) {
    const estrada = Colors.white;
    return Container(
      color: const Color(0xFFECEEE6),
      child: Stack(
        children: [
          Positioned(
            left: 225,
            top: 190,
            child: Container(
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFD5E6CC),
                borderRadius: BorderRadius.circular(45),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 385,
            child: Container(
              width: 100,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD5E6CC),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(left: 48, top: 0, bottom: 0, child: Container(width: 6, color: estrada)),
          Positioned(left: 212, top: 100, bottom: 0, child: Container(width: 6, color: estrada)),
          Positioned(left: 0, right: 0, top: 316, child: Container(height: 6, color: estrada)),
          Positioned(
            left: -40,
            right: -40,
            top: 214,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(height: 14, color: estrada),
            ),
          ),
          Positioned(
            left: -40,
            right: -40,
            top: 425,
            child: Transform.rotate(
              angle: -0.21,
              child: Container(height: 6, color: estrada),
            ),
          ),
          Positioned(
            left: 145,
            top: -20,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(width: 14, color: estrada),
            ),
          ),
          Positioned(
            left: 300,
            top: -20,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(width: 6, color: estrada),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 605,
            bottom: 0,
            child: Container(color: const Color(0xFFC9DCEB)),
          ),
        ],
      ),
    );
  }
}

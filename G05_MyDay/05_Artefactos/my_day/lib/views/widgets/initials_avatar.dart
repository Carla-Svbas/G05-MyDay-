import 'package:flutter/material.dart';

/// Círculo com as iniciais de uma pessoa (ex.: "Cristiano Zanzala" → "CZ").
/// A cor é escolhida a partir do nome, para cada pessoa ter sempre a mesma.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const InitialsAvatar({super.key, required this.name, this.size = 32});

  // [fundo, texto], lidos do Figma (comentários e Comunidade).
  static const List<List<Color>> _palette = [
    [Color(0xFFFFE2CC), Color(0xFF8A3A00)], // pêssego
    [Color(0xFFDCEFE4), Color(0xFF1D6B40)], // verde
    [Color(0xFFE3E8FF), Color(0xFF2A3FC2)], // azul
    [Color(0xFFF3E3F6), Color(0xFF7B2C8A)], // roxo
  ];

  String get _initials {
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words.first[0] + words.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _palette[name.length % _palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors[0], shape: BoxShape.circle),
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: colors[1],
        ),
      ),
    );
  }
}

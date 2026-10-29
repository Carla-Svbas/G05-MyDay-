import 'package:flutter/material.dart';

import '../../models/entry.dart';

/// Cores das capas dos projetos (lidas do Figma). Project.colorIndex escolhe uma.
const List<Color> projectCoverColors = [
  Color(0xFFDDE3F5), // azul claro
  Color(0xFF3D5AFE), // azul (primária)
  Color(0xFFF3E6D3), // pêssego
  Color(0xFFDCEFE4), // verde
  Color(0xFFF3E3F6), // roxo
  Color(0xFFE8EAEF), // cinzento
];

Color projectCoverColor(int colorIndex) {
  return projectCoverColors[colorIndex % projectCoverColors.length];
}

/// Etiqueta de visibilidade por cima da capa do projeto (fundo claro, sem ícone).
class CoverVisibilityChip extends StatelessWidget {
  final EntryVisibility visibility;

  const CoverVisibilityChip({super.key, required this.visibility});

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color foreground = const Color(0xFF3A4150);
    if (visibility == EntryVisibility.friends) {
      background = const Color(0xFFFFF1D6);
      foreground = const Color(0xFF7A4A00);
    } else if (visibility == EntryVisibility.public) {
      foreground = const Color(0xFF2A3FC2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        visibilityLabel(visibility),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: foreground),
      ),
    );
  }
}

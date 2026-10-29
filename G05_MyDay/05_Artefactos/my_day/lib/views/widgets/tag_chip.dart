import 'package:flutter/material.dart';

import '../../models/entry.dart';

/// Etiqueta pequena com fundo colorido (disciplina ou visibilidade).
/// Guia de estilo: cantos de 6, texto 12 / 600.
class TagChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const TagChip({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
    this.icon,
  });

  /// Etiqueta de uma disciplina, com a cor dessa disciplina.
  factory TagChip.subject(String subject) {
    final colors = _subjectColors[subject] ?? _defaultColors;
    return TagChip(text: subject, background: colors[0], foreground: colors[1]);
  }

  /// Etiqueta de visibilidade (Privado / Só amigos / Público).
  /// Na Comunidade aparece sem ícone (withIcon: false).
  factory TagChip.visibility(EntryVisibility visibility, {bool withIcon = true}) {
    switch (visibility) {
      case EntryVisibility.private:
        return TagChip(
          text: visibilityLabel(visibility),
          background: const Color(0xFFE8EAEF),
          foreground: const Color(0xFF3A4150),
          icon: withIcon ? Icons.lock_outline : null,
        );
      case EntryVisibility.friends:
        return TagChip(
          text: visibilityLabel(visibility),
          background: const Color(0xFFFFF1D6),
          foreground: const Color(0xFF7A4A00),
          icon: withIcon ? Icons.people_outline : null,
        );
      case EntryVisibility.public:
        return TagChip(
          text: visibilityLabel(visibility),
          background: const Color(0xFFE3E8FF),
          foreground: const Color(0xFF2A3FC2),
          icon: withIcon ? Icons.public : null,
        );
    }
  }

  // [fundo, texto] de cada disciplina, lidos do Figma.
  static const Map<String, List<Color>> _subjectColors = {
    'Matemática Discreta': [Color(0xFFE3E8FF), Color(0xFF2A3FC2)],
    'Bases de Dados': [Color(0xFFDCEFE4), Color(0xFF1D6B40)],
    'Prog. Móvel': [Color(0xFFF3E3F6), Color(0xFF7B2C8A)],
    'Redes': [Color(0xFFF6E8D8), Color(0xFF8A4B12)],
  };
  static const List<Color> _defaultColors = [Color(0xFFE8EAEF), Color(0xFF3A4150)];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 2, icon == null ? 8 : 7, 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 15 / 12,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

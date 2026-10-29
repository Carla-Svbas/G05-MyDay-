import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Botão redondo de filtro (ex.: "Todos", "A seguir").
/// Escolhido: fundo escuro e texto branco. Não escolhido: branco com contorno.
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Sem "alignment": assim o Container fica só com a largura do texto.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          border: Border.all(color: selected ? AppColors.ink : const Color(0xFFD9DCE4)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}

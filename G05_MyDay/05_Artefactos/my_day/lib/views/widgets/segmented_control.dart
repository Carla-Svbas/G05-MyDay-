import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Seletor de opções lado a lado.
/// Estilo normal: fundo cinzento e opção escolhida em branco.
/// Estilo escuro (dark: true, por cima do mapa): fundo branco e opção escolhida a preto.
class SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool dark;

  const SegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? AppColors.surface : AppColors.segmentBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: dark
            ? const [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 4))]
            : null,
      ),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++)
            Expanded(child: _buildOption(i)),
        ],
      ),
    );
  }

  Widget _buildOption(int index) {
    final bool selected = index == selectedIndex;

    Color background = Colors.transparent;
    Color textColor = AppColors.bodyText;
    if (selected) {
      background = dark ? AppColors.ink : AppColors.surface;
      textColor = dark ? Colors.white : AppColors.ink;
    }

    return GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected && !dark
              ? const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))]
              : null,
        ),
        child: Text(
          options[index],
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

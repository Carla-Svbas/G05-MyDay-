import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Interruptor com o tamanho e as cores do Figma (48 x 28).
/// O Switch do Flutter tem outro tamanho, por isso fizemos um simples.
class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      // AnimatedContainer anima a mudança de cor e de posição da bola.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFC9CED8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Barra de navegação inferior: Diário, Projetos, [+], Comunidade, Perfil.
/// O botão "+" do meio não é um separador: abre o ecrã "Novo registo".
class BottomNavBar extends StatelessWidget {
  final int selectedIndex; // 0 Diário, 1 Projetos, 2 Comunidade, 3 Perfil
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(0, Icons.menu_book_outlined, 'Diário'),
          _buildItem(1, Icons.folder_outlined, 'Projetos'),
          _buildAddButton(),
          _buildItem(2, Icons.people_outline, 'Comunidade'),
          _buildItem(3, Icons.person_outline, 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String label) {
    final bool selected = index == selectedIndex;
    final Color color = selected ? AppColors.primary : AppColors.text2;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// Botão azul "+" (56 x 48) no centro.
  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onAddPressed,
        child: Container(
          width: 56,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../theme/app_theme.dart';
import 'initials_avatar.dart';

/// Cartão de um grupo de estudo, com as iniciais dos membros sobrepostas.
/// Usado nos ecrãs Projetos e Comunidade.
class StudyGroupCard extends StatelessWidget {
  final StudyGroup group;
  final VoidCallback onTap;

  const StudyGroupCard({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const int shown = 2; // iniciais visíveis; as restantes aparecem como "+N"
    final int extra = group.memberNames.length - shown;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Círculos de 36 (32 + contorno branco de 2), cada um 26 à direita do anterior.
            SizedBox(
              width: 36 + 26.0 * shown,
              height: 36,
              child: Stack(
                children: [
                  for (int i = 0; i < shown; i++)
                    Positioned(left: 26.0 * i, child: _ringed(InitialsAvatar(name: group.memberNames[i]))),
                  if (extra > 0)
                    Positioned(
                      left: 26.0 * shown,
                      child: _ringed(Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFE3E8FF), shape: BoxShape.circle),
                        child: Text(
                          '+$extra',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2A3FC2)),
                        ),
                      )),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.memberNames.length} membros · ${group.sharedEntries} registos partilhados',
                    style: const TextStyle(fontSize: 12, height: 15 / 12, color: AppColors.text2),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.text2),
          ],
        ),
      ),
    );
  }

  /// Contorno branco à volta de cada círculo, para se distinguirem quando sobrepostos.
  Widget _ringed(Widget child) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: child,
    );
  }
}

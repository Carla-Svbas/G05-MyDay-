import 'package:flutter/material.dart';

import '../../models/entry.dart';
import '../../theme/app_theme.dart';
import '../../utils/pt_dates.dart';
import 'tag_chip.dart';

/// Cartão de um registo na lista do Diário.
class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback onTap;

  const EntryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14), // + 1 de contorno = 15, como no Figma
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildContent()),
            if (entry.hasPhoto) ...[
              const SizedBox(width: 12),
              _buildPhoto(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TagChip.subject(entry.subject),
            const SizedBox(width: 7),
            Text(
              formatTime(entry.date),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.text2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          entry.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          entry.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.bodyText,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooter(),
      ],
    );
  }

  /// Linha de baixo: local / áudio / vídeo à esquerda, visibilidade à direita.
  Widget _buildFooter() {
    IconData? icon;
    String? label;
    if (entry.locationName != null) {
      icon = Icons.location_on_outlined;
      label = entry.locationName;
    } else if (entry.audioDuration != null) {
      icon = Icons.mic_none;
      label = 'Áudio · ${entry.audioDuration}';
    } else if (entry.videoDuration != null) {
      icon = Icons.videocam_outlined;
      label = 'Vídeo · ${entry.videoDuration}';
    }

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.text2),
          const SizedBox(width: 10),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.text2,
            ),
          ),
        ],
        const Spacer(),
        TagChip.visibility(entry.visibility),
      ],
    );
  }

  /// Espaço da fotografia (76 x 76). O protótipo ainda não guarda imagens.
  Widget _buildPhoto() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.photoPlaceholder,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.photo_camera_outlined, size: 22, color: AppColors.text2),
    );
  }
}

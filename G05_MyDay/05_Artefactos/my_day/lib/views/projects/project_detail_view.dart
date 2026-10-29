import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/entry_controller.dart';
import '../../controllers/project_controller.dart';
import '../../models/entry.dart';
import '../../models/project.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/pt_dates.dart';
import '../entry_detail_view.dart';
import '../new_entry_view.dart';
import '../widgets/segmented_control.dart';

/// View do ecrã "06 · Projeto": dados do projeto, visibilidade, ações e linha temporal.
class ProjectDetailView extends StatelessWidget {
  final Project project;
  final AuthController authController;
  final EntryController entryController;
  final ProjectController projectController;

  const ProjectDetailView({
    super.key,
    required this.project,
    required this.authController,
    required this.entryController,
    required this.projectController,
  });

  User? get _user => authController.currentUser;
  bool get _isOwner => _user != null && project.ownerEmail == _user!.email;

  // ---------- Ações ----------

  Future<void> _onEdit(BuildContext context) async {
    // Guardado antes do "await": depois da janela o context pode já não existir.
    final messenger = ScaffoldMessenger.of(context);
    final nameController = TextEditingController(text: project.name);
    final descriptionController = TextEditingController(text: project.description);
    final bool? save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar projeto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (save != true) return;

    final String? error = projectController.editProject(
      project,
      nameController.text,
      descriptionController.text,
    );
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _onVisibilityChanged(BuildContext context, int index) {
    if (!_isOwner) {
      _showMessage(context, 'Só o dono do projeto pode mudar a visibilidade.');
      return;
    }
    projectController.setVisibility(project, EntryVisibility.values[index]);
  }

  void _onQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(project.name, textAlign: TextAlign.center),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 160, color: AppColors.ink),
            SizedBox(height: 8),
            Text(
              'Mostra este código para partilhar o projeto (simulação).',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text2),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void _onNewEntry(BuildContext context) {
    if (_user == null) {
      _showMessage(context, 'Cria uma conta para fazeres registos.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEntryView(
          authController: authController,
          entryController: entryController,
          initialProject: project.name,
        ),
      ),
    );
  }

  void _openEntry(BuildContext context, Entry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailView(
          entry: entry,
          authController: authController,
          entryController: entryController,
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------- Desenho do ecrã ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([projectController, entryController]),
        builder: (context, child) {
          final List<Entry> entries = projectController.entriesOf(project, _user);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            children: [
              _buildTopBar(context),
              const SizedBox(height: 15),
              Text(
                project.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.56,
                  color: AppColors.ink,
                ),
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  project.description,
                  style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.text2),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _statsText(entries),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bodyText),
              ),
              const SizedBox(height: 16),
              _buildVisibilityCard(context),
              const SizedBox(height: 16),
              _buildActions(context),
              const SizedBox(height: 20),
              const Text(
                'LINHA TEMPORAL',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.text2,
                ),
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                const Text(
                  'Ainda não há registos neste projeto.',
                  style: TextStyle(fontSize: 14, color: AppColors.text2),
                ),
              for (int i = 0; i < entries.length; i++)
                _buildTimelineItem(context, entries[i], isLast: i == entries.length - 1),
            ],
          );
        },
      ),
    );
  }

  /// "23 registos · 4 disciplinas · desde 5 out"
  String _statsText(List<Entry> entries) {
    final int subjects = projectController.subjectCount(project, _user);
    final String entriesText = entries.length == 1 ? '1 registo' : '${entries.length} registos';
    final String subjectsText = subjects == 1 ? '1 disciplina' : '$subjects disciplinas';
    return '$entriesText · $subjectsText · desde ${formatShortDayMonth(project.createdAt)}';
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _squareButton(Icons.chevron_left, 24, () => Navigator.pop(context)),
        const Spacer(),
        if (_isOwner) _squareButton(Icons.edit_outlined, 20, () => _onEdit(context)),
      ],
    );
  }

  Widget _squareButton(IconData icon, double iconSize, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: iconSize, color: AppColors.ink),
      ),
    );
  }

  Widget _buildVisibilityCard(BuildContext context) {
    const List<String> descriptions = [
      'Só tu vês este projeto e os seus registos.',
      'Só os teus amigos veem este projeto.',
      'Visível para todos, incluindo convidados. As localizações aparecem aproximadas.',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quem pode ver este projeto',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 10),
          SegmentedControl(
            options: const ['Privado', 'Só amigos', 'Público'],
            selectedIndex: project.visibility.index,
            onChanged: (index) => _onVisibilityChanged(context, index),
          ),
          const SizedBox(height: 11),
          Text(
            descriptions[project.visibility.index],
            style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.text2),
          ),
        ],
      ),
    );
  }

  /// Exportar PDF · QR Code · + Registo
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(Icons.file_download_outlined, 'Exportar PDF',
              () => _showMessage(context, 'PDF do projeto exportado (simulação).')),
        ),
        const SizedBox(width: 8),
        Expanded(child: _actionButton(Icons.qr_code_2, 'QR Code', () => _onQrCode(context))),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(Icons.add, 'Registo', () => _onNewEntry(context), primary: true),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap, {bool primary = false}) {
    final Color color = primary ? Colors.white : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.surface,
          border: primary ? null : Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  /// Um ponto da linha temporal. Azul se for da última semana, cinzento se for mais antigo.
  Widget _buildTimelineItem(BuildContext context, Entry entry, {required bool isLast}) {
    final int days = daysBetween(entry.date, DateTime.now());
    final bool recent = days < 7;
    final String date = days <= 1
        ? '${formatRelativeDay(entry.date)} · ${formatTime(entry.date)}'
        : formatShortDayMonth(entry.date);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openEntry(context, entry),
      child: SizedBox(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ponto + linha vertical até ao próximo ponto
            SizedBox(
              width: 14,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: recent ? AppColors.primary : const Color(0xFFC3C8D3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: const Color(0xFFD5D9E1))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _mediaText(entry),
                    style: const TextStyle(fontSize: 13, color: AppColors.text2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Vídeo · 0:42", "Áudio · 1:24", "Texto · 2 fotografias" ou "Texto".
  String _mediaText(Entry entry) {
    if (entry.videoDuration != null) return 'Vídeo · ${entry.videoDuration}';
    if (entry.audioDuration != null) return 'Áudio · ${entry.audioDuration}';
    if (entry.photoCount == 1) return 'Texto · 1 fotografia';
    if (entry.photoCount > 1) return 'Texto · ${entry.photoCount} fotografias';
    return 'Texto';
  }
}

import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/entry_controller.dart';
import '../../controllers/project_controller.dart';
import '../../models/entry.dart';
import '../../models/project.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/pt_dates.dart';
import '../widgets/pill_chip.dart';
import '../widgets/study_group_card.dart';
import 'project_detail_view.dart';
import 'project_widgets.dart';

/// View do ecrã "05 · Projetos": grelha de projetos com filtros e grupos de estudo.
class ProjectsView extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController;
  final ProjectController projectController;

  const ProjectsView({
    super.key,
    required this.authController,
    required this.entryController,
    required this.projectController,
  });

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  EntryVisibility? _filter; // null = "Todos"

  User? get _user => widget.authController.currentUser;

  // ---------- Ações ----------

  Future<void> _onNewProject() async {
    if (_user == null) {
      _showMessage('Cria uma conta para teres projetos.');
      return;
    }
    final controller = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo projeto'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nome do projeto'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    if (name == null) return;

    final String? error = widget.projectController.createProject(_user!, name);
    _showMessage(error ?? 'Projeto criado.');
  }

  void _openProject(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailView(
          project: project,
          authController: widget.authController,
          entryController: widget.entryController,
          projectController: widget.projectController,
        ),
      ),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------- Desenho do ecrã ----------

  @override
  Widget build(BuildContext context) {
    // Redesenha quando mudam os projetos ou os registos.
    return ListenableBuilder(
      listenable: Listenable.merge([widget.projectController, widget.entryController]),
      builder: (context, child) {
        final projects = widget.projectController.projectsFor(_user, filter: _filter);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            if (projects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Não há projetos para mostrar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.text2),
                ),
              )
            else
              _buildGrid(projects),
            if (_user != null) ...[
              const SizedBox(height: 22),
              const Text(
                'GRUPOS DE ESTUDO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.text2,
                ),
              ),
              const SizedBox(height: 16),
              for (final group in widget.projectController.groups)
                StudyGroupCard(
                  group: group,
                  onTap: () => _showMessage('Os grupos de estudo vão ser desenvolvidos numa próxima versão.'),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Projetos',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.56,
              color: AppColors.ink,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _onNewProject,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Novo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// Todos · Privados · Só amigos · Públicos
  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _filterChip('Todos', null),
        _filterChip('Privados', EntryVisibility.private),
        _filterChip('Só amigos', EntryVisibility.friends),
        _filterChip('Públicos', EntryVisibility.public),
      ],
    );
  }

  Widget _filterChip(String label, EntryVisibility? value) {
    return PillChip(
      label: label,
      selected: _filter == value,
      onTap: () => setState(() => _filter = value),
    );
  }

  /// Dois projetos por linha.
  Widget _buildGrid(List<Project> projects) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 169 / 149,
      children: [for (final project in projects) _buildProjectCard(project)],
    );
  }

  Widget _buildProjectCard(Project project) {
    final entries = widget.projectController.entriesOf(project, _user);
    final String count = entries.length == 1 ? '1 registo' : '${entries.length} registos';
    final String meta = entries.isEmpty ? 'Sem registos' : '$count · ${_lastActivity(entries.first)}';

    return GestureDetector(
      onTap: () => _openProject(project),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa colorida com a visibilidade
            Container(
              height: 88,
              width: double.infinity,
              color: projectCoverColor(project.colorIndex),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(8),
              child: CoverVisibilityChip(visibility: project.visibility),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: const TextStyle(fontSize: 12, color: AppColors.text2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "hoje", "ontem" ou "3 dias", a partir do registo mais recente.
  String _lastActivity(Entry latest) {
    final int days = daysBetween(latest.date, DateTime.now());
    if (days == 0) return 'hoje';
    if (days == 1) return 'ontem';
    return '$days dias';
  }
}

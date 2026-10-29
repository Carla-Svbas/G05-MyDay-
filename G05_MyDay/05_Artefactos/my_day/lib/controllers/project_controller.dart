import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/entry.dart';
import '../models/project.dart';
import '../models/user.dart';
import 'entry_controller.dart';

/// Controller dos projetos: lista, filtra, cria e edita projetos.
/// Usa o EntryController para saber que registos pertencem a cada projeto.
class ProjectController extends ChangeNotifier {
  final EntryController entryController;
  final List<Project> _projects = sampleProjects;

  ProjectController({required this.entryController});

  List<StudyGroup> get groups => sampleGroups;

  /// Projetos que um utilizador pode ver, opcionalmente filtrados por visibilidade.
  /// Um convidado (user == null) só vê projetos públicos.
  List<Project> projectsFor(User? user, {EntryVisibility? filter}) {
    final List<Project> result = [];
    for (final project in _projects) {
      final bool isMine = user != null && project.ownerEmail == user.email;
      final bool isPublic = project.visibility == EntryVisibility.public;
      final bool visible = isMine || (user == null && isPublic);
      final bool matchesFilter = filter == null || project.visibility == filter;
      if (visible && matchesFilter) result.add(project);
    }
    return result;
  }

  /// Registos do projeto, do mais recente para o mais antigo.
  List<Entry> entriesOf(Project project, User? user) {
    return [
      for (final entry in entryController.entriesFor(user))
        if (entry.project == project.name) entry,
    ];
  }

  /// Número de disciplinas diferentes nos registos do projeto.
  int subjectCount(Project project, User? user) {
    final Set<String> subjects = {};
    for (final entry in entriesOf(project, user)) {
      subjects.add(entry.subject);
    }
    return subjects.length;
  }

  /// Cria um projeto novo. Devolve null se correu bem, ou o erro.
  String? createProject(User user, String name) {
    name = name.trim();
    if (name.isEmpty) return 'Escreve o nome do projeto.';
    for (final project in projectsFor(user)) {
      if (project.name.toLowerCase() == name.toLowerCase()) {
        return 'Já tens um projeto com esse nome.';
      }
    }
    _projects.add(Project(
      ownerEmail: user.email,
      name: name,
      description: '',
      createdAt: DateTime.now(),
      colorIndex: _projects.length, // cada projeto novo tem outra cor
    ));
    notifyListeners();
    return null;
  }

  /// Muda o nome e a descrição. Os registos acompanham o novo nome.
  String? editProject(Project project, String name, String description) {
    name = name.trim();
    if (name.isEmpty) return 'O nome não pode ficar vazio.';
    entryController.renameProject(project.name, name);
    project.name = name;
    project.description = description.trim();
    notifyListeners();
    return null;
  }

  void setVisibility(Project project, EntryVisibility visibility) {
    project.visibility = visibility;
    notifyListeners();
  }
}

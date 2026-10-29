import 'entry.dart';

/// Model: um projeto que agrupa registos (ex.: "App MyDay").
/// Os registos ligam-se ao projeto pelo nome (Entry.project).
class Project {
  final String ownerEmail;
  String name; // pode ser editado
  String description; // pode ser editado
  EntryVisibility visibility; // pode ser alterada no ecrã do projeto
  final DateTime createdAt;
  final int colorIndex; // cor da capa (a paleta está na View)

  Project({
    required this.ownerEmail,
    required this.name,
    required this.description,
    required this.createdAt,
    this.visibility = EntryVisibility.private,
    this.colorIndex = 0,
  });
}

/// Model: um grupo de estudo (secção "Grupos de estudo" do ecrã 05).
class StudyGroup {
  final String name;
  final List<String> memberNames;
  final int sharedEntries;

  const StudyGroup({
    required this.name,
    required this.memberNames,
    required this.sharedEntries,
  });
}

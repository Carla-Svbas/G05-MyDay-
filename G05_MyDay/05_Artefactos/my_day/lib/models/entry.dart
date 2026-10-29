import 'comment.dart';

/// Quem pode ver um registo.
enum EntryVisibility { private, friends, public }

/// Texto de cada visibilidade, tal como aparece nos ecrãs.
String visibilityLabel(EntryVisibility visibility) {
  switch (visibility) {
    case EntryVisibility.private:
      return 'Privado';
    case EntryVisibility.friends:
      return 'Só amigos';
    case EntryVisibility.public:
      return 'Público';
  }
}

/// Model: um registo do diário (o que o estudante aprendeu num momento).
class Entry {
  final String authorEmail; // Dono do registo
  final String subject; // Disciplina, ex.: "Matemática Discreta"
  final String title;
  final String text;
  final DateTime date;
  final EntryVisibility visibility;

  // Campos opcionais: só alguns registos os têm.
  String? project; // ex.: "App MyDay" (muda se o projeto mudar de nome)
  final List<String> tags; // sem o "#", ex.: ["iterações", "cálculo"]
  final String? locationName; // ex.: "Biblioteca IADE"
  final String? locationAddress; // ex.: "Av. Dom Carlos I, Lisboa"
  final String? audioDuration; // ex.: "1:24"
  final String? videoDuration; // ex.: "0:42"
  final int photoCount;

  /// Comentários deste registo. A lista pode crescer (novos comentários).
  final List<Comment> comments;

  /// true se um administrador ocultou o registo (deixa de aparecer aos outros).
  bool hidden = false;

  Entry({
    required this.authorEmail,
    required this.subject,
    required this.title,
    required this.text,
    required this.date,
    this.visibility = EntryVisibility.private, // Privado por defeito (Figma, ecrã 03)
    this.project,
    this.tags = const [],
    this.locationName,
    this.locationAddress,
    this.audioDuration,
    this.videoDuration,
    this.photoCount = 0,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  bool get hasPhoto => photoCount > 0;
}

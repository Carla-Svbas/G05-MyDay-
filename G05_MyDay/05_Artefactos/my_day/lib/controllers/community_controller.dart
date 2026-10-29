import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/entry.dart';
import '../models/project.dart';
import '../models/user.dart';
import 'entry_controller.dart';

/// Controller da Comunidade: quem segue quem e que registos de outras
/// pessoas cada utilizador pode ver.
class CommunityController extends ChangeNotifier {
  final EntryController entryController;
  final Map<String, Set<String>> _following = sampleFollowing;

  CommunityController({required this.entryController});

  String get challenge => sampleChallenge;

  /// Muda o desafio da semana (feito pelo administrador).
  void setChallenge(String text) {
    sampleChallenge = text;
    notifyListeners();
  }

  int get userCount => sampleUsers.length;
  List<StudyGroup> get groups => sampleGroups;

  /// Nome de quem escreveu o registo.
  String authorName(Entry entry) {
    for (final user in sampleUsers) {
      if (user.email == entry.authorEmail) return user.name;
    }
    return entry.authorEmail;
  }

  bool isFollowing(User? user, String email) {
    if (user == null) return false;
    return _following[user.email]?.contains(email) ?? false;
  }

  void toggleFollow(User user, String email) {
    final Set<String> set = _following.putIfAbsent(user.email, () => {});
    if (set.contains(email)) {
      set.remove(email);
    } else {
      set.add(email);
    }
    notifyListeners();
  }

  int followingCount(User user) => _following[user.email]?.length ?? 0;

  /// Pessoas que o utilizador segue.
  List<User> followingOf(User user) {
    return [
      for (final other in sampleUsers)
        if (other.email != user.email && isFollowing(user, other.email)) other,
    ];
  }

  /// Pessoas que seguem o utilizador.
  List<User> followersOf(User user) {
    return [
      for (final other in sampleUsers)
        if (other.email != user.email && isFollowing(other, user.email)) other,
    ];
  }

  int followersCount(User user) {
    int count = 0;
    for (final set in _following.values) {
      if (set.contains(user.email)) count++;
    }
    return count;
  }

  /// Regra de visibilidade para registos de outras pessoas:
  /// públicos → todos; "só amigos" → quem segue o autor; privados → ninguém.
  bool canSee(Entry entry, User? user) {
    if (user != null && entry.authorEmail == user.email) return true;
    switch (entry.visibility) {
      case EntryVisibility.public:
        return true;
      case EntryVisibility.friends:
        return isFollowing(user, entry.authorEmail);
      case EntryVisibility.private:
        return false;
    }
  }

  /// Registos de outras pessoas para a Comunidade.
  /// [followingOnly] true → separador "A seguir"; false → "Descobrir".
  /// [query] filtra por título, texto, disciplina, autor ou tag.
  List<Entry> feed(User? user, {required bool followingOnly, String query = ''}) {
    final String search = query.trim().toLowerCase();
    final List<Entry> result = [];

    for (final entry in entryController.allEntries) {
      final bool isMine = user != null && entry.authorEmail == user.email;
      if (isMine || entry.hidden || !canSee(entry, user)) continue;

      final bool follows = isFollowing(user, entry.authorEmail);
      if (followingOnly != follows) continue;

      if (search.isNotEmpty && !_matches(entry, search)) continue;
      result.add(entry);
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  bool _matches(Entry entry, String search) {
    final String text = [
      entry.title,
      entry.text,
      entry.subject,
      authorName(entry),
      ...entry.tags,
    ].join(' ').toLowerCase();
    return text.contains(search);
  }
}

import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/comment.dart';
import '../models/entry.dart';
import '../models/map_place.dart';
import '../models/report.dart';
import '../models/user.dart';
import '../utils/pt_dates.dart';

/// Controller dos registos do diário: lista, cria e calcula estatísticas.
class EntryController extends ChangeNotifier {
  final List<Entry> _entries = sampleEntries;

  /// Todos os registos (usado pela Comunidade, que aplica as suas regras).
  List<Entry> get allEntries => List.unmodifiable(_entries);

  /// Registos que um utilizador pode ver no seu Diário, do mais recente
  /// para o mais antigo. Um convidado (user == null) só vê registos públicos.
  List<Entry> entriesFor(User? user) {
    final List<Entry> result = [];
    for (final entry in _entries) {
      final bool isMine = user != null && entry.authorEmail == user.email;
      final bool isPublic = entry.visibility == EntryVisibility.public && !entry.hidden;
      if (isMine || (user == null && isPublic)) {
        result.add(entry);
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// Opções para o ecrã "Novo registo".
  List<String> get subjects => sampleSubjects;
  /// Nomes dos projetos do utilizador (para escolher no Novo registo).
  List<String> projectNamesFor(User? user) {
    return [
      for (final project in sampleProjects)
        if (user != null && project.ownerEmail == user.email) project.name,
    ];
  }

  /// O protótipo não usa GPS: este é o local "atual" simulado.
  static const String simulatedLocationName = 'Biblioteca IADE';
  static const String simulatedLocationAddress = 'Av. Dom Carlos I, Lisboa';

  /// Cria e guarda um registo novo.
  /// Devolve null se correu bem, ou a mensagem de erro para mostrar.
  String? createEntry({
    required User author,
    required String title,
    required String text,
    required String? subject,
    required String? project,
    required List<String> tags,
    required EntryVisibility visibility,
    required bool withLocation,
    required int photoCount,
    required bool withAudio,
    required bool withVideo,
  }) {
    if (title.trim().isEmpty) {
      return 'Escreve um título para o registo.';
    }
    if (subject == null) {
      return 'Escolhe a disciplina.';
    }

    _entries.add(Entry(
      authorEmail: author.email,
      subject: subject,
      title: title.trim(),
      text: text.trim(),
      date: DateTime.now(),
      visibility: visibility,
      project: project,
      tags: tags,
      locationName: withLocation ? simulatedLocationName : null,
      locationAddress: withLocation ? simulatedLocationAddress : null,
      photoCount: photoCount,
      // Gravações simuladas: guardamos só uma duração de exemplo.
      audioDuration: withAudio ? '0:15' : null,
      videoDuration: withVideo ? '0:30' : null,
    ));
    notifyListeners(); // O Diário redesenha-se e mostra o registo novo.
    return null;
  }

  // ---------- Ecrã 04 · Registo ----------

  /// Registos marcados como favoritos (só em memória).
  final Set<Entry> _favorites = {};

  bool isFavorite(Entry entry) => _favorites.contains(entry);

  void toggleFavorite(Entry entry) {
    if (_favorites.contains(entry)) {
      _favorites.remove(entry);
    } else {
      _favorites.add(entry);
    }
    notifyListeners();
  }

  /// Só o autor pode apagar o seu registo.
  bool isOwner(Entry entry, User? user) {
    return user != null && entry.authorEmail == user.email;
  }

  void deleteEntry(Entry entry) {
    _entries.remove(entry);
    _favorites.remove(entry);
    notifyListeners();
  }

  // ---------- Denúncias (tratadas no ecrã 11 · Administração) ----------

  final List<Report> _reports = sampleReports;

  /// Denúncias ainda por tratar.
  List<Report> get openReports => List.unmodifiable(_reports);

  /// Denuncia um registo (ou um comentário). Se já houver uma denúncia igual,
  /// soma mais uma pessoa em vez de criar outra.
  void reportEntry(Entry entry, String reason, {Comment? comment}) {
    for (final report in _reports) {
      if (report.entry == entry && report.comment == comment && report.reason == reason) {
        report.count++;
        notifyListeners();
        return;
      }
    }
    _reports.add(Report(entry: entry, comment: comment, reason: reason));
    notifyListeners();
  }

  /// Retira a denúncia da fila (depois de o administrador decidir).
  void closeReport(Report report) {
    _reports.remove(report);
    notifyListeners();
  }

  /// Oculta um registo: deixa de aparecer a outras pessoas.
  void hideEntry(Entry entry) {
    entry.hidden = true;
    notifyListeners();
  }

  void removeComment(Entry entry, Comment comment) {
    entry.comments.remove(comment);
    notifyListeners();
  }

  /// Apaga todos os registos de um utilizador (usado ao apagar a conta).
  void deleteEntriesOf(String email) {
    _entries.removeWhere((entry) => entry.authorEmail == email);
    notifyListeners();
  }

  /// Acrescenta um comentário. Devolve null se correu bem, ou o erro.
  String? addComment(Entry entry, User? user, String text) {
    if (user == null) {
      return 'Os convidados não podem comentar. Cria uma conta.';
    }
    if (text.trim().isEmpty) {
      return 'Escreve o comentário antes de enviar.';
    }
    entry.comments.add(Comment(
      authorName: user.name,
      text: text.trim(),
      date: DateTime.now(),
    ));
    notifyListeners();
    return null;
  }

  /// Quando um projeto muda de nome, os registos passam a usar o nome novo.
  void renameProject(String oldName, String newName) {
    for (final entry in _entries) {
      if (entry.project == oldName) entry.project = newName;
    }
    notifyListeners();
  }

  // ---------- Ecrã 07 · Mapa ----------

  List<MapPlace> get places => samplePlaces;

  /// Registos de um utilizador feitos num local, do mais recente para o mais antigo.
  /// Se [lastDays] for indicado, só conta os registos desses últimos dias.
  List<Entry> entriesAtPlace(MapPlace place, User? user, {int? lastDays}) {
    final DateTime? since =
        lastDays == null ? null : addDays(onlyDay(DateTime.now()), -(lastDays - 1));
    final List<Entry> result = [];
    for (final entry in entriesFor(user)) {
      final bool samePlace = entry.locationName == place.name;
      final bool recent = since == null || !entry.date.isBefore(since);
      if (samePlace && recent) result.add(entry);
    }
    return result;
  }

  /// Encontra o local de um registo (ou null se não tiver local no mapa).
  MapPlace? placeOf(Entry entry) {
    for (final place in places) {
      if (place.name == entry.locationName) return place;
    }
    return null;
  }

  // ---------- Ecrã 08 · Calendário e estatísticas ----------

  /// Registos de um utilizador num dia.
  List<Entry> entriesOnDay(User? user, DateTime day) {
    final List<Entry> result = [];
    for (final entry in entriesFor(user)) {
      if (onlyDay(entry.date) == onlyDay(day)) result.add(entry);
    }
    return result;
  }

  int totalEntries(User? user) => entriesFor(user).length;

  /// Número de registos por disciplina, da mais trabalhada para a menos.
  List<MapEntry<String, int>> entriesPerSubject(User? user) {
    final Map<String, int> counts = {};
    for (final entry in entriesFor(user)) {
      counts[entry.subject] = (counts[entry.subject] ?? 0) + 1;
    }
    final list = counts.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// Transforma "#iterações cálculo, #flutter" em ["iterações", "cálculo", "flutter"].
  List<String> parseTags(String text) {
    final List<String> tags = [];
    for (final word in text.split(RegExp(r'[\s,]+'))) {
      final tag = word.replaceAll('#', '').trim();
      if (tag.isNotEmpty && !tags.contains(tag)) tags.add(tag);
    }
    return tags;
  }

  /// Quantos dias seguidos (até hoje) o utilizador fez pelo menos um registo.
  int streakDays(User? user) {
    final entries = entriesFor(user);
    int streak = 0;
    DateTime day = onlyDay(DateTime.now());

    while (_hasEntryOn(entries, day)) {
      streak++;
      day = addDays(day, -1);
    }
    return streak;
  }

  /// Para cada dia desta semana (segunda a domingo): houve registo?
  List<bool> weekActivity(User? user) {
    final entries = entriesFor(user);
    final DateTime monday = _mondayOfThisWeek();
    final List<bool> days = [];
    for (int i = 0; i < 7; i++) {
      days.add(_hasEntryOn(entries, addDays(monday, i)));
    }
    return days;
  }

  /// Número de registos feitos desde segunda-feira.
  int entriesThisWeek(User? user) {
    final DateTime monday = _mondayOfThisWeek();
    int count = 0;
    for (final entry in entriesFor(user)) {
      if (!entry.date.isBefore(monday)) count++;
    }
    return count;
  }

  bool _hasEntryOn(List<Entry> entries, DateTime day) {
    for (final entry in entries) {
      if (onlyDay(entry.date) == day) return true;
    }
    return false;
  }

  DateTime _mondayOfThisWeek() {
    final today = onlyDay(DateTime.now());
    return addDays(today, -(today.weekday - 1));
  }
}

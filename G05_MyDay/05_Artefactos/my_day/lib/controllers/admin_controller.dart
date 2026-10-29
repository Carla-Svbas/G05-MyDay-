import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/report.dart';
import '../models/user.dart';
import '../utils/pt_dates.dart';
import 'community_controller.dart';
import 'entry_controller.dart';

/// Controller da Administração: trata as denúncias, mostra estatísticas
/// e guarda o registo das ações dos administradores.
class AdminController extends ChangeNotifier {
  final EntryController entryController;
  final CommunityController communityController;
  final List<AdminAction> _actions = sampleAdminActions;

  AdminController({required this.entryController, required this.communityController});

  /// Nome do administrador no registo de ações ("Lurdes" → "lurdes.admin").
  String adminHandle(User admin) => '${admin.name.toLowerCase()}.admin';

  /// Ações, da mais recente para a mais antiga (a lista já está por essa ordem).
  List<AdminAction> get actions => List.unmodifiable(_actions);

  /// Regista uma ação no início da lista (a mais recente fica em primeiro).
  void _log(User admin, String description) {
    _actions.insert(0, AdminAction(
      adminName: adminHandle(admin),
      description: description,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  // ---------- Denúncias ----------

  List<Report> get openReports => entryController.openReports;

  /// Quem escreveu o conteúdo denunciado.
  String authorOf(Report report) {
    return report.comment?.authorName ?? communityController.authorName(report.entry);
  }

  /// Ocultar: esconde o registo (ou apaga o comentário) e fecha a denúncia.
  void hide(Report report, User admin) {
    if (report.comment != null) {
      entryController.removeComment(report.entry, report.comment!);
    } else {
      entryController.hideEntry(report.entry);
    }
    entryController.closeReport(report);
    _log(admin, 'ocultou «${report.title}»');
  }

  /// Avisar autor: o conteúdo fica, mas o autor é avisado (simulado).
  void warnAuthor(Report report, User admin) {
    entryController.closeReport(report);
    _log(admin, 'avisou ${authorOf(report)}');
  }

  /// Ignorar: a denúncia não tinha razão; nada muda.
  void ignore(Report report, User admin) {
    entryController.closeReport(report);
    _log(admin, 'ignorou a denúncia a «${report.title}»');
  }

  // ---------- Estatísticas ----------

  int get userCount => communityController.userCount;

  int get entriesToday {
    int count = 0;
    for (final entry in entryController.allEntries) {
      if (daysBetween(entry.date, DateTime.now()) == 0) count++;
    }
    return count;
  }

  int get totalEntries => entryController.allEntries.length;

  /// Tags usadas nos registos e quantas vezes, da mais usada para a menos.
  List<MapEntry<String, int>> get tags {
    final Map<String, int> counts = {};
    for (final entry in entryController.allEntries) {
      for (final tag in entry.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final list = counts.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  // ---------- Desafios ----------

  String get challenge => communityController.challenge;

  /// Publica um novo desafio da semana. Devolve null se correu bem, ou o erro.
  String? publishChallenge(User admin, String text) {
    text = text.trim();
    if (text.isEmpty) return 'Escreve o desafio.';
    communityController.setChallenge(text);
    _log(admin, 'publicou um desafio');
    return null;
  }
}

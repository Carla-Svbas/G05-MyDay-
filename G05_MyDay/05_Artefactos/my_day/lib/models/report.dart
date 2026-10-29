import 'comment.dart';
import 'entry.dart';

/// Model: uma denúncia feita a um registo ou a um comentário.
class Report {
  final Entry entry; // registo denunciado (ou onde está o comentário)
  final Comment? comment; // preenchido se a denúncia for a um comentário
  final String reason; // ex.: "Conteúdo copiado"
  int count; // quantas pessoas denunciaram

  Report({
    required this.entry,
    required this.reason,
    this.comment,
    this.count = 1,
  });

  /// "Resumo de Física – exame" ou "Comentário em «Listas Ligadas»".
  String get title => comment == null ? entry.title : 'Comentário em «${entry.title}»';
}

/// Model: uma ação feita por um administrador (para o "Registo de ações").
class AdminAction {
  final String adminName; // ex.: "lurdes.admin"
  final String description; // ex.: "publicou um desafio"
  final DateTime date;

  AdminAction({
    required this.adminName,
    required this.description,
    required this.date,
  });
}

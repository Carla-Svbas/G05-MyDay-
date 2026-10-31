import 'registo.dart';

class Projeto {
  final int id;
  final String donoEmail;
  final String nome;
  final String descricao;
  final Visibilidade visibilidade;
  final DateTime criadoEm;
  final int cor;

  const Projeto({
    required this.id,
    required this.donoEmail,
    required this.nome,
    required this.descricao,
    required this.criadoEm,
    this.visibilidade = Visibilidade.privado,
    this.cor = 0,
  });

  Projeto copyWith({
    String? nome,
    String? descricao,
    Visibilidade? visibilidade,
  }) {
    return Projeto(
      id: id,
      donoEmail: donoEmail,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      visibilidade: visibilidade ?? this.visibilidade,
      criadoEm: criadoEm,
      cor: cor,
    );
  }
}

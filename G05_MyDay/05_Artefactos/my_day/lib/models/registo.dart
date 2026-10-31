import 'comentario.dart';

enum Visibilidade { privado, amigos, publico }

String nomeVisibilidade(Visibilidade visibilidade) {
  if (visibilidade == Visibilidade.privado) {
    return 'Privado';
  }
  if (visibilidade == Visibilidade.amigos) {
    return 'Só amigos';
  }
  return 'Público';
}

class Registo {
  final int id;
  final String autorEmail;
  final String disciplina;
  final String titulo;
  final String texto;
  final DateTime data;
  final Visibilidade visibilidade;
  final String? projeto;
  final List<String> tags;
  final String? local;
  final String? morada;
  final String? audio;
  final String? video;
  final int fotos;
  final List<Comentario> comentarios;
  final bool oculto;

  const Registo({
    required this.id,
    required this.autorEmail,
    required this.disciplina,
    required this.titulo,
    required this.texto,
    required this.data,
    this.visibilidade = Visibilidade.privado,
    this.projeto,
    this.tags = const [],
    this.local,
    this.morada,
    this.audio,
    this.video,
    this.fotos = 0,
    this.comentarios = const [],
    this.oculto = false,
  });

  bool get temFoto => fotos > 0;

  Registo copyWith({
    String? projeto,
    List<Comentario>? comentarios,
    bool? oculto,
  }) {
    return Registo(
      id: id,
      autorEmail: autorEmail,
      disciplina: disciplina,
      titulo: titulo,
      texto: texto,
      data: data,
      visibilidade: visibilidade,
      projeto: projeto ?? this.projeto,
      tags: tags,
      local: local,
      morada: morada,
      audio: audio,
      video: video,
      fotos: fotos,
      comentarios: comentarios ?? this.comentarios,
      oculto: oculto ?? this.oculto,
    );
  }
}

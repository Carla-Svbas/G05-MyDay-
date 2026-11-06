class Definicoes {
  final bool localizacao;
  final bool microfone;
  final bool lembretes;
  final int hora;
  final int minuto;

  const Definicoes({
    this.localizacao = true,
    this.microfone = false,
    this.lembretes = true,
    this.hora = 21,
    this.minuto = 0,
  });

  Definicoes copyWith({
    bool? localizacao,
    bool? microfone,
    bool? lembretes,
    int? hora,
    int? minuto,
  }) {
    return Definicoes(
      localizacao: localizacao ?? this.localizacao,
      microfone: microfone ?? this.microfone,
      lembretes: lembretes ?? this.lembretes,
      hora: hora ?? this.hora,
      minuto: minuto ?? this.minuto,
    );
  }
}

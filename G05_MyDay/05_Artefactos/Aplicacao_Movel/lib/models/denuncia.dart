class Denuncia {
  final int id;
  final int registoId;
  final int? comentarioId;
  final String motivo;
  final int pessoas;

  const Denuncia({
    required this.id,
    required this.registoId,
    required this.motivo,
    this.comentarioId,
    this.pessoas = 1,
  });

  Denuncia copyWith({int? pessoas}) {
    return Denuncia(
      id: id,
      registoId: registoId,
      comentarioId: comentarioId,
      motivo: motivo,
      pessoas: pessoas ?? this.pessoas,
    );
  }
}

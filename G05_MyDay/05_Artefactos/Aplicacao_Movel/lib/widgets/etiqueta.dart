import 'package:flutter/material.dart';

import '../models/registo.dart';

class Etiqueta extends StatelessWidget {
  final String texto;
  final Color fundo;
  final Color cor;
  final IconData? icone;

  const Etiqueta({
    super.key,
    required this.texto,
    required this.fundo,
    required this.cor,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) Icon(icone, size: 12, color: cor),
          if (icone != null) const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor),
          ),
        ],
      ),
    );
  }
}

Etiqueta etiquetaDisciplina(String disciplina) {
  if (disciplina == 'Matemática Discreta') {
    return Etiqueta(
        texto: disciplina, fundo: const Color(0xFFE3E8FF), cor: const Color(0xFF2A3FC2));
  }
  if (disciplina == 'Bases de Dados') {
    return Etiqueta(
        texto: disciplina, fundo: const Color(0xFFDCEFE4), cor: const Color(0xFF1D6B40));
  }
  if (disciplina == 'Prog. Móvel') {
    return Etiqueta(
        texto: disciplina, fundo: const Color(0xFFF3E3F6), cor: const Color(0xFF7B2C8A));
  }
  if (disciplina == 'Redes') {
    return Etiqueta(
        texto: disciplina, fundo: const Color(0xFFF6E8D8), cor: const Color(0xFF8A4B12));
  }
  return Etiqueta(texto: disciplina, fundo: const Color(0xFFE8EAEF), cor: const Color(0xFF3A4150));
}

Etiqueta etiquetaVisibilidade(Visibilidade visibilidade, {bool comIcone = true}) {
  final texto = nomeVisibilidade(visibilidade);
  if (visibilidade == Visibilidade.privado) {
    return Etiqueta(
      texto: texto,
      fundo: const Color(0xFFE8EAEF),
      cor: const Color(0xFF3A4150),
      icone: comIcone ? Icons.lock_outline : null,
    );
  }
  if (visibilidade == Visibilidade.amigos) {
    return Etiqueta(
      texto: texto,
      fundo: const Color(0xFFFFF1D6),
      cor: const Color(0xFF7A4A00),
      icone: comIcone ? Icons.people_outline : null,
    );
  }
  return Etiqueta(
    texto: texto,
    fundo: const Color(0xFFE3E8FF),
    cor: const Color(0xFF2A3FC2),
    icone: comIcone ? Icons.public : null,
  );
}

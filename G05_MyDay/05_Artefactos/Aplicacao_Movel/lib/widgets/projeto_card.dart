import 'package:flutter/material.dart';

import '../models/projeto.dart';
import '../models/registo.dart';
import 'cores.dart';

const coresProjeto = [
  Color(0xFFDDE3F5),
  Color(0xFF3D5AFE),
  Color(0xFFF3E6D3),
  Color(0xFFDCEFE4),
  Color(0xFFF3E3F6),
  Color(0xFFE8EAEF),
];

class ProjetoCard extends StatelessWidget {
  final Projeto projeto;
  final String info;
  final VoidCallback aoTocar;

  const ProjetoCard({
    super.key,
    required this.projeto,
    required this.info,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Cores.branco,
          border: Border.all(color: Cores.linha),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 88,
              width: double.infinity,
              color: coresProjeto[projeto.cor % coresProjeto.length],
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(8),
              child: _etiqueta(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projeto.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
                  ),
                  const SizedBox(height: 4),
                  Text(info, style: const TextStyle(fontSize: 12, color: Cores.texto2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etiqueta() {
    var fundo = Colors.white;
    var cor = Cores.textoCorpo;
    if (projeto.visibilidade == Visibilidade.amigos) {
      fundo = const Color(0xFFFFF1D6);
      cor = const Color(0xFF7A4A00);
    } else if (projeto.visibilidade == Visibilidade.publico) {
      cor = Cores.azulEscuro;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(6)),
      child: Text(
        nomeVisibilidade(projeto.visibilidade),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor),
      ),
    );
  }
}

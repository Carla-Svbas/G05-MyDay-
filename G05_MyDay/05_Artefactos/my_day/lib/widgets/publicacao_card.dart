import 'package:flutter/material.dart';

import '../models/registo.dart';
import 'avatar.dart';
import 'cores.dart';
import 'etiqueta.dart';
import 'formatar_data.dart';

class PublicacaoCard extends StatelessWidget {
  final Registo registo;
  final String autor;
  final bool favorito;
  final Color corFoto;
  final VoidCallback aoTocar;
  final VoidCallback aoFavoritar;

  const PublicacaoCard({
    super.key,
    required this.registo,
    required this.autor,
    required this.favorito,
    required this.corFoto,
    required this.aoTocar,
    required this.aoFavoritar,
  });

  @override
  Widget build(BuildContext context) {
    final corFavorito = favorito ? Cores.primaria : Cores.textoCorpo;
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Cores.branco,
          border: Border.all(color: Cores.linha),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(nome: autor, tamanho: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        autor,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
                      ),
                      Text(
                        '${registo.disciplina} · ${haQuantoTempo(registo.data)}',
                        style: const TextStyle(fontSize: 12, color: Cores.texto2),
                      ),
                    ],
                  ),
                ),
                etiquetaVisibilidade(registo.visibilidade, comIcone: false),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registo.titulo,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Cores.tinta),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        registo.texto,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, height: 1.4, color: Cores.texto2),
                      ),
                    ],
                  ),
                ),
                if (registo.temFoto) const SizedBox(width: 12),
                if (registo.temFoto)
                  Container(
                    width: 72,
                    height: 72,
                    decoration:
                        BoxDecoration(color: corFoto, borderRadius: BorderRadius.circular(12)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 18, color: Cores.textoCorpo),
                const SizedBox(width: 6),
                Text('${registo.comentarios.length}',
                    style: const TextStyle(fontSize: 13, color: Cores.textoCorpo)),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: aoFavoritar,
                  child: Row(
                    children: [
                      Icon(favorito ? Icons.bookmark : Icons.bookmark_border,
                          size: 18, color: corFavorito),
                      const SizedBox(width: 6),
                      Text(
                        favorito ? 'Favorito' : 'Favoritar',
                        style: TextStyle(fontSize: 13, color: corFavorito),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

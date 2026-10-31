import 'package:flutter/material.dart';

import 'cores.dart';

class DenunciaCard extends StatelessWidget {
  final String titulo;
  final String autor;
  final String motivo;
  final int pessoas;
  final Color corFoto;
  final VoidCallback aoOcultar;
  final VoidCallback aoAvisar;
  final VoidCallback aoIgnorar;

  const DenunciaCard({
    super.key,
    required this.titulo,
    required this.autor,
    required this.motivo,
    required this.pessoas,
    required this.corFoto,
    required this.aoOcultar,
    required this.aoAvisar,
    required this.aoIgnorar,
  });

  @override
  Widget build(BuildContext context) {
    final textoPessoas = pessoas == 1 ? '1 denúncia' : '$pessoas denúncias';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.branco,
        border: Border.all(color: Cores.linha),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: corFoto, borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
                    ),
                    Text('por $autor · $textoPessoas',
                        style: const TextStyle(fontSize: 12, color: Cores.texto2)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE7E7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        motivo,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFA61B1B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _botao('Ocultar', aoOcultar, true)),
              const SizedBox(width: 6),
              Expanded(child: _botao('Avisar autor', aoAvisar, false)),
              const SizedBox(width: 6),
              Expanded(child: _botao('Ignorar', aoIgnorar, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botao(String texto, VoidCallback aoTocar, bool escuro) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: escuro ? Cores.tinta : Cores.branco,
          border: escuro ? null : Border.all(color: const Color(0xFFDCE0E7)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: escuro ? Colors.white : Cores.tinta,
          ),
        ),
      ),
    );
  }
}

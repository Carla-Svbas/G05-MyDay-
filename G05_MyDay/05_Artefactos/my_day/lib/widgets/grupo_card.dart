import 'package:flutter/material.dart';

import '../models/grupo_estudo.dart';
import 'avatar.dart';
import 'cores.dart';

class GrupoCard extends StatelessWidget {
  final GrupoEstudo grupo;
  final VoidCallback aoTocar;

  const GrupoCard({super.key, required this.grupo, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Cores.branco,
          border: Border.all(color: Cores.linha),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 36,
              child: Stack(
                children: [
                  Positioned(left: 0, child: _circulo(Avatar(nome: grupo.membros[0]))),
                  Positioned(left: 26, child: _circulo(Avatar(nome: grupo.membros[1]))),
                  Positioned(left: 52, child: _circulo(_mais())),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grupo.nome,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
                  ),
                  Text(
                    '${grupo.membros.length} membros · ${grupo.registosPartilhados} registos partilhados',
                    style: const TextStyle(fontSize: 12, color: Cores.texto2),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Cores.texto2),
          ],
        ),
      ),
    );
  }

  Widget _mais() {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Color(0xFFE3E8FF), shape: BoxShape.circle),
      child: Text(
        '+${grupo.membros.length - 2}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Cores.azulEscuro),
      ),
    );
  }

  Widget _circulo(Widget filho) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: filho,
    );
  }
}

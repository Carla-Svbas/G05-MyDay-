import 'package:flutter/material.dart';

import 'cores.dart';

class BarraNavegacao extends StatelessWidget {
  final int separador;
  final ValueChanged<int> aoMudar;
  final VoidCallback aoCarregarMais;

  const BarraNavegacao({
    super.key,
    required this.separador,
    required this.aoMudar,
    required this.aoCarregarMais,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(top: BorderSide(color: Cores.linha)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _item(0, Icons.menu_book_outlined, 'Diário'),
          _item(1, Icons.folder_outlined, 'Projetos'),
          GestureDetector(
            onTap: aoCarregarMais,
            child: Container(
              width: 56,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Cores.primaria,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          _item(2, Icons.people_outline, 'Comunidade'),
          _item(3, Icons.person_outline, 'Perfil'),
        ],
      ),
    );
  }

  Widget _item(int numero, IconData icone, String texto) {
    final cor = numero == separador ? Cores.primaria : Cores.texto2;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => aoMudar(numero),
        child: Column(
          children: [
            Icon(icone, size: 22, color: cor),
            const SizedBox(height: 4),
            Text(texto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor)),
          ],
        ),
      ),
    );
  }
}

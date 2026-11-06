import 'package:flutter/material.dart';

import 'cores.dart';

class BotaoFiltro extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;

  const BotaoFiltro({
    super.key,
    required this.texto,
    required this.ativo,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? Cores.tinta : Cores.branco,
          border: Border.all(color: ativo ? Cores.tinta : const Color(0xFFD9DCE4)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ativo ? Colors.white : Cores.textoCorpo,
          ),
        ),
      ),
    );
  }
}

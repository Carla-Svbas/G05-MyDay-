import 'package:flutter/material.dart';

import 'cores.dart';

class Seletor extends StatelessWidget {
  final List<String> opcoes;
  final int escolhida;
  final ValueChanged<int> aoMudar;
  final bool escuro;

  const Seletor({
    super.key,
    required this.opcoes,
    required this.escolhida,
    required this.aoMudar,
    this.escuro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: escuro ? Cores.branco : Cores.cinzaClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++) Expanded(child: _opcao(i)),
        ],
      ),
    );
  }

  Widget _opcao(int i) {
    final ativa = i == escolhida;
    var fundo = Colors.transparent;
    var corTexto = Cores.textoCorpo;
    if (ativa && escuro) {
      fundo = Cores.tinta;
      corTexto = Colors.white;
    } else if (ativa) {
      fundo = Cores.branco;
      corTexto = Cores.tinta;
    }
    return GestureDetector(
      onTap: () => aoMudar(i),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          opcoes[i],
          style: TextStyle(
            fontSize: 14,
            fontWeight: ativa ? FontWeight.w700 : FontWeight.w600,
            color: corTexto,
          ),
        ),
      ),
    );
  }
}

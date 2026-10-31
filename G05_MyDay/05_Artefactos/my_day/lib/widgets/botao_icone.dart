import 'package:flutter/material.dart';

import 'cores.dart';

/// Botão pequeno só com um ícone (voltar, pesquisa, notificações, editar, mudar de mês…).
/// Pode ser redondo ([circular]) ou de cantos arredondados ([raio]),
/// com ou sem borda, e com um ponto vermelho de aviso ([temPonto]).
class BotaoIcone extends StatelessWidget {
  final IconData icone;
  final VoidCallback aoTocar;
  final double tamanho;
  final double tamanhoIcone;
  final double raio;
  final bool circular;
  final bool comBorda;
  final bool temPonto;
  final Color fundo;

  const BotaoIcone({
    super.key,
    required this.icone,
    required this.aoTocar,
    this.tamanho = 44,
    this.tamanhoIcone = 24,
    this.raio = 12,
    this.circular = false,
    this.comBorda = true,
    this.temPonto = false,
    this.fundo = Cores.branco,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          color: fundo,
          border: comBorda ? Border.all(color: Cores.linha) : null,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(raio),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icone, size: tamanhoIcone, color: Cores.tinta)),
            if (temPonto)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFE5484D), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

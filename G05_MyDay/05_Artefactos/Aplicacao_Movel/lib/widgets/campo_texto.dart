import 'package:flutter/material.dart';

import 'cores.dart';

/// Campo de texto com ícone, usado nos ecrãs Entrar e Criar conta.
/// O ícone pode ser um ícone do Flutter ([icone]) ou uma imagem local ([imagem]).
class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String dica;
  final bool escondido;
  final IconData? icone;
  final String? imagem;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.dica,
    this.escondido = false,
    this.icone,
    this.imagem,
  });

  @override
  Widget build(BuildContext context) {
    Widget simbolo = const SizedBox(width: 16);
    if (imagem != null) {
      simbolo = Image.asset(imagem!, width: 16, height: 16);
    } else if (icone != null) {
      simbolo = Icon(icone, size: 16, color: Cores.cinzaTexto);
    }
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Cores.campoFundo,
        border: Border.all(color: Cores.campoBorda),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          simbolo,
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: escondido,
              style: const TextStyle(fontSize: 15, color: Cores.tinta),
              decoration: InputDecoration.collapsed(
                hintText: dica,
                hintStyle: const TextStyle(fontSize: 15, color: Cores.cinzaTexto),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

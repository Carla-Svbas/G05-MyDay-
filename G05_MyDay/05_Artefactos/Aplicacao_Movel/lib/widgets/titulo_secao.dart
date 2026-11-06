import 'package:flutter/material.dart';

import 'cores.dart';

class TituloSecao extends StatelessWidget {
  final String texto;

  const TituloSecao({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Cores.texto2,
      ),
    );
  }
}

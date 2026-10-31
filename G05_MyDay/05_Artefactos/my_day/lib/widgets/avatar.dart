import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String nome;
  final double tamanho;

  const Avatar({super.key, required this.nome, this.tamanho = 32});

  String get iniciais {
    final palavras = nome.trim().split(' ');
    if (palavras.length == 1) {
      return palavras.first[0].toUpperCase();
    }
    return (palavras.first[0] + palavras.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fundos = [
      const Color(0xFFFFE2CC),
      const Color(0xFFDCEFE4),
      const Color(0xFFE3E8FF),
      const Color(0xFFF3E3F6),
    ];
    final cores = [
      const Color(0xFF8A3A00),
      const Color(0xFF1D6B40),
      const Color(0xFF2A3FC2),
      const Color(0xFF7B2C8A),
    ];
    final i = nome.length % 4;
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fundos[i], shape: BoxShape.circle),
      child: Text(
        iniciais,
        style: TextStyle(fontSize: tamanho * 0.38, fontWeight: FontWeight.w700, color: cores[i]),
      ),
    );
  }
}

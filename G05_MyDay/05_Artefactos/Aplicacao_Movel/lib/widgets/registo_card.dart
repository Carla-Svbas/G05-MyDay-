import 'package:flutter/material.dart';

import '../models/registo.dart';
import 'cores.dart';
import 'etiqueta.dart';
import 'formatar_data.dart';

class RegistoCard extends StatelessWidget {
  final Registo registo;
  final VoidCallback aoTocar;

  const RegistoCard({super.key, required this.registo, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Cores.branco,
          border: Border.all(color: Cores.linha),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _conteudo()),
            if (registo.temFoto) const SizedBox(width: 12),
            if (registo.temFoto) _foto(),
          ],
        ),
      ),
    );
  }

  Widget _conteudo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            etiquetaDisciplina(registo.disciplina),
            const SizedBox(width: 7),
            Text(hora(registo.data), style: const TextStyle(fontSize: 12, color: Cores.texto2)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          registo.titulo,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Cores.tinta),
        ),
        const SizedBox(height: 7),
        Text(
          registo.texto,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, height: 1.6, color: Cores.textoCorpo),
        ),
        const SizedBox(height: 16),
        _rodape(),
      ],
    );
  }

  Widget _rodape() {
    IconData? icone;
    var texto = '';
    if (registo.local != null) {
      icone = Icons.location_on_outlined;
      texto = registo.local!;
    } else if (registo.audio != null) {
      icone = Icons.mic_none;
      texto = 'Áudio · ${registo.audio}';
    } else if (registo.video != null) {
      icone = Icons.videocam_outlined;
      texto = 'Vídeo · ${registo.video}';
    }
    return Row(
      children: [
        if (icone != null) Icon(icone, size: 16, color: Cores.texto2),
        if (icone != null) const SizedBox(width: 10),
        Text(texto, style: const TextStyle(fontSize: 12, color: Cores.texto2)),
        const Spacer(),
        etiquetaVisibilidade(registo.visibilidade),
      ],
    );
  }

  Widget _foto() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Cores.fotoVazia,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.photo_camera_outlined, color: Cores.texto2),
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../models/comentario.dart';
import '../models/registo.dart';
import '../widgets/avatar.dart';
import '../widgets/botao_icone.dart';
import '../widgets/cores.dart';
import '../widgets/etiqueta.dart';
import '../widgets/formatar_data.dart';

class RegistoPage extends StatefulWidget {
  final Controladores app;
  final int registoId;
  final ValueChanged<String>? verNoMapa;

  const RegistoPage({
    super.key,
    required this.app,
    required this.registoId,
    this.verNoMapa,
  });

  @override
  State<RegistoPage> createState() => _RegistoPageState();
}

class _RegistoPageState extends State<RegistoPage> {
  final comentarioController = TextEditingController();
  final focoComentario = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.app.registos.addListener(atualizar);
  }

  void atualizar() => setState(() {});

  @override
  void dispose() {
    widget.app.registos.removeListener(atualizar);
    comentarioController.dispose();
    focoComentario.dispose();
    super.dispose();
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void enviarComentario() {
    final erro = widget.app.registos.comentar(
      widget.registoId,
      widget.app.sessao.utilizador,
      comentarioController.text,
    );
    if (erro != null) {
      mostrarMensagem(erro);
      return;
    }
    comentarioController.clear();
    focoComentario.unfocus();
  }

  void verNoMapa(Registo registo) {
    final local = widget.app.registos.localDe(registo);
    if (local == null || widget.verNoMapa == null) {
      mostrarMensagem('Este local não está no mapa.');
      return;
    }
    Navigator.pop(context);
    widget.verNoMapa!(local.nome);
  }

  void maisOpcoes(Registo registo) {
    final dono = widget.app.registos.eDono(registo, widget.app.sessao.utilizador);
    showModalBottomSheet(
      context: context,
      builder: (contextoFolha) {
        return SafeArea(
          child: dono
              ? ListTile(
                  leading: const Icon(Icons.delete_outline, color: Cores.perigo),
                  title: const Text('Apagar registo', style: TextStyle(color: Cores.perigo)),
                  onTap: () {
                    Navigator.pop(contextoFolha);
                    confirmarApagar();
                  },
                )
              : ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Denunciar registo'),
                  onTap: () {
                    Navigator.pop(contextoFolha);
                    escolherMotivo();
                  },
                ),
        );
      },
    );
  }

  void escolherMotivo() {
    final motivos = ['Conteúdo copiado', 'Linguagem ofensiva', 'Spam', 'Outro motivo'];
    showModalBottomSheet(
      context: context,
      builder: (contextoFolha) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Porque queres denunciar?',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              for (final motivo in motivos)
                ListTile(
                  title: Text(motivo),
                  onTap: () {
                    Navigator.pop(contextoFolha);
                    widget.app.registos.denunciar(widget.registoId, motivo);
                    mostrarMensagem('Denúncia enviada. Obrigado!');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void confirmarApagar() {
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: const Text('Apagar registo?'),
          content: const Text('Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contextoJanela), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(contextoJanela);
                widget.app.registos.apagar(widget.registoId);
                mostrarMensagem('Registo apagado.');
                Navigator.pop(context);
              },
              child: const Text('Apagar', style: TextStyle(color: Cores.perigo)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final registo = widget.app.registos.procurar(widget.registoId);
    if (registo == null) {
      return const Scaffold(body: Center(child: Text('Este registo já não existe.')));
    }
    return Scaffold(
      backgroundColor: Cores.branco,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                fotografia(registo),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: conteudo(registo),
                ),
              ],
            ),
          ),
          caixaComentario(),
        ],
      ),
    );
  }

  Widget fotografia(Registo registo) {
    return Container(
      height: 230,
      color: Cores.fotoVazia,
      child: Stack(
        children: [
          const Center(child: Icon(Icons.photo_camera_outlined, size: 36, color: Cores.texto2)),
          Positioned(
              top: 48,
              left: 16,
              child: BotaoIcone(
                  icone: Icons.chevron_left,
                  circular: true,
                  comBorda: false,
                  aoTocar: () => Navigator.pop(context))),
          Positioned(
              top: 48,
              right: 16,
              child: BotaoIcone(
                  icone: Icons.more_horiz,
                  circular: true,
                  comBorda: false,
                  aoTocar: () => maisOpcoes(registo))),
        ],
      ),
    );
  }

  Widget conteudo(Registo registo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            etiquetaDisciplina(registo.disciplina),
            const SizedBox(width: 4),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child:
                    registo.projeto == null ? const SizedBox() : etiquetaProjeto(registo.projeto!),
              ),
            ),
            const SizedBox(width: 8),
            etiquetaVisibilidade(registo.visibilidade),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          registo.titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Cores.tinta),
        ),
        const SizedBox(height: 4),
        Text(dataCompleta(registo.data), style: const TextStyle(fontSize: 13, color: Cores.texto2)),
        const SizedBox(height: 14),
        Text(registo.texto,
            style: const TextStyle(fontSize: 15, height: 1.6, color: Cores.textoCorpo)),
        if (registo.local != null) const SizedBox(height: 20),
        if (registo.local != null) caixaLocal(registo),
        if (registo.tags.isNotEmpty) const SizedBox(height: 12),
        if (registo.tags.isNotEmpty)
          Text(
            registo.tags.map((t) => '#$t').join('  '),
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Cores.primaria),
          ),
        const SizedBox(height: 12),
        acoes(registo),
        const SizedBox(height: 12),
        const Text(
          'Comentários',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
        ),
        const SizedBox(height: 12),
        if (registo.comentarios.isEmpty)
          const Text('Ainda não há comentários.', style: TextStyle(color: Cores.texto2)),
        for (final comentario in registo.comentarios) linhaComentario(comentario),
      ],
    );
  }

  Widget etiquetaProjeto(String projeto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Cores.fundo,
        border: Border.all(color: Cores.linha),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Projeto · $projeto',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Cores.textoCorpo),
      ),
    );
  }

  Widget caixaLocal(Registo registo) {
    var texto = registo.local!;
    if (registo.morada != null) {
      texto = '$texto, ${registo.morada!.split(',').last.trim()}';
    }
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Cores.fundo, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18, color: Cores.tinta),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Cores.tinta)),
          ),
          GestureDetector(
            onTap: () => verNoMapa(registo),
            child: const Text(
              'Ver no mapa',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Cores.primaria),
            ),
          ),
        ],
      ),
    );
  }

  Widget acoes(Registo registo) {
    final favorito = widget.app.registos.favorito(registo.id);
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: Cores.linha)),
      ),
      child: Row(
        children: [
          acao(
            favorito ? Icons.bookmark : Icons.bookmark_border,
            favorito ? 'Favorito' : 'Favoritar',
            favorito ? Cores.primaria : Cores.textoCorpo,
            () => widget.app.registos.alternarFavorito(registo.id),
          ),
          acao(Icons.chat_bubble_outline, '${registo.comentarios.length}', Cores.textoCorpo,
              () => focoComentario.requestFocus()),
          acao(Icons.file_download_outlined, 'PDF', Cores.textoCorpo,
              () => mostrarMensagem('PDF exportado (simulação).')),
        ],
      ),
    );
  }

  Widget acao(IconData icone, String texto, Color cor, VoidCallback aoTocar) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: aoTocar,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 20, color: cor),
            const SizedBox(width: 6),
            Text(texto, style: TextStyle(fontSize: 14, color: cor)),
          ],
        ),
      ),
    );
  }

  Widget linhaComentario(Comentario comentario) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(nome: comentario.autor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comentario.autor,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: Cores.tinta),
                    ),
                    Text(
                      ' · ${haQuantoTempo(comentario.data)}',
                      style: const TextStyle(fontSize: 13, color: Cores.texto2),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(comentario.texto,
                    style: const TextStyle(fontSize: 14, color: Cores.textoCorpo)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget caixaComentario() {
    final convidado = widget.app.sessao.utilizador == null;
    var dica = 'Escreve um comentário…';
    if (convidado) {
      dica = 'Entra com uma conta para comentar';
    }
    return Container(
      height: 85,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(top: BorderSide(color: Cores.linha)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Cores.fundo,
                border: Border.all(color: const Color(0xFFDBDEE5)),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: comentarioController,
                focusNode: focoComentario,
                enabled: !convidado,
                onSubmitted: (texto) => enviarComentario(),
                decoration: InputDecoration.collapsed(
                  hintText: dica,
                  hintStyle: const TextStyle(color: Cores.cinzaDescricao),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: enviarComentario,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: Cores.primaria, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

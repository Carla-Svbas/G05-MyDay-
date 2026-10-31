import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../models/registo.dart';
import '../widgets/cores.dart';
import '../widgets/seletor.dart';

class NovoRegistoPage extends StatefulWidget {
  final Controladores app;
  final String? projetoInicial;

  const NovoRegistoPage({super.key, required this.app, this.projetoInicial});

  @override
  State<NovoRegistoPage> createState() => _NovoRegistoPageState();
}

class _NovoRegistoPageState extends State<NovoRegistoPage> {
  final tituloController = TextEditingController();
  final textoController = TextEditingController();
  int fotos = 0;
  bool video = false;
  bool audio = false;
  bool local = false;
  String? disciplina;
  String? projeto;
  List<String> tags = [];
  Visibilidade visibilidade = Visibilidade.privado;

  @override
  void initState() {
    super.initState();
    projeto = widget.projetoInicial;
  }

  @override
  void dispose() {
    tituloController.dispose();
    textoController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void guardar() {
    final erro = widget.app.registos.criarRegisto(
      autor: widget.app.sessao.utilizador!,
      titulo: tituloController.text,
      texto: textoController.text,
      disciplina: disciplina,
      projeto: projeto,
      tags: tags,
      visibilidade: visibilidade,
      comLocal: local,
      fotos: fotos,
      comAudio: audio,
      comVideo: video,
    );
    if (erro != null) {
      mostrarMensagem(erro);
      return;
    }
    mostrarMensagem('Registo guardado.');
    Navigator.pop(context);
  }

  void adicionarFoto() {
    setState(() => fotos++);
    mostrarMensagem('Fotografia adicionada (simulação: a câmara não é usada).');
  }

  void escolherDisciplina() {
    escolherOpcao('Disciplina', widget.app.registos.disciplinas, (opcao) {
      setState(() => disciplina = opcao);
    });
  }

  void escolherProjeto() {
    final opcoes = ['Nenhum', ...widget.app.projetos.nomesProjetos(widget.app.sessao.utilizador)];
    escolherOpcao('Projeto', opcoes, (opcao) {
      setState(() {
        if (opcao == 'Nenhum') {
          projeto = null;
        } else {
          projeto = opcao;
        }
      });
    });
  }

  void escolherOpcao(String titulo, List<String> opcoes, ValueChanged<String> aoEscolher) {
    showModalBottomSheet(
      context: context,
      builder: (contextoFolha) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child:
                    Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              for (final opcao in opcoes)
                ListTile(
                  title: Text(opcao),
                  onTap: () {
                    Navigator.pop(contextoFolha);
                    aoEscolher(opcao);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void editarTags() {
    final tagsController = TextEditingController(text: tags.map((t) => '#$t').join(' '));
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: const Text('Tags'),
          content: TextField(
            controller: tagsController,
            autofocus: true,
            decoration: const InputDecoration(hintText: '#iterações #cálculo'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contextoJanela), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                setState(() => tags = widget.app.registos.lerTags(tagsController.text));
                Navigator.pop(contextoJanela);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.branco,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 0),
            child: barraTopo(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                campoTitulo(),
                const SizedBox(height: 14),
                campoTexto(),
                const SizedBox(height: 14),
                fotografias(),
                const SizedBox(height: 14),
                botoesMultimedia(),
                if (local) const SizedBox(height: 14),
                if (local) cartaoLocal(),
                const SizedBox(height: 14),
                Container(height: 1, color: Cores.linha),
                linhaOpcao('Disciplina', disciplina ?? 'Escolher', escolherDisciplina),
                linhaOpcao('Projeto', projeto ?? 'Nenhum', escolherProjeto),
                linhaOpcao('Tags', tags.isEmpty ? 'Adicionar' : tags.map((t) => '#$t').join(' '),
                    editarTags),
                const SizedBox(height: 14),
                escolherVisibilidade(),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(Icons.cloud_outlined, size: 15, color: Cores.texto2),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Guardado neste dispositivo. Sincroniza quando houver ligação.',
                        style: TextStyle(fontSize: 12, color: Cores.texto2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget barraTopo() {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(fontSize: 15, color: Cores.texto2)),
            ),
          ),
          const Text(
            'Novo registo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Cores.tinta),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Cores.primaria,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget campoTitulo() {
    return TextField(
      controller: tituloController,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Cores.tinta),
      decoration: const InputDecoration.collapsed(
        hintText: 'Título do registo',
        hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Cores.cinzaTexto),
      ),
    );
  }

  Widget campoTexto() {
    return TextField(
      controller: textoController,
      minLines: 3,
      maxLines: null,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Cores.textoCorpo),
      decoration: const InputDecoration.collapsed(
        hintText: 'O que aprendeste hoje?',
        hintStyle: TextStyle(fontSize: 15, color: Cores.cinzaTexto),
      ),
    );
  }

  Widget fotografias() {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < fotos; i++)
            GestureDetector(
              onTap: () => setState(() => fotos--),
              child: Container(
                width: 96,
                margin: const EdgeInsets.only(right: 10),
                decoration:
                    BoxDecoration(color: Cores.fotoVazia, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.photo_camera_outlined, color: Cores.texto2),
              ),
            ),
          GestureDetector(
            onTap: adicionarFoto,
            child: Container(
              width: 96,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBCFD8), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Cores.texto2),
            ),
          ),
        ],
      ),
    );
  }

  Widget botoesMultimedia() {
    return Row(
      children: [
        Expanded(
            child: botaoMultimedia(Icons.photo_camera_outlined, 'Foto', fotos > 0, adicionarFoto)),
        const SizedBox(width: 8),
        Expanded(
          child: botaoMultimedia(Icons.videocam_outlined, 'Vídeo', video, () {
            setState(() => video = !video);
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: botaoMultimedia(Icons.mic_none, 'Áudio', audio, () {
            setState(() => audio = !audio);
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: botaoMultimedia(Icons.location_on_outlined, 'Local', local, () {
            setState(() => local = !local);
          }),
        ),
      ],
    );
  }

  Widget botaoMultimedia(IconData icone, String texto, bool ativo, VoidCallback aoTocar) {
    final cor = ativo ? Cores.azulEscuro : Cores.tinta;
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: ativo ? Cores.azulClaro : Cores.fundo,
          border: Border.all(color: ativo ? Cores.primaria : Cores.linha),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 20, color: cor),
            const SizedBox(height: 4),
            Text(texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor)),
          ],
        ),
      ),
    );
  }

  Widget cartaoLocal() {
    final atual = widget.app.registos.localAtual;
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Cores.fundo, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: Cores.primaria, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.location_on_outlined, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(atual.nome,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta)),
                Text(atual.morada, style: const TextStyle(fontSize: 12, color: Cores.texto2)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => local = false),
            icon: const Icon(Icons.close, size: 18, color: Cores.texto2),
          ),
        ],
      ),
    );
  }

  Widget linhaOpcao(String texto, String valor, VoidCallback aoTocar) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: Container(
        height: 52,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Cores.linha))),
        child: Row(
          children: [
            Text(texto,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Cores.tinta)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                valor,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Cores.texto2),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Cores.texto2),
          ],
        ),
      ),
    );
  }

  Widget escolherVisibilidade() {
    final explicacoes = [
      'Só tu vês este registo. Os registos são privados por defeito.',
      'Só os teus amigos veem este registo.',
      'Todos veem este registo, incluindo convidados.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visibilidade',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Cores.tinta)),
        const SizedBox(height: 8),
        Seletor(
          opcoes: const ['Privado', 'Só amigos', 'Público'],
          escolhida: visibilidade.index,
          aoMudar: (numero) => setState(() => visibilidade = Visibilidade.values[numero]),
        ),
        const SizedBox(height: 8),
        Text(explicacoes[visibilidade.index],
            style: const TextStyle(fontSize: 12, color: Cores.texto2)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../models/projeto.dart';
import '../models/registo.dart';
import '../widgets/botao_icone.dart';
import '../widgets/cores.dart';
import '../widgets/formatar_data.dart';
import '../widgets/seletor.dart';
import '../widgets/titulo_secao.dart';
import 'novo_registo_page.dart';
import 'registo_page.dart';

class ProjetoPage extends StatefulWidget {
  final Controladores app;
  final int projetoId;

  const ProjetoPage({super.key, required this.app, required this.projetoId});

  @override
  State<ProjetoPage> createState() => _ProjetoPageState();
}

class _ProjetoPageState extends State<ProjetoPage> {
  @override
  void initState() {
    super.initState();
    widget.app.projetos.addListener(atualizar);
    widget.app.registos.addListener(atualizar);
  }

  void atualizar() => setState(() {});

  @override
  void dispose() {
    widget.app.projetos.removeListener(atualizar);
    widget.app.registos.removeListener(atualizar);
    super.dispose();
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  bool eDono(Projeto projeto) {
    final utilizador = widget.app.sessao.utilizador;
    return utilizador != null && projeto.donoEmail == utilizador.email;
  }

  void editar(Projeto projeto) {
    final nomeController = TextEditingController(text: projeto.nome);
    final descricaoController = TextEditingController(text: projeto.descricao);
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: const Text('Editar projeto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
              TextField(
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contextoJanela), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(contextoJanela);
                final erro = widget.app.projetos.editar(
                  projeto.id,
                  nomeController.text,
                  descricaoController.text,
                );
                if (erro != null) {
                  mostrarMensagem(erro);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void mudarVisibilidade(Projeto projeto, int numero) {
    if (!eDono(projeto)) {
      mostrarMensagem('Só o dono do projeto pode mudar a visibilidade.');
      return;
    }
    widget.app.projetos.mudarVisibilidade(projeto.id, Visibilidade.values[numero]);
  }

  void mostrarQrCode(Projeto projeto) {
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: Text(projeto.nome, textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2, size: 160),
              Text('Mostra este código para partilhar o projeto (simulação).',
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(contextoJanela), child: const Text('Fechar')),
          ],
        );
      },
    );
  }

  void novoRegisto(Projeto projeto) {
    if (widget.app.sessao.utilizador == null) {
      mostrarMensagem('Cria uma conta para fazeres registos.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovoRegistoPage(app: widget.app, projetoInicial: projeto.nome),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projeto = widget.app.projetos.procurar(widget.projetoId);
    if (projeto == null) {
      return const Scaffold(body: Center(child: Text('Este projeto já não existe.')));
    }
    final utilizador = widget.app.sessao.utilizador;
    final registos = widget.app.projetos.registosDoProjeto(projeto, utilizador);
    final disciplinas = widget.app.projetos.numeroDisciplinas(projeto, utilizador);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        children: [
          Row(
            children: [
              BotaoIcone(icone: Icons.chevron_left, aoTocar: () => Navigator.pop(context)),
              const Spacer(),
              if (eDono(projeto))
                BotaoIcone(icone: Icons.edit_outlined, aoTocar: () => editar(projeto)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            projeto.nome,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Cores.tinta),
          ),
          if (projeto.descricao.isNotEmpty) const SizedBox(height: 6),
          if (projeto.descricao.isNotEmpty)
            Text(projeto.descricao,
                style: const TextStyle(fontSize: 15, height: 1.4, color: Cores.texto2)),
          const SizedBox(height: 4),
          Text(
            '${registos.length} registos · $disciplinas disciplinas · desde ${diaMesCurto(projeto.criadoEm)}',
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Cores.textoCorpo),
          ),
          const SizedBox(height: 16),
          cartaoVisibilidade(projeto),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: botaoAcao(Icons.file_download_outlined, 'Exportar PDF', false,
                    () => mostrarMensagem('PDF do projeto exportado (simulação).')),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      botaoAcao(Icons.qr_code_2, 'QR Code', false, () => mostrarQrCode(projeto))),
              const SizedBox(width: 8),
              Expanded(child: botaoAcao(Icons.add, 'Registo', true, () => novoRegisto(projeto))),
            ],
          ),
          const SizedBox(height: 20),
          const TituloSecao(texto: 'Linha temporal'),
          const SizedBox(height: 16),
          if (registos.isEmpty) const Text('Ainda não há registos neste projeto.'),
          for (var i = 0; i < registos.length; i++)
            pontoLinhaTemporal(registos[i], i == registos.length - 1),
        ],
      ),
    );
  }

  Widget cartaoVisibilidade(Projeto projeto) {
    final explicacoes = [
      'Só tu vês este projeto e os seus registos.',
      'Só os teus amigos veem este projeto.',
      'Visível para todos, incluindo convidados. As localizações aparecem aproximadas.',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.branco,
        border: Border.all(color: Cores.linha),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quem pode ver este projeto',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Cores.tinta),
          ),
          const SizedBox(height: 10),
          Seletor(
            opcoes: const ['Privado', 'Só amigos', 'Público'],
            escolhida: projeto.visibilidade.index,
            aoMudar: (numero) => mudarVisibilidade(projeto, numero),
          ),
          const SizedBox(height: 11),
          Text(explicacoes[projeto.visibilidade.index],
              style: const TextStyle(fontSize: 12, color: Cores.texto2)),
        ],
      ),
    );
  }

  Widget botaoAcao(IconData icone, String texto, bool azul, VoidCallback aoTocar) {
    final cor = azul ? Colors.white : Cores.tinta;
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: azul ? Cores.primaria : Cores.branco,
          border: azul ? null : Border.all(color: Cores.linha),
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

  String textoMultimedia(Registo registo) {
    if (registo.video != null) {
      return 'Vídeo · ${registo.video}';
    }
    if (registo.audio != null) {
      return 'Áudio · ${registo.audio}';
    }
    if (registo.fotos == 1) {
      return 'Texto · 1 fotografia';
    }
    if (registo.fotos > 1) {
      return 'Texto · ${registo.fotos} fotografias';
    }
    return 'Texto';
  }

  Widget pontoLinhaTemporal(Registo registo, bool ultimo) {
    final dias = diasDesde(registo.data);
    var data = diaMesCurto(registo.data);
    if (dias <= 1) {
      data = '${hojeOntem(registo.data)} · ${hora(registo.data)}';
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegistoPage(app: widget.app, registoId: registo.id)),
        );
      },
      child: SizedBox(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 14,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dias < 7 ? Cores.primaria : const Color(0xFFC3C8D3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!ultimo) Expanded(child: Container(width: 2, color: const Color(0xFFD5D9E1))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data, style: const TextStyle(fontSize: 12, color: Cores.texto2)),
                  Text(
                    registo.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
                  ),
                  Text(textoMultimedia(registo),
                      style: const TextStyle(fontSize: 13, color: Cores.texto2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

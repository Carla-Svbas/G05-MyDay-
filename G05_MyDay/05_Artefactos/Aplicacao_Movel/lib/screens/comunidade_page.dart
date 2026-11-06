import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/botao_filtro.dart';
import '../widgets/cores.dart';
import '../widgets/grupo_card.dart';
import '../widgets/publicacao_card.dart';
import 'novo_registo_page.dart';
import 'registo_page.dart';

class ComunidadePage extends StatefulWidget {
  final Controladores app;

  const ComunidadePage({super.key, required this.app});

  @override
  State<ComunidadePage> createState() => _ComunidadePageState();
}

class _ComunidadePageState extends State<ComunidadePage> {
  int separador = 0;
  String pesquisa = '';

  @override
  void initState() {
    super.initState();
    widget.app.comunidade.addListener(atualizar);
    widget.app.registos.addListener(atualizar);
  }

  void atualizar() => setState(() {});

  @override
  void dispose() {
    widget.app.comunidade.removeListener(atualizar);
    widget.app.registos.removeListener(atualizar);
    super.dispose();
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void participarDesafio() {
    if (widget.app.sessao.utilizador == null) {
      mostrarMensagem('Cria uma conta para participares no desafio.');
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NovoRegistoPage(app: widget.app)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Comunidade',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Cores.tinta),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  mostrarMensagem('As mensagens vão ser desenvolvidas numa próxima versão.'),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Cores.branco,
                  border: Border.all(color: Cores.linha),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble_outline, size: 22, color: Cores.tinta),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Cores.branco,
            border: Border.all(color: const Color(0xFFD8DCE4)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: Cores.texto2),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (texto) => setState(() => pesquisa = texto),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Pessoas, projetos, tags, conteúdos…',
                    hintStyle: TextStyle(color: Cores.cinzaDescricao),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            BotaoFiltro(
                texto: 'A seguir',
                ativo: separador == 0,
                aoTocar: () => setState(() => separador = 0)),
            BotaoFiltro(
                texto: 'Descobrir',
                ativo: separador == 1,
                aoTocar: () => setState(() => separador = 1)),
            BotaoFiltro(
                texto: 'Grupos',
                ativo: separador == 2,
                aoTocar: () => setState(() => separador = 2)),
          ],
        ),
        const SizedBox(height: 14),
        ...conteudo(),
      ],
    );
  }

  List<Widget> conteudo() {
    if (separador == 2) {
      return [
        for (final grupo in widget.app.comunidade.grupos)
          GrupoCard(
            grupo: grupo,
            aoTocar: () =>
                mostrarMensagem('Os grupos de estudo vão ser desenvolvidos numa próxima versão.'),
          ),
      ];
    }
    final utilizador = widget.app.sessao.utilizador;
    final registos = widget.app.comunidade.feed(utilizador, separador == 0, pesquisa);
    final coresFoto = [const Color(0xFFF3E6D3), const Color(0xFFDDE3F5)];
    return [
      cartaoDesafio(),
      const SizedBox(height: 14),
      if (registos.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('Não há registos para mostrar.', textAlign: TextAlign.center),
        ),
      for (var i = 0; i < registos.length; i++)
        PublicacaoCard(
          registo: registos[i],
          autor: widget.app.comunidade.nomeAutor(registos[i].autorEmail),
          favorito: widget.app.registos.favorito(registos[i].id),
          corFoto: coresFoto[i % 2],
          aoFavoritar: () => widget.app.registos.alternarFavorito(registos[i].id),
          aoTocar: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RegistoPage(app: widget.app, registoId: registos[i].id)),
            );
          },
        ),
    ];
  }

  Widget cartaoDesafio() {
    return GestureDetector(
      onTap: participarDesafio,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Cores.azulClaro,
          border: Border.all(color: Cores.primaria),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(color: Cores.primaria, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.emoji_events_outlined, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desafio da semana',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Cores.azulEscuro),
                  ),
                  Text(
                    widget.app.comunidade.desafio,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

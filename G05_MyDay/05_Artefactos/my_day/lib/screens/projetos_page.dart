import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../models/projeto.dart';
import '../models/registo.dart';
import '../widgets/botao_filtro.dart';
import '../widgets/cores.dart';
import '../widgets/formatar_data.dart';
import '../widgets/grupo_card.dart';
import '../widgets/projeto_card.dart';
import '../widgets/titulo_secao.dart';
import 'projeto_page.dart';

class ProjetosPage extends StatefulWidget {
  final Controladores app;

  const ProjetosPage({super.key, required this.app});

  @override
  State<ProjetosPage> createState() => _ProjetosPageState();
}

class _ProjetosPageState extends State<ProjetosPage> {
  Visibilidade? filtro;

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

  void novoProjeto() {
    final utilizador = widget.app.sessao.utilizador;
    if (utilizador == null) {
      mostrarMensagem('Cria uma conta para teres projetos.');
      return;
    }
    final nomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: const Text('Novo projeto'),
          content: TextField(
            controller: nomeController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nome do projeto'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contextoJanela), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(contextoJanela);
                final erro = widget.app.projetos.criar(utilizador, nomeController.text);
                mostrarMensagem(erro ?? 'Projeto criado.');
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  String infoProjeto(Projeto projeto) {
    final registos = widget.app.projetos.registosDoProjeto(projeto, widget.app.sessao.utilizador);
    if (registos.isEmpty) {
      return 'Sem registos';
    }
    final dias = diasDesde(registos.first.data);
    var quando = '$dias dias';
    if (dias == 0) {
      quando = 'hoje';
    } else if (dias == 1) {
      quando = 'ontem';
    }
    return '${registos.length} registos · $quando';
  }

  @override
  Widget build(BuildContext context) {
    final utilizador = widget.app.sessao.utilizador;
    final projetos = widget.app.projetos.projetosDe(utilizador, filtro: filtro);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Projetos',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Cores.tinta),
              ),
            ),
            ElevatedButton.icon(
              onPressed: novoProjeto,
              icon: const Icon(Icons.add, size: 18),
              label:
                  const Text('Novo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Cores.primaria,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            BotaoFiltro(
                texto: 'Todos',
                ativo: filtro == null,
                aoTocar: () => setState(() => filtro = null)),
            BotaoFiltro(
              texto: 'Privados',
              ativo: filtro == Visibilidade.privado,
              aoTocar: () => setState(() => filtro = Visibilidade.privado),
            ),
            BotaoFiltro(
              texto: 'Só amigos',
              ativo: filtro == Visibilidade.amigos,
              aoTocar: () => setState(() => filtro = Visibilidade.amigos),
            ),
            BotaoFiltro(
              texto: 'Públicos',
              ativo: filtro == Visibilidade.publico,
              aoTocar: () => setState(() => filtro = Visibilidade.publico),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (projetos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('Não há projetos para mostrar.', textAlign: TextAlign.center),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projetos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 169 / 149,
          ),
          itemBuilder: (context, index) {
            final projeto = projetos[index];
            return ProjetoCard(
              projeto: projeto,
              info: infoProjeto(projeto),
              aoTocar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjetoPage(app: widget.app, projetoId: projeto.id),
                  ),
                );
              },
            );
          },
        ),
        if (utilizador != null) const SizedBox(height: 22),
        if (utilizador != null) const TituloSecao(texto: 'Grupos de estudo'),
        if (utilizador != null) const SizedBox(height: 16),
        if (utilizador != null)
          for (final grupo in widget.app.projetos.grupos)
            GrupoCard(
              grupo: grupo,
              aoTocar: () =>
                  mostrarMensagem('Os grupos de estudo vão ser desenvolvidos numa próxima versão.'),
            ),
      ],
    );
  }
}

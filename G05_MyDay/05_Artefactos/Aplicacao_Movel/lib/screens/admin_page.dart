import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/cores.dart';
import '../widgets/denuncia_card.dart';
import '../widgets/formatar_data.dart';
import '../widgets/titulo_secao.dart';

class AdminPage extends StatefulWidget {
  final Controladores app;

  const AdminPage({super.key, required this.app});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int separador = 0;

  @override
  void initState() {
    super.initState();
    widget.app.admin.addListener(atualizar);
    widget.app.registos.addListener(atualizar);
  }

  void atualizar() => setState(() {});

  @override
  void dispose() {
    widget.app.admin.removeListener(atualizar);
    widget.app.registos.removeListener(atualizar);
    super.dispose();
  }

  void sair() {
    widget.app.sessao.sair();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (rota) => false);
  }

  void novoDesafio() {
    final desafioController = TextEditingController();
    showDialog(
      context: context,
      builder: (contextoJanela) {
        return AlertDialog(
          title: const Text('Novo desafio da semana'),
          content: TextField(controller: desafioController, autofocus: true, maxLines: 2),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contextoJanela), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(contextoJanela);
                final erro = widget.app.admin
                    .publicarDesafio(widget.app.sessao.utilizador!, desafioController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(erro ?? 'Desafio publicado na Comunidade.')),
                );
              },
              child: const Text('Publicar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          cabecalho(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: conteudo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget cabecalho() {
    final separadores = [
      'Denúncias · ${widget.app.admin.denuncias.length}',
      'Estatísticas',
      'Tags',
      'Desafios',
    ];
    return Container(
      color: Cores.tinta,
      padding: const EdgeInsets.fromLTRB(20, 60, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Image.asset('assets/icons/logo.png', width: 22, height: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Administração',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: sair,
                  child: const Text('Sair',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFC9CEDA))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < separadores.length; i++) botaoSeparador(separadores[i], i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget botaoSeparador(String texto, int numero) {
    final ativo = numero == separador;
    return GestureDetector(
      onTap: () => setState(() => separador = numero),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? Colors.white : Colors.transparent,
          border: Border.all(color: ativo ? Colors.white : const Color(0xFF353C4B)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ativo ? Cores.tinta : const Color(0xFFC9CEDA),
          ),
        ),
      ),
    );
  }

  List<Widget> conteudo() {
    if (separador == 1) {
      return [
        Row(
          children: [
            Expanded(child: numero('${widget.app.admin.utilizadores}', 'utilizadores', false)),
            const SizedBox(width: 8),
            Expanded(
                child: numero('${widget.app.admin.totalRegistos}', 'registos no total', false)),
            const SizedBox(width: 8),
            Expanded(child: numero('${widget.app.admin.registosHoje}', 'registos hoje', false)),
          ],
        ),
      ];
    }
    if (separador == 2) {
      final tags = widget.app.admin.tags();
      final linhas = <Widget>[];
      tags.forEach((tag, quantos) {
        linhas.add(ListTile(title: Text('#$tag'), trailing: Text('$quantos registos')));
      });
      return linhas;
    }
    if (separador == 3) {
      return [
        const TituloSecao(texto: 'Desafio atual'),
        const SizedBox(height: 10),
        Text(widget.app.admin.desafio,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ElevatedButton(onPressed: novoDesafio, child: const Text('Publicar novo desafio')),
      ];
    }
    return denuncias();
  }

  List<Widget> denuncias() {
    final admin = widget.app.admin;
    final utilizador = widget.app.sessao.utilizador!;
    final lista = admin.denuncias;
    final coresFoto = [const Color(0xFFDDE3F5), const Color(0xFFF3E6D3)];
    return [
      Row(
        children: [
          Expanded(child: numero('${lista.length}', 'denúncias abertas', true)),
          const SizedBox(width: 8),
          Expanded(child: numero('${admin.utilizadores}', 'utilizadores ativos', false)),
          const SizedBox(width: 8),
          Expanded(child: numero('${admin.registosHoje}', 'registos hoje', false)),
        ],
      ),
      const SizedBox(height: 18),
      const TituloSecao(texto: 'Fila de moderação'),
      const SizedBox(height: 14),
      if (lista.isEmpty) const Text('Não há denúncias por tratar.'),
      for (var i = 0; i < lista.length; i++)
        DenunciaCard(
          titulo: admin.tituloDenuncia(lista[i]),
          autor: admin.autorDenuncia(lista[i]),
          motivo: lista[i].motivo,
          pessoas: lista[i].pessoas,
          corFoto: coresFoto[i % 2],
          aoOcultar: () => admin.ocultar(lista[i], utilizador),
          aoAvisar: () => admin.avisarAutor(lista[i], utilizador),
          aoIgnorar: () => admin.ignorar(lista[i], utilizador),
        ),
      const SizedBox(height: 4),
      const TituloSecao(texto: 'Registo de ações'),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(
          color: Cores.branco,
          border: Border.all(color: Cores.linha),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            for (final acao in admin.acoes)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Text('${acao.admin}  ',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    Expanded(child: Text(acao.descricao, style: const TextStyle(fontSize: 13))),
                    Text(hora(acao.data),
                        style: const TextStyle(fontSize: 13, color: Cores.texto2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }

  Widget numero(String valor, String texto, bool vermelho) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
      decoration: BoxDecoration(
        color: Cores.branco,
        border: Border.all(color: Cores.linha),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: vermelho ? Cores.perigo : Cores.tinta,
            ),
          ),
          Text(texto, style: const TextStyle(fontSize: 12, color: Cores.texto2)),
        ],
      ),
    );
  }
}

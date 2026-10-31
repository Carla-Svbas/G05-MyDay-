import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/cores.dart';
import '../widgets/formatar_data.dart';
import 'registo_page.dart';

class CalendarioPage extends StatefulWidget {
  final Controladores app;
  final Widget seletor;
  final ValueChanged<String> verNoMapa;

  const CalendarioPage({
    super.key,
    required this.app,
    required this.seletor,
    required this.verNoMapa,
  });

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime mes = DateTime(DateTime.now().year, DateTime.now().month);

  void mudarMes(int quantos) {
    setState(() {
      mes = DateTime(mes.year, mes.month + quantos);
    });
  }

  void abrirDia(DateTime dia) {
    final registos = widget.app.registos.registosNoDia(widget.app.sessao.utilizador, dia);
    if (registos.isEmpty) {
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (contextoFolha) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(dataLonga(dia),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              for (final registo in registos)
                ListTile(
                  title: Text(registo.titulo),
                  subtitle: Text('${registo.disciplina} · ${hora(registo.data)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(contextoFolha);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistoPage(
                          app: widget.app,
                          registoId: registo.id,
                          verNoMapa: widget.verNoMapa,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      children: [
        widget.seletor,
        const SizedBox(height: 14),
        calendario(),
        const SizedBox(height: 14),
        estatisticas(),
        const SizedBox(height: 14),
        disciplinas(),
      ],
    );
  }

  Widget calendario() {
    final letras = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final diasDoMes = DateTime(mes.year, mes.month + 1, 0).day;
    final vazios = mes.weekday - 1;
    final celulas = <Widget>[];
    for (var i = 0; i < vazios; i++) {
      celulas.add(const SizedBox());
    }
    for (var d = 1; d <= diasDoMes; d++) {
      celulas.add(dia(DateTime(mes.year, mes.month, d)));
    }
    return cartao(
      Column(
        children: [
          Row(
            children: [
              botaoMes(Icons.chevron_left, () => mudarMes(-1)),
              Expanded(
                child: Text(
                  mesAno(mes),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800, color: Cores.tinta),
                ),
              ),
              botaoMes(Icons.chevron_right, () => mudarMes(1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final letra in letras)
                Expanded(
                  child: Text(
                    letra,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: Cores.texto2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 46 / 42,
            children: celulas,
          ),
        ],
      ),
    );
  }

  Widget botaoMes(IconData icone, VoidCallback aoTocar) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Cores.fundo, borderRadius: BorderRadius.circular(10)),
        child: Icon(icone, size: 18, color: Cores.tinta),
      ),
    );
  }

  Widget dia(DateTime data) {
    final hoje = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final eHoje = data == hoje;
    final futuro = data.isAfter(hoje);
    final temRegistos =
        widget.app.registos.registosNoDia(widget.app.sessao.utilizador, data).isNotEmpty;
    var corNumero = Cores.tinta;
    if (eHoje) {
      corNumero = Colors.white;
    } else if (futuro) {
      corNumero = Cores.cinzaDescricao;
    }
    return GestureDetector(
      onTap: () => abrirDia(data),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: eHoje ? Cores.primaria : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '${data.day}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: corNumero),
            ),
          ),
          const SizedBox(height: 3),
          if (temRegistos)
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: eHoje ? Cores.primaria : Cores.laranja,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget estatisticas() {
    final utilizador = widget.app.sessao.utilizador;
    return Row(
      children: [
        Expanded(
            child: numero(
                '${widget.app.registos.registosDaSemana(utilizador)}', 'registos esta semana')),
        const SizedBox(width: 8),
        Expanded(child: numero('${widget.app.registos.diasSeguidos(utilizador)}', 'dias seguidos')),
        const SizedBox(width: 8),
        Expanded(child: numero('${widget.app.registos.total(utilizador)}', 'registos no total')),
      ],
    );
  }

  Widget numero(String valor, String texto) {
    return cartao(
      SizedBox(
        height: 62,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Cores.tinta)),
            Text(texto, style: const TextStyle(fontSize: 12, color: Cores.texto2)),
          ],
        ),
      ),
    );
  }

  Widget disciplinas() {
    final contagem = widget.app.registos.porDisciplina(widget.app.sessao.utilizador);
    var maximo = 1;
    if (contagem.isNotEmpty) {
      maximo = contagem.values.first;
    }
    final linhas = <Widget>[];
    contagem.forEach((disciplina, quantos) {
      linhas.add(Row(
        children: [
          Expanded(
            child: Text(
              disciplina,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Cores.tinta),
            ),
          ),
          Text('$quantos registos', style: const TextStyle(fontSize: 13, color: Cores.texto2)),
        ],
      ));
      linhas.add(const SizedBox(height: 4));
      linhas.add(LinearProgressIndicator(
        value: quantos / maximo,
        minHeight: 8,
        backgroundColor: Cores.cinzaClaro,
        color: Cores.primaria,
        borderRadius: BorderRadius.circular(4),
      ));
      linhas.add(const SizedBox(height: 10));
    });
    return cartao(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disciplinas mais trabalhadas',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Cores.tinta),
          ),
          const SizedBox(height: 10),
          ...linhas,
        ],
      ),
    );
  }

  Widget cartao(Widget filho) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.branco,
        border: Border.all(color: Cores.linha),
        borderRadius: BorderRadius.circular(16),
      ),
      child: filho,
    );
  }
}

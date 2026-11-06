import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../models/registo.dart';
import '../widgets/botao_icone.dart';
import '../widgets/cores.dart';
import '../widgets/formatar_data.dart';
import '../widgets/registo_card.dart';
import '../widgets/titulo_secao.dart';
import 'registo_page.dart';

class ListaPage extends StatelessWidget {
  final Controladores app;
  final Widget seletor;
  final ValueChanged<String> verNoMapa;

  const ListaPage({
    super.key,
    required this.app,
    required this.seletor,
    required this.verNoMapa,
  });

  @override
  Widget build(BuildContext context) {
    final utilizador = app.sessao.utilizador;
    final registos = app.registos.registosDe(utilizador);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      children: [
        cabecalho(context),
        const SizedBox(height: 15),
        if (utilizador != null) cartaoDiasSeguidos(),
        if (utilizador != null) const SizedBox(height: 16),
        seletor,
        const SizedBox(height: 16),
        if (registos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text(
              'Ainda não há registos para mostrar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Cores.texto2),
            ),
          ),
        ...listaPorDia(context, registos),
      ],
    );
  }

  Widget cabecalho(BuildContext context) {
    final utilizador = app.sessao.utilizador;
    var nome = 'convidado';
    if (utilizador != null) {
      nome = utilizador.primeiroNome;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dataLonga(DateTime.now()),
                  style: const TextStyle(fontSize: 13, color: Cores.texto2)),
              Text(
                'Olá, $nome!',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Cores.tinta),
              ),
            ],
          ),
        ),
        botaoAviso(context, Icons.search, 'A pesquisa estará disponível em breve.', false),
        const SizedBox(width: 8),
        botaoAviso(context, Icons.notifications_none, 'Não tens notificações novas.', true),
      ],
    );
  }

  Widget botaoAviso(BuildContext context, IconData icone, String mensagem, bool temPonto) {
    return BotaoIcone(
      icone: icone,
      tamanhoIcone: 22,
      raio: 14,
      temPonto: temPonto,
      aoTocar: () =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem))),
    );
  }

  Widget cartaoDiasSeguidos() {
    final utilizador = app.sessao.utilizador;
    final dias = app.registos.diasSeguidos(utilizador);
    final daSemana = app.registos.registosDaSemana(utilizador);
    final semana = app.registos.semana(utilizador);
    final letras = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(color: Cores.tinta, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(color: Cores.laranja, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.local_fire_department_outlined, size: 26, color: Cores.tinta),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '$dias dias\nseguidos',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '$daSemana registos esta\nsemana',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFBEC2CE)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: semana[i] ? Cores.laranja : Cores.textoCorpo,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                letras[i],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB2B8C3),
                                ),
                              ),
                            ],
                          ),
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

  List<Widget> listaPorDia(BuildContext context, List<Registo> registos) {
    final lista = <Widget>[];
    var ultimoDia = '';
    for (final registo in registos) {
      final dia = hojeOntem(registo.data);
      if (dia != ultimoDia) {
        lista.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          child: TituloSecao(texto: dia),
        ));
        ultimoDia = dia;
      }
      lista.add(RegistoCard(
        registo: registo,
        aoTocar: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RegistoPage(app: app, registoId: registo.id, verNoMapa: verNoMapa),
            ),
          );
        },
      ));
    }
    return lista;
  }
}

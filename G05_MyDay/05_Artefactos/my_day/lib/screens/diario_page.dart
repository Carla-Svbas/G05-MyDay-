import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/seletor.dart';
import 'calendario_page.dart';
import 'lista_page.dart';
import 'mapa_page.dart';

class DiarioPage extends StatefulWidget {
  final Controladores app;

  const DiarioPage({super.key, required this.app});

  @override
  State<DiarioPage> createState() => _DiarioPageState();
}

class _DiarioPageState extends State<DiarioPage> {
  int vista = 0;
  String? localEscolhido;

  @override
  void initState() {
    super.initState();
    widget.app.registos.addListener(atualizar);
  }

  void atualizar() => setState(() {});

  @override
  void dispose() {
    widget.app.registos.removeListener(atualizar);
    super.dispose();
  }

  void verNoMapa(String local) {
    setState(() {
      vista = 1;
      localEscolhido = local;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seletor = Seletor(
      opcoes: const ['Lista', 'Mapa', 'Calendário'],
      escolhida: vista,
      escuro: vista == 1,
      aoMudar: (numero) => setState(() => vista = numero),
    );
    if (vista == 1) {
      return MapaPage(
        key: ValueKey(localEscolhido),
        app: widget.app,
        seletor: seletor,
        localInicial: localEscolhido,
        verNoMapa: verNoMapa,
      );
    }
    if (vista == 2) {
      return CalendarioPage(app: widget.app, seletor: seletor, verNoMapa: verNoMapa);
    }
    return ListaPage(app: widget.app, seletor: seletor, verNoMapa: verNoMapa);
  }
}

import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/barra_navegacao.dart';
import 'comunidade_page.dart';
import 'diario_page.dart';
import 'novo_registo_page.dart';
import 'perfil_page.dart';
import 'projetos_page.dart';

class InicioPage extends StatefulWidget {
  final Controladores app;

  const InicioPage({super.key, required this.app});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int separador = 0;

  void novoRegisto() {
    if (widget.app.sessao.convidado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cria uma conta para fazeres registos.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NovoRegistoPage(app: widget.app)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: separador,
        children: [
          DiarioPage(app: widget.app),
          ProjetosPage(app: widget.app),
          ComunidadePage(app: widget.app),
          PerfilPage(app: widget.app),
        ],
      ),
      bottomNavigationBar: BarraNavegacao(
        separador: separador,
        aoMudar: (numero) => setState(() => separador = numero),
        aoCarregarMais: novoRegisto,
      ),
    );
  }
}

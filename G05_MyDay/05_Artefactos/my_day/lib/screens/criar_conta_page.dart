import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/cores.dart';
import 'inicio_page.dart';

class CriarContaPage extends StatefulWidget {
  final Controladores app;
  final String emailInicial;

  const CriarContaPage({super.key, required this.app, this.emailInicial = ''});

  @override
  State<CriarContaPage> createState() => _CriarContaPageState();
}

class _CriarContaPageState extends State<CriarContaPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cursoController = TextEditingController();
  final palavraPasseController = TextEditingController();
  final confirmarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = widget.emailInicial;
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    cursoController.dispose();
    palavraPasseController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  void criarConta() {
    final ok = widget.app.sessao.criarConta(
      nome: nomeController.text,
      email: emailController.text,
      palavraPasse: palavraPasseController.text,
      confirmarPalavraPasse: confirmarController.text,
      curso: cursoController.text,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.app.sessao.erro!)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada. Bem-vindo ao MyDay!')),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => InicioPage(app: widget.app)),
      (rota) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.branco,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 54, 28, 24),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Cores.branco,
                    border: Border.all(color: Cores.linha),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chevron_left, color: Cores.tinta),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/icons/logo.png',
                width: 32,
                height: 32,
                color: Cores.primaria,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Criar conta',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Cores.tinta),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cria a tua conta para começares a registar o que aprendes.',
            style: TextStyle(fontSize: 14, height: 1.4, color: Cores.cinzaDescricao),
          ),
          const SizedBox(height: 20),
          etiquetaCampo('Nome'),
          campo(nomeController, Icons.person_outline, 'O teu nome', false),
          const SizedBox(height: 12),
          etiquetaCampo('Email'),
          campo(emailController, Icons.mail_outline, 'nome@escola.pt', false),
          const SizedBox(height: 12),
          etiquetaCampo('Curso'),
          campo(cursoController, Icons.school_outlined, 'Ex.: Eng. Informática · IADE', false),
          const SizedBox(height: 12),
          etiquetaCampo('Palavra-passe'),
          campo(palavraPasseController, Icons.lock_outline, 'Pelo menos 6 caracteres', true),
          const SizedBox(height: 12),
          etiquetaCampo('Confirmar palavra-passe'),
          campo(confirmarController, Icons.lock_outline, 'Repete a palavra-passe', true),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: criarConta,
              style: ElevatedButton.styleFrom(
                backgroundColor: Cores.primaria,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Criar conta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Já tens conta? Entrar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Cores.primaria),
            ),
          ),
        ],
      ),
    );
  }

  Widget etiquetaCampo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Cores.tinta),
      ),
    );
  }

  Widget campo(TextEditingController controller, IconData icone, String dica, bool escondido) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Cores.campoFundo,
        border: Border.all(color: Cores.campoBorda),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, size: 16, color: Cores.cinzaTexto),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: escondido,
              style: const TextStyle(fontSize: 15, color: Cores.tinta),
              decoration: InputDecoration.collapsed(
                hintText: dica,
                hintStyle: const TextStyle(fontSize: 15, color: Cores.cinzaTexto),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

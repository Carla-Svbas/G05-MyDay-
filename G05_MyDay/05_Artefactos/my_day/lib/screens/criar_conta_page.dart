import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/campo_texto.dart';
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

  Future<void> criarConta() async {
    final ok = await widget.app.sessao.criarContaOnline(
      nome: nomeController.text,
      email: emailController.text,
      palavraPasse: palavraPasseController.text,
      confirmarPalavraPasse: confirmarController.text,
      curso: cursoController.text,
    );
    if (ok) {
      try {
        await carregarDadosDaApi(widget.app);
      } catch (_) {}
    }
    if (!mounted) {
      return;
    }
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
          CampoTexto(
            controller: nomeController,
            icone: Icons.person_outline,
            dica: 'O teu nome',
          ),
          const SizedBox(height: 12),
          etiquetaCampo('Email'),
          CampoTexto(
            controller: emailController,
            icone: Icons.mail_outline,
            dica: 'nome@escola.pt',
          ),
          const SizedBox(height: 12),
          etiquetaCampo('Curso'),
          CampoTexto(
            controller: cursoController,
            icone: Icons.school_outlined,
            dica: 'Ex.: Eng. Informática · IADE',
          ),
          const SizedBox(height: 12),
          etiquetaCampo('Palavra-passe'),
          CampoTexto(
            controller: palavraPasseController,
            icone: Icons.lock_outline,
            dica: 'Pelo menos 6 caracteres',
            escondido: true,
          ),
          const SizedBox(height: 12),
          etiquetaCampo('Confirmar palavra-passe'),
          CampoTexto(
            controller: confirmarController,
            icone: Icons.lock_outline,
            dica: 'Repete a palavra-passe',
            escondido: true,
          ),
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
}

import 'package:flutter/material.dart';

import '../controllers/controladores.dart';
import '../widgets/cores.dart';
import 'admin_page.dart';
import 'criar_conta_page.dart';
import 'inicio_page.dart';

class LoginPage extends StatefulWidget {
  final Controladores app;

  const LoginPage({super.key, required this.app});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final palavraPasseController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    palavraPasseController.dispose();
    super.dispose();
  }

  void entrar() {
    final ok = widget.app.sessao.entrar(emailController.text, palavraPasseController.text);
    if (ok) {
      abrirApp();
      return;
    }
    mostrarMensagem(widget.app.sessao.erro!);
    if (widget.app.sessao.semConta) {
      criarConta();
    }
  }

  void criarConta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriarContaPage(app: widget.app, emailInicial: emailController.text),
      ),
    );
  }

  void entrarComoConvidado() {
    widget.app.sessao.entrarComoConvidado();
    abrirApp();
  }

  void abrirApp() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Widget pagina = InicioPage(app: widget.app);
    if (widget.app.sessao.admin) {
      pagina = AdminPage(app: widget.app);
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => pagina));
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.loginFundo,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Cores.loginFundo, Cores.loginMeio, Cores.loginFundo],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 104,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/login_illustration.jpg',
                    width: 240,
                    height: 156,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(top: 52, left: 24, right: 24, child: barraTopo()),
            Positioned(top: 270, left: 0, right: 0, bottom: 0, child: cartao()),
          ],
        ),
      ),
    );
  }

  Widget barraTopo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset('assets/icons/logo.png', width: 24, height: 24),
        ),
        GestureDetector(
          onTap: () => mostrarMensagem('Por agora só está disponível Português (PT).'),
          child: Row(
            children: [
              Image.asset('assets/icons/globe.png', width: 16, height: 16),
              const SizedBox(width: 6),
              const Text(
                'Português (PT)',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE0E7FF)),
              ),
              const SizedBox(width: 6),
              Image.asset('assets/icons/chevron.png', width: 14, height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget cartao() {
    return Container(
      decoration: const BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Cores.campoBorda,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'MyDay',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Cores.tinta),
            ),
            const SizedBox(height: 4),
            const Text(
              'O diário do teu percurso de estudante. Regista o que aprendes, '
              'organiza em projetos e partilha só o que quiseres.',
              style: TextStyle(fontSize: 14, height: 1.4, color: Cores.cinzaDescricao),
            ),
            const SizedBox(height: 20),
            etiquetaCampo('Email'),
            const SizedBox(height: 6),
            campo(emailController, 'assets/icons/mail.png', 'nome@escola.pt', false),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                etiquetaCampo('Palavra-passe'),
                GestureDetector(
                  onTap: () => mostrarMensagem(
                      'Vais receber um email com instruções para recuperar a palavra-passe.'),
                  child: const Text(
                    'Esqueci-me da palavra-passe',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Cores.primaria),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            campo(palavraPasseController, 'assets/icons/lock.png', '••••••••', true),
            const SizedBox(height: 20),
            botao('Entrar', entrar, Cores.primaria, Colors.white),
            const SizedBox(height: 10),
            botao('Criar conta', criarConta, const Color(0xFFF0F2FF), Cores.primaria),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 1, color: Cores.campoBorda)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('ou', style: TextStyle(fontSize: 12, color: Cores.cinzaTexto)),
                ),
                Expanded(child: Container(height: 1, color: Cores.campoBorda)),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: entrarComoConvidado,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Continuar como convidado',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Cores.primaria),
                  ),
                  const SizedBox(width: 6),
                  Image.asset('assets/icons/arrow_right.png', width: 14, height: 14),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Como convidado vês conteúdo público, mas não podes seguir, '
              'comentar nem criar registos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.4, color: Cores.cinzaTexto),
            ),
          ],
        ),
      ),
    );
  }

  Widget etiquetaCampo(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Cores.tinta),
    );
  }

  Widget campo(TextEditingController controller, String icone, String dica, bool escondido) {
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
          Image.asset(icone, width: 16, height: 16),
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

  Widget botao(String texto, VoidCallback aoCarregar, Color fundo, Color corTexto) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: aoCarregar,
        style: ElevatedButton.styleFrom(
          backgroundColor: fundo,
          foregroundColor: corTexto,
          elevation: 0,
          side: fundo == Cores.primaria ? null : const BorderSide(color: Color(0xFFC7D0FF)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

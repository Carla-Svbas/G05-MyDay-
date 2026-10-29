import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../controllers/entry_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/project_controller.dart';
import '../theme/app_theme.dart';
import 'main_view.dart';
import 'admin_view.dart';
import 'widgets/login_header.dart';

/// View do ecrã "01 · Entrar".
/// Só desenha o ecrã e passa as ações ao AuthController.
class LoginView extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController; // Passado ao ecrã seguinte
  final ProjectController projectController; // Passado ao ecrã seguinte
  final CommunityController communityController; // Passado ao ecrã seguinte
  final ProfileController profileController; // Passado ao ecrã seguinte
  final AdminController adminController; // Passado ao ecrã seguinte

  const LoginView({
    super.key,
    required this.authController,
    required this.entryController,
    required this.projectController,
    required this.communityController,
    required this.profileController,
    required this.adminController,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Guardam o texto escrito nos campos.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------- Ações (a View pede, o Controller decide) ----------

  void _onLoginPressed() {
    final bool ok = widget.authController.login(
      _emailController.text,
      _passwordController.text,
    );
    ok ? _goToNextScreen() : _showMessage(widget.authController.errorMessage!);
  }

  void _onCreateAccountPressed() {
    final bool ok = widget.authController.register(
      _emailController.text,
      _passwordController.text,
    );
    ok ? _goToNextScreen() : _showMessage(widget.authController.errorMessage!);
  }

  void _onGuestPressed() {
    widget.authController.continueAsGuest();
    _goToNextScreen();
  }

  /// Administradores vão para a Administração; os restantes para o Diário.
  void _goToNextScreen() {
    final Widget next = widget.authController.isAdmin
        ? AdminView(
            authController: widget.authController,
            adminController: widget.adminController,
          )
        : MainView(
            authController: widget.authController,
            entryController: widget.entryController,
            projectController: widget.projectController,
            communityController: widget.communityController,
            profileController: widget.profileController,
          );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => next),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------- Desenho do ecrã ----------

  @override
  Widget build(BuildContext context) {
    // Ícones da barra de estado brancos, porque o fundo é escuro.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.loginBackground,
        body: Container(
          // Fundo em degradé (escuro → azul-escuro → escuro)
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.loginBackground,
                AppColors.loginGradientMiddle,
                AppColors.loginBackground,
              ],
              stops: [0, 0.45, 1],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(top: 0, left: 0, right: 0, child: LoginHeader()),
              Positioned(top: 52, left: 24, right: 24, child: _buildTopBar()),
              Positioned(top: 270, left: 0, right: 0, bottom: 0, child: _buildCard()),
            ],
          ),
        ),
      ),
    );
  }

  /// Logótipo à esquerda e seletor de idioma à direita.
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Image.asset('assets/icons/logo.png', width: 24, height: 24),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showMessage('Por agora só está disponível Português (PT).'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Image.asset('assets/icons/globe.png', width: 16, height: 16),
                const SizedBox(width: 6),
                const Text(
                  'Português (PT)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.loginLanguageText,
                  ),
                ),
                const SizedBox(width: 6),
                Image.asset('assets/icons/chevron.png', width: 14, height: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Cartão branco com o formulário.
  Widget _buildCard() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Color(0x40000000), offset: Offset(0, -8), blurRadius: 16),
        ],
      ),
      // Permite deslizar quando o teclado aparece ou o ecrã é pequeno.
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pega do cartão
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.fieldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'MyDay',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.56,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'O diário do teu percurso de estudante. Regista o que aprendes, '
              'organiza em projetos e partilha só o que quiseres.',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.descriptionGrey,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel('Email'),
            const SizedBox(height: 6),
            _buildField(
              controller: _emailController,
              icon: 'assets/icons/mail.png',
              hint: 'nome@escola.pt',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Palavra-passe'),
                GestureDetector(
                  onTap: () => _showMessage(
                      'Vais receber um email com instruções para recuperar a palavra-passe.'),
                  child: const Text(
                    'Esqueci-me da palavra-passe',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildField(
              controller: _passwordController,
              icon: 'assets/icons/lock.png',
              hint: '••••••••',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _buildPrimaryButton('Entrar', _onLoginPressed),
            const SizedBox(height: 10),
            _buildSecondaryButton('Criar conta', _onCreateAccountPressed),
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 10),
            _buildGuestLink(),
            const SizedBox(height: 10),
            const Text(
              'Como convidado vês conteúdo público, mas não podes seguir, '
              'comentar nem criar registos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 17 / 12,
                color: AppColors.placeholderGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Peças pequenas usadas no cartão ----------

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }

  /// Campo de texto com ícone, fundo cinzento claro e cantos de 14.
  Widget _buildField({
    required TextEditingController controller,
    required String icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        border: Border.all(color: AppColors.fieldBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 16, height: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(fontSize: 15, color: AppColors.ink),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: AppColors.placeholderGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botão azul "Entrar", com sombra azulada.
  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x593D5AFF), offset: Offset(0, 6), blurRadius: 8),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  /// Botão claro "Criar conta", com contorno azul.
  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.secondaryButton,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.secondaryButtonBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  /// Linha — ou — linha
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.fieldBorder)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'ou',
            style: TextStyle(fontSize: 12, color: AppColors.placeholderGrey),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.fieldBorder)),
      ],
    );
  }

  Widget _buildGuestLink() {
    return Center(
      child: GestureDetector(
        onTap: _onGuestPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Continuar como convidado',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Image.asset('assets/icons/arrow_right.png', width: 14, height: 14),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Parte de cima do ecrã de Entrar: luzes desfocadas, ilustração
/// e pequenas partículas. Tal como no Figma, a ilustração e as
/// partículas sobem e descem devagar (animação em ciclo).
class LoginHeader extends StatefulWidget {
  const LoginHeader({super.key});

  @override
  State<LoginHeader> createState() => _LoginHeaderState();
}

class _LoginHeaderState extends State<LoginHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    // No Figma: sobe/desce 2 s com "ease-in-out", sempre em ciclo.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _float = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, child) {
          final double t = _float.value; // vai de 0 a 1 e volta a 0
          return Stack(
            children: [
              // Luzes desfocadas (glow-orb 1, 2 e 3)
              _glowOrb(left: -60, top: -60, size: 300, color: const Color(0x2E3D5AFF), blur: 30),
              _glowOrb(left: 180, top: 80, size: 260, color: const Color(0x247B26FA), blur: 40),
              _glowOrb(left: 60, top: 200, size: 200, color: const Color(0x1A2ECCE6), blur: 25),

              // Ilustração principal (240 x 156, cantos de 24), sobe até 5 px
              Positioned(
                top: 104 - 5 * t,
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

              // Escurecimento por baixo da ilustração
              Positioned(
                top: 220,
                left: 0,
                right: 0,
                height: 50,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x000D0F1A), AppColors.loginBackground],
                    ),
                  ),
                ),
              ),

              // Partículas: umas descem 4 px, outras sobem 4 px
              _particle(left: 32, top: 60 + 4 * t, size: 4, color: Colors.white.withOpacity(0.6)),
              _particle(left: 350, top: 110 - 4 * t, size: 3, color: const Color(0xFFA78BFA).withOpacity(0.8)),
              _particle(left: 310, top: 44 + 4 * t, size: 5, color: const Color(0xFF60A5FA).withOpacity(0.5)),
              _particle(left: 70, top: 160 - 4 * t, size: 3, color: const Color(0xFFF472B6).withOpacity(0.5)),
              _particle(left: 360, top: 200 + 4 * t, size: 4, color: Colors.white.withOpacity(0.4)),
              _particle(left: 20, top: 280 - 4 * t, size: 3, color: const Color(0xFF818CF8).withOpacity(0.6)),
            ],
          );
        },
      ),
    );
  }

  /// Círculo de cor desfocado, como as "glow-orb" do Figma.
  Widget _glowOrb({
    required double left,
    required double top,
    required double size,
    required Color color,
    required double blur,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  /// Pequeno ponto de luz.
  Widget _particle({
    required double left,
    required double top,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Cores da aplicação, copiadas do Figma.
/// As primeiras vêm do ecrã "12 · Guia de estilo";
/// as restantes aparecem em ecrãs específicos.
class AppColors {
  // Guia de estilo
  static const Color primary = Color(0xFF3D5AFE);
  static const Color ink = Color(0xFF161A24); // "Tinta": texto principal
  static const Color text2 = Color(0xFF5B6372); // texto secundário
  static const Color background = Color(0xFFF4F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE3E6EC);
  static const Color streak = Color(0xFFFFB020);
  static const Color danger = Color(0xFFC62828);

  // Ecrã 01 · Entrar
  static const Color loginBackground = Color(0xFF0D0F1A);
  static const Color loginGradientMiddle = Color(0xFF1A1F3A);
  static const Color loginLanguageText = Color(0xFFE0E7FF);
  static const Color descriptionGrey = Color(0xFF6B7280);
  static const Color placeholderGrey = Color(0xFF9CA3AF);
  static const Color fieldBackground = Color(0xFFF8F9FB);
  static const Color fieldBorder = Color(0xFFE2E8F0);
  static const Color secondaryButton = Color(0xFFF0F2FF);
  static const Color secondaryButtonBorder = Color(0xFFC7D0FF);

  // Ecrã 02 · Diário
  static const Color bodyText = Color(0xFF3A4150); // texto dos cartões
  static const Color notificationDot = Color(0xFFE5484D);
  static const Color streakSubtitle = Color(0xFFBEC2CE);
  static const Color streakDayLabel = Color(0xFFB2B8C3);
  static const Color streakBarOff = Color(0xFF3A4150);
  static const Color segmentBackground = Color(0xFFE8EAEF);
  static const Color photoPlaceholder = Color(0xFFDDE3F5);
}

/// Tema geral: define a fonte e as cores base para toda a app.
class AppTheme {
  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData get theme {
    return ThemeData(
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    );
  }
}

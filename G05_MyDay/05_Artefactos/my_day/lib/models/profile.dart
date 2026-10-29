/// Tipos de conquista (cada um tem o seu ícone e cor na View).
enum AchievementType { streak7, firstPublicProject, streak30 }

/// Model: uma conquista do perfil (ex.: "7 dias seguidos").
class Achievement {
  final AchievementType type;
  final String title;
  final bool unlocked;

  const Achievement({
    required this.type,
    required this.title,
    required this.unlocked,
  });
}

/// Model: as configurações de privacidade e lembretes de um utilizador.
class UserSettings {
  bool locationEnabled;
  bool microphoneEnabled;
  bool remindersEnabled;
  int reminderHour;
  int reminderMinute;

  UserSettings({
    this.locationEnabled = true,
    this.microphoneEnabled = false,
    this.remindersEnabled = true,
    this.reminderHour = 21,
    this.reminderMinute = 0,
  });
}

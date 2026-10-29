import 'package:flutter/foundation.dart';

import '../models/entry.dart';
import '../models/profile.dart';
import '../models/user.dart';
import 'auth_controller.dart';
import 'entry_controller.dart';
import 'project_controller.dart';

/// Controller do Perfil: conquistas, configurações e apagar conta.
class ProfileController extends ChangeNotifier {
  final AuthController authController;
  final EntryController entryController;
  final ProjectController projectController;

  /// Configurações de cada utilizador (email → configurações).
  final Map<String, UserSettings> _settings = {};

  ProfileController({
    required this.authController,
    required this.entryController,
    required this.projectController,
  });

  /// Configurações do utilizador; na primeira vez usa os valores do Figma.
  UserSettings settingsOf(User user) {
    return _settings.putIfAbsent(user.email, () => UserSettings());
  }

  void setLocation(User user, bool value) {
    settingsOf(user).locationEnabled = value;
    notifyListeners();
  }

  void setMicrophone(User user, bool value) {
    settingsOf(user).microphoneEnabled = value;
    notifyListeners();
  }

  void setReminders(User user, bool value) {
    settingsOf(user).remindersEnabled = value;
    notifyListeners();
  }

  void setReminderTime(User user, int hour, int minute) {
    settingsOf(user)
      ..reminderHour = hour
      ..reminderMinute = minute;
    notifyListeners();
  }

  /// "Todos os dias às 21:00" ou "Desligados".
  String reminderText(User user) {
    final settings = settingsOf(user);
    if (!settings.remindersEnabled) return 'Desligados';
    final hour = settings.reminderHour.toString().padLeft(2, '0');
    final minute = settings.reminderMinute.toString().padLeft(2, '0');
    return 'Todos os dias às $hour:$minute';
  }

  /// Conquistas, calculadas a partir dos registos e dos projetos.
  List<Achievement> achievementsOf(User user) {
    final int streak = entryController.streakDays(user);
    bool hasPublicProject = false;
    for (final project in projectController.projectsFor(user)) {
      if (project.visibility == EntryVisibility.public) hasPublicProject = true;
    }
    return [
      Achievement(type: AchievementType.streak7, title: '7 dias seguidos', unlocked: streak >= 7),
      Achievement(
          type: AchievementType.firstPublicProject,
          title: '1.º projeto público',
          unlocked: hasPublicProject),
      Achievement(type: AchievementType.streak30, title: '30 dias seguidos', unlocked: streak >= 30),
    ];
  }

  /// Apaga a conta e todos os registos do utilizador, e termina a sessão.
  void deleteAccount(User user) {
    entryController.deleteEntriesOf(user.email);
    authController.deleteAccount(user);
    _settings.remove(user.email);
    notifyListeners();
  }
}

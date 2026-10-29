import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../controllers/entry_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/profile.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'widgets/dashed_box.dart';
import 'widgets/toggle_switch.dart';

/// View do ecrã "10 · Perfil e privacidade".
class ProfileView extends StatelessWidget {
  final AuthController authController;
  final EntryController entryController;
  final CommunityController communityController;
  final ProfileController profileController;

  const ProfileView({
    super.key,
    required this.authController,
    required this.entryController,
    required this.communityController,
    required this.profileController,
  });

  // ---------- Ações ----------

  /// Volta à rota inicial ('/' = ecrã de Entrar) e apaga o histórico de ecrãs,
  /// para o botão "voltar" não regressar à conta.
  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _onLogout(BuildContext context) {
    authController.logout();
    _goToLogin(context);
  }

  Future<void> _onDeleteAccount(BuildContext context, User user) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar conta?'),
        content: const Text('A conta e todos os teus registos vão ser apagados. '
            'Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Apagar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      profileController.deleteAccount(user);
      _goToLogin(context);
    }
  }

  Future<void> _onReminderTime(BuildContext context, User user) async {
    final settings = profileController.settingsOf(user);
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute),
    );
    if (time != null) profileController.setReminderTime(user, time.hour, time.minute);
  }

  void _onQrCode(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(user.name, textAlign: TextAlign.center),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 160, color: AppColors.ink),
            SizedBox(height: 8),
            Text(
              'Mostra este código a um colega para te seguir (simulação).',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text2),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Fechar')),
        ],
      ),
    );
  }

  /// Lista de seguidores ou de pessoas que sigo, com botão para seguir / deixar de seguir.
  void _showPeople(BuildContext context, User user, {required bool followers}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ListenableBuilder(
        listenable: communityController,
        builder: (sheetContext, child) {
          final List<User> people = followers
              ? communityController.followersOf(user)
              : communityController.followingOf(user);
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    followers ? 'Seguidores' : 'A seguir',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                if (people.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text('Ainda não há ninguém aqui.', style: TextStyle(color: AppColors.text2)),
                  ),
                for (final person in people)
                  ListTile(
                    title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(person.course),
                    trailing: TextButton(
                      onPressed: () => communityController.toggleFollow(user, person.email),
                      child: Text(communityController.isFollowing(user, person.email)
                          ? 'Deixar de seguir'
                          : 'Seguir'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------- Desenho do ecrã ----------

  @override
  Widget build(BuildContext context) {
    final User? user = authController.currentUser;
    if (user == null) return _buildGuest(context);

    return ListenableBuilder(
      listenable: Listenable.merge([profileController, communityController, entryController]),
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          children: [
            _buildHeader(context, user),
            const SizedBox(height: 20),
            _sectionTitle('Dados Pessoais'),
            const SizedBox(height: 9),
            _buildPersonalCard(user),
            const SizedBox(height: 12),
            _sectionTitle('Gerir Seguidores'),
            const SizedBox(height: 9),
            _buildFollowersCard(context, user),
            const SizedBox(height: 12),
            _sectionTitle('Configurações'),
            const SizedBox(height: 9),
            _buildSettingsCard(context, user),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _onLogout(context),
                child: const Text(
                  'Terminar sessão',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.bodyText),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Convidado: não tem perfil, mas pode ir criar uma conta.
  Widget _buildGuest(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 48, color: AppColors.text2),
            const SizedBox(height: 12),
            const Text(
              'Estás a usar o MyDay como convidado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Entrar ou criar conta'),
            ),
          ],
        ),
      ),
    );
  }

  /// Círculo azul com iniciais, nome, curso e botão do QR Code.
  Widget _buildHeader(BuildContext context, User user) {
    final words = user.name.split(' ');
    final String initials =
        (words.first[0] + (words.length > 1 ? words.last[0] : '')).toUpperCase();

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Text(
            initials,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
              if (user.course.isNotEmpty)
                Text(user.course, style: const TextStyle(fontSize: 13, color: AppColors.text2)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _onQrCode(context, user),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2, size: 20, color: AppColors.ink),
          ),
        ),
      ],
    );
  }

  /// Título de secção com a barra azul à esquerda.
  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
      ],
    );
  }

  Widget _card({required Widget child, EdgeInsets padding = EdgeInsets.zero}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  /// Etiqueta pequena em maiúsculas ("REGISTOS", "SEGUIDORES"...).
  Widget _smallLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.text2,
      ),
    );
  }

  /// Registos + conquistas.
  Widget _buildPersonalCard(User user) {
    final int total = entryController.totalEntries(user);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _smallLabel('Registos'),
                const SizedBox(height: 2),
                Text(
                  total.toString().padLeft(2, '0'), // "05", como no Figma
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.line),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _smallLabel('Conquistas'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final achievement in profileController.achievementsOf(user))
                      _buildAchievement(achievement),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Conquista: desbloqueada (círculo colorido) ou bloqueada (cadeado e contorno tracejado).
  Widget _buildAchievement(Achievement achievement) {
    IconData icon;
    Color circle;
    Color iconColor;
    if (!achievement.unlocked) {
      icon = Icons.lock_outline;
      circle = AppColors.segmentBackground;
      iconColor = AppColors.text2;
    } else if (achievement.type == AchievementType.firstPublicProject) {
      icon = Icons.public;
      circle = AppColors.primary;
      iconColor = Colors.white;
    } else {
      icon = Icons.local_fire_department_outlined;
      circle = AppColors.streak;
      iconColor = AppColors.ink;
    }

    final content = Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: achievement.unlocked ? AppColors.ink : AppColors.text2,
            ),
          ),
        ),
      ],
    );

    if (!achievement.unlocked) {
      return DashedBox(
        width: 100,
        height: 84,
        radius: 12,
        color: const Color(0xFFC9CED8),
        child: content,
      );
    }
    return Container(
      width: 100,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFFE8EAEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: content,
    );
  }

  /// SEGUIDORES | A SEGUIR — tocar abre a lista.
  Widget _buildFollowersCard(BuildContext context, User user) {
    Widget column(String label, int value, bool followers) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showPeople(context, user, followers: followers),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _smallLabel(label),
                const SizedBox(height: 4),
                Text(
                  '$value',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _card(
      child: Row(
        children: [
          column('Seguidores', communityController.followersCount(user), true),
          Container(width: 1, height: 44, color: AppColors.line),
          column('A seguir', communityController.followingCount(user), false),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, User user) {
    final settings = profileController.settingsOf(user);
    return _card(
      child: Column(
        children: [
          _settingRow(
            'Localização',
            'Só quando adicionas a um registo',
            settings.locationEnabled,
            (value) => profileController.setLocation(user, value),
          ),
          _settingRow(
            'Microfone',
            'Para gravar áudio',
            settings.microphoneEnabled,
            (value) => profileController.setMicrophone(user, value),
          ),
          _settingRow(
            'Lembretes diários',
            profileController.reminderText(user),
            settings.remindersEnabled,
            (value) => profileController.setReminders(user, value),
            onTap: () => _onReminderTime(context, user),
          ),
          _actionRow(
            'Exportar os meus dados',
            () => _showMessage(context, 'Os teus dados foram exportados (simulação).'),
            trailing: const Icon(Icons.file_download_outlined, size: 18, color: AppColors.text2),
          ),
          _actionRow('Apagar conta', () => _onDeleteAccount(context, user),
              color: AppColors.danger, showLine: false),
        ],
      ),
    );
  }

  /// Linha com título, explicação e interruptor.
  Widget _settingRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged,
      {VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
                ],
              ),
            ),
            ToggleSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(String title, VoidCallback onTap,
      {Widget? trailing, Color color = AppColors.ink, bool showLine = true}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: showLine ? const Border(bottom: BorderSide(color: AppColors.line)) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

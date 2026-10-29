import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/entry_controller.dart';
import '../../models/entry.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/pt_dates.dart';
import '../entry_detail_view.dart';
import '../widgets/entry_card.dart';

/// Ecrã "02 · Diário (início)": saudação, sequência de dias e lista de registos.
class DiaryListTab extends StatelessWidget {
  final AuthController authController;
  final EntryController entryController;
  final Widget selector; // "Lista / Mapa / Calendário"
  final ValueChanged<String> onShowOnMap; // para o botão "Ver no mapa"

  const DiaryListTab({
    super.key,
    required this.authController,
    required this.entryController,
    required this.selector,
    required this.onShowOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = authController.currentUser;
    final List<Entry> entries = entryController.entriesFor(user);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      children: [
        _buildHeader(context, user),
        const SizedBox(height: 15),
        // Convidados não têm diário próprio, por isso não têm sequência.
        if (user != null) ...[
          _buildStreakCard(user),
          const SizedBox(height: 16),
        ],
        selector,
        const SizedBox(height: 16),
        ..._buildEntryList(context, entries),
      ],
    );
  }

  // ---------- Saudação + botões ----------

  Widget _buildHeader(BuildContext context, User? user) {
    final String firstName = user == null ? 'convidado' : user.name.split(' ').first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatLongDate(DateTime.now()),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Olá, $firstName!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        _buildRoundButton(
          icon: Icons.search,
          onTap: () => _showMessage(context, 'A pesquisa estará disponível em breve.'),
        ),
        const SizedBox(width: 8),
        _buildRoundButton(
          icon: Icons.notifications_none,
          showDot: true,
          onTap: () => _showMessage(context, 'Não tens notificações novas.'),
        ),
      ],
    );
  }

  /// Botão branco 44 x 44 com contorno (Pesquisar / Notificações).
  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 22, color: AppColors.ink)),
            if (showDot)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.notificationDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- Cartão escuro "X dias seguidos" ----------

  Widget _buildStreakCard(User? user) {
    final int streak = entryController.streakDays(user);
    final int thisWeek = entryController.entriesThisWeek(user);
    final List<bool> week = entryController.weekActivity(user);
    const List<String> dayLetters = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Quadrado laranja com a chama
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.streak,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_fire_department_outlined,
                size: 26, color: AppColors.ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        streak == 1 ? '1 dia\nseguido' : '$streak dias\nseguidos',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 21 / 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        thisWeek == 1
                            ? '1 registo esta\nsemana'
                            : '$thisWeek registos esta\nsemana',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 15 / 12,
                          color: AppColors.streakSubtitle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Uma barra por dia da semana: laranja se houve registo
                Row(
                  children: [
                    for (int i = 0; i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: week[i] ? AppColors.streak : AppColors.streakBarOff,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dayLetters[i],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.streakDayLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Lista agrupada por dia ----------

  /// Escreve um título ("Hoje", "Ontem", "26 de outubro") sempre que o dia muda.
  List<Widget> _buildEntryList(BuildContext context, List<Entry> entries) {
    if (entries.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'Ainda não há registos para mostrar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.text2),
          ),
        ),
      ];
    }

    final List<Widget> widgets = [];
    String? lastDay;
    for (final entry in entries) {
      final String day = formatRelativeDay(entry.date);
      if (day != lastDay) {
        widgets.add(_buildSectionTitle(day));
        lastDay = day;
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: EntryCard(
          entry: entry,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntryDetailView(
                entry: entry,
                authController: authController,
                entryController: entryController,
                onShowOnMap: onShowOnMap,
              ),
            ),
          ),
        ),
      ));
    }
    return widgets;
  }

  /// "HOJE", "ONTEM"...
  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.text2,
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

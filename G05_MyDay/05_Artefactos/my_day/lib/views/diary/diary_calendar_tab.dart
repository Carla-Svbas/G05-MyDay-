import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/entry_controller.dart';
import '../../models/entry.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/pt_dates.dart';
import '../entry_detail_view.dart';

/// Ecrã "08 · Calendário e estatísticas".
/// Um ponto debaixo de cada dia com registos; tocar num dia mostra esses registos.
class DiaryCalendarTab extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController;
  final Widget selector; // "Lista / Mapa / Calendário"
  final ValueChanged<String> onShowOnMap;

  const DiaryCalendarTab({
    super.key,
    required this.authController,
    required this.entryController,
    required this.selector,
    required this.onShowOnMap,
  });

  @override
  State<DiaryCalendarTab> createState() => _DiaryCalendarTabState();
}

class _DiaryCalendarTabState extends State<DiaryCalendarTab> {
  // Primeiro dia do mês que está a ser mostrado.
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  User? get _user => widget.authController.currentUser;

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  /// Folha que sobe do fundo com os registos do dia tocado.
  void _showDay(DateTime day) {
    final List<Entry> entries = widget.entryController.entriesOnDay(_user, day);
    if (entries.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                formatLongDate(day),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            for (final entry in entries)
              ListTile(
                title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${entry.subject} · ${formatTime(entry.date)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryDetailView(
                        entry: entry,
                        authController: widget.authController,
                        entryController: widget.entryController,
                        onShowOnMap: widget.onShowOnMap,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      children: [
        widget.selector,
        const SizedBox(height: 14),
        _buildCalendar(),
        const SizedBox(height: 14),
        _buildStats(),
        const SizedBox(height: 14),
        _buildSubjects(),
      ],
    );
  }

  // ---------- Calendário ----------

  Widget _buildCalendar() {
    const List<String> weekdays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final int daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final int emptyCells = _month.weekday - 1; // a semana começa à segunda

    // Lista de células: null = espaço vazio antes do dia 1.
    final List<DateTime?> cells = [
      for (int i = 0; i < emptyCells; i++) null,
      for (int day = 1; day <= daysInMonth; day++) DateTime(_month.year, _month.month, day),
    ];

    return _card(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              _monthButton(Icons.chevron_left, () => _changeMonth(-1)),
              Expanded(
                child: Text(
                  formatMonthYear(_month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ),
              _monthButton(Icons.chevron_right, () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final letter in weekdays)
                Expanded(
                  child: Text(
                    letter,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Grelha de 7 colunas, uma linha por semana.
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 46 / 42,
            children: [
              for (final day in cells) day == null ? const SizedBox() : _buildDay(day),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }

  /// Um dia: número + ponto (laranja se houve registo; azul no dia de hoje).
  Widget _buildDay(DateTime day) {
    final DateTime today = onlyDay(DateTime.now());
    final bool isToday = day == today;
    final bool isFuture = day.isAfter(today);
    final bool hasEntries = widget.entryController.entriesOnDay(_user, day).isNotEmpty;

    final Widget number = Text(
      '${day.day}',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 18 / 15,
        color: isToday
            ? Colors.white
            : (isFuture ? AppColors.descriptionGrey : AppColors.ink),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDay(day),
      child: Column(
        children: [
          isToday
              ? Container(
                  width: 28,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: number,
                )
              : Padding(padding: const EdgeInsets.only(top: 2), child: number),
          SizedBox(height: isToday ? 3 : 2.5),
          if (hasEntries)
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : AppColors.streak,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Estatísticas ----------

  Widget _buildStats() {
    final int week = widget.entryController.entriesThisWeek(_user);
    final int streak = widget.entryController.streakDays(_user);
    final int total = widget.entryController.totalEntries(_user);
    return Row(
      children: [
        Expanded(child: _statCard('$week', week == 1 ? 'registo esta semana' : 'registos esta semana')),
        const SizedBox(width: 8),
        Expanded(child: _statCard('$streak', streak == 1 ? 'dia seguido' : 'dias seguidos')),
        const SizedBox(width: 8),
        Expanded(child: _statCard('$total', total == 1 ? 'registo no total' : 'registos no total')),
      ],
    );
  }

  Widget _statCard(String number, String label) {
    return _card(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 62,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, height: 16 / 12, color: AppColors.text2),
            ),
          ],
        ),
      ),
    );
  }

  /// "Disciplinas mais trabalhadas": uma barra por disciplina.
  Widget _buildSubjects() {
    final subjects = widget.entryController.entriesPerSubject(_user);
    final int max = subjects.isEmpty ? 1 : subjects.first.value;

    return _card(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disciplinas mais trabalhadas',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 10),
          for (final subject in subjects) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject.key,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                ),
                Text(
                  subject.value == 1 ? '1 registo' : '${subject.value} registos',
                  style: const TextStyle(fontSize: 13, color: AppColors.text2),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Barra cinzenta com a parte azul proporcional ao número de registos.
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: subject.value / max,
                minHeight: 8,
                backgroundColor: AppColors.segmentBackground,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  /// Cartão branco com contorno e cantos de 16.
  Widget _card({required Widget child, required EdgeInsets padding}) {
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
}

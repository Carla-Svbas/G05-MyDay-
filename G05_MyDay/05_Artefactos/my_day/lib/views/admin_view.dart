import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/report.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../utils/pt_dates.dart';

/// View do ecrã "11 · Administração": denúncias, estatísticas, tags e desafios.
class AdminView extends StatefulWidget {
  final AuthController authController;
  final AdminController adminController;

  const AdminView({
    super.key,
    required this.authController,
    required this.adminController,
  });

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  int _tab = 0; // 0 Denúncias, 1 Estatísticas, 2 Tags, 3 Desafios

  AdminController get admin => widget.adminController;
  User get _user => widget.authController.currentUser!;

  // ---------- Ações ----------

  void _onLogout() {
    widget.authController.logout();
    // Volta à rota inicial ('/' = ecrã de Entrar) e apaga o histórico.
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _onNewChallenge() async {
    // Guardado antes do "await": depois da janela o context pode já não existir.
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController();
    final String? text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo desafio da semana'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Ex.: Desenha um esquema do que aprendeste'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
    if (text == null) return;
    final String? error = admin.publishChallenge(_user, text);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Desafio publicado na Comunidade.')),
    );
  }

  // ---------- Desenho do ecrã ----------

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // cabeçalho escuro → ícones claros
      child: Scaffold(
        body: ListenableBuilder(
          listenable: admin,
          builder: (context, child) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: _buildTabContent(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Cabeçalho escuro com o título, "Sair" e os separadores.
  Widget _buildHeader() {
    final tabs = ['Denúncias · ${admin.openReports.length}', 'Estatísticas', 'Tags', 'Desafios'];
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(20, 60, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Image.asset('assets/icons/logo.png', width: 22, height: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Administração',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: _onLogout,
                  child: const Text(
                    'Sair',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFC9CEDA)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          // Separadores com deslize horizontal (não cabem todos no ecrã).
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < tabs.length; i++) _darkPill(tabs[i], i),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkPill(String label, int index) {
    final bool selected = index == _tab;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            border: Border.all(color: selected ? Colors.white : const Color(0xFF353C4B)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.ink : const Color(0xFFC9CEDA),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabContent() {
    switch (_tab) {
      case 1:
        return _buildStatisticsTab();
      case 2:
        return _buildTagsTab();
      case 3:
        return _buildChallengeTab();
      default:
        return _buildReportsTab();
    }
  }

  // ---------- Separador Denúncias (o do Figma) ----------

  List<Widget> _buildReportsTab() {
    final reports = admin.openReports;
    return [
      Row(
        children: [
          Expanded(child: _statCard('${reports.length}', 'denúncias abertas', highlight: true)),
          const SizedBox(width: 8),
          Expanded(child: _statCard('${admin.userCount}', 'utilizadores ativos')),
          const SizedBox(width: 8),
          Expanded(child: _statCard('${admin.entriesToday}', 'registos hoje')),
        ],
      ),
      const SizedBox(height: 18),
      _sectionTitle('Fila de moderação'),
      const SizedBox(height: 14),
      if (reports.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text(
            'Não há denúncias por tratar.',
            style: TextStyle(fontSize: 14, color: AppColors.text2),
          ),
        ),
      for (int i = 0; i < reports.length; i++) _buildReportCard(reports[i], i),
      const SizedBox(height: 4),
      _sectionTitle('Registo de ações'),
      const SizedBox(height: 14),
      _buildActionLog(),
    ];
  }

  Widget _statCard(String number, String label, {bool highlight = false}) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.danger : AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, height: 1.15, color: AppColors.text2)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.text2,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.line),
      borderRadius: BorderRadius.circular(16),
    );
  }

  /// Cartão de uma denúncia com os três botões de decisão.
  Widget _buildReportCard(Report report, int index) {
    const List<Color> thumbColors = [Color(0xFFDDE3F5), Color(0xFFF3E6D3)];
    final String count = report.count == 1 ? '1 denúncia' : '${report.count} denúncias';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: thumbColors[index % thumbColors.length],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'por ${admin.authorOf(report)} · $count',
                      style: const TextStyle(fontSize: 12, color: AppColors.text2),
                    ),
                    const SizedBox(height: 4),
                    // Motivo da denúncia, a vermelho
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE7E7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.reason,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA61B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _decisionButton('Ocultar', () => admin.hide(report, _user), filled: true)),
              const SizedBox(width: 6),
              Expanded(child: _decisionButton('Avisar autor', () => admin.warnAuthor(report, _user))),
              const SizedBox(width: 6),
              Expanded(child: _decisionButton('Ignorar', () => admin.ignore(report, _user))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decisionButton(String label, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.ink : AppColors.surface,
          border: filled ? null : Border.all(color: const Color(0xFFDCE0E7)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }

  /// "lurdes.admin  publicou um desafio ........ 11:20"
  Widget _buildActionLog() {
    final actions = admin.actions;
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < actions.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: i == actions.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${actions[i].adminName}  ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: actions[i].description),
                        ],
                      ),
                      style: const TextStyle(fontSize: 13, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatTime(actions[i].date),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6F7683)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Outros separadores (não desenhados no Figma: versão simples) ----------

  List<Widget> _buildStatisticsTab() {
    return [
      Row(
        children: [
          Expanded(child: _statCard('${admin.userCount}', 'utilizadores')),
          const SizedBox(width: 8),
          Expanded(child: _statCard('${admin.totalEntries}', 'registos no total')),
          const SizedBox(width: 8),
          Expanded(child: _statCard('${admin.entriesToday}', 'registos hoje')),
        ],
      ),
    ];
  }

  List<Widget> _buildTagsTab() {
    final tags = admin.tags;
    if (tags.isEmpty) {
      return [const Text('Ainda não há tags.', style: TextStyle(color: AppColors.text2))];
    }
    return [
      Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            for (final tag in tags)
              ListTile(
                title: Text('#${tag.key}', style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(
                  tag.value == 1 ? '1 registo' : '${tag.value} registos',
                  style: const TextStyle(color: AppColors.text2),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildChallengeTab() {
    return [
      _sectionTitle('Desafio atual'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Text(
          admin.challenge,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: _onNewChallenge,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Publicar novo desafio'),
        ),
      ),
    ];
  }
}

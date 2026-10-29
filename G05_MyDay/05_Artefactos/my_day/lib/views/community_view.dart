import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../controllers/entry_controller.dart';
import '../models/entry.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../utils/pt_dates.dart';
import 'entry_detail_view.dart';
import 'new_entry_view.dart';
import 'widgets/initials_avatar.dart';
import 'widgets/pill_chip.dart';
import 'widgets/study_group_card.dart';
import 'widgets/tag_chip.dart';

/// View do ecrã "09 · Comunidade": pesquisa, separadores, desafio da semana
/// e registos de outras pessoas.
class CommunityView extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController;
  final CommunityController communityController;

  const CommunityView({
    super.key,
    required this.authController,
    required this.entryController,
    required this.communityController,
  });

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  int _tab = 0; // 0 A seguir, 1 Descobrir, 2 Grupos
  String _query = '';

  User? get _user => widget.authController.currentUser;

  // ---------- Ações ----------

  void _openEntry(Entry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailView(
          entry: entry,
          authController: widget.authController,
          entryController: widget.entryController,
        ),
      ),
    );
  }

  /// Participar no desafio: abre um registo novo.
  void _onChallenge() {
    if (_user == null) {
      _showMessage('Cria uma conta para participares no desafio.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEntryView(
          authController: widget.authController,
          entryController: widget.entryController,
        ),
      ),
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
    return ListenableBuilder(
      listenable: Listenable.merge([widget.communityController, widget.entryController]),
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildSearch(),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                PillChip(label: 'A seguir', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                PillChip(label: 'Descobrir', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                PillChip(label: 'Grupos', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
              ],
            ),
            const SizedBox(height: 14),
            ..._buildTabContent(),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Comunidade',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.56,
              color: AppColors.ink,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showMessage('As mensagens vão ser desenvolvidas numa próxima versão.'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 22, color: AppColors.ink),
          ),
        ),
      ],
    );
  }

  /// Caixa de pesquisa: filtra os registos à medida que se escreve.
  Widget _buildSearch() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: const Color(0xFFD8DCE4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.text2),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (text) => setState(() => _query = text),
              style: const TextStyle(fontSize: 15, color: AppColors.ink),
              decoration: const InputDecoration.collapsed(
                hintText: 'Pessoas, projetos, tags, conteúdos…',
                hintStyle: TextStyle(fontSize: 15, color: AppColors.descriptionGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabContent() {
    if (_tab == 2) {
      return [
        for (final group in widget.communityController.groups)
          StudyGroupCard(
            group: group,
            onTap: () => _showMessage('Os grupos de estudo vão ser desenvolvidos numa próxima versão.'),
          ),
      ];
    }

    final List<Entry> posts = widget.communityController.feed(
      _user,
      followingOnly: _tab == 0,
      query: _query,
    );

    String emptyText = 'Não há registos para mostrar.';
    if (_tab == 0 && _user == null) emptyText = 'Entra com uma conta para seguires colegas.';

    return [
      _buildChallenge(),
      const SizedBox(height: 14),
      if (posts.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.text2),
          ),
        ),
      for (int i = 0; i < posts.length; i++) _buildPost(posts[i], i),
    ];
  }

  /// Cartão azul "Desafio da semana".
  Widget _buildChallenge() {
    return GestureDetector(
      onTap: _onChallenge,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1FF),
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_events_outlined, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desafio da semana',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2A3FC2)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.communityController.challenge,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cartão de um registo de outra pessoa.
  Widget _buildPost(Entry entry, int index) {
    // Cores das miniaturas, alternadas como no Figma (pêssego / azul).
    const List<Color> thumbColors = [Color(0xFFF3E6D3), Color(0xFFDDE3F5)];
    final String author = widget.communityController.authorName(entry);
    final bool favorite = widget.entryController.isFavorite(entry);

    return GestureDetector(
      onTap: () => _openEntry(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Autor · disciplina · há quanto tempo ........ visibilidade
            Row(
              children: [
                InitialsAvatar(name: author, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      Text(
                        '${entry.subject} · ${formatTimeAgo(entry.date)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.text2),
                      ),
                    ],
                  ),
                ),
                TagChip.visibility(entry.visibility, withIcon: false),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        entry.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.text2),
                      ),
                    ],
                  ),
                ),
                if (entry.hasPhoto) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: thumbColors[index % thumbColors.length],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Comentários · Favoritar
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.bodyText),
                const SizedBox(width: 6),
                Text(
                  '${entry.comments.length}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.bodyText),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => widget.entryController.toggleFavorite(entry),
                  child: Row(
                    children: [
                      Icon(
                        favorite ? Icons.bookmark : Icons.bookmark_border,
                        size: 18,
                        color: favorite ? AppColors.primary : AppColors.bodyText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        favorite ? 'Favorito' : 'Favoritar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: favorite ? AppColors.primary : AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

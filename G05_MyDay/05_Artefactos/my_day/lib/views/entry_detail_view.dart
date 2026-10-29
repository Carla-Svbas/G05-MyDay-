import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/entry_controller.dart';
import '../models/comment.dart';
import '../models/entry.dart';
import '../theme/app_theme.dart';
import '../utils/pt_dates.dart';
import 'widgets/initials_avatar.dart';
import 'widgets/tag_chip.dart';

/// View do ecrã "04 · Registo": mostra um registo, os comentários
/// e permite favoritar, comentar, exportar e (se for o autor) apagar.
class EntryDetailView extends StatefulWidget {
  final Entry entry;
  final AuthController authController;
  final EntryController entryController;

  /// Chamado por "Ver no mapa" com o nome do local (abre o separador Mapa).
  final ValueChanged<String>? onShowOnMap;

  const EntryDetailView({
    super.key,
    required this.entry,
    required this.authController,
    required this.entryController,
    this.onShowOnMap,
  });

  @override
  State<EntryDetailView> createState() => _EntryDetailViewState();
}

class _EntryDetailViewState extends State<EntryDetailView> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  Entry get entry => widget.entry;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  // ---------- Ações ----------

  void _onSendComment() {
    final String? error = widget.entryController.addComment(
      entry,
      widget.authController.currentUser,
      _commentController.text,
    );
    if (error != null) {
      _showMessage(error);
      return;
    }
    _commentController.clear();
    _commentFocus.unfocus();
  }

  void _onMoreOptions() {
    final bool isOwner =
        widget.entryController.isOwner(entry, widget.authController.currentUser);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Apagar registo', style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Denunciar registo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _chooseReportReason();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Pede o motivo e envia a denúncia para a fila da Administração.
  Future<void> _chooseReportReason() async {
    const reasons = ['Conteúdo copiado', 'Linguagem ofensiva', 'Spam', 'Outro motivo'];
    final String? reason = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Porque queres denunciar?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            for (final reason in reasons)
              ListTile(title: Text(reason), onTap: () => Navigator.pop(sheetContext, reason)),
          ],
        ),
      ),
    );
    if (reason == null) return;
    widget.entryController.reportEntry(entry, reason);
    _showMessage('Denúncia enviada. Obrigado!');
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar registo?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Apagar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.entryController.deleteEntry(entry);
      _showMessage('Registo apagado.');
      Navigator.pop(context);
    }
  }

  /// Volta ao Diário e mostra o local deste registo no Mapa.
  void _onShowOnMap() {
    final place = widget.entryController.placeOf(entry);
    if (place == null || widget.onShowOnMap == null) {
      _showMessage('Este local não está no mapa.');
      return;
    }
    Navigator.pop(context);
    widget.onShowOnMap!(place.name);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------- Desenho do ecrã ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // Redesenha quando muda um favorito ou chega um comentário.
      body: ListenableBuilder(
        listenable: widget.entryController,
        builder: (context, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPhotoHeader(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        child: _buildContent(),
                      ),
                    ],
                  ),
                ),
              ),
              _buildCommentForm(),
            ],
          );
        },
      ),
    );
  }

  /// Zona da fotografia (230 de altura) com os botões Voltar e Mais opções.
  Widget _buildPhotoHeader() {
    return Container(
      height: 230,
      color: AppColors.photoPlaceholder,
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.photo_camera_outlined, size: 36, color: AppColors.text2),
          ),
          Positioned(
            top: 48,
            left: 16,
            child: _circleButton(Icons.chevron_left, () => Navigator.pop(context)),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: _circleButton(Icons.more_horiz, _onMoreOptions),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: Icon(icon, size: 24, color: AppColors.ink),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Disciplina · Projeto ........ Visibilidade
        Row(
          children: [
            TagChip.subject(entry.subject),
            const SizedBox(width: 4),
            // Ocupa o espaço do meio; se o nome do projeto for comprido,
            // a etiqueta encolhe e acaba em "…" em vez de sair do ecrã.
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: entry.project == null ? null : _projectChip(entry.project!),
              ),
            ),
            const SizedBox(width: 8),
            TagChip.visibility(entry.visibility),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          entry.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatShortDateTime(entry.date),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text2),
        ),
        const SizedBox(height: 14),
        Text(
          entry.text,
          style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.bodyText),
        ),
        if (entry.locationName != null) ...[
          const SizedBox(height: 20),
          _buildLocation(),
        ],
        if (entry.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              for (final tag in entry.tags)
                Text(
                  '#$tag',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildActions(),
        const SizedBox(height: 12),
        const Text(
          'Comentários',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        if (entry.comments.isEmpty)
          const Text(
            'Ainda não há comentários.',
            style: TextStyle(fontSize: 14, color: AppColors.text2),
          ),
        for (final comment in entry.comments) _buildComment(comment),
      ],
    );
  }

  /// Etiqueta cinzenta "Projeto · Nome".
  Widget _projectChip(String project) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Projeto · $project',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 15 / 12,
          color: AppColors.bodyText,
        ),
      ),
    );
  }

  /// Caixa cinzenta com o local e a ligação "Ver no mapa".
  Widget _buildLocation() {
    // "Biblioteca IADE" + cidade da morada ("Av. Dom Carlos I, Lisboa" → "Lisboa")
    String label = entry.locationName!;
    if (entry.locationAddress != null) {
      label += ', ${entry.locationAddress!.split(',').last.trim()}';
    }
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ),
          GestureDetector(
            onTap: _onShowOnMap,
            child: const Text(
              'Ver no mapa',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Favoritar · Comentários · PDF, entre duas linhas.
  Widget _buildActions() {
    final bool favorite = widget.entryController.isFavorite(entry);
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          _action(
            favorite ? Icons.bookmark : Icons.bookmark_border,
            favorite ? 'Favorito' : 'Favoritar',
            () => widget.entryController.toggleFavorite(entry),
            color: favorite ? AppColors.primary : AppColors.bodyText,
          ),
          _action(
            Icons.chat_bubble_outline,
            '${entry.comments.length}',
            () => _commentFocus.requestFocus(),
          ),
          _action(
            Icons.file_download_outlined,
            'PDF',
            () => _showMessage('PDF exportado (simulação).'),
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap,
      {Color color = AppColors.bodyText}) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildComment(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(name: comment.authorName),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: comment.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      TextSpan(
                        text: ' · ${formatTimeAgo(comment.date)}',
                        style: const TextStyle(color: AppColors.text2),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.bodyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Caixa fixa em baixo para escrever um comentário.
  Widget _buildCommentForm() {
    final bool isGuest = widget.authController.currentUser == null;
    return Container(
      height: 85,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: const Color(0xFFDBDEE5)),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocus,
                enabled: !isGuest,
                onSubmitted: (_) => _onSendComment(),
                style: const TextStyle(fontSize: 15, color: AppColors.ink),
                decoration: InputDecoration.collapsed(
                  hintText: isGuest ? 'Entra com uma conta para comentar' : 'Escreve um comentário…',
                  hintStyle: const TextStyle(fontSize: 15, color: AppColors.descriptionGrey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _onSendComment,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

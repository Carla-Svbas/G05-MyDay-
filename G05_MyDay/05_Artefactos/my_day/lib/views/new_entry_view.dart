import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/entry_controller.dart';
import '../models/entry.dart';
import '../theme/app_theme.dart';
import 'widgets/dashed_box.dart';
import 'widgets/segmented_control.dart';

/// View do ecrã "03 · Novo registo".
/// Guarda o que o utilizador vai preenchendo e, ao carregar em "Guardar",
/// entrega tudo ao EntryController, que valida e cria o registo.
class NewEntryView extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController;
  final String? initialProject; // já escolhido quando se vem de um projeto

  const NewEntryView({
    super.key,
    required this.authController,
    required this.entryController,
    this.initialProject,
  });

  @override
  State<NewEntryView> createState() => _NewEntryViewState();
}

class _NewEntryViewState extends State<NewEntryView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  // Estado do formulário (só existe enquanto o ecrã está aberto).
  int _photoCount = 0;
  bool _withVideo = false;
  bool _withAudio = false;
  bool _withLocation = false;
  String? _subject;
  String? _project;
  List<String> _tags = [];
  EntryVisibility _visibility = EntryVisibility.private;

  @override
  void initState() {
    super.initState();
    _project = widget.initialProject;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ---------- Ações ----------

  void _onSavePressed() {
    final String? error = widget.entryController.createEntry(
      author: widget.authController.currentUser!,
      title: _titleController.text,
      text: _textController.text,
      subject: _subject,
      project: _project,
      tags: _tags,
      visibility: _visibility,
      withLocation: _withLocation,
      photoCount: _photoCount,
      withAudio: _withAudio,
      withVideo: _withVideo,
    );

    if (error != null) {
      _showMessage(error);
      return;
    }
    _showMessage('Registo guardado.');
    Navigator.pop(context);
  }

  void _addPhoto() {
    setState(() => _photoCount++);
    _showMessage('Fotografia adicionada (simulação: a câmara não é usada).');
  }

  void _removePhoto() {
    setState(() => _photoCount--);
  }

  void _toggleVideo() {
    setState(() => _withVideo = !_withVideo);
    if (_withVideo) _showMessage('Vídeo gravado (simulação).');
  }

  void _toggleAudio() {
    setState(() => _withAudio = !_withAudio);
    if (_withAudio) _showMessage('Áudio gravado (simulação).');
  }

  void _toggleLocation() {
    setState(() => _withLocation = !_withLocation);
  }

  Future<void> _chooseSubject() async {
    final String? choice = await _showOptions('Disciplina', widget.entryController.subjects);
    if (choice != null) setState(() => _subject = choice);
  }

  Future<void> _chooseProject() async {
    final String? choice = await _showOptions(
      'Projeto',
      ['Nenhum', ...widget.entryController.projectNamesFor(widget.authController.currentUser)],
    );
    if (choice != null) setState(() => _project = choice == 'Nenhum' ? null : choice);
  }

  Future<void> _editTags() async {
    final controller = TextEditingController(text: _tags.map((t) => '#$t').join(' '));
    final String? text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tags'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '#iterações #cálculo'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (text != null) setState(() => _tags = widget.entryController.parseTags(text));
  }

  /// Lista de opções numa folha que sobe do fundo do ecrã.
  Future<String?> _showOptions(String title, List<String> options) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option),
                onTap: () => Navigator.pop(context, option),
              ),
          ],
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 0),
            child: _buildTopBar(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 14),
                  _buildTextField(),
                  const SizedBox(height: 14),
                  _buildPhotos(),
                  const SizedBox(height: 14),
                  _buildMediaButtons(),
                  if (_withLocation) ...[
                    const SizedBox(height: 14),
                    _buildLocationCard(),
                  ],
                  const SizedBox(height: 14),
                  _buildOptionRows(),
                  const SizedBox(height: 14),
                  _buildVisibility(),
                  const SizedBox(height: 14),
                  _buildSyncNote(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Cancelar"   Novo registo   [Guardar]
  Widget _buildTopBar() {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text2,
                ),
              ),
            ),
          ),
          const Text(
            'Novo registo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _onSavePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    const style = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      color: AppColors.ink,
    );
    return TextField(
      controller: _titleController,
      style: style,
      decoration: InputDecoration.collapsed(
        hintText: 'Título do registo',
        hintStyle: style.copyWith(color: AppColors.placeholderGrey),
      ),
    );
  }

  Widget _buildTextField() {
    const style = TextStyle(fontSize: 15, height: 1.5, color: AppColors.bodyText);
    return TextField(
      controller: _textController,
      style: style,
      minLines: 3,
      maxLines: null, // cresce com o texto
      decoration: InputDecoration.collapsed(
        hintText: 'O que aprendeste hoje?',
        hintStyle: style.copyWith(color: AppColors.placeholderGrey),
      ),
    );
  }

  /// Fotografias adicionadas + caixa tracejada para adicionar mais.
  Widget _buildPhotos() {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < _photoCount; i++) ...[
            GestureDetector(
              onTap: _removePhoto, // Tocar numa fotografia remove-a
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.photoPlaceholder,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.photo_camera_outlined,
                    size: 24, color: AppColors.text2),
              ),
            ),
            const SizedBox(width: 10),
          ],
          GestureDetector(
            onTap: _addPhoto,
            child: const DashedBox(
              width: 96,
              height: 96,
              radius: 16,
              color: Color(0xFFCBCFD8),
              child: Icon(Icons.add, size: 24, color: AppColors.text2),
            ),
          ),
        ],
      ),
    );
  }

  /// Foto · Vídeo · Áudio · Local
  Widget _buildMediaButtons() {
    return Row(
      children: [
        Expanded(child: _mediaButton(Icons.photo_camera_outlined, 'Foto', _photoCount > 0, _addPhoto)),
        const SizedBox(width: 8),
        Expanded(child: _mediaButton(Icons.videocam_outlined, 'Vídeo', _withVideo, _toggleVideo)),
        const SizedBox(width: 8),
        Expanded(child: _mediaButton(Icons.mic_none, 'Áudio', _withAudio, _toggleAudio)),
        const SizedBox(width: 8),
        Expanded(child: _mediaButton(Icons.location_on_outlined, 'Local', _withLocation, _toggleLocation)),
      ],
    );
  }

  Widget _mediaButton(IconData icon, String label, bool selected, VoidCallback onTap) {
    final Color color = selected ? const Color(0xFF2A3FC2) : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF1FF) : AppColors.background,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// Cartão cinzento com o local escolhido e um "x" para o remover.
  Widget _buildLocationCard() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_outlined, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EntryController.simulatedLocationName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                SizedBox(height: 2),
                Text(
                  EntryController.simulatedLocationAddress,
                  style: TextStyle(fontSize: 12, color: AppColors.text2),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleLocation,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, size: 18, color: AppColors.text2),
            ),
          ),
        ],
      ),
    );
  }

  /// Disciplina / Projeto / Tags, separados por linhas.
  Widget _buildOptionRows() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        children: [
          _optionRow('Disciplina', _subject ?? 'Escolher', _chooseSubject),
          _optionRow('Projeto', _project ?? 'Nenhum', _chooseProject),
          _optionRow(
            'Tags',
            _tags.isEmpty ? 'Adicionar' : _tags.map((t) => '#$t').join(' '),
            _editTags,
          ),
        ],
      ),
    );
  }

  Widget _optionRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: AppColors.text2),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.text2),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibility() {
    const List<String> descriptions = [
      'Só tu vês este registo. Os registos são privados por defeito.',
      'Só os teus amigos veem este registo.',
      'Todos veem este registo, incluindo convidados.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visibilidade',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
        const SizedBox(height: 8),
        SegmentedControl(
          options: const ['Privado', 'Só amigos', 'Público'],
          selectedIndex: _visibility.index,
          onChanged: (index) => setState(() => _visibility = EntryVisibility.values[index]),
        ),
        const SizedBox(height: 8),
        Text(
          descriptions[_visibility.index],
          style: const TextStyle(fontSize: 12, color: AppColors.text2),
        ),
      ],
    );
  }

  Widget _buildSyncNote() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.cloud_outlined, size: 15, color: AppColors.text2),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Guardado neste dispositivo. Sincroniza quando houver ligação.',
            style: TextStyle(fontSize: 12, height: 15 / 12, color: AppColors.text2),
          ),
        ),
      ],
    );
  }
}

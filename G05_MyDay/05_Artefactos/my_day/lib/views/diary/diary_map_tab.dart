import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/entry_controller.dart';
import '../../models/entry.dart';
import '../../models/map_place.dart';
import '../../theme/app_theme.dart';
import '../../utils/pt_dates.dart';
import '../entry_detail_view.dart';
import '../widgets/map_background.dart';

/// Ecrã "07 · Mapa": os registos agrupados por local.
/// Cada marcador mostra quantos registos foram feitos nesse local;
/// ao tocar num marcador, o cartão em baixo mostra o registo mais recente.
class DiaryMapTab extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController;
  final Widget selector; // "Lista / Mapa / Calendário"
  final String? initialPlaceName; // vem do botão "Ver no mapa"
  final ValueChanged<String> onShowOnMap;

  const DiaryMapTab({
    super.key,
    required this.authController,
    required this.entryController,
    required this.selector,
    required this.onShowOnMap,
    this.initialPlaceName,
  });

  @override
  State<DiaryMapTab> createState() => _DiaryMapTabState();
}

class _DiaryMapTabState extends State<DiaryMapTab> {
  bool _onlyLast30Days = true;
  String? _selectedPlaceName;

  @override
  void initState() {
    super.initState();
    _selectedPlaceName = widget.initialPlaceName;
  }

  int? get _lastDays => _onlyLast30Days ? 30 : null;

  List<Entry> _entriesAt(MapPlace place) {
    return widget.entryController.entriesAtPlace(
      place,
      widget.authController.currentUser,
      lastDays: _lastDays,
    );
  }

  /// Local escolhido; se nenhum foi escolhido, usa o do registo mais recente.
  MapPlace? _selectedPlace(List<MapPlace> visiblePlaces) {
    for (final place in visiblePlaces) {
      if (place.name == _selectedPlaceName) return place;
    }
    for (final entry in widget.entryController.entriesFor(widget.authController.currentUser)) {
      final place = widget.entryController.placeOf(entry);
      if (place != null && visiblePlaces.contains(place)) return place;
    }
    return null;
  }

  void _onLocatePressed() {
    setState(() => _selectedPlaceName = EntryController.simulatedLocationName);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Localização simulada: Biblioteca IADE.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    // Só mostramos locais com pelo menos um registo.
    final List<MapPlace> visiblePlaces = [];
    for (final place in widget.entryController.places) {
      if (_entriesAt(place).isNotEmpty) visiblePlaces.add(place);
    }
    final MapPlace? selected = _selectedPlace(visiblePlaces);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = constraints.maxWidth / 390; // posições do Figma
        return Stack(
          children: [
            const Positioned.fill(child: MapBackground()),
            for (final place in visiblePlaces)
              _buildMarker(place, place == selected, scale),
            Positioned(top: 52, left: 16, right: 16, child: widget.selector),
            Positioned(top: 110, left: 16, child: _buildPeriodChip()),
            Positioned(top: 496 * scale, right: 16, child: _buildLocateButton()),
            Positioned(top: 544 * scale, left: 12, child: _buildAttribution()),
            if (selected != null)
              Positioned(left: 16, right: 16, bottom: 16, child: _buildEntryCard(selected)),
          ],
        );
      },
    );
  }

  /// Círculo com o número de registos. O escolhido é maior e escuro.
  Widget _buildMarker(MapPlace place, bool isSelected, double scale) {
    final double size = isSelected ? 48 : 40;
    return Positioned(
      left: place.x * scale - size / 2,
      top: place.y * scale - size / 2,
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlaceName = place.name),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ink : AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            '${_entriesAt(place).length}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// "Últimos 30 dias" ⇄ "Todos os registos"
  Widget _buildPeriodChip() {
    return GestureDetector(
      onTap: () => setState(() => _onlyLast30Days = !_onlyLast30Days),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.ink),
            const SizedBox(width: 7),
            Text(
              _onlyLast30Days ? 'Últimos 30 dias' : 'Todos os registos',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocateButton() {
    return GestureDetector(
      onTap: _onLocatePressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.my_location, size: 22, color: AppColors.primary),
      ),
    );
  }

  /// Crédito do mapa, como no Figma.
  Widget _buildAttribution() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '© contribuidores OpenStreetMap',
        style: TextStyle(fontSize: 10, color: AppColors.bodyText),
      ),
    );
  }

  /// Cartão em baixo com o registo mais recente do local escolhido.
  Widget _buildEntryCard(MapPlace place) {
    final List<Entry> entries = _entriesAt(place);
    final Entry entry = entries.first;
    final String placeText =
        entries.length > 1 ? '${place.name} · ${entries.length} registos' : place.name;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntryDetailView(
            entry: entry,
            authController: widget.authController,
            entryController: widget.entryController,
            onShowOnMap: widget.onShowOnMap,
          ),
        ),
      ),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.photoPlaceholder,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatRelativeDay(entry.date)} · ${formatTime(entry.date)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    placeText,
                    style: const TextStyle(fontSize: 13, color: AppColors.text2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

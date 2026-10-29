import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/entry_controller.dart';
import '../widgets/segmented_control.dart';
import 'diary_calendar_tab.dart';
import 'diary_list_tab.dart';
import 'diary_map_tab.dart';

/// Separador "Diário": troca entre as vistas Lista, Mapa e Calendário.
class DiaryView extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController;

  const DiaryView({
    super.key,
    required this.authController,
    required this.entryController,
  });

  @override
  State<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<DiaryView> {
  int _selectedView = 0; // 0 Lista, 1 Mapa, 2 Calendário
  String? _placeToShow; // local pedido pelo botão "Ver no mapa"

  /// Chamado pelo ecrã Registo ("Ver no mapa"): abre o Mapa nesse local.
  void _showOnMap(String placeName) {
    setState(() {
      _selectedView = 1;
      _placeToShow = placeName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // O seletor é o mesmo nas três vistas; cada vista decide onde o mostra.
    // Por cima do mapa usa o estilo escuro, como no Figma.
    final selector = SegmentedControl(
      options: const ['Lista', 'Mapa', 'Calendário'],
      selectedIndex: _selectedView,
      dark: _selectedView == 1,
      onChanged: (index) => setState(() => _selectedView = index),
    );

    // ListenableBuilder redesenha o Diário quando o EntryController muda
    // (por exemplo, quando é criado um registo novo).
    return ListenableBuilder(
      listenable: widget.entryController,
      builder: (context, child) {
        switch (_selectedView) {
          case 1:
            return DiaryMapTab(
              // A key muda com o local pedido, para o mapa começar nesse local.
              key: ValueKey(_placeToShow),
              authController: widget.authController,
              entryController: widget.entryController,
              selector: selector,
              initialPlaceName: _placeToShow,
              onShowOnMap: _showOnMap,
            );
          case 2:
            return DiaryCalendarTab(
              authController: widget.authController,
              entryController: widget.entryController,
              selector: selector,
              onShowOnMap: _showOnMap,
            );
          default:
            return DiaryListTab(
              authController: widget.authController,
              entryController: widget.entryController,
              selector: selector,
              onShowOnMap: _showOnMap,
            );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../controllers/entry_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/project_controller.dart';
import 'community_view.dart';
import 'diary/diary_view.dart';
import 'new_entry_view.dart';
import 'projects/projects_view.dart';
import 'profile_view.dart';
import 'widgets/bottom_nav_bar.dart';

/// Ecrã principal depois de entrar: mostra o separador escolhido
/// na barra inferior (Diário, Projetos, Comunidade ou Perfil).
class MainView extends StatefulWidget {
  final AuthController authController;
  final EntryController entryController;
  final ProjectController projectController;
  final CommunityController communityController;
  final ProfileController profileController;

  const MainView({
    super.key,
    required this.authController,
    required this.entryController,
    required this.projectController,
    required this.communityController,
    required this.profileController,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedTab = 0;

  void _onAddPressed() {
    // Convidados não podem criar registos (texto do ecrã de Entrar).
    if (widget.authController.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cria uma conta para fazeres registos.')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantém cada separador "vivo" ao trocar entre eles.
      body: IndexedStack(
        index: _selectedTab,
        children: [
          DiaryView(
            authController: widget.authController,
            entryController: widget.entryController,
          ),
          ProjectsView(
            authController: widget.authController,
            entryController: widget.entryController,
            projectController: widget.projectController,
          ),
          CommunityView(
            authController: widget.authController,
            entryController: widget.entryController,
            communityController: widget.communityController,
          ),
          ProfileView(
            authController: widget.authController,
            entryController: widget.entryController,
            communityController: widget.communityController,
            profileController: widget.profileController,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedTab,
        onTabSelected: (index) => setState(() => _selectedTab = index),
        onAddPressed: _onAddPressed,
      ),
    );
  }
}

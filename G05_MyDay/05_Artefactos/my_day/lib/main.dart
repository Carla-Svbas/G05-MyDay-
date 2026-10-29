import 'package:flutter/material.dart';

import 'controllers/admin_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/community_controller.dart';
import 'controllers/entry_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/project_controller.dart';
import 'theme/app_theme.dart';
import 'views/login_view.dart';

void main() {
  runApp(MyDayApp());
}

/// Raiz da aplicação: aplica o tema e abre o ecrã de Entrar.
class MyDayApp extends StatelessWidget {
  MyDayApp({super.key});

  // Os controllers são criados uma só vez, aqui,
  // e passados aos ecrãs que precisam deles.
  final AuthController authController = AuthController();
  final EntryController entryController = EntryController();
  // "late": é criado na primeira utilização, quando entryController já existe.
  late final ProjectController projectController =
      ProjectController(entryController: entryController);
  late final CommunityController communityController =
      CommunityController(entryController: entryController);
  late final ProfileController profileController = ProfileController(
    authController: authController,
    entryController: entryController,
    projectController: projectController,
  );
  late final AdminController adminController = AdminController(
    entryController: entryController,
    communityController: communityController,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // Rota '/' = ecrã de Entrar. "Terminar sessão" e "Sair" voltam aqui
      // com pushNamedAndRemoveUntil('/'), sem precisarem de conhecer os controllers.
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(
              authController: authController,
              entryController: entryController,
              projectController: projectController,
              communityController: communityController,
              profileController: profileController,
              adminController: adminController,
            ),
      },
    );
  }
}

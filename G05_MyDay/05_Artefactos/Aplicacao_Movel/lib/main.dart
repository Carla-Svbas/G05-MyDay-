import 'package:flutter/material.dart';

import 'controllers/controladores.dart';
import 'screens/login_page.dart';
import 'widgets/cores.dart';

void main() {
  runApp(MyDayApp(app: criarControladores()));
}

class MyDayApp extends StatelessWidget {
  final Controladores app;

  const MyDayApp({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: Cores.fundo,
        colorScheme: ColorScheme.fromSeed(seedColor: Cores.primaria),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(app: app),
      },
    );
  }
}

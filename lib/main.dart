import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o banco de dados
  try {
    await DatabaseService().database;
  } catch (e) {
    print('Erro ao inicializar banco de dados: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '⚽ Soccer Teams - Sorteio de Times',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
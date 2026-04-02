import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_menu.dart';

/// Точка входа приложения.
void main() {
  // ProviderScope инициализирует Riverpod и предоставляет доступ к провайдерам.
  runApp(
    const ProviderScope(
      child: SudokuApp(),
    ),
  );
}

/// Корневой виджет приложения Судоку.
class SudokuApp extends StatelessWidget {
  /// Создаёт корневой виджет приложения.
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp задаёт тему и начальный экран.
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Базовый шрифт приложения.
        fontFamily: 'Geologica',
      ),
      home: const MainMenu(),
    );
  }
}

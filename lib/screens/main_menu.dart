import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../widgets/difficulty_dialog.dart';
import 'game_screen.dart';

/// Главный экран меню с запуском игры и выходом.
class MainMenu extends ConsumerWidget {
  /// Создаёт экран главного меню.
  const MainMenu({super.key});

  /// Закрывает приложение на нативных платформах.
  void _closeApp() {
    if (kIsWeb) return;
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  /// Показывает диалог выбора сложности и запускает игру.
  void _showDifficultyDialog(BuildContext context, WidgetRef ref) async {
    // Выбранная сложность возвращается из диалога.
    final Difficulty? difficulty = await showGeneralDialog<Difficulty>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Difficulty',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const DifficultyDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        // Анимация с плавным появлением и сдвигом вверх.
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );

    if (difficulty != null && context.mounted) {
      ref.read(gameProvider.notifier).startNewGame(difficulty);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    }
  }

  /// Строит основной интерфейс главного меню.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // constraints — фактические размеры доступной области.
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1920,
                height: 1327,
                child: Stack(
                  children: [
                    /// === ДЕКОРАТИВНЫЙ КРУГ ФОНА ===
                    Positioned(
                      top: 138,
                      left: 560,
                      width: 769,
                      height: 565,
                      child: Image.asset(
                        'assets/background_circle.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    /// === ЗАГОЛОВОК ===
                    const Positioned(
                      left: 378.73,
                      top: 389.88,
                      child: Text(
                        'sudoku',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 254.53,
                          fontFamily: 'Major Mono Display',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    /// === РАЗДЕЛИТЕЛЬНАЯ ЛИНИЯ ===
                    Positioned(
                      left: 391.09,
                      top: 731.37,
                      child: Container(
                        width: 1110.46,
                        height: 4.11,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),

                    /// === ДЕКОРАТИВНЫЕ ТОЧКИ НА ЛИНИИ ===
                    Positioned(
                      left: 1485.10,
                      top: 714.92,
                      child: _circle(const Color(0xFFFFD093)),
                    ),
                    Positioned(
                      left: 376,
                      top: 715.33,
                      child: _circle(const Color(0xFFFFD796)),
                    ),

                    /// === КНОПКА НОВОЙ ИГРЫ ===
                    Positioned(
                      left: 440.35,
                      top: 799.48,
                      child: _buildMenuButton(
                        'новая гульня',
                        1009.23,
                        154.53,
                        103.24,
                        onTap: () => _showDifficultyDialog(context, ref),
                        showCorners: const [0, 1], // Только верхние углы
                      ),
                    ),

                    /// === КНОПКА ВЫХОДА ===
                    Positioned(
                      left: 503.75,
                      top: 972,
                      child: _buildMenuButton(
                        'выхад',
                        885.02,
                        135.60,
                        90.59,
                        onTap: _closeApp,
                        showCorners: const [2, 3], // Только нижние углы
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Рисует маленький цветной круг для декоративной линии.
  Widget _circle(Color color) {
    return Container(
      width: 28.79,
      height: 28.79,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Строит кнопку меню с декоративными углами.
  ///
  /// [label] — текст кнопки.
  /// [width]/[height] — размеры кнопки.
  /// [fontSize] — размер шрифта текста.
  /// [onTap] — обработчик нажатия.
  /// [showCorners] — какие углы рисовать (0..3).
  Widget _buildMenuButton(
    String label,
    double width,
    double height,
    double fontSize, {
    required VoidCallback onTap,
    List<int> showCorners = const [0, 1, 2, 3],
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Внутренний фон кнопки.
            Container(
              width: width * 0.92,
              height: height * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xBFFFD796),
                borderRadius: BorderRadius.circular(width * 0.02),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontFamily: 'Anonymous Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Декоративные углы в зависимости от выбранных индексов.
            if (showCorners.contains(0)) Transform.translate(offset: const Offset(10, -5), child: _corner(width, height, 0)), // Верхний левый
            if (showCorners.contains(1)) Transform.translate(offset: const Offset(-24, -18), child: _corner(width, height, 1)), // Верхний правый
            if (showCorners.contains(2)) Transform.translate(offset: const Offset(-9, 4), child: _corner(width, height, 2)), // Нижний правый
            if (showCorners.contains(3)) Transform.translate(offset: const Offset(19, 16), child: _corner(width, height, 3)), // Нижний левый
          ],
        ),
      ),
    );
  }

  /// Создаёт декоративный угол кнопки по индексу [index].
  Widget _corner(double btnWidth, double btnHeight, int index) {
    // Угол поворота декоративного элемента.
    double angle = index * math.pi / 2;
    // Размер изображения угла относительно высоты кнопки.
    double cornerSize = btnHeight * 0.8;

    // Выравнивание угла в зависимости от индекса.
    Alignment alignment;
    switch (index) {
      case 0: alignment = Alignment.topLeft; break;
      case 1: alignment = Alignment.topRight; break;
      case 2: alignment = Alignment.bottomRight; break;
      case 3: alignment = Alignment.bottomLeft; break;
      default: alignment = Alignment.topLeft;
    }

    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: angle,
        child: Image.asset(
          'assets/button_corner.png',
          width: cornerSize,
          height: cornerSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

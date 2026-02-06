import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../widgets/difficulty_dialog.dart';
import 'game_screen.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class MainMenu extends ConsumerWidget {
  const MainMenu({super.key});

  void _closeApp() {
    if (kIsWeb) return;
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void _showDifficultyDialog(BuildContext context, WidgetRef ref) async {
    final Difficulty? difficulty = await showGeneralDialog<Difficulty>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Difficulty',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const DifficultyDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1.drive(Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic))),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1920,
                height: 1327,
                child: Stack(
                  children: [
                    /// === BACKGROUND CIRCLE ===
                    Positioned(
                      top: 138, 
                      left: 560, 
                      width: 769,
                      height: 565,
                      child: Image.asset(
                        "assets/background_circle.png",
                        fit: BoxFit.contain,
                      ),
                    ),

                    /// === TITLE SECTION ===
                    const Positioned(
                      left: 378.73,
                      top: 439.88, 
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

                    /// === DIVIDER LINE ===
                    Positioned(
                      left: 391.09,
                      top: 731.37, 
                      child: Container(
                        width: 1110.46,
                        height: 4.11,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),

                    /// === DOTS ON LINE ===
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

                    /// === NEW GAME BUTTON ===
                    Positioned(
                      left: 440.35,
                      top: 799.48, 
                      child: _buildMenuButton(
                        'новая гульня',
                        1009.23,
                        154.53,
                        103.24,
                        onTap: () => _showDifficultyDialog(context, ref),
                        showCorners: const [0, 1], // Only upper corners
                      ),
                    ),

                    /// === EXIT BUTTON ===
                    Positioned(
                      left: 503.75,
                      top: 972, 
                      child: _buildMenuButton(
                        'выхад',
                        885.02,
                        135.60,
                        90.59,
                        onTap: _closeApp,
                        showCorners: const [2, 3], // Only down corners
                      ),
                    ),

                    /// === TOP ICONS SECTION ===
                    Positioned(
                      left: 1394.09,
                      top: 141, 
                      child: Row(
                        children: [
                          Icon(Icons.format_paint_outlined, color: Colors.grey[300], size: 80),
                          const SizedBox(width: 40),
                          Icon(Icons.settings_outlined, color: Colors.grey[300], size: 80),
                        ],
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

  Widget _buildMenuButton(String label, double width, double height, double fontSize, {required VoidCallback onTap, List<int> showCorners = const [0, 1, 2, 3]}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner Background
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
            // Corner Decorations
            if (showCorners.contains(0)) Transform.translate(offset: const Offset(7, -5), child: _corner(width, height, 0)), // Top Left
            if (showCorners.contains(1)) Transform.translate(offset: const Offset(5, -3), child: _corner(width, height, 1)), // Top Right
            if (showCorners.contains(2)) _corner(width, height, 2), // Bottom Right
            if (showCorners.contains(3)) _corner(width, height, 3), // Bottom Left
          ],
        ),
      ),
    );
  }

  Widget _corner(double btnWidth, double btnHeight, int index) {
    double angle = index * math.pi / 2;
    double cornerSize = btnHeight * 0.8;

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
          "assets/button_corner.png",
          width: cornerSize,
          height: cornerSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../widgets/difficulty_dialog.dart';
import 'game_screen.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
            scale: anim1.drive(Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic))),
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
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.8;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative Circle
          Positioned(
            top: -circleSize * 0.3,
            left: (size.width - circleSize) / 2,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.peachLight.withOpacity(0.5),
              ),
            ),
          ),
          
          // Icons
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconButton(Icons.palette_outlined),
                    const SizedBox(width: 12),
                    _iconButton(Icons.settings_outlined),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SUDOKU',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDivider(context),
                const SizedBox(height: 60),
                _menuButton(
                  'new game',
                  onTap: () => _showDifficultyDialog(context, ref),
                  isPrimary: true,
                ),
                const SizedBox(height: 20),
                _menuButton(
                  'exit',
                  onTap: _closeApp,
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.6;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(),
        Container(width: width, height: 1, color: AppColors.grayMedium),
        _dot(),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: AppColors.peachAccent,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textSecondary, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _menuButton(String label, {required VoidCallback onTap, required bool isPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.peachLight,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

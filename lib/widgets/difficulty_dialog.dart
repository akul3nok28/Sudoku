import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Диалог выбора сложности при запуске новой игры.
class DifficultyDialog extends StatelessWidget {
  /// Создаёт диалог выбора сложности.
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(color: Colors.black, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.newGame,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _DifficultyButton(difficulty: Difficulty.easy),
              const SizedBox(height: 16),
              _DifficultyButton(difficulty: Difficulty.medium),
              const SizedBox(height: 16),
              _DifficultyButton(difficulty: Difficulty.hard),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка уровня сложности.
class _DifficultyButton extends StatelessWidget {
  /// Уровень сложности, который представляет кнопка.
  final Difficulty difficulty;

  /// Создаёт кнопку сложности.
  const _DifficultyButton({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, difficulty),
        child: Stack(
          alignment: Alignment.center,
          children: [
          // Внешняя рамка с цветом сложности.
          Container(
            width: 260,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: difficulty.color, width: 1.5),
            ),
          ),
          // Внутренняя панель с текстом.
          Container(
            width: 250,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              difficulty.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

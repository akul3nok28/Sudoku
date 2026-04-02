import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Диалог завершения игры (победа или поражение).
class EndGameDialog extends StatelessWidget {
  /// Признак победы (иначе — поражение).
  final bool isWin;

  /// Коллбек для перехода в главное меню.
  final VoidCallback onMainMenu;

  /// Коллбек для перезапуска игры.
  final VoidCallback onRestart;

  /// Создаёт диалог завершения игры.
  const EndGameDialog({
    super.key,
    required this.isWin,
    required this.onMainMenu,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    // Акцентный цвет зависит от результата игры.
    final accent = isWin ? AppColors.easyGreen : AppColors.hardRed;
    // Заголовок диалога по результату.
    final title = isWin ? 'перамога' : 'параза';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontFamily: 'Anonymous Pro',
              ),
            ),
            const SizedBox(height: 22),
            _DialogButton(
              label: 'галоўнае меню',
              accent: accent,
              onTap: onMainMenu,
            ),
            const SizedBox(height: 14),
            _DialogButton(
              label: 'пачаць спачатку',
              accent: accent,
              onTap: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}

/// Кнопка внутри диалога окончания игры.
class _DialogButton extends StatelessWidget {
  /// Текст кнопки.
  final String label;

  /// Акцентный цвет рамки.
  final Color accent;

  /// Обработчик нажатия.
  final VoidCallback onTap;

  /// Создаёт кнопку диалога.
  const _DialogButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent, width: 1.5),
            ),
          ),
          Container(
            width: 250,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontFamily: 'Anonymous Pro',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

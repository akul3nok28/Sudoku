import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Диалог выбора цветовой темы игры.
class ThemeDialog extends StatelessWidget {
  /// Текущая выбранная тема.
  final GameTheme selectedTheme;

  /// Коллбек, вызываемый при выборе новой темы.
  final ValueChanged<GameTheme> onSelect;

  /// Создаёт диалог выбора темы.
  const ThemeDialog({
    super.key,
    required this.selectedTheme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Признак мобильного экрана для адаптации размеров.
    final isMobile = MediaQuery.of(context).size.width < 700;
    // Размер цветного кружка темы.
    final swatchSize = isMobile ? 64.0 : 90.0;
    // Отступ между кружками.
    final gap = isMobile ? 12.0 : 18.0;
    // Внутренние отступы диалога.
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: GameTheme.values.map((theme) {
            // Проверяем, является ли тема выбранной.
            final isSelected = theme == selectedTheme;
            return Padding(
              padding: EdgeInsets.only(right: theme == GameTheme.values.last ? 0 : gap),
              child: _ThemeSwatch(
                theme: theme,
                size: swatchSize,
                selected: isSelected,
                onTap: () => onSelect(theme),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Элемент-плитка для отображения одной темы.
class _ThemeSwatch extends StatelessWidget {
  /// Тема, которую представляет плитка.
  final GameTheme theme;

  /// Размер плитки.
  final double size;

  /// Выделена ли плитка как выбранная.
  final bool selected;

  /// Обработчик нажатия на плитку.
  final VoidCallback onTap;

  /// Создаёт плитку темы.
  const _ThemeSwatch({
    required this.theme,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Палитра цветов для выбранной темы.
    final palette = theme.palette;
    // Вспомогательные параметры для позиционирования цветного акцента.
    final style = _SwatchStyle.forTheme(theme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: ClipOval(
          child: Stack(
            children: [
              Container(color: palette.block),
              Align(
                alignment: style.alignment,
                child: Transform.translate(
                  offset: Offset(style.offset.dx * size, style.offset.dy * size),
                  child: SizedBox(
                    width: size * style.scale,
                    height: size * style.scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.icon,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Параметры расположения акцентного круга внутри плитки.
class _SwatchStyle {
  /// Выравнивание акцентного круга.
  final Alignment alignment;

  /// Смещение акцента относительно центра.
  final Offset offset;

  /// Масштаб акцентного круга.
  final double scale;

  /// Создаёт объект параметров оформления.
  const _SwatchStyle({
    required this.alignment,
    required this.offset,
    required this.scale,
  });

  /// Возвращает параметры для конкретной темы.
  static _SwatchStyle forTheme(GameTheme theme) {
    switch (theme) {
      case GameTheme.red:
        return const _SwatchStyle(
          alignment: Alignment.topLeft,
          offset: Offset(-0.12, -0.12),
          scale: 1.25,
        );
      case GameTheme.orange:
        return const _SwatchStyle(
          alignment: Alignment.centerLeft,
          offset: Offset(-0.18, 0.0),
          scale: 1.25,
        );
      case GameTheme.purple:
        return const _SwatchStyle(
          alignment: Alignment.bottomCenter,
          offset: Offset(0.0, 0.18),
          scale: 1.3,
        );
      case GameTheme.blue:
        return const _SwatchStyle(
          alignment: Alignment.centerRight,
          offset: Offset(0.18, 0.0),
          scale: 1.25,
        );
      case GameTheme.green:
        return const _SwatchStyle(
          alignment: Alignment.topRight,
          offset: Offset(0.12, -0.12),
          scale: 1.25,
        );
    }
  }
}

import 'package:flutter/material.dart';

/// Набор базовых цветов приложения.
class AppColors {
  /// Основной фон экранов.
  static const background = Colors.white;

  /// Светлый "персиковый" оттенок для акцентов.
  static const peachLight = Color(0xFFFFF5EB);

  /// Средний "персиковый" оттенок.
  static const peachMedium = Color(0xFFFFDAB9);

  /// Тёмный "персиковый" оттенок.
  static const peachDark = Color(0xFFE69138);

  /// Цвет декоративного круга на главном экране.
  static const peachCircle = Color(0xFFFFEBD6);

  /// Основной цвет текста.
  static const textPrimary = Colors.black;

  /// Вторичный цвет текста.
  static const textSecondary = Color(0xFF9E9E9E);

  /// Серый цвет иконок.
  static const iconGray = Color(0xFFBDBDBD);

  /// Цвет для лёгкой сложности.
  static const easyGreen = Color(0xFF2E7D32);

  /// Цвет для средней сложности.
  static const mediumOrange = Color(0xFFE69138);

  /// Цвет для сложной сложности.
  static const hardRed = Color(0xFFC62828);

  /// Подсветка выбранной строки/столбца в сетке.
  static const gridHighlight = Color(0xFFF0F0F0);

  /// Цвет линий сетки.
  static const gridLines = Colors.black;
}

/// Палитра текущей темы — цвета блоков, линий и иконок.
class ThemePalette {
  /// Цвет заливки блоков 3x3.
  final Color block;

  /// Цвет тонких линий сетки.
  final Color thinLine;

  /// Цвет иконок/акцентов.
  final Color icon;

  /// Создаёт палитру темы.
  const ThemePalette({
    required this.block,
    required this.thinLine,
    required this.icon,
  });

  /// Цвет кнопок (используем тот же, что и у блоков).
  Color get button => block;

  /// Цвет подсветки выбранной строки/столбца.
  Color get highlight {
    return Color.fromARGB(
      255,
      (block.red * 0.95).round(),
      (block.green * 0.90).round(),
      (block.blue * 0.90).round(),
    );
  }
}

/// Доступные цветовые темы игры.
enum GameTheme {
  /// Красная тема.
  red,

  /// Оранжевая тема.
  orange,

  /// Фиолетовая тема.
  purple,

  /// Синяя тема.
  blue,

  /// Зелёная тема.
  green,
}

/// Расширение, возвращающее палитру для выбранной темы.
extension GameThemeX on GameTheme {
  /// Палитра цветов, соответствующая текущей теме.
  ThemePalette get palette {
    switch (this) {
      case GameTheme.red:
        return const ThemePalette(
          block: Color(0xFFFDD1D1),
          thinLine: Color(0xFFF6CCCC),
          icon: Color(0xFFC43B3B),
        );
      case GameTheme.orange:
        return const ThemePalette(
          block: Color(0xFFFFEAC9),
          thinLine: Color(0xFFEDDABB),
          icon: Color(0xFFF4AE52),
        );
      case GameTheme.purple:
        return const ThemePalette(
          block: Color(0xFFECC5F6),
          thinLine: Color(0xFFDCB7E5),
          icon: Color(0xFFBC51C2),
        );
      case GameTheme.blue:
        return const ThemePalette(
          block: Color(0xFFB1C0FF),
          thinLine: Color(0xFFA5B3ED),
          icon: Color(0xFF5179C2),
        );
      case GameTheme.green:
        return const ThemePalette(
          block: Color(0xFFC5F8BD),
          thinLine: Color(0xFFB6E7AF),
          icon: Color(0xFF289623),
        );
    }
  }
}

/// Уровни сложности с количеством подсказок и цветами.
enum Difficulty {
  /// Лёгкий уровень: больше подсказок.
  easy(38, 'лёгкі', AppColors.easyGreen),
  /// Средний уровень: сбалансированное число подсказок.
  medium(30, 'сярэдні', AppColors.mediumOrange),
  /// Сложный уровень: минимум подсказок.
  hard(24, 'складаны', AppColors.hardRed);

  /// Сколько заполненных клеток остаётся в начале игры.
  final int clues;

  /// Локализованная подпись уровня.
  final String label;

  /// Цвет, связанный с уровнем сложности.
  final Color color;

  /// Создаёт описание уровня сложности.
  const Difficulty(this.clues, this.label, this.color);
}

/// Статические строки интерфейса.
class AppStrings {
  /// Заголовок игры.
  static const title = 'SUDOKU';

  /// Текст кнопки запуска новой игры.
  static const newGame = 'новая гульня';

  /// Текст кнопки выхода.
  static const exit = 'выхад';
}

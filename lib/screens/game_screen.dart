import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/sudoku_cell.dart';
import '../providers/game_provider.dart';
import '../widgets/end_game_dialog.dart';
import '../widgets/theme_dialog.dart';

/// Экран игры: отображает поле Судоку, кнопки и состояние партии.
class GameScreen extends ConsumerWidget {
  /// Создаёт экран игры.
  const GameScreen({super.key});

  // === Десктопный макет (1920x1327) ===

  static const double _screenWidth = 1920; // Ширина макета для десктопа.
  static const double _screenHeight = 1327; // Высота макета для десктопа.

  static const double _boardLeft = 297; // Отступ поля слева.
  static const double _boardTop = 355; // Отступ поля сверху.
  static const double _boardSize = 735; // Размер квадрата поля.

  static const double _titleLeft = 383; // Отступ заголовка слева.
  static const double _titleTop = 159; // Отступ заголовка сверху.
  static const double _titleWidth = 487; // Ширина области заголовка.
  static const double _titleHeight = 61; // Высота области заголовка.

  static const double _desktopBackLeft = 141; // Отступ кнопки "назад" слева.
  static const double _desktopBackTop = 165; // Отступ кнопки "назад" сверху.
  static const double _desktopBackWidth = 40; // Ширина кнопки "назад".
  static const double _desktopBackHeight = 35; // Высота кнопки "назад".

  static const double _desktopMistakesLeft = 300; // Отступ счётчика ошибок слева.
  static const double _desktopMistakesTop = 313; // Отступ счётчика ошибок сверху.
  static const double _desktopMistakesWidth = 188; // Ширина области счётчика ошибок.
  static const double _desktopMistakesHeight = 24; // Высота области счётчика ошибок.

  static const double _desktopDifficultyLeft = 910; // Отступ сложности слева.
  static const double _desktopDifficultyTop = 314; // Отступ сложности сверху.
  static const double _desktopDifficultyWidth = 116; // Ширина области сложности.
  static const double _desktopDifficultyHeight = 26; // Высота области сложности.

  static const double _desktopPaintLeft = 1394; // Отступ иконки темы слева.
  static const double _desktopPaintTop = 161; // Отступ иконки темы сверху.
  static const double _desktopPaintWidth = 83; // Ширина иконки темы.
  static const double _desktopPaintHeight = 93; // Высота иконки темы.

  static const double _desktopSettingsLeft = 1526; // Отступ иконки настроек слева.
  static const double _desktopSettingsTop = 161; // Отступ иконки настроек сверху.
  static const double _desktopSettingsWidth = 93; // Ширина иконки настроек.
  static const double _desktopSettingsHeight = 94; // Высота иконки настроек.

  static const double _numpadLeft = 1153; // Отступ цифрового блока слева.
  static const double _numpadTop = 373; // Отступ цифрового блока сверху.
  static const double _numpadCellSize = 140; // Размер одной кнопки цифрового блока.
  static const double _numpadGapX = 24; // Горизонтальный интервал между кнопками.
  static const double _numpadGapY = 26; // Вертикальный интервал между кнопками.
  static const double _desktopNumpadFontSize = 96; // Размер шрифта цифр в блоке.

  static const double _desktopActionTop = 890; // Отступ ряда действий сверху.
  static const double _desktopActionHeight = 83; // Высота кнопок действий.
  static const double _desktopAction1Left = 1152; // Отступ кнопки "карандаш" слева.
  static const double _desktopAction2Left = 1317; // Отступ кнопки "ластик" слева.
  static const double _desktopAction3Left = 1481; // Отступ кнопки "подсказка" слева.
  static const double _desktopActionWidth = 140; // Ширина кнопок действий.

  static const double _desktopActionIconHeight = 50; // Высота иконок действий.
  static const double _desktopActionLabelFontSize = 16; // Размер подписи под иконкой.
  static const double _desktopActionLabelSpacing = 4; // Отступ между иконкой и подписью.

  static const double _newGameLeft = 1152; // Отступ кнопки новой игры слева.
  static const double _newGameTop = 1001; // Отступ кнопки новой игры сверху.
  static const double _newGameWidth = 468; // Ширина кнопки новой игры.
  static const double _newGameHeight = 90; // Высота кнопки новой игры.
  static const double _desktopNewGameTextWidth = 357; // Ширина области текста кнопки.
  static const double _desktopNewGameTextHeight = 37; // Высота области текста кнопки.

  // === Мобильный макет (412x917) ===

  static const double _mobileWidth = 412; // Ширина мобильного макета.
  static const double _mobileHeight = 917; // Высота мобильного макета.

  static const double _mobileBackLeft = 31; // Отступ кнопки "назад" слева (моб.).
  static const double _mobileBackTop = 106; // Отступ кнопки "назад" сверху (моб.).
  static const double _mobileBackWidth = 17; // Ширина кнопки "назад" (моб.).
  static const double _mobileBackHeight = 39; // Высота кнопки "назад" (моб.).

  static const double _mobilePaintLeft = 294; // Отступ иконки темы слева (моб.).
  static const double _mobilePaintTop = 104; // Отступ иконки темы сверху (моб.).
  static const double _mobilePaintWidth = 37; // Ширина иконки темы (моб.).
  static const double _mobilePaintHeight = 96; // Высота иконки темы (моб.).

  static const double _mobileSettingsLeft = 354; // Отступ иконки настроек слева (моб.).
  static const double _mobileSettingsTop = 104; // Отступ иконки настроек сверху (моб.).
  static const double _mobileSettingsWidth = 42; // Ширина иконки настроек (моб.).
  static const double _mobileSettingsHeight = 43; // Высота иконки настроек (моб.).

  static const double _mobileTitleLeft = 75; // Отступ заголовка слева (моб.).
  static const double _mobileTitleTop = 173; // Отступ заголовка сверху (моб.).

  static const double _mobileMistakesLeft = 16; // Отступ ошибок слева (моб.).
  static const double _mobileMistakesTop = 237; // Отступ ошибок сверху (моб.).
  static const double _mobileDifficultyLeft = 364; // Отступ сложности слева (моб.).
  static const double _mobileDifficultyTop = 238; // Отступ сложности сверху (моб.).

  static const double _mobileBoardLeft = 16; // Отступ поля слева (моб.).
  static const double _mobileBoardTop = 253; // Отступ поля сверху (моб.).
  static const double _mobileBoardSize = 379; // Размер поля (моб.).

  static const double _mobileActionTop = 653; // Отступ ряда действий сверху (моб.).
  static const double _mobileActionHeight = 67; // Высота кнопок действий (моб.).
  static const double _mobileAction1Left = 16; // Отступ кнопки "карандаш" слева (моб.).
  static const double _mobileAction1Width = 113; // Ширина кнопки "карандаш" (моб.).
  static const double _mobileAction2Left = 150; // Отступ кнопки "ластик" слева (моб.).
  static const double _mobileAction2Width = 112; // Ширина кнопки "ластик" (моб.).
  static const double _mobileAction3Left = 283; // Отступ кнопки "подсказка" слева (моб.).
  static const double _mobileAction3Width = 112; // Ширина кнопки "подсказка" (моб.).

  static const double _mobileActionIconHeight = 34; // Высота иконок действий (моб.).
  static const double _mobileActionLabelFontSize = 10; // Размер подписи действий (моб.).
  static const double _mobileActionLabelSpacing = 3; // Отступ подписи от иконки (моб.).

  static const double _mobileNumbersLeft = 16; // Отступ панели чисел слева (моб.).
  static const double _mobileNumbersTop = 740; // Отступ панели чисел сверху (моб.).
  static const double _mobileNumbersWidth = 379; // Ширина панели чисел (моб.).
  static const double _mobileNumbersHeight = 64; // Высота панели чисел (моб.).
  static const double _mobileNumberInset = 5; // Внутренний отступ панели чисел.
  static const double _mobileNumberCell = 41; // Ширина одной цифры (моб.).

  static const Color _mobileIconGrey = Color(0xFFDDDDDD); // Цвет иконок (моб.).

  static const Color _desktopIconGrey = Color(0xFFE2E2E2); // Цвет иконок (дескт.).

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Текущее состояние игры из провайдера.
    final gameState = ref.watch(gameProvider);

    // Слушаем завершение игры, чтобы показать диалог.
    ref.listen<GameState>(gameProvider, (previous, next) {
      // previous/next — состояние до и после обновления.
      // Флаг предыдущего состояния (заканчивается ли игра).
      final wasOver = previous?.isGameOver ?? false;
      if (wasOver || !next.isGameOver) return;

      // Победа, если ошибок меньше 3.
      final isWin = next.mistakes < 3;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => EndGameDialog(
            isWin: isWin,
            onMainMenu: () => Navigator.of(context).popUntil((route) => route.isFirst),
            onRestart: () {
              Navigator.of(context).pop();
              ref.read(gameProvider.notifier).startNewGame(next.difficulty);
            },
          ),
        );
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Определяем, мобильный ли формат.
          final isMobile = constraints.maxWidth < 700;
          // Размеры макета, на который будет масштабироваться интерфейс.
          final designWidth = isMobile ? _mobileWidth : _screenWidth;
          final designHeight = isMobile ? _mobileHeight : _screenHeight;

          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: designWidth,
                height: designHeight,
                child: Stack(
                  children: isMobile
                      ? _buildMobileLayout(context, ref, gameState)
                      : _buildDesktopLayout(context, ref, gameState),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Показывает диалог выбора цветовой темы.
  void _showThemeDialog(BuildContext context, WidgetRef ref, GameTheme selectedTheme) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ThemeDialog(
        selectedTheme: selectedTheme,
        onSelect: (theme) {
          ref.read(gameProvider.notifier).setTheme(theme);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Собирает список виджетов для десктопного макета.
  List<Widget> _buildDesktopLayout(BuildContext context, WidgetRef ref, GameState gameState) {
    // Количество ошибок для отображения.
    final errorCount = gameState.mistakes;
    // Палитра текущей темы.
    final palette = gameState.theme.palette;
    // Базовый список элементов интерфейса.
    final widgets = <Widget>[
      Positioned(
        left: _desktopBackLeft,
        top: _desktopBackTop,
        width: _desktopBackWidth,
        height: _desktopBackHeight,
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: CustomPaint(
            painter: _BackChevronPainter(palette.icon),
          ),
        ),
      ),
      Positioned(
        left: _titleLeft,
        top: _titleTop,
        width: _titleWidth,
        height: _titleHeight,
        child: const FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          child: Text(
            AppStrings.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 132,
              fontFamily: 'Anonymous Pro',
              fontWeight: FontWeight.w400,
              height: 1.0,
            ),
          ),
        ),
      ),
      Positioned(
        left: _desktopMistakesLeft,
        top: _desktopMistakesTop,
        width: _desktopMistakesWidth,
        height: _desktopMistakesHeight,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          child: Text(
            'памылкі $errorCount/3',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'Anonymous Pro',
              fontWeight: FontWeight.w400,
              height: 1.0,
            ),
          ),
        ),
      ),
      Positioned(
        left: _desktopDifficultyLeft,
        top: _desktopDifficultyTop,
        width: _desktopDifficultyWidth,
        height: _desktopDifficultyHeight,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
          child: Text(
            gameState.difficulty.label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'Anonymous Pro',
              fontWeight: FontWeight.w400,
              height: 1.0,
            ),
          ),
        ),
      ),
      Positioned(
        left: _desktopPaintLeft,
        top: _desktopPaintTop,
        width: _desktopPaintWidth,
        height: _desktopPaintHeight,
        child: GestureDetector(
          onTap: () => _showThemeDialog(context, ref, gameState.theme),
          child: const FittedBox(
            fit: BoxFit.contain,
            child: Icon(Icons.format_paint_outlined, color: _desktopIconGrey),
          ),
        ),
      ),
      Positioned(
        left: _desktopSettingsLeft,
        top: _desktopSettingsTop,
        width: _desktopSettingsWidth,
        height: _desktopSettingsHeight,
        child: const FittedBox(
          fit: BoxFit.contain,
          child: Icon(Icons.settings_outlined, color: _desktopIconGrey),
        ),
      ),
      Positioned(
        left: _boardLeft,
        top: _boardTop,
        child: _SudokuBoard(
          size: _boardSize,
          state: gameState,
          onSelect: (r, c) => ref.read(gameProvider.notifier).selectCell(r, c),
          blockColor: palette.block,
          highlightColor: palette.highlight,
          thinLineColor: palette.thinLine,
          thickLineColor: Colors.black,
          thinLineWidth: 1.0,
          thickLineWidth: 1.0,
          cellFontSize: 72,
        ),
      ),
      Positioned(
        left: _numpadLeft,
        top: _numpadTop,
        child: _buildNumpad(ref, palette.button),
      ),
      Positioned(
        left: _newGameLeft,
        top: _newGameTop,
        child: _buildNewGameButton(ref, gameState, palette.button),
      ),
    ];

    widgets.addAll(_buildDesktopActionButtons(ref, palette.button));
    widgets.addAll(_buildDesktopActionIcons(palette.icon));

    return widgets;
  }

  /// Создаёт фоновые кнопки действий для десктопа.
  List<Widget> _buildDesktopActionButtons(WidgetRef ref, Color buttonColor) {
    return [
      _buildDesktopActionButton(
        left: _desktopAction1Left,
        color: buttonColor,
        onTap: () => ref.read(gameProvider.notifier).toggleNoteMode(),
      ),
      _buildDesktopActionButton(
        left: _desktopAction2Left,
        color: buttonColor,
        onTap: () => ref.read(gameProvider.notifier).inputNumber(0),
      ),
      _buildDesktopActionButton(
        left: _desktopAction3Left,
        color: buttonColor,
        onTap: () => ref.read(gameProvider.notifier).giveHint(),
      ),
    ];
  }

  /// Рисует одну кнопку действия (фон).
  Widget _buildDesktopActionButton({
    required double left,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: _desktopActionTop,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: _desktopActionWidth,
          height: _desktopActionHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// Возвращает иконки/подписи для кнопок действий (десктоп).
  List<Widget> _buildDesktopActionIcons(Color iconColor) {
    return [
      _buildActionContent(
        left: _desktopAction1Left,
        top: _desktopActionTop,
        width: _desktopActionWidth,
        height: _desktopActionHeight,
        asset: 'assets/icon_pencil.png',
        label: 'алоўак',
        color: iconColor,
        iconHeight: _desktopActionIconHeight,
        fontSize: _desktopActionLabelFontSize,
        spacing: _desktopActionLabelSpacing,
      ),
      _buildActionContent(
        left: _desktopAction2Left,
        top: _desktopActionTop,
        width: _desktopActionWidth,
        height: _desktopActionHeight,
        asset: 'assets/icon_eraser.png',
        label: 'гумка',
        color: iconColor,
        iconHeight: _desktopActionIconHeight,
        fontSize: _desktopActionLabelFontSize,
        spacing: _desktopActionLabelSpacing,
      ),
      _buildActionContent(
        left: _desktopAction3Left,
        top: _desktopActionTop,
        width: _desktopActionWidth,
        height: _desktopActionHeight,
        asset: 'assets/icon_hint.png',
        label: 'падказка',
        color: iconColor,
        iconHeight: _desktopActionIconHeight,
        fontSize: _desktopActionLabelFontSize,
        spacing: _desktopActionLabelSpacing,
      ),
    ];
  }

  /// Собирает список виджетов для мобильного макета.
  List<Widget> _buildMobileLayout(BuildContext context, WidgetRef ref, GameState gameState) {
    // Количество ошибок для отображения.
    final errorCount = gameState.mistakes;
    // Палитра текущей темы.
    final palette = gameState.theme.palette;
    // Базовый список элементов интерфейса.
    final List<Widget> widgets = [
      Positioned(
        left: _mobileBackLeft,
        top: _mobileBackTop,
        width: _mobileBackWidth,
        height: _mobileBackHeight,
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: CustomPaint(
            painter: _BackChevronPainter(palette.icon),
          ),
        ),
      ),
      Positioned(
        left: _mobilePaintLeft,
        top: _mobilePaintTop,
        width: _mobilePaintWidth,
        height: _mobilePaintHeight,
        child: GestureDetector(
          onTap: () => _showThemeDialog(context, ref, gameState.theme),
          child: const FittedBox(
            fit: BoxFit.contain,
            child: Icon(Icons.format_paint_outlined, color: _mobileIconGrey),
          ),
        ),
      ),
      Positioned(
        left: _mobileSettingsLeft,
        top: _mobileSettingsTop,
        width: _mobileSettingsWidth,
        height: _mobileSettingsHeight,
        child: const FittedBox(
          fit: BoxFit.contain,
          child: Icon(Icons.settings_outlined, color: _mobileIconGrey),
        ),
      ),
      Positioned(
        left: _mobileTitleLeft,
        top: _mobileTitleTop,
        child: const Text(
          AppStrings.title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 46,
            fontFamily: 'Anonymous Pro',
            fontWeight: FontWeight.w400,
            height: 1.0,
          ),
        ),
      ),
      Positioned(
        left: _mobileMistakesLeft,
        top: _mobileMistakesTop,
        child: Text(
          'mistakes $errorCount/3',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Anonymous Pro',
            fontWeight: FontWeight.w400,
            height: 1.0,
          ),
        ),
      ),
      Positioned(
        left: _mobileDifficultyLeft,
        top: _mobileDifficultyTop,
        child: Text(
          gameState.difficulty.label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Anonymous Pro',
            fontWeight: FontWeight.w400,
            height: 1.0,
          ),
        ),
      ),
      Positioned(
        left: _mobileBoardLeft,
        top: _mobileBoardTop,
        child: _SudokuBoard(
          size: _mobileBoardSize,
          state: gameState,
          onSelect: (r, c) => ref.read(gameProvider.notifier).selectCell(r, c),
          blockColor: palette.block,
          highlightColor: palette.highlight,
          thinLineColor: palette.thinLine,
          thickLineColor: Colors.black,
          thinLineWidth: 1.0,
          thickLineWidth: 1.0,
          cellFontSize: 30,
        ),
      ),
      _buildMobileActionButton(
        left: _mobileAction1Left,
        width: _mobileAction1Width,
        color: palette.button,
        onTap: () => ref.read(gameProvider.notifier).toggleNoteMode(),
      ),
      _buildMobileActionButton(
        left: _mobileAction2Left,
        width: _mobileAction2Width,
        color: palette.button,
        onTap: () => ref.read(gameProvider.notifier).inputNumber(0),
      ),
      _buildMobileActionButton(
        left: _mobileAction3Left,
        width: _mobileAction3Width,
        color: palette.button,
        onTap: () => ref.read(gameProvider.notifier).giveHint(),
      ),
      Positioned(
        left: _mobileNumbersLeft,
        top: _mobileNumbersTop,
        child: Container(
          width: _mobileNumbersWidth,
          height: _mobileNumbersHeight,
          decoration: BoxDecoration(
            color: palette.button,
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    ];

    widgets.addAll(_buildMobileActionIcons(palette.icon));
    widgets.addAll(_buildMobileNumberButtons(ref));

    return widgets;
  }

  /// Рисует фон кнопки действия для мобильного макета.
  Widget _buildMobileActionButton({
    required double left,
    required double width,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: _mobileActionTop,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: _mobileActionHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// Возвращает иконки/подписи для кнопок действий (моб.).
  List<Widget> _buildMobileActionIcons(Color iconColor) {
    return [
      _buildActionContent(
        left: _mobileAction1Left,
        top: _mobileActionTop,
        width: _mobileAction1Width,
        height: _mobileActionHeight,
        asset: 'assets/icon_pencil.png',
        label: 'алоўак',
        color: iconColor,
        iconHeight: _mobileActionIconHeight,
        fontSize: _mobileActionLabelFontSize,
        spacing: _mobileActionLabelSpacing,
      ),
      _buildActionContent(
        left: _mobileAction2Left,
        top: _mobileActionTop,
        width: _mobileAction2Width,
        height: _mobileActionHeight,
        asset: 'assets/icon_eraser.png',
        label: 'гумка',
        color: iconColor,
        iconHeight: _mobileActionIconHeight,
        fontSize: _mobileActionLabelFontSize,
        spacing: _mobileActionLabelSpacing,
      ),
      _buildActionContent(
        left: _mobileAction3Left,
        top: _mobileActionTop,
        width: _mobileAction3Width,
        height: _mobileActionHeight,
        asset: 'assets/icon_hint.png',
        label: 'падказка',
        color: iconColor,
        iconHeight: _mobileActionIconHeight,
        fontSize: _mobileActionLabelFontSize,
        spacing: _mobileActionLabelSpacing,
      ),
    ];
  }

  /// Универсальный блок с иконкой и подписью для кнопок действий.
  Widget _buildActionContent({
    required double left,
    required double top,
    required double width,
    required double height,
    required String asset,
    required String label,
    required Color color,
    required double iconHeight,
    required double fontSize,
    required double spacing,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: IgnorePointer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: iconHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(
                  image: AssetImage(asset),
                  color: color,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: spacing),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize,
                fontFamily: 'Anonymous Pro',
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Создаёт кнопки чисел для мобильного режима.
  List<Widget> _buildMobileNumberButtons(WidgetRef ref) {
    // Список кнопок 1..9.
    final List<Widget> buttons = [];

    // i — индекс цифры от 0 до 8.
    for (int i = 0; i < 9; i++) {
      // Горизонтальная позиция текущей цифры.
      final left = _mobileNumbersLeft + _mobileNumberInset + _mobileNumberCell * i;
      buttons.add(
        Positioned(
          left: left,
          top: _mobileNumbersTop,
          width: _mobileNumberCell,
          height: _mobileNumbersHeight,
          child: GestureDetector(
            onTap: () => ref.read(gameProvider.notifier).inputNumber(i + 1),
            behavior: HitTestBehavior.translucent,
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, 2),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Major Mono Display',
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  /// Строит цифровой блок (numpad) для десктопа.
  Widget _buildNumpad(WidgetRef ref, Color buttonColor) {
    return SizedBox(
      width: _numpadCellSize * 3 + _numpadGapX * 2,
      height: _numpadCellSize * 3 + _numpadGapY * 2,
      child: Column(
        children: List.generate(3, (r) {
          // r — индекс строки в numpad.
          return Padding(
            padding: EdgeInsets.only(bottom: r < 2 ? _numpadGapY : 0),
            child: Row(
              children: List.generate(3, (c) {
                // c — индекс столбца в numpad.
                final value = r * 3 + c + 1;
                return Padding(
                  padding: EdgeInsets.only(right: c < 2 ? _numpadGapX : 0),
                  child: _buildNumpadButton(ref, value, buttonColor),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  /// Строит кнопку numpad с числом [number].
  Widget _buildNumpadButton(WidgetRef ref, int number, Color buttonColor) {
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).inputNumber(number),
      child: Container(
        width: _numpadCellSize,
        height: _numpadCellSize,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.black,
            fontSize: _desktopNumpadFontSize,
            fontFamily: 'Major Mono Display',
            fontWeight: FontWeight.w400,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  /// Строит кнопку "Новая игра".
  Widget _buildNewGameButton(WidgetRef ref, GameState state, Color buttonColor) {
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).startNewGame(state.difficulty),
      child: Container(
        width: _newGameWidth,
        height: _newGameHeight,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: _desktopNewGameTextWidth,
          height: _desktopNewGameTextHeight,
          child: const FittedBox(
            fit: BoxFit.contain,
            child: Text(
              AppStrings.newGame,
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontFamily: 'Anonymous Pro',
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Виджет, рисующий сетку Судоку и обрабатывающий выбор клеток.
class _SudokuBoard extends StatelessWidget {
  /// Размер квадрата поля (в пикселях дизайна).
  final double size;

  /// Текущее состояние игры.
  final GameState state;

  /// Коллбек выбора клетки (row/col).
  final void Function(int row, int col) onSelect;

  /// Цвет заливки блоков 3x3.
  final Color blockColor;

  /// Цвет подсветки выбранной строки/столбца.
  final Color highlightColor;

  /// Цвет тонких линий.
  final Color thinLineColor;

  /// Цвет толстых линий.
  final Color thickLineColor;

  /// Толщина тонких линий.
  final double thinLineWidth;

  /// Толщина толстых линий.
  final double thickLineWidth;

  /// Размер шрифта для цифр в клетках.
  final double cellFontSize;

  /// Создаёт виджет поля с параметрами отрисовки.
  const _SudokuBoard({
    required this.size,
    required this.state,
    required this.onSelect,
    this.blockColor = const Color(0x6BD5D5D5),
    this.highlightColor = const Color(0x63B0B0B0),
    this.thinLineColor = const Color(0x12000000),
    this.thickLineColor = Colors.black,
    this.thinLineWidth = 1.6,
    this.thickLineWidth = 1.6,
    this.cellFontSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _SudokuBoardPainter(
              selectedRow: state.selectedRow,
              selectedCol: state.selectedCol,
              blockColor: blockColor,
              highlightColor: highlightColor,
              thinLineColor: thinLineColor,
              thickLineColor: thickLineColor,
              thinLineWidth: thinLineWidth,
              thickLineWidth: thickLineWidth,
            ),
          ),
          Positioned.fill(
            child: Column(
              children: List.generate(9, (r) {
                // r — индекс строки в поле.
                return Expanded(
                  child: Row(
                    children: List.generate(9, (c) {
                      // c — индекс столбца в поле.
                      return Expanded(
                        child: _SudokuCell(
                          cell: _safeCell(r, c),
                          onTap: () => onSelect(r, c),
                          fontSize: cellFontSize,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Возвращает клетку, даже если доска ещё не создана.
  SudokuCell _safeCell(int r, int c) {
    if (state.board.isEmpty) {
      return SudokuCell();
    }
    return state.board[r][c];
  }
}

/// Виджет отдельной клетки поля.
class _SudokuCell extends StatelessWidget {
  /// Модель клетки с её состоянием.
  final SudokuCell cell;

  /// Обработчик нажатия на клетку.
  final VoidCallback onTap;

  /// Размер шрифта цифры в клетке.
  final double fontSize;

  /// Создаёт виджет клетки.
  const _SudokuCell({
    required this.cell,
    required this.onTap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Значение клетки (0 — пусто).
    final value = cell.value;
    // Цвет текста: красный при ошибке.
    final textColor = cell.isError ? AppColors.hardRed : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: value == 0
            ? const SizedBox.shrink()
            : Text(
                '$value',
                textAlign: TextAlign.center,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontFamily: 'Major Mono Display',
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
      ),
    );
  }
}

/// CustomPainter, рисующий фон поля и линии сетки.
class _SudokuBoardPainter extends CustomPainter {
  /// Выбранная строка (может быть `null`).
  final int? selectedRow;

  /// Выбранный столбец (может быть `null`).
  final int? selectedCol;

  /// Цвет блоков 3x3.
  final Color blockColor;

  /// Цвет подсветки выбранных строки/столбца.
  final Color highlightColor;

  /// Цвет тонких линий.
  final Color thinLineColor;

  /// Цвет толстых линий.
  final Color thickLineColor;

  /// Толщина тонких линий.
  final double thinLineWidth;

  /// Толщина толстых линий.
  final double thickLineWidth;

  /// Создаёт painter с параметрами отрисовки.
  _SudokuBoardPainter({
    required this.selectedRow,
    required this.selectedCol,
    required this.blockColor,
    required this.highlightColor,
    required this.thinLineColor,
    required this.thickLineColor,
    required this.thinLineWidth,
    required this.thickLineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Размер одной клетки.
    final cell = size.width / 9;
    // Базовая кисть для заливок.
    final paint = Paint()..style = PaintingStyle.fill;

    // Рисуем чередующиеся блоки 3x3.
    // br/bc — индексы блока по вертикали и горизонтали.
    for (int br = 0; br < 3; br++) {
      for (int bc = 0; bc < 3; bc++) {
        paint.color = ((br + bc) % 2 == 0) ? blockColor : Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(bc * cell * 3, br * cell * 3, cell * 3, cell * 3),
          paint,
        );
      }
    }

    // Подсветка выбранной строки.
    if (selectedRow != null) {
      paint.color = highlightColor;
      canvas.drawRect(
        Rect.fromLTWH(0, selectedRow! * cell, size.width, cell),
        paint,
      );
    }

    // Подсветка выбранного столбца.
    if (selectedCol != null) {
      paint.color = highlightColor;
      canvas.drawRect(
        Rect.fromLTWH(selectedCol! * cell, 0, cell, size.height),
        paint,
      );
    }

    // Кисть для тонких линий.
    final thinPaint = Paint()
      ..color = thinLineColor
      ..strokeWidth = thinLineWidth;
    // Кисть для толстых линий.
    final thickPaint = Paint()
      ..color = thickLineColor
      ..strokeWidth = thickLineWidth;

    // Рисуем тонкие линии между клетками.
    for (int i = 1; i < 9; i++) {
      // i — индекс линии между клетками.
      // Координата линии сетки.
      final pos = cell * i;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), thinPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), thinPaint);
    }

    // Рисуем толстые линии границ блоков 3x3.
    for (int i = 0; i <= 9; i += 3) {
      // i — индекс границы блока 3x3.
      // Координата границы блока 3x3.
      final pos = cell * i;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), thickPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), thickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SudokuBoardPainter oldDelegate) {
    return oldDelegate.selectedRow != selectedRow ||
        oldDelegate.selectedCol != selectedCol ||
        oldDelegate.blockColor != blockColor ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.thinLineColor != thinLineColor ||
        oldDelegate.thickLineColor != thickLineColor ||
        oldDelegate.thinLineWidth != thinLineWidth ||
        oldDelegate.thickLineWidth != thickLineWidth;
  }
}

/// Painter, рисующий двойную стрелку "назад".
class _BackChevronPainter extends CustomPainter {
  /// Цвет линий стрелки.
  final Color color;

  /// Создаёт painter для стрелки с заданным цветом.
  _BackChevronPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Настройка кисти.
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Размеры области рисования.
    final w = size.width;
    final h = size.height;

    // Первая половина двойной стрелки.
    final path1 = Path()
      ..moveTo(w * 0.72, h * 0.08)
      ..lineTo(w * 0.28, h * 0.5)
      ..lineTo(w * 0.72, h * 0.92);

    // Вторая половина двойной стрелки.
    final path2 = Path()
      ..moveTo(w * 0.98, h * 0.08)
      ..lineTo(w * 0.54, h * 0.5)
      ..lineTo(w * 0.98, h * 0.92);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _BackChevronPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

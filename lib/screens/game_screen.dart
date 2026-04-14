import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/sudoku_cell.dart';
import '../providers/game_provider.dart';
import '../widgets/end_game_dialog.dart';
import '../widgets/theme_dialog.dart';

/// Главный экран игры в Судоку.
///
/// Отвечает за:
/// - Отображение поля 9×9 ([_SudokuBoard]), цифровых кнопок и кнопок действий.
/// - Адаптивную раскладку: мобильная (ширина < 700) или десктопная.
/// - Масштабирование интерфейса через [FittedBox]: вся вёрстка ведётся
///   в фиксированных «пикселях дизайна» (412×917 / 1920×1327),
///   а [FittedBox] подстраивает их под реальный экран, сохраняя пропорции.
/// - Реакцию на конец игры: при [GameState.isGameOver] показывает
///   [EndGameDialog] через [WidgetsBinding.addPostFrameCallback],
///   чтобы не строить диалог во время сборки дерева виджетов.
/// - Выбор цветовой темы через [ThemeDialog].
class GameScreen extends ConsumerWidget {
  /// Создаёт главный экран игры.
  const GameScreen({super.key});

  // ───────────────────────────────────────────────────────────────────────────
  // КОНСТАНТЫ ДЕСКТОПНОГО МАКЕТА (проектные размеры 1920 × 1327)
  //
  // Все значения — в «пикселях дизайна»; FittedBox масштабирует их
  // пропорционально до реального размера окна.
  // ───────────────────────────────────────────────────────────────────────────

  /// Ширина холста дизайна для десктопа.
  static const double _screenWidth = 1920;

  /// Высота холста дизайна для десктопа.
  static const double _screenHeight = 1327;

  // --- Игровое поле (desktop) ---

  /// Отступ игрового поля от левого края холста.
  static const double _boardLeft = 297;

  /// Отступ игрового поля от верхнего края холста.
  static const double _boardTop = 355;

  /// Размер стороны квадратного игрового поля.
  static const double _boardSize = 735;

  // --- Заголовок SUDOKU (desktop) ---

  /// Отступ заголовка от левого края.
  static const double _titleLeft = 383;

  /// Отступ заголовка от верхнего края.
  static const double _titleTop = 159;

  /// Ширина области заголовка (FittedBox масштабирует текст внутрь).
  static const double _titleWidth = 487;

  /// Высота области заголовка.
  static const double _titleHeight = 61;

  // --- Кнопка «Назад» (desktop) ---

  /// Отступ кнопки «Назад» от левого края.
  static const double _desktopBackLeft = 141;

  /// Отступ кнопки «Назад» от верхнего края.
  static const double _desktopBackTop = 142;

  /// Ширина области кнопки «Назад».
  static const double _desktopBackWidth = 168;

  /// Высота области кнопки «Назад».
  static const double _desktopBackHeight = 77;

  // --- Счётчик ошибок (desktop) ---

  /// Отступ счётчика ошибок от левого края.
  static const double _desktopMistakesLeft = 300;

  /// Отступ счётчика ошибок от верхнего края.
  static const double _desktopMistakesTop = 313;

  /// Ширина области счётчика ошибок (FittedBox масштабирует текст внутрь).
  static const double _desktopMistakesWidth = 188;

  /// Высота области счётчика ошибок.
  static const double _desktopMistakesHeight = 24;

  // --- Метка сложности (desktop) ---

  /// Отступ метки сложности от левого края.
  static const double _desktopDifficultyLeft = 910;

  /// Отступ метки сложности от верхнего края.
  static const double _desktopDifficultyTop = 314;

  /// Ширина области метки сложности.
  static const double _desktopDifficultyWidth = 116;

  /// Высота области метки сложности.
  static const double _desktopDifficultyHeight = 26;

  // --- Кнопка выбора темы (desktop) ---

  /// Отступ иконки выбора темы от левого края.
  static const double _desktopPaintLeft = 1394;

  /// Отступ иконки выбора темы от верхнего края.
  static const double _desktopPaintTop = 161;

  /// Ширина области иконки выбора темы.
  static const double _desktopPaintWidth = 83;

  /// Высота области иконки выбора темы.
  static const double _desktopPaintHeight = 93;

  // --- Цифровой блок (numpad) 3×3 (desktop) ---

  /// Отступ цифрового блока от левого края.
  static const double _numpadLeft = 1153;

  /// Отступ цифрового блока от верхнего края.
  static const double _numpadTop = 373;

  /// Размер стороны одной клавиши цифрового блока.
  static const double _numpadCellSize = 140;

  /// Горизонтальный зазор между клавишами цифрового блока.
  static const double _numpadGapX = 24;

  /// Вертикальный зазор между клавишами цифрового блока.
  static const double _numpadGapY = 26;

  /// Размер шрифта цифры на клавише numpad.
  static const double _desktopNumpadFontSize = 96;

  // --- Кнопки действий: карандаш / ластик / подсказка (desktop) ---

  /// Вертикальное положение ряда кнопок действий.
  static const double _desktopActionTop = 890;

  /// Высота кнопок действий.
  static const double _desktopActionHeight = 83;

  /// Горизонтальное положение кнопки «Карандаш».
  static const double _desktopAction1Left = 1152;

  /// Горизонтальное положение кнопки «Ластик».
  static const double _desktopAction2Left = 1317;

  /// Горизонтальное положение кнопки «Подсказка».
  static const double _desktopAction3Left = 1481;

  /// Ширина каждой кнопки действия.
  static const double _desktopActionWidth = 140;

  /// Высота области иконки внутри кнопки действия.
  static const double _desktopActionIconHeight = 50;

  /// Размер шрифта подписи под иконкой кнопки действия.
  static const double _desktopActionLabelFontSize = 16;

  /// Отступ между иконкой и подписью кнопки действия.
  static const double _desktopActionLabelSpacing = 4;

  // --- Кнопка «Новая игра» (desktop) ---

  /// Отступ кнопки «Новая игра» от левого края.
  static const double _newGameLeft = 1152;

  /// Отступ кнопки «Новая игра» от верхнего края.
  static const double _newGameTop = 1001;

  /// Ширина кнопки «Новая игра».
  static const double _newGameWidth = 468;

  /// Высота кнопки «Новая игра».
  static const double _newGameHeight = 90;

  /// Ширина текстовой области внутри кнопки «Новая игра».
  static const double _desktopNewGameTextWidth = 357;

  /// Высота текстовой области внутри кнопки «Новая игра».
  static const double _desktopNewGameTextHeight = 37;

  // ───────────────────────────────────────────────────────────────────────────
  // КОНСТАНТЫ МОБИЛЬНОГО МАКЕТА (проектные размеры 412 × 917)
  // ───────────────────────────────────────────────────────────────────────────

  /// Ширина холста дизайна для мобильного макета.
  static const double _mobileWidth = 412;

  /// Высота холста дизайна для мобильного макета.
  static const double _mobileHeight = 917;

  // --- Шапка: кнопка «Назад» + заголовок + кнопка темы на одной линии ---
  //
  // Все три элемента шапки имеют одинаковые [top] и [height],
  // что выравнивает их по горизонтальной оси.

  /// Отступ кнопки «Назад» от левого края (мобильный).
  static const double _mobileBackLeft = 16;

  /// Вертикальное положение шапки — одинаково для всех трёх элементов.
  static const double _mobileBackTop = 98;

  /// Ширина области кнопки «Назад».
  static const double _mobileBackWidth = 70;

  /// Высота шапки — одинакова для кнопки «Назад», заголовка и кнопки темы.
  static const double _mobileBackHeight = 54;

  /// Отступ иконки выбора темы от левого края (мобильный).
  /// Расположена у правого края экрана.
  static const double _mobilePaintLeft = 359;

  /// Вертикальное положение иконки темы — совпадает с [_mobileBackTop].
  static const double _mobilePaintTop = 98;

  /// Ширина иконки выбора темы (мобильный).
  static const double _mobilePaintWidth = 37;

  /// Высота области иконки темы — совпадает с [_mobileBackHeight].
  static const double _mobilePaintHeight = 54;

  /// Отступ заголовка от левого края — сразу правее кнопки «Назад».
  static const double _mobileTitleLeft = 94;

  /// Вертикальное положение заголовка — совпадает с [_mobileBackTop].
  static const double _mobileTitleTop = 98;

  /// Ширина области заголовка — пространство между кнопкой «Назад» и кнопкой темы.
  static const double _mobileTitleWidth = 257;

  // --- Счётчик ошибок и метка сложности (мобильный) ---

  /// Отступ счётчика ошибок от левого края.
  static const double _mobileMistakesLeft = 16;

  /// Вертикальное положение счётчика ошибок.
  static const double _mobileMistakesTop = 237;

  /// Отступ метки сложности от левого края (прижата к правому краю экрана).
  static const double _mobileDifficultyLeft = 364;

  /// Вертикальное положение метки сложности.
  static const double _mobileDifficultyTop = 238;

  // --- Игровое поле (мобильный) ---

  /// Отступ поля от левого края.
  static const double _mobileBoardLeft = 16;

  /// Отступ поля от верхнего края.
  static const double _mobileBoardTop = 253;

  /// Размер стороны квадратного поля.
  static const double _mobileBoardSize = 379;

  // --- Кнопки действий: карандаш / ластик / подсказка (мобильный) ---

  /// Вертикальное положение ряда кнопок действий.
  static const double _mobileActionTop = 653;

  /// Высота кнопок действий.
  static const double _mobileActionHeight = 67;

  /// Отступ кнопки «Карандаш» от левого края.
  static const double _mobileAction1Left = 16;

  /// Ширина кнопки «Карандаш».
  static const double _mobileAction1Width = 113;

  /// Отступ кнопки «Ластик» от левого края.
  static const double _mobileAction2Left = 150;

  /// Ширина кнопки «Ластик».
  static const double _mobileAction2Width = 112;

  /// Отступ кнопки «Подсказка» от левого края.
  static const double _mobileAction3Left = 283;

  /// Ширина кнопки «Подсказка».
  static const double _mobileAction3Width = 112;

  /// Высота области иконки внутри кнопки действия.
  static const double _mobileActionIconHeight = 34;

  /// Размер шрифта подписи под иконкой.
  static const double _mobileActionLabelFontSize = 10;

  /// Отступ между иконкой и подписью.
  static const double _mobileActionLabelSpacing = 3;

  // --- Панель цифр 1–9 (мобильный) ---

  /// Отступ панели цифр от левого края.
  static const double _mobileNumbersLeft = 16;

  /// Вертикальное положение панели цифр.
  static const double _mobileNumbersTop = 740;

  /// Полная ширина панели цифр.
  static const double _mobileNumbersWidth = 379;

  /// Высота панели цифр.
  static const double _mobileNumbersHeight = 64;

  /// Внутренний горизонтальный отступ первой цифры от левого края панели.
  static const double _mobileNumberInset = 5;

  /// Ширина области одной цифры в панели (9 кнопок в ряд).
  static const double _mobileNumberCell = 41;

  // ───────────────────────────────────────────────────────────────────────────
  // ЦВЕТА
  // ───────────────────────────────────────────────────────────────────────────

  /// Цвет иконок на мобильном макете (светло-серый, нейтральный).
  static const Color _mobileIconGrey = Color(0xFFDDDDDD);

  /// Цвет иконок на десктопном макете (чуть теплее серого).
  static const Color _desktopIconGrey = Color(0xFFE2E2E2);

  /// Цвет цифр-кандидатов в режиме заметок (тёмно-серый, менее акцентный чем основные цифры).
  static const Color _noteTextColor = Color(0xFF4F4F4F);

  // ───────────────────────────────────────────────────────────────────────────
  // МЕТОДЫ
  // ───────────────────────────────────────────────────────────────────────────

  /// Собирает дерево виджетов экрана.
  ///
  /// Логика работы:
  /// 1. Подписывается на [gameProvider] для получения актуального [GameState].
  /// 2. Слушает изменения через [ref.listen]: при переходе игры в состояние
  ///    [GameState.isGameOver] откладывает показ [EndGameDialog] на следующий
  ///    кадр (через [WidgetsBinding.addPostFrameCallback]), чтобы не вызывать
  ///    `showDialog` во время выполнения `build`.
  /// 3. Возвращает [Scaffold] с [LayoutBuilder]:
  ///    - ширина < 700 → мобильный макет ([_buildMobileLayout]);
  ///    - иначе → десктопный макет ([_buildDesktopLayout]).
  /// 4. [FittedBox] масштабирует [SizedBox] проектного разрешения
  ///    до реальных размеров экрана, сохраняя пропорции.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Текущий снимок состояния игры из Riverpod-провайдера.
    final gameState = ref.watch(gameProvider);

    // Слушаем изменения состояния; при конце игры показываем диалог.
    ref.listen<GameState>(gameProvider, (previous, next) {
      // Если игра уже заканчивалась ранее или ещё не завершена — выходим.
      final wasOver = previous?.isGameOver ?? false;
      if (wasOver || !next.isGameOver) return;

      // Победа, если совершено менее 3 ошибок.
      final isWin = next.mistakes < 3;

      // Откладываем показ диалога на следующий кадр: Flutter запрещает
      // вызывать showDialog прямо внутри rebuild-цикла.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false, // нельзя закрыть тапом мимо диалога
          builder: (_) => EndGameDialog(
            isWin: isWin,
            onMainMenu: () =>
                // Возвращаемся на самый первый маршрут (главное меню).
                Navigator.of(context).popUntil((route) => route.isFirst),
            onRestart: () {
              Navigator.of(context).pop(); // закрываем диалог
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
          // Выбор макета по ширине: меньше 700 — мобильный, иначе — десктоп.
          final isMobile = constraints.maxWidth < 700;
          final designWidth = isMobile ? _mobileWidth : _screenWidth;
          final designHeight = isMobile ? _mobileHeight : _screenHeight;

          // FittedBox масштабирует SizedBox проектного разрешения до экрана.
          // Внутри SizedBox все элементы позиционируются в «пикселях дизайна».
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

  /// Показывает всплывающий диалог выбора цветовой темы.
  ///
  /// Передаёт [selectedTheme], чтобы диалог мог отобразить текущий выбор.
  /// При выборе новой темы вызывает [gameProvider.notifier.setTheme]
  /// и закрывает диалог.
  void _showThemeDialog(BuildContext context, WidgetRef ref, GameTheme selectedTheme) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // закрывается тапом вне диалога
      builder: (_) => ThemeDialog(
        selectedTheme: selectedTheme,
        onSelect: (theme) {
          ref.read(gameProvider.notifier).setTheme(theme);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ── Десктопный макет ───────────────────────────────────────────────────────

  /// Возвращает список [Positioned]-виджетов для десктопного макета.
  ///
  /// Элементы раскладываются в абсолютных координатах внутри [Stack]
  /// размером [_screenWidth] × [_screenHeight].
  /// Порядок в списке определяет Z-порядок: последний элемент — поверх.
  List<Widget> _buildDesktopLayout(BuildContext context, WidgetRef ref, GameState gameState) {
    final errorCount = gameState.mistakes;
    final palette = gameState.theme.palette;

    final widgets = <Widget>[
      // Кнопка «Назад» — возврат в главное меню.
      Positioned(
        left: _desktopBackLeft,
        top: _desktopBackTop,
        width: _desktopBackWidth,
        height: _desktopBackHeight,
        child: _buildBackButton(
          onTap: () => Navigator.of(context).maybePop(),
          theme: gameState.theme,
        ),
      ),

      // Заголовок «SUDOKU» — масштабируется через FittedBox.
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

      // Счётчик ошибок «памылкі N/3».
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

      // Метка текущей сложности (лёгкі / сярэдні / складаны).
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

      // Иконка «кисть» — открывает диалог смены темы.
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

      // Игровое поле 9×9.
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

      // Цифровой блок (numpad) 3×3 справа от поля.
      Positioned(
        left: _numpadLeft,
        top: _numpadTop,
        child: _buildNumpad(ref, palette.button),
      ),

      // Кнопка «Новая игра» под numpad.
      Positioned(
        left: _newGameLeft,
        top: _newGameTop,
        child: _buildNewGameButton(ref, gameState, palette.button),
      ),
    ];

    // Сначала — фоновые прямоугольники кнопок действий (обрабатывают тапы).
    widgets.addAll(_buildDesktopActionButtons(ref, palette, gameState.isNoteMode));
    // Поверх — иконки и подписи, завёрнутые в IgnorePointer (не перехватывают тапы).
    widgets.addAll(_buildDesktopActionIcons(palette.icon));

    return widgets;
  }

  /// Создаёт фоновые прямоугольники трёх кнопок действий (desktop).
  ///
  /// Кнопки: «Карандаш» (режим заметок), «Ластик» (стереть), «Подсказка».
  /// Активная кнопка (в данный момент — «Карандаш» в режиме [isNoteMode])
  /// выделяется цветной рамкой акцентного цвета темы.
  List<Widget> _buildDesktopActionButtons(
    WidgetRef ref,
    ThemePalette palette,
    bool isNoteMode,
  ) {
    return [
      _buildDesktopActionButton(
        left: _desktopAction1Left,
        color: palette.button,
        accentColor: palette.icon,
        isActive: isNoteMode, // рамка появляется при активном режиме заметок
        onTap: () => ref.read(gameProvider.notifier).toggleNoteMode(),
      ),
      _buildDesktopActionButton(
        left: _desktopAction2Left,
        color: palette.button,
        accentColor: palette.icon,
        onTap: () => ref.read(gameProvider.notifier).inputNumber(0), // 0 = стереть
      ),
      _buildDesktopActionButton(
        left: _desktopAction3Left,
        color: palette.button,
        accentColor: palette.icon,
        onTap: () => ref.read(gameProvider.notifier).giveHint(),
      ),
    ];
  }

  /// Строит один фоновый прямоугольник кнопки действия (desktop).
  ///
  /// [isActive] управляет видимостью рамки: если `true` — рисуется рамка
  /// цвета [accentColor] толщиной 3, иначе — прозрачная рамка нулевой ширины.
  Widget _buildDesktopActionButton({
    required double left,
    required Color color,
    required Color accentColor,
    required VoidCallback onTap,
    bool isActive = false,
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
            border: Border.all(
              color: isActive ? accentColor : Colors.transparent,
              width: isActive ? 3 : 0,
            ),
          ),
        ),
      ),
    );
  }

  /// Возвращает иконки и подписи для кнопок действий (desktop).
  ///
  /// Все три виджета завёрнуты в [IgnorePointer] — тапы «проваливаются»
  /// сквозь них к фоновым [GestureDetector]-ам ниже по стеку.
  List<Widget> _buildDesktopActionIcons(Color iconColor) {
    return [
      _buildActionContent(
        left: _desktopAction1Left,
        top: _desktopActionTop,
        width: _desktopActionWidth,
        height: _desktopActionHeight,
        asset: 'assets/icon_pencil.png',
        label: 'аловак',
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

  // ── Мобильный макет ────────────────────────────────────────────────────────

  /// Возвращает список [Positioned]-виджетов для мобильного макета.
  ///
  /// Элементы раскладываются в абсолютных координатах внутри [Stack]
  /// размером [_mobileWidth] × [_mobileHeight].
  ///
  /// Шапка (кнопка «Назад», заголовок, кнопка темы) расположена на одной
  /// горизонтальной линии: все три элемента имеют одинаковые [top] и [height].
  List<Widget> _buildMobileLayout(BuildContext context, WidgetRef ref, GameState gameState) {
    final errorCount = gameState.mistakes;
    final palette = gameState.theme.palette;

    final List<Widget> widgets = [
      // ── Шапка ─────────────────────────────────────────────────────────────

      // Кнопка «Назад» — левая часть шапки.
      Positioned(
        left: _mobileBackLeft,
        top: _mobileBackTop,
        width: _mobileBackWidth,
        height: _mobileBackHeight,
        child: _buildBackButton(
          onTap: () => Navigator.of(context).maybePop(),
          theme: gameState.theme,
        ),
      ),

      // Иконка выбора темы — правая часть шапки.
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

      // Заголовок «SUDOKU» — центральная часть шапки.
      // [Center] вертикально выравнивает текст (fontSize=46) внутри
      // строки высотой [_mobileBackHeight] (54px).
      Positioned(
        left: _mobileTitleLeft,
        top: _mobileTitleTop,
        width: _mobileTitleWidth,
        height: _mobileBackHeight,
        child: const Center(
          child: Text(
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
      ),

      // ── Подзаголовок ──────────────────────────────────────────────────────

      // Счётчик ошибок слева.
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

      // Метка сложности справа.
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

      // ── Игровое поле ──────────────────────────────────────────────────────

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

      // ── Кнопки действий ───────────────────────────────────────────────────

      // Фон кнопки «Карандаш»; при активном режиме заметок появляется рамка.
      _buildMobileActionButton(
        left: _mobileAction1Left,
        width: _mobileAction1Width,
        color: palette.button,
        accentColor: palette.icon,
        isActive: gameState.isNoteMode,
        onTap: () => ref.read(gameProvider.notifier).toggleNoteMode(),
      ),

      // Фон кнопки «Ластик».
      _buildMobileActionButton(
        left: _mobileAction2Left,
        width: _mobileAction2Width,
        color: palette.button,
        accentColor: palette.icon,
        onTap: () => ref.read(gameProvider.notifier).inputNumber(0), // 0 = стереть
      ),

      // Фон кнопки «Подсказка».
      _buildMobileActionButton(
        left: _mobileAction3Left,
        width: _mobileAction3Width,
        color: palette.button,
        accentColor: palette.icon,
        onTap: () => ref.read(gameProvider.notifier).giveHint(),
      ),

      // ── Панель цифр 1–9 ───────────────────────────────────────────────────

      // Цветной фон панели цифр.
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

    // Иконки и подписи поверх фонов кнопок действий (IgnorePointer).
    widgets.addAll(_buildMobileActionIcons(palette.icon));
    // Кнопки цифр поверх фонового прямоугольника панели.
    widgets.addAll(_buildMobileNumberButtons(ref));

    return widgets;
  }

  /// Строит фоновый прямоугольник одной кнопки действия (мобильный).
  ///
  /// [isActive] включает цветную рамку (для кнопки «Карандаш» в режиме заметок).
  /// Тапы обрабатываются здесь же через [GestureDetector].
  Widget _buildMobileActionButton({
    required double left,
    required double width,
    required Color color,
    required Color accentColor,
    required VoidCallback onTap,
    bool isActive = false,
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
            border: Border.all(
              color: isActive ? accentColor : Colors.transparent,
              width: isActive ? 2.5 : 0,
            ),
          ),
        ),
      ),
    );
  }

  /// Возвращает иконки и подписи для кнопок действий (мобильный).
  ///
  /// Завёрнуты в [IgnorePointer] — тапы обрабатываются
  /// фоновыми [GestureDetector]-ами ниже по стеку.
  List<Widget> _buildMobileActionIcons(Color iconColor) {
    return [
      _buildActionContent(
        left: _mobileAction1Left,
        top: _mobileActionTop,
        width: _mobileAction1Width,
        height: _mobileActionHeight,
        asset: 'assets/icon_pencil.png',
        label: 'аловак',
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

  // ── Общие строители ────────────────────────────────────────────────────────

  /// Строит блок «иконка + подпись» для кнопки действия.
  ///
  /// Используется как для десктопного, так и для мобильного макета.
  /// Завёрнут в [IgnorePointer]: это визуальный слой поверх интерактивного фона,
  /// поэтому он не должен перехватывать тапы.
  ///
  /// - [asset] — путь к PNG-иконке; тонируется цветом [color]
  ///   через [BlendMode.srcIn] (заменяет пиксели иконки на заданный цвет).
  /// - [label] — текстовая подпись под иконкой.
  /// - [iconHeight], [fontSize], [spacing] — размерные параметры.
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
            // Иконка масштабируется до [iconHeight] и тонируется цветом темы.
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

  /// Возвращает путь к PNG-ресурсу кнопки «Назад» для данной [theme].
  ///
  /// Каждая тема имеет своё изображение (двойная стрелка влево)
  /// в фирменном цвете темы. Файлы хранятся в папке `assets/`.
  String _backButtonAsset(GameTheme theme) {
    switch (theme) {
      case GameTheme.red:
        return 'assets/back_red.png';
      case GameTheme.blue:
        return 'assets/back_blue.png';
      case GameTheme.purple:
        return 'assets/back_purple.png';
      case GameTheme.orange:
        return 'assets/back_orange.png';
      case GameTheme.green:
        return 'assets/back_green.png';
    }
  }

  /// Строит кнопку «Назад» из PNG-ресурса текущей темы.
  ///
  /// [HitTestBehavior.opaque] обеспечивает срабатывание тапа по всей
  /// прямоугольной области, включая прозрачные пиксели изображения.
  Widget _buildBackButton({
    required VoidCallback onTap,
    required GameTheme theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        _backButtonAsset(theme),
        fit: BoxFit.contain,
      ),
    );
  }

  /// Создаёт список кнопок цифр 1–9 для мобильного макета.
  ///
  /// Кнопки расположены горизонтально поверх цветного фонового прямоугольника.
  /// Каждая кнопка вызывает [inputNumber] с соответствующей цифрой (1–9).
  List<Widget> _buildMobileNumberButtons(WidgetRef ref) {
    final List<Widget> buttons = [];

    for (int i = 0; i < 9; i++) {
      // Горизонтальная позиция i-й цифры с учётом внутреннего отступа.
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
              // Небольшой сдвиг вниз для оптической центровки шрифта Major Mono.
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

  /// Строит цифровой блок (numpad) 3×3 для десктопного макета.
  ///
  /// Генерирует сетку 3 строки × 3 столбца через [List.generate].
  /// Зазоры между клавишами: [_numpadGapX] — горизонтальный,
  /// [_numpadGapY] — вертикальный. Добавляются только между клавишами
  /// (не после последней в строке/столбце).
  Widget _buildNumpad(WidgetRef ref, Color buttonColor) {
    return SizedBox(
      width: _numpadCellSize * 3 + _numpadGapX * 2,
      height: _numpadCellSize * 3 + _numpadGapY * 2,
      child: Column(
        children: List.generate(3, (r) {
          return Padding(
            // Зазор снизу у первых двух строк; у третьей — не нужен.
            padding: EdgeInsets.only(bottom: r < 2 ? _numpadGapY : 0),
            child: Row(
              children: List.generate(3, (c) {
                // Вычисляем цифру кнопки: строка r, столбец c → значение 1..9.
                final value = r * 3 + c + 1;
                return Padding(
                  // Зазор справа у первых двух столбцов.
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

  /// Строит одну кнопку numpad с цифрой [number].
  ///
  /// Нажатие вызывает [inputNumber] с переданной цифрой.
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

  /// Строит кнопку «Новая игра» для десктопного макета.
  ///
  /// Нажатие запускает новую партию с той же сложностью [state.difficulty].
  /// Текст масштабируется через [FittedBox] внутри фиксированного [SizedBox].
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

/// Виджет игрового поля 9×9.
///
/// Состоит из двух слоёв в [Stack]:
/// 1. [_SudokuBoardPainter] — [CustomPaint], рисующий:
///    - чередующийся цветной/белый фон блоков 3×3;
///    - полупрозрачную подсветку выбранной строки и столбца;
///    - тонкие линии между клетками и толстые границы блоков 3×3.
/// 2. Сетка 9×9 виджетов [_SudokuCell] поверх фона — каждая клетка
///    занимает равную долю площади через [Expanded].
class _SudokuBoard extends StatelessWidget {
  /// Размер стороны квадратного поля в «пикселях дизайна».
  final double size;

  /// Снимок состояния игры: клетки, выбранная позиция.
  final GameState state;

  /// Коллбек, вызываемый при тапе по клетке с координатами ([row], [col]).
  final void Function(int row, int col) onSelect;

  /// Цвет заливки нечётных блоков 3×3 (чётные блоки всегда белые).
  final Color blockColor;

  /// Цвет полупрозрачной подсветки выбранных строки/столбца.
  final Color highlightColor;

  /// Цвет тонких линий между клетками внутри блоков.
  final Color thinLineColor;

  /// Цвет толстых линий — границ блоков 3×3.
  final Color thickLineColor;

  /// Толщина тонких линий в логических пикселях.
  final double thinLineWidth;

  /// Толщина толстых линий в логических пикселях.
  final double thickLineWidth;

  /// Размер шрифта цифр в клетках.
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
          // Слой 1: фон блоков, подсветка строки/столбца, линии сетки.
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

          // Слой 2: интерактивная сетка клеток 9×9.
          // Positioned.fill растягивает Column на весь SizedBox.
          Positioned.fill(
            child: Column(
              children: List.generate(9, (r) {
                return Expanded(
                  child: Row(
                    children: List.generate(9, (c) {
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

  /// Безопасно возвращает клетку [r][c], отдавая пустую при незаполненной доске.
  ///
  /// Нужен на первом кадре, когда [GameState.board] ещё не инициализирован.
  SudokuCell _safeCell(int r, int c) {
    if (state.board.isEmpty) return SudokuCell();
    return state.board[r][c];
  }
}

/// Виджет одной клетки поля 9×9.
///
/// Отображает одно из трёх состояний:
/// - Цифра ([SudokuCell.value] ≠ 0): крупный текст, красный при ошибке.
/// - Заметки-кандидаты ([SudokuCell.value] == 0, [SudokuCell.notes] не пуст):
///   мини-сетка 3×3 через [_CellNotes].
/// - Пустая клетка без заметок: невидимый [SizedBox.shrink].
class _SudokuCell extends StatelessWidget {
  /// Модель клетки: значение, флаг ошибки, список заметок.
  final SudokuCell cell;

  /// Коллбек при тапе по клетке.
  final VoidCallback onTap;

  /// Размер шрифта главной цифры.
  final double fontSize;

  /// Создаёт виджет клетки.
  const _SudokuCell({
    required this.cell,
    required this.onTap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final value = cell.value;
    // Ошибочно введённые цифры подсвечиваются красным цветом.
    final textColor = cell.isError ? AppColors.hardRed : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // прозрачный фон, чтобы painter был виден
        alignment: Alignment.center,
        child: value == 0
            // Клетка пуста — показываем заметки (или ничего, если заметок нет).
            ? SizedBox.expand(child: _CellNotes(notes: cell.notes))
            // Клетка заполнена — показываем цифру.
            : Text(
                '$value',
                textAlign: TextAlign.center,
                textHeightBehavior: const TextHeightBehavior(
                  // Отключаем дополнительные вертикальные отступы шрифта,
                  // чтобы цифра была строго по центру клетки.
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

/// Виджет мини-сетки 3×3 с числами-кандидатами внутри пустой клетки.
///
/// Показывает только те цифры (1–9), которые присутствуют в [notes].
/// Размер шрифта и внутренний отступ вычисляются динамически относительно
/// реального размера клетки через [LayoutBuilder], адаптируясь к любому экрану.
class _CellNotes extends StatelessWidget {
  /// Список цифр-кандидатов, введённых игроком в режиме заметок.
  final List<int> notes;

  /// Создаёт виджет заметок.
  const _CellNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    // Ничего не рисуем, если заметок нет.
    if (notes.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Адаптируем размер шрифта и отступ к реальному размеру клетки.
        final shortestSide = constraints.biggest.shortestSide;
        final noteFontSize = shortestSide * 0.23; // ~23% от стороны клетки
        final padding = shortestSide * 0.08; // ~8% отступ по краям

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: List.generate(3, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(3, (col) {
                    // Позиция (row, col) соответствует цифре: (0,0)=1 ... (2,2)=9.
                    final note = row * 3 + col + 1;
                    final hasNote = notes.contains(note);

                    return Expanded(
                      child: Center(
                        child: hasNote
                            ? Text(
                                '$note',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: GameScreen._noteTextColor,
                                  fontSize: noteFontSize,
                                  fontFamily: 'Anonymous Pro',
                                  fontWeight: FontWeight.w400,
                                  height: 1.0,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// [CustomPainter] для рисования фона и сетки линий поля Судоку.
///
/// Порядок рисования (каждый слой перекрывает предыдущий):
/// 1. Чередующиеся цветные/белые прямоугольники блоков 3×3.
/// 2. Полупрозрачная подсветка выбранной строки (если выбрана).
/// 3. Полупрозрачная подсветка выбранного столбца (если выбран).
/// 4. Тонкие линии между клетками внутри блоков.
/// 5. Толстые линии на границах блоков 3×3 (включая внешние края).
///
/// [shouldRepaint] возвращает `true` только при изменении входных параметров,
/// избегая лишних перерисовок при неизменённом состоянии.
class _SudokuBoardPainter extends CustomPainter {
  /// Индекс выбранной строки (0–8), или `null` — ничего не выбрано.
  final int? selectedRow;

  /// Индекс выбранного столбца (0–8), или `null` — ничего не выбрано.
  final int? selectedCol;

  /// Цвет нечётных блоков 3×3 (чётные блоки всегда белые).
  final Color blockColor;

  /// Цвет полупрозрачной подсветки выбранных строки и столбца.
  final Color highlightColor;

  /// Цвет тонких линий между клетками.
  final Color thinLineColor;

  /// Цвет толстых линий — границ блоков 3×3.
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
    // Размер одной клетки — поле квадратное, делим на 9.
    final cell = size.width / 9;
    final paint = Paint()..style = PaintingStyle.fill;

    // ── Шаг 1: фон блоков 3×3 ─────────────────────────────────────────────
    // br/bc — индексы блока (0..2) по вертикали и горизонтали.
    // Блоки с чётной суммой индексов (br+bc % 2 == 0) — цветные, остальные — белые.
    for (int br = 0; br < 3; br++) {
      for (int bc = 0; bc < 3; bc++) {
        paint.color = ((br + bc) % 2 == 0) ? blockColor : Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(bc * cell * 3, br * cell * 3, cell * 3, cell * 3),
          paint,
        );
      }
    }

    // ── Шаг 2: подсветка выбранной строки ─────────────────────────────────
    if (selectedRow != null) {
      paint.color = highlightColor;
      canvas.drawRect(
        Rect.fromLTWH(0, selectedRow! * cell, size.width, cell),
        paint,
      );
    }

    // ── Шаг 3: подсветка выбранного столбца ───────────────────────────────
    if (selectedCol != null) {
      paint.color = highlightColor;
      canvas.drawRect(
        Rect.fromLTWH(selectedCol! * cell, 0, cell, size.height),
        paint,
      );
    }

    // ── Шаг 4: тонкие линии между клетками ────────────────────────────────
    final thinPaint = Paint()
      ..color = thinLineColor
      ..strokeWidth = thinLineWidth;

    // i = 1..8 — линии между клетками (не на краях поля).
    for (int i = 1; i < 9; i++) {
      final pos = cell * i;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), thinPaint); // вертикальная
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), thinPaint);  // горизонтальная
    }

    // ── Шаг 5: толстые линии границ блоков 3×3 ────────────────────────────
    final thickPaint = Paint()
      ..color = thickLineColor
      ..strokeWidth = thickLineWidth;

    // i = 0, 3, 6, 9 — границы блоков, включая внешние края поля.
    for (int i = 0; i <= 9; i += 3) {
      final pos = cell * i;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), thickPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), thickPaint);
    }
  }

  /// Возвращает `true`, если хотя бы один параметр изменился
  /// и поле требует перерисовки.
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

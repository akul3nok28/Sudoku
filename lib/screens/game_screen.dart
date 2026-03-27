import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/sudoku_cell.dart';
import '../providers/game_provider.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  static const double _screenWidth = 1920;
  static const double _screenHeight = 1327;

  static const double _boardLeft = 311;
  static const double _boardTop = 355;
  static const double _boardSize = 736;

  static const double _titleLeft = 365;
  static const double _titleTop = 134;

  static const double _numpadLeft = 1150.41;
  static const double _numpadTop = 395.37;
  static const double _numpadCellSize = 139.84;
  static const double _numpadGapX = 23.48;
  static const double _numpadGapY = 25.52;

  static const double _newGameLeft = 1149;
  static const double _newGameTop = 919;
  static const double _newGameWidth = 468.28;
  static const double _newGameHeight = 90.17;

  // Mobile layout based on provided prototype image (412x917)
  static const double _mobileWidth = 412;
  static const double _mobileHeight = 917;

  static const double _mobileBackLeft = 31;
  static const double _mobileBackTop = 106;
  static const double _mobileBackWidth = 17;
  static const double _mobileBackHeight = 39;

  static const double _mobilePaintLeft = 294;
  static const double _mobilePaintTop = 104;
  static const double _mobilePaintWidth = 37;
  static const double _mobilePaintHeight = 96;

  static const double _mobileSettingsLeft = 354;
  static const double _mobileSettingsTop = 104;
  static const double _mobileSettingsWidth = 42;
  static const double _mobileSettingsHeight = 43;

  static const double _mobileTitleLeft = 75;
  static const double _mobileTitleTop = 173;

  static const double _mobileMistakesLeft = 16;
  static const double _mobileMistakesTop = 237;
  static const double _mobileDifficultyLeft = 364;
  static const double _mobileDifficultyTop = 238;

  static const double _mobileBoardLeft = 16;
  static const double _mobileBoardTop = 253;
  static const double _mobileBoardSize = 379;

  static const double _mobileActionTop = 653;
  static const double _mobileActionHeight = 67;
  static const double _mobileAction1Left = 16;
  static const double _mobileAction1Width = 113;
  static const double _mobileAction2Left = 150;
  static const double _mobileAction2Width = 112;
  static const double _mobileAction3Left = 283;
  static const double _mobileAction3Width = 112;

  static const double _mobilePencilLeft = 61;
  static const double _mobilePencilTop = 659;
  static const double _mobilePencilWidth = 26;
  static const double _mobilePencilHeight = 41;

  static const double _mobileEraserLeft = 191;
  static const double _mobileEraserTop = 663;
  static const double _mobileEraserWidth = 32;
  static const double _mobileEraserHeight = 37;

  static const double _mobileHintLeft = 326;
  static const double _mobileHintTop = 657;
  static const double _mobileHintWidth = 27;
  static const double _mobileHintHeight = 43;

  static const double _mobilePencilTextLeft = 49;
  static const double _mobilePencilTextTop = 705;
  static const double _mobileEraserTextLeft = 182;
  static const double _mobileEraserTextTop = 707;
  static const double _mobileHintTextLeft = 320;
  static const double _mobileHintTextTop = 705;

  static const double _mobileNumbersLeft = 16;
  static const double _mobileNumbersTop = 740;
  static const double _mobileNumbersWidth = 379;
  static const double _mobileNumbersHeight = 64;
  static const double _mobileNumberInset = 5;
  static const double _mobileNumberCell = 41;

  static const Color _mobilePink = Color(0xFFFFDADA);
  static const Color _mobileIconGrey = Color(0xFFDDDDDD);
  static const Color _mobileIconRed = Color(0xFFD95E60);
  static const Color _mobileBackRed = Color(0xFFE9A5A7);
  static const Color _mobileThinLine = Color(0xFFF8D4D4);
  static const Color _mobileHighlight = Color(0xFFF2C2C2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
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
                      : _buildDesktopLayout(ref, gameState),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDesktopLayout(WidgetRef ref, GameState gameState) {
    return [
      Positioned(
        left: _titleLeft,
        top: _titleTop,
        child: Text(
          AppStrings.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 132,
            fontFamily: 'Anonymous Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      Positioned(
        left: 1394.09,
        top: 141,
        child: Row(
          children: [
            Icon(Icons.format_paint_outlined, color: Colors.grey[300], size: 60),
            const SizedBox(width: 30),
            Icon(Icons.settings_outlined, color: Colors.grey[300], size: 60),
          ],
        ),
      ),
      Positioned(
        left: _boardLeft,
        top: _boardTop,
        child: _SudokuBoard(
          size: _boardSize,
          state: gameState,
          onSelect: (r, c) => ref.read(gameProvider.notifier).selectCell(r, c),
          cellFontSize: 72,
        ),
      ),
      Positioned(
        left: _numpadLeft,
        top: _numpadTop,
        child: _buildNumpad(ref),
      ),
      Positioned(
        left: _newGameLeft,
        top: _newGameTop,
        child: _buildNewGameButton(ref, gameState),
      ),
    ];
  }

  List<Widget> _buildMobileLayout(BuildContext context, WidgetRef ref, GameState gameState) {
    final List<Widget> widgets = [
      Positioned(
        left: _mobileBackLeft,
        top: _mobileBackTop,
        width: _mobileBackWidth,
        height: _mobileBackHeight,
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: CustomPaint(
            painter: _BackChevronPainter(_mobileBackRed),
          ),
        ),
      ),
      Positioned(
        left: _mobilePaintLeft,
        top: _mobilePaintTop,
        width: _mobilePaintWidth,
        height: _mobilePaintHeight,
        child: const FittedBox(
          fit: BoxFit.contain,
          child: Icon(Icons.format_paint_outlined, color: _mobileIconGrey),
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
      const Positioned(
        left: _mobileMistakesLeft,
        top: _mobileMistakesTop,
        child: Text(
          'mistakes 0/3',
          style: TextStyle(
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
          gameState.difficulty.name,
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
          blockColor: _mobilePink,
          highlightColor: _mobileHighlight,
          thinLineColor: _mobileThinLine,
          thickLineColor: Colors.black,
          thinLineWidth: 1.0,
          thickLineWidth: 1.0,
          cellFontSize: 30,
        ),
      ),
      _buildMobileActionButton(
        left: _mobileAction1Left,
        width: _mobileAction1Width,
        onTap: () => ref.read(gameProvider.notifier).toggleNoteMode(),
      ),
      _buildMobileActionButton(
        left: _mobileAction2Left,
        width: _mobileAction2Width,
        onTap: () => ref.read(gameProvider.notifier).inputNumber(0),
      ),
      _buildMobileActionButton(
        left: _mobileAction3Left,
        width: _mobileAction3Width,
        onTap: () => ref.read(gameProvider.notifier).giveHint(),
      ),
      Positioned(
        left: _mobileNumbersLeft,
        top: _mobileNumbersTop,
        child: Container(
          width: _mobileNumbersWidth,
          height: _mobileNumbersHeight,
          decoration: BoxDecoration(
            color: _mobilePink,
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    ];

    widgets.addAll(_buildMobileActionIcons());
    widgets.addAll(_buildMobileActionLabels());
    widgets.addAll(_buildMobileNumberButtons(ref));

    return widgets;
  }

  Widget _buildMobileActionButton({
    required double left,
    required double width,
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
            color: _mobilePink,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMobileActionIcons() {
    return [
      Positioned(
        left: _mobilePencilLeft,
        top: _mobilePencilTop,
        width: _mobilePencilWidth,
        height: _mobilePencilHeight,
        child: const IgnorePointer(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(Icons.edit, color: _mobileIconRed),
          ),
        ),
      ),
      Positioned(
        left: _mobileEraserLeft,
        top: _mobileEraserTop,
        width: _mobileEraserWidth,
        height: _mobileEraserHeight,
        child: const IgnorePointer(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(Icons.crop_square, color: _mobileIconRed),
          ),
        ),
      ),
      Positioned(
        left: _mobileHintLeft,
        top: _mobileHintTop,
        width: _mobileHintWidth,
        height: _mobileHintHeight,
        child: const IgnorePointer(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(Icons.lightbulb, color: _mobileIconRed),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildMobileActionLabels() {
    const labelStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontFamily: 'Anonymous Pro',
      fontWeight: FontWeight.w400,
      height: 1.0,
    );

    return const [
      Positioned(
        left: _mobilePencilTextLeft,
        top: _mobilePencilTextTop,
        child: Text('pencil', style: labelStyle),
      ),
      Positioned(
        left: _mobileEraserTextLeft,
        top: _mobileEraserTextTop,
        child: Text('eraser', style: labelStyle),
      ),
      Positioned(
        left: _mobileHintTextLeft,
        top: _mobileHintTextTop,
        child: Text('hints', style: labelStyle),
      ),
    ];
  }

  List<Widget> _buildMobileNumberButtons(WidgetRef ref) {
    final List<Widget> buttons = [];

    for (int i = 0; i < 9; i++) {
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

  Widget _buildNumpad(WidgetRef ref) {
    return SizedBox(
      width: _numpadCellSize * 3 + _numpadGapX * 2,
      height: _numpadCellSize * 3 + _numpadGapY * 2,
      child: Column(
        children: List.generate(3, (r) {
          return Padding(
            padding: EdgeInsets.only(bottom: r < 2 ? _numpadGapY : 0),
            child: Row(
              children: List.generate(3, (c) {
                final value = r * 3 + c + 1;
                return Padding(
                  padding: EdgeInsets.only(right: c < 2 ? _numpadGapX : 0),
                  child: _buildNumpadButton(ref, value),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumpadButton(WidgetRef ref, int number) {
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).inputNumber(number),
      child: Container(
        width: _numpadCellSize,
        height: _numpadCellSize,
        decoration: BoxDecoration(
          color: const Color(0x6BD5D5D5),
          borderRadius: BorderRadius.circular(10.21),
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 102.07,
            fontFamily: 'Major Mono Display',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildNewGameButton(WidgetRef ref, GameState state) {
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).startNewGame(state.difficulty),
      child: Container(
        width: _newGameWidth,
        height: _newGameHeight,
        decoration: BoxDecoration(
          color: const Color(0x6BD5D5D5),
          borderRadius: BorderRadius.circular(10.25),
        ),
        alignment: Alignment.center,
        child: const Text(
          AppStrings.newGame,
          style: TextStyle(
            color: Colors.black,
            fontSize: 55.77,
            fontFamily: 'Anonymous Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SudokuBoard extends StatelessWidget {
  final double size;
  final GameState state;
  final void Function(int row, int col) onSelect;
  final Color blockColor;
  final Color highlightColor;
  final Color thinLineColor;
  final Color thickLineColor;
  final double thinLineWidth;
  final double thickLineWidth;
  final double cellFontSize;

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

  SudokuCell _safeCell(int r, int c) {
    if (state.board.isEmpty) {
      return SudokuCell();
    }
    return state.board[r][c];
  }
}

class _SudokuCell extends StatelessWidget {
  final SudokuCell cell;
  final VoidCallback onTap;
  final double fontSize;

  const _SudokuCell({
    required this.cell,
    required this.onTap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final value = cell.value;
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

class _SudokuBoardPainter extends CustomPainter {
  final int? selectedRow;
  final int? selectedCol;
  final Color blockColor;
  final Color highlightColor;
  final Color thinLineColor;
  final Color thickLineColor;
  final double thinLineWidth;
  final double thickLineWidth;

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
    final cell = size.width / 9;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int br = 0; br < 3; br++) {
      for (int bc = 0; bc < 3; bc++) {
        paint.color = ((br + bc) % 2 == 0) ? blockColor : Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(bc * cell * 3, br * cell * 3, cell * 3, cell * 3),
          paint,
        );
      }
    }

    if (selectedRow != null) {
      paint.color = highlightColor;
      canvas.drawRect(
        Rect.fromLTWH(0, selectedRow! * cell, size.width, cell),
        paint,
      );
    }

    if (selectedCol != null) {
      paint.color = highlightColor;
      canvas.drawRect(
        Rect.fromLTWH(selectedCol! * cell, 0, cell, size.height),
        paint,
      );
    }

    final thinPaint = Paint()
      ..color = thinLineColor
      ..strokeWidth = thinLineWidth;
    final thickPaint = Paint()
      ..color = thickLineColor
      ..strokeWidth = thickLineWidth;

    for (int i = 1; i < 9; i++) {
      final pos = cell * i;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), thinPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), thinPaint);
    }

    for (int i = 0; i <= 9; i += 3) {
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

class _BackChevronPainter extends CustomPainter {
  final Color color;

  _BackChevronPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path1 = Path()
      ..moveTo(w * 0.72, h * 0.08)
      ..lineTo(w * 0.28, h * 0.5)
      ..lineTo(w * 0.72, h * 0.92);

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

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

//закрытие приложения
void closeApp() {
  if (kIsWeb) return; // на вебе игнорируем
  if (Platform.isAndroid || Platform.isIOS) {
    SystemNavigator.pop();
  } else {
    exit(0);
  }
}

// --- главное меню ---
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final circleSize = (width * 0.9).clamp(0.0, 800.0); // ограничим максимальный размер
          final titleSize = width > 600 ? 72.0 : 56.0;
          final buttonWidth = width > 400 ? 260.0 : width * 0.7;

          return Stack(
            children: [
              // 🎨 Фон-круг
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFE6C7), // светлый тон
                          Color(0xFFFFC07F), // более насыщенный тон
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //иконки сверху справа
              Positioned(
                top: 24,
                right: 24,
                child: Row(
                  children: const [
                    Icon(Icons.format_paint, color: Colors.grey),
                    SizedBox(width: 16),
                    Icon(Icons.settings, color: Colors.grey),
                  ],
                ),
              ),

              //контент
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //заголовок
                    Text(
                      'SUDOKU',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 6,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    //линия с кружками
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(),
                        Container(
                          width: buttonWidth,
                          height: 2,
                          color: Colors.black,
                        ),
                        _dot(),
                      ],
                    ),

                    const SizedBox(height: 40),

                    //кнопки
                    DecoratedButton(
                      text: 'НОВАЯ ГУЛЬНЯ',
                      width: buttonWidth,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SudokuBoardScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    DecoratedButton(
                      text: 'ВЫХАД',
                      width: buttonWidth,
                      onTap: closeApp,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _dot() {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF4B266),
        shape: BoxShape.circle,
      ),
    );
  }
}

//кнопка с ушками
class DecoratedButton extends StatelessWidget {
  final String text;
  final double width;
  final VoidCallback onTap;

  const DecoratedButton({
    super.key,
    required this.text,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        //левое ушко
        Positioned(
          left: 0,
          child: _ear(),
        ),
        //правое ушко
        Positioned(
          right: 0,
          child: _ear(),
        ),
        //кнопка
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD9A0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF4B266),
                width: 2,
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ear() {
    return Container(
      width: 18,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF4B266),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// --- экран игрового поля ---
class SudokuGenerator {
  static const int size = 9;
  static const int boxSize = 3;

  final Random _random = Random();

  List<List<int>> generate({int clues = 30}) {
    final board = List.generate(size, (_) => List.filled(size, 0));

    _fillBoard(board);
    _removeNumbers(board, clues);

    return board;
  }

  // --- заполнение решённой сетки ---
  bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (board[row][col] == 0) {
          final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

          for (final num in numbers) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  // --- проверка правил ---
  bool _isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < size; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }

    final boxRow = row - row % boxSize;
    final boxCol = col - col % boxSize;

    for (int r = 0; r < boxSize; r++) {
      for (int c = 0; c < boxSize; c++) {
        if (board[boxRow + r][boxCol + c] == num) return false;
      }
    }
    return true;
  }

  // --- удаление чисел ---
  void _removeNumbers(List<List<int>> board, int clues) {
    int cellsToRemove = size * size - clues;

    while (cellsToRemove > 0) {
      final row = _random.nextInt(size);
      final col = _random.nextInt(size);

      if (board[row][col] != 0) {
        board[row][col] = 0;
        cellsToRemove--;
      }
    }
  }
}

class SudokuBoardScreen extends StatefulWidget {
  const SudokuBoardScreen({super.key});

  @override
  State<SudokuBoardScreen> createState() => _SudokuBoardScreenState();
}

class _SudokuBoardScreenState extends State<SudokuBoardScreen> {
  late List<List<int>> board;
  late List<List<bool>> initialCells;
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    _generateNewGame();
  }

  void _generateNewGame() {
    setState(() {
      board = SudokuGenerator().generate(clues: 40);
      initialCells = List.generate(9, (r) => List.generate(9, (c) => board[r][c] != 0));
      selectedRow = null;
      selectedCol = null;
    });
  }

  bool _isCellInvalid(int row, int col, int value) {
    if (value == 0) return false;
    // Check row
    for (int i = 0; i < 9; i++) {
      if (i != col && board[row][i] == value) return true;
    }
    // Check column
    for (int i = 0; i < 9; i++) {
      if (i != row && board[i][col] == value) return true;
    }
    // Check box
    int boxRow = row - row % 3;
    int boxCol = col - col % 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && board[r][c] == value) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
                        tooltip: 'Назад',
                      ),
                      const Text(
                        'SUDOKU',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.format_paint, color: Colors.grey),
                      SizedBox(width: 16),
                      Icon(Icons.settings, color: Colors.grey),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Main Content
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sudoku Board (Left)
                    Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400, width: 1.5),
                            ),
                            child: Column(
                              children: List.generate(9, (row) {
                                return Expanded(
                                  child: Row(
                                    children: List.generate(9, (col) {
                                      return _buildCell(row, col);
                                    }),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    // Controls (Keypad - Right, shifted left and down)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60, right: 30), // Shifting keypad
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildKeypad(),
                            const SizedBox(height: 50),
                            _buildNewGameButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final value = board[row][col];
    final isSelected = selectedRow == row && selectedCol == col;
    final isInitial = initialCells[row][col];
    final isInvalid = _isCellInvalid(row, col, value);
    
    // Check if cell should be highlighted
    bool isHighlighted = false;
    if (selectedRow != null && selectedCol != null) {
       if (selectedRow == row || selectedCol == col) {
         isHighlighted = true;
       }
       // Box highlight
       int boxRow = selectedRow! - selectedRow! % 3;
       int boxCol = selectedCol! - selectedCol! % 3;
       if (row >= boxRow && row < boxRow + 3 && col >= boxCol && col < boxCol + 3) {
         isHighlighted = true;
       }
    }

    final borderColor = Colors.grey.shade300;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRow = row;
            selectedCol = col;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFE0E0E0) 
                : (isHighlighted ? const Color(0xFFF5F5F5) : Colors.transparent),
            border: Border(
              right: BorderSide(
                color: (col + 1) % 3 == 0 && col != 8 ? Colors.grey.shade500 : borderColor,
                width: (col + 1) % 3 == 0 && col != 8 ? 1.5 : 0.5,
              ),
              bottom: BorderSide(
                color: (row + 1) % 3 == 0 && row != 8 ? Colors.grey.shade500 : borderColor,
                width: (row + 1) % 3 == 0 && row != 8 ? 1.5 : 0.5,
              ),
            ),
          ),
          child: Center(
            child: Text(
              value == 0 ? '' : value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: isInitial ? FontWeight.w600 : FontWeight.w300,
                color: isInvalid ? Colors.red : (isInitial ? Colors.black : Colors.blue.shade700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keypadWidth = constraints.maxWidth;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Decorative "ears" for the keypad
            Positioned(
              left: -6,
              top: -6,
              child: _keypadEar(),
            ),
            Positioned(
              right: -6,
              top: -6,
              child: _keypadEar(),
            ),
            Positioned(
              left: -6,
              bottom: -6,
              child: _keypadEar(),
            ),
            Positioned(
              right: -6,
              bottom: -6,
              child: _keypadEar(),
            ),
            
            // Keypad Grid
            Container(
              width: keypadWidth,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(9, (index) {
                  final number = index + 1;
                  return GestureDetector(
                    onTap: () {
                      if (selectedRow != null && selectedCol != null) {
                        if (!initialCells[selectedRow!][selectedCol!]) {
                          setState(() {
                            board[selectedRow!][selectedCol!] = number;
                          });
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _keypadEar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFD35450),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildNewGameButton() {
    return GestureDetector(
      onTap: _generateNewGame,
      child: Container(
        width: 180,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: const Text(
          'новая гульня',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

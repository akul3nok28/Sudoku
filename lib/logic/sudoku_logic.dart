import 'dart:math';

/// Логика генерации и проверки Судоку.
///
/// Этот класс отвечает за:
/// - генерацию полной корректной сетки;
/// - вырезание клеток для получения головоломки с нужным числом подсказок;
/// - проверку уникальности решения;
/// - вспомогательные операции с битовыми масками кандидатов.
class SudokuLogic {
  /// Размер стороны стандартного поля Судоку (9x9).
  static const int size = 9;

  /// Размер стороны блока 3x3.
  static const int boxSize = 3;

  /// Битовая маска с установленными 9 битами (кандидаты 1..9).
  static const int _allMask = (1 << size) - 1;

  /// Генератор случайных чисел для рандомизации перебора.
  final Random _random = Random();

  /// Генерирует полностью заполненную корректную сетку Судоку.
  List<List<int>> generateFullBoard() {
    // Доска 9x9, ноль означает "пусто".
    final board = List<List<int>>.generate(size, (_) => List<int>.filled(size, 0));
    // Маски занятых цифр по строкам.
    final rowMask = List<int>.filled(size, 0);
    // Маски занятых цифр по столбцам.
    final colMask = List<int>.filled(size, 0);
    // Маски занятых цифр по блокам 3x3.
    final boxMask = List<int>.filled(size, 0);

    // Заполняем доску рекурсивным поиском.
    _fillBoard(board, rowMask, colMask, boxMask);
    return board;
  }

  /// Рекурсивно заполняет доску корректными значениями.
  ///
  /// [board] — текущая доска (меняется по месту).
  /// [rowMask]/[colMask]/[boxMask] — битовые маски уже использованных цифр.
  bool _fillBoard(
    List<List<int>> board,
    List<int> rowMask,
    List<int> colMask,
    List<int> boxMask,
  ) {
    // Координаты "лучшей" (самой ограниченной) пустой клетки.
    int bestRow = -1;
    int bestCol = -1;
    // Маска возможных значений для выбранной клетки.
    int bestMask = 0;
    // Количество кандидатов в выбранной клетке.
    int bestCount = 10;

    // Ищем пустую клетку с минимальным числом кандидатов.
    outer:
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (board[row][col] != 0) continue;
        // Маска возможных значений для текущей клетки.
        final mask = _candidateMask(rowMask, colMask, boxMask, row, col);
        // Количество установленных битов = число кандидатов.
        final count = _bitCount(mask);
        if (count == 0) return false;
        if (count < bestCount) {
          bestCount = count;
          bestMask = mask;
          bestRow = row;
          bestCol = col;
          if (count == 1) break outer;
        }
      }
    }

    // Если пустых клеток больше нет — решение найдено.
    if (bestRow == -1) return true;

    // Преобразуем маску кандидатов в список чисел и перемешиваем.
    final candidates = _maskToNumbers(bestMask)..shuffle(_random);
    for (final num in candidates) {
      // Пробуем поставить число.
      _placeNumber(board, rowMask, colMask, boxMask, bestRow, bestCol, num);
      if (_fillBoard(board, rowMask, colMask, boxMask)) return true;
      // Откатываем ход, если решение не найдено.
      _removeNumber(board, rowMask, colMask, boxMask, bestRow, bestCol, num);
    }

    return false;
  }

  /// Создаёт головоломку, удаляя клетки из полного решения.
  ///
  /// [fullBoard] — полностью заполненная корректная доска.
  /// [clues] — количество подсказок (непустых клеток), которое нужно оставить.
  List<List<int>> createPuzzle(List<List<int>> fullBoard, int clues) {
    // Копия полной доски, которую будем "вычищать".
    final puzzle = List<List<int>>.generate(size, (r) => List<int>.from(fullBoard[r]));
    // Сколько клеток нужно удалить.
    int toRemove = 81 - clues;
    // Список всех позиций 0..80 в случайном порядке.
    final positions = List<int>.generate(size * size, (i) => i)..shuffle(_random);

    for (final pos in positions) {
      if (toRemove == 0) break;
      // Переводим индекс в координаты строки/столбца.
      final row = pos ~/ size;
      final col = pos % size;
      if (puzzle[row][col] == 0) continue;
      // Сохраняем значение, чтобы восстановить при необходимости.
      final backup = puzzle[row][col];
      puzzle[row][col] = 0;

      // Удаляем клетку только если решение остаётся уникальным.
      if (_hasUniqueSolution(puzzle)) {
        toRemove--;
      } else {
        puzzle[row][col] = backup;
      }
    }

    return puzzle;
  }

  /// Проверяет, что у доски ровно одно решение.
  bool _hasUniqueSolution(List<List<int>> board) {
    return _countSolutions(board, limit: 2) == 1;
  }

  /// Считает количество подсказок (непустых клеток) на доске.
  int countClues(List<List<int>> board) {
    // Счётчик заполненных клеток.
    int count = 0;
    for (final row in board) {
      for (final value in row) {
        if (value != 0) count++;
      }
    }
    return count;
  }

  /// Считает количество решений доски с ограничением [limit].
  ///
  /// Возвращает 0, если доска некорректна или решений нет.
  int _countSolutions(List<List<int>> board, {int limit = 2}) {
    // Маски уже использованных цифр по строкам/столбцам/блокам.
    final rowMask = List<int>.filled(size, 0);
    final colMask = List<int>.filled(size, 0);
    final boxMask = List<int>.filled(size, 0);
    if (!_initMasks(board, rowMask, colMask, boxMask)) return 0;

    // Количество найденных решений.
    int solutions = 0;

    void search() {
      if (solutions >= limit) return;

      // Находим клетку с минимальным числом кандидатов.
      int bestRow = -1;
      int bestCol = -1;
      int bestMask = 0;
      int bestCount = 10;

      outer:
      for (int row = 0; row < size; row++) {
        for (int col = 0; col < size; col++) {
          if (board[row][col] != 0) continue;
          final mask = _candidateMask(rowMask, colMask, boxMask, row, col);
          final count = _bitCount(mask);
          if (count == 0) return;
          if (count < bestCount) {
            bestCount = count;
            bestMask = mask;
            bestRow = row;
            bestCol = col;
            if (count == 1) break outer;
          }
        }
      }

      // Если пустых клеток нет — найдено одно решение.
      if (bestRow == -1) {
        solutions++;
        return;
      }

      // Перебираем кандидатов с использованием битовой маски.
      int mask = bestMask;
      while (mask != 0) {
        final bit = mask & -mask;
        final num = _trailingZeroBits(bit) + 1;
        _placeNumber(board, rowMask, colMask, boxMask, bestRow, bestCol, num);
        search();
        _removeNumber(board, rowMask, colMask, boxMask, bestRow, bestCol, num);
        if (solutions >= limit) return;
        mask &= mask - 1;
      }
    }

    search();
    return solutions;
  }

  /// Инициализирует маски занятых цифр по текущей доске.
  ///
  /// Возвращает `false`, если в исходной доске есть противоречие.
  bool _initMasks(
    List<List<int>> board,
    List<int> rowMask,
    List<int> colMask,
    List<int> boxMask,
  ) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        // Текущее значение клетки.
        final value = board[row][col];
        if (value == 0) continue;
        // Бит для текущего значения.
        final bit = 1 << (value - 1);
        // Индекс блока 3x3.
        final box = _boxIndex(row, col);
        // Если бит уже установлен — доска некорректна.
        if ((rowMask[row] & bit) != 0 ||
            (colMask[col] & bit) != 0 ||
            (boxMask[box] & bit) != 0) {
          return false;
        }
        // Отмечаем значение в масках.
        rowMask[row] |= bit;
        colMask[col] |= bit;
        boxMask[box] |= bit;
      }
    }
    return true;
  }

  /// Возвращает маску допустимых кандидатов для клетки [row]/[col].
  int _candidateMask(
    List<int> rowMask,
    List<int> colMask,
    List<int> boxMask,
    int row,
    int col,
  ) {
    return _allMask & ~(rowMask[row] | colMask[col] | boxMask[_boxIndex(row, col)]);
  }

  /// Ставит число [num] в клетку и обновляет маски.
  void _placeNumber(
    List<List<int>> board,
    List<int> rowMask,
    List<int> colMask,
    List<int> boxMask,
    int row,
    int col,
    int num,
  ) {
    // Записываем число в доску.
    board[row][col] = num;
    // Устанавливаем соответствующий бит в масках.
    final bit = 1 << (num - 1);
    rowMask[row] |= bit;
    colMask[col] |= bit;
    boxMask[_boxIndex(row, col)] |= bit;
  }

  /// Удаляет число [num] из клетки и обновляет маски.
  void _removeNumber(
    List<List<int>> board,
    List<int> rowMask,
    List<int> colMask,
    List<int> boxMask,
    int row,
    int col,
    int num,
  ) {
    // Стираем значение на доске.
    board[row][col] = 0;
    // Снимаем соответствующий бит в масках.
    final bit = 1 << (num - 1);
    rowMask[row] &= ~bit;
    colMask[col] &= ~bit;
    boxMask[_boxIndex(row, col)] &= ~bit;
  }

  /// Возвращает индекс блока 3x3 для координат [row]/[col].
  int _boxIndex(int row, int col) {
    return (row ~/ boxSize) * boxSize + (col ~/ boxSize);
  }

  /// Считает количество установленных битов в числе.
  int _bitCount(int value) {
    // Количество установленных битов.
    int count = 0;
    // Рабочая копия значения.
    int v = value;
    while (v != 0) {
      v &= v - 1;
      count++;
    }
    return count;
  }

  /// Преобразует битовую маску кандидатов в список чисел 1..9.
  List<int> _maskToNumbers(int mask) {
    // Список кандидатных значений.
    final numbers = <int>[];
    // Рабочая копия маски.
    int m = mask;
    while (m != 0) {
      final bit = m & -m;
      numbers.add(_trailingZeroBits(bit) + 1);
      m &= m - 1;
    }
    return numbers;
  }

  /// Возвращает количество нулевых битов справа (позицию младшего бита).
  int _trailingZeroBits(int value) {
    // Счётчик нулевых битов.
    int count = 0;
    // Рабочая копия значения.
    int v = value;
    while ((v & 1) == 0) {
      v >>= 1;
      count++;
    }
    return count;
  }
}

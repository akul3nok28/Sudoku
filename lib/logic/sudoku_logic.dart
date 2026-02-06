import 'dart:math';

class SudokuLogic {
  static const int size = 9;
  static const int boxSize = 3;

  List<List<int>> generateFullBoard() {
    List<List<int>> board = List.generate(size, (_) => List.filled(size, 0));
    _solve(board);
    return board;
  }

  bool _solve(List<List<int>> board) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (board[row][col] == 0) {
          List<int> numbers = List.generate(9, (i) => i + 1)..shuffle();
          for (int num in numbers) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_solve(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < size; i++) {
      if (board[row][i] == num) return false;
      if (board[i][col] == num) return false;
    }

    int startRow = (row ~/ boxSize) * boxSize;
    int startCol = (col ~/ boxSize) * boxSize;
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  List<List<int>> createPuzzle(List<List<int>> fullBoard, int clues) {
    List<List<int>> puzzle = List.generate(size, (r) => List.from(fullBoard[r]));
    int toRemove = 81 - clues;
    Random random = Random();

    while (toRemove > 0) {
      int row = random.nextInt(size);
      int col = random.nextInt(size);
      if (puzzle[row][col] != 0) {
        int backup = puzzle[row][col];
        puzzle[row][col] = 0;
        
        if (_hasUniqueSolution(puzzle)) {
          toRemove--;
        } else {
          puzzle[row][col] = backup;
        }
      }
    }
    return puzzle;
  }

  bool _hasUniqueSolution(List<List<int>> board) {
    int solutions = 0;
    
    void countSolutions(List<List<int>> b) {
      if (solutions > 1) return;
      
      int row = -1;
      int col = -1;
      bool empty = false;
      for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
          if (b[i][j] == 0) {
            row = i;
            col = j;
            empty = true;
            break;
          }
        }
        if (empty) break;
      }

      if (!empty) {
        solutions++;
        return;
      }

      for (int num = 1; num <= 9; num++) {
        if (_isValid(b, row, col, num)) {
          b[row][col] = num;
          countSolutions(b);
          b[row][col] = 0;
        }
      }
    }

    List<List<int>> copy = List.generate(size, (r) => List.from(board[r]));
    countSolutions(copy);
    return solutions == 1;
  }
}

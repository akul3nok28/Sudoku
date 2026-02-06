import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sudoku_cell.dart';
import '../logic/sudoku_logic.dart';
import '../core/constants.dart';

class GameState {
  final List<List<SudokuCell>> board;
  final List<List<SudokuCell>> history;
  final int? selectedRow;
  final int? selectedCol;
  final bool isNoteMode;
  final Difficulty difficulty;
  final int seconds;
  final bool isGameOver;

  GameState({
    required this.board,
    this.history = const [],
    this.selectedRow,
    this.selectedCol,
    this.isNoteMode = false,
    required this.difficulty,
    this.seconds = 0,
    this.isGameOver = false,
  });

  GameState copyWith({
    List<List<SudokuCell>>? board,
    int? selectedRow,
    int? selectedCol,
    bool? isNoteMode,
    int? seconds,
    bool? isGameOver,
  }) {
    return GameState(
      board: board ?? this.board,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      difficulty: this.difficulty,
      seconds: seconds ?? this.seconds,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  Timer? _timer;
  final SudokuLogic _logic = SudokuLogic();

  GameNotifier() : super(GameState(board: [], difficulty: Difficulty.easy));

  void startNewGame(Difficulty difficulty) {
    final fullBoard = _logic.generateFullBoard();
    final puzzle = _logic.createPuzzle(fullBoard, difficulty.clues);
    
    List<List<SudokuCell>> board = List.generate(9, (r) => List.generate(9, (c) => SudokuCell(
      value: puzzle[r][c],
      isInitial: puzzle[r][c] != 0,
    )));

    state = GameState(board: board, difficulty: difficulty);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(seconds: state.seconds + 1);
    });
  }

  void selectCell(int r, int c) {
    state = state.copyWith(selectedRow: r, selectedCol: c);
  }

  void toggleNoteMode() {
    state = state.copyWith(isNoteMode: !state.isNoteMode);
  }

  void inputNumber(int number) {
    if (state.selectedRow == null || state.selectedCol == null) return;
    int r = state.selectedRow!;
    int c = state.selectedCol!;
    
    if (state.board[r][c].isInitial) return;

    List<List<SudokuCell>> newBoard = List.generate(9, (row) => List.from(state.board[row]));

    if (state.isNoteMode) {
      List<int> notes = List.from(newBoard[r][c].notes);
      if (notes.contains(number)) {
        notes.remove(number);
      } else {
        notes.add(number);
        notes.sort();
      }
      newBoard[r][c] = newBoard[r][c].copyWith(notes: notes, value: 0);
    } else {
      bool isError = !_isValidMove(r, c, number);
      newBoard[r][c] = newBoard[r][c].copyWith(value: number, notes: [], isError: isError);
    }

    state = state.copyWith(board: newBoard);
    _checkWin();
  }

  bool _isValidMove(int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (i != col && state.board[row][i].value == num) return false;
      if (i != row && state.board[i][col].value == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int r = startRow + i;
        int c = startCol + j;
        if ((r != row || c != col) && state.board[r][c].value == num) return false;
      }
    }
    return true;
  }

  void _checkWin() {
    bool complete = true;
    for (var row in state.board) {
      for (var cell in row) {
        if (cell.value == 0 || cell.isError) {
          complete = false;
          break;
        }
      }
    }
    if (complete) {
      _timer?.cancel();
      state = state.copyWith(isGameOver: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

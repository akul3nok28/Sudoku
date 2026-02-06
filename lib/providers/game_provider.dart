import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_cell.dart';
import '../logic/sudoku_logic.dart';
import '../core/constants.dart';

class GameState {
  final List<List<SudokuCell>> board;
  final List<List<int>> solution;
  final List<List<List<SudokuCell>>> undoHistory;
  final List<List<List<SudokuCell>>> redoHistory;
  final int? selectedRow;
  final int? selectedCol;
  final bool isNoteMode;
  final Difficulty difficulty;
  final int seconds;
  final bool isGameOver;

  GameState({
    required this.board,
    required this.solution,
    this.undoHistory = const [],
    this.redoHistory = const [],
    this.selectedRow,
    this.selectedCol,
    this.isNoteMode = false,
    required this.difficulty,
    this.seconds = 0,
    this.isGameOver = false,
  });

  GameState copyWith({
    List<List<SudokuCell>>? board,
    List<List<int>>? solution,
    List<List<List<SudokuCell>>>? undoHistory,
    List<List<List<SudokuCell>>>? redoHistory,
    int? selectedRow,
    int? selectedCol,
    bool? isNoteMode,
    Difficulty? difficulty,
    int? seconds,
    bool? isGameOver,
  }) {
    return GameState(
      board: board ?? this.board,
      solution: solution ?? this.solution,
      undoHistory: undoHistory ?? this.undoHistory,
      redoHistory: redoHistory ?? this.redoHistory,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      difficulty: difficulty ?? this.difficulty,
      seconds: seconds ?? this.seconds,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  Timer? _timer;
  final SudokuLogic _logic = SudokuLogic();
  SharedPreferences? _prefs;

  GameNotifier() : super(GameState(board: [], solution: [], difficulty: Difficulty.easy)) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadGame();
    } catch (_) {}
  }

  void startNewGame(Difficulty difficulty) {
    final fullBoard = _logic.generateFullBoard();
    final puzzle = _logic.createPuzzle(fullBoard, difficulty.clues);
    
    final board = List.generate(9, (r) => List.generate(9, (c) => SudokuCell(
      value: puzzle[r][c],
      isInitial: puzzle[r][c] != 0,
    )));

    state = GameState(
      board: board,
      solution: fullBoard,
      difficulty: difficulty,
      undoHistory: [],
      redoHistory: [],
    );
    _startTimer();
    _saveGame();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(seconds: state.seconds + 1);
      if (state.seconds % 5 == 0) _saveGame();
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
    final r = state.selectedRow!;
    final c = state.selectedCol!;
    
    if (state.board[r][c].isInitial) return;

    _saveToHistory();

    final newBoard = state.board.map((row) => List<SudokuCell>.from(row)).toList();

    if (state.isNoteMode && number != 0) {
      final notes = List<int>.from(newBoard[r][c].notes);
      if (notes.contains(number)) {
        notes.remove(number);
      } else {
        notes.add(number);
        notes.sort();
      }
      newBoard[r][c] = newBoard[r][c].copyWith(notes: notes, value: 0);
    } else {
      if (number == 0) {
        newBoard[r][c] = newBoard[r][c].copyWith(value: 0, notes: [], isError: false);
      } else {
        final isError = state.solution[r][c] != number;
        newBoard[r][c] = newBoard[r][c].copyWith(value: number, notes: [], isError: isError);
      }
    }

    state = state.copyWith(board: newBoard, redoHistory: []);
    _checkWin();
    _saveGame();
  }

  void _saveToHistory() {
    final currentBoard = state.board.map((row) => List<SudokuCell>.from(row)).toList();
    final newHistory = List<List<List<SudokuCell>>>.from(state.undoHistory)..add(currentBoard);
    state = state.copyWith(undoHistory: newHistory);
  }

  void undo() {
    if (state.undoHistory.isEmpty) return;
    final lastBoard = state.undoHistory.last;
    final newUndoHistory = List<List<List<SudokuCell>>>.from(state.undoHistory)..removeLast();
    final newRedoHistory = List<List<List<SudokuCell>>>.from(state.redoHistory)..add(state.board);
    
    state = state.copyWith(
      board: lastBoard,
      undoHistory: newUndoHistory,
      redoHistory: newRedoHistory,
    );
    _saveGame();
  }

  void redo() {
    if (state.redoHistory.isEmpty) return;
    final nextBoard = state.redoHistory.last;
    final newRedoHistory = List<List<List<SudokuCell>>>.from(state.redoHistory)..removeLast();
    final newUndoHistory = List<List<List<SudokuCell>>>.from(state.undoHistory)..add(state.board);

    state = state.copyWith(
      board: nextBoard,
      undoHistory: newUndoHistory,
      redoHistory: newUndoHistory,
    );
    _saveGame();
  }

  void giveHint() {
    if (state.selectedRow == null || state.selectedCol == null) return;
    final r = state.selectedRow!;
    final c = state.selectedCol!;
    
    if (state.board[r][c].isInitial || (state.board[r][c].value == state.solution[r][c] && state.board[r][c].value != 0)) return;

    _saveToHistory();
    final newBoard = state.board.map((row) => List<SudokuCell>.from(row)).toList();
    newBoard[r][c] = newBoard[r][c].copyWith(value: state.solution[r][c], notes: [], isError: false);
    
    state = state.copyWith(board: newBoard, redoHistory: []);
    _checkWin();
    _saveGame();
  }

  void _checkWin() {
    if (state.board.isEmpty || state.solution.isEmpty) return;
    bool complete = true;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (state.board[r][c].value != state.solution[r][c]) {
          complete = false;
          break;
        }
      }
      if (!complete) break;
    }
    if (complete) {
      _timer?.cancel();
      state = state.copyWith(isGameOver: true);
    }
  }

  Future<void> _saveGame() async {
    if (_prefs == null || state.board.isEmpty) return;
    final boardData = state.board.map((r) => r.map((c) => {
      'v': c.value,
      'i': c.isInitial,
      'e': c.isError,
      'n': c.notes,
    }).toList()).toList();
    
    await _prefs!.setString('board', jsonEncode(boardData));
    await _prefs!.setString('solution', jsonEncode(state.solution));
    await _prefs!.setInt('seconds', state.seconds);
    await _prefs!.setString('difficulty', state.difficulty.name);
  }

  void _loadGame() {
    final boardStr = _prefs?.getString('board');
    if (boardStr == null) return;

    try {
      final List<dynamic> boardData = jsonDecode(boardStr);
      final board = boardData.map((r) => (r as List).map((c) => SudokuCell(
        value: c['v'],
        isInitial: c['i'],
        isError: c['e'],
        notes: List<int>.from(c['n']),
      )).toList()).toList();

      final solutionStr = _prefs?.getString('solution');
      final List<List<int>> solution = (jsonDecode(solutionStr!) as List)
          .map((r) => List<int>.from(r)).toList();
      
      final diffStr = _prefs?.getString('difficulty');
      final diff = Difficulty.values.firstWhere((e) => e.name == diffStr, orElse: () => Difficulty.easy);
      final seconds = _prefs?.getInt('seconds') ?? 0;

      state = GameState(
        board: board,
        solution: solution,
        difficulty: diff,
        seconds: seconds,
      );
      _startTimer();
    } catch (_) {}
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

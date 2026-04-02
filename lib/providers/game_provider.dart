import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_cell.dart';
import '../logic/sudoku_logic.dart';
import '../core/constants.dart';

/// Полное состояние игры, которое хранится в Riverpod.
class GameState {
  /// Текущая игровая доска в виде моделей клеток.
  final List<List<SudokuCell>> board;

  /// Полное решение (9x9) для текущей игры.
  final List<List<int>> solution;

  /// История для отмены ходов (undo).
  final List<List<List<SudokuCell>>> undoHistory;

  /// История для повтора отменённых ходов (redo).
  final List<List<List<SudokuCell>>> redoHistory;

  /// Индекс выбранной строки (или `null`, если ничего не выбрано).
  final int? selectedRow;

  /// Индекс выбранного столбца (или `null`, если ничего не выбрано).
  final int? selectedCol;

  /// Включён ли режим заметок (карандаш).
  final bool isNoteMode;

  /// Текущая сложность игры.
  final Difficulty difficulty;

  /// Активная цветовая тема.
  final GameTheme theme;

  /// Сколько секунд прошло с начала игры.
  final int seconds;

  /// Флаг завершения игры (победа или поражение).
  final bool isGameOver;

  /// Количество ошибок, допущенных игроком.
  final int mistakes;

  /// Создаёт состояние игры с заданными параметрами.
  GameState({
    required this.board,
    required this.solution,
    this.undoHistory = const [],
    this.redoHistory = const [],
    this.selectedRow,
    this.selectedCol,
    this.isNoteMode = false,
    required this.difficulty,
    this.theme = GameTheme.red,
    this.seconds = 0,
    this.isGameOver = false,
    this.mistakes = 0,
  });

  /// Возвращает копию состояния с изменёнными полями.
  GameState copyWith({
    List<List<SudokuCell>>? board,
    List<List<int>>? solution,
    List<List<List<SudokuCell>>>? undoHistory,
    List<List<List<SudokuCell>>>? redoHistory,
    int? selectedRow,
    int? selectedCol,
    bool? isNoteMode,
    Difficulty? difficulty,
    GameTheme? theme,
    int? seconds,
    bool? isGameOver,
    int? mistakes,
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
      theme: theme ?? this.theme,
      seconds: seconds ?? this.seconds,
      isGameOver: isGameOver ?? this.isGameOver,
      mistakes: mistakes ?? this.mistakes,
    );
  }
}

/// Контроллер игры: управляет состоянием, таймером и сохранением.
class GameNotifier extends StateNotifier<GameState> {
  /// Таймер игрового времени.
  Timer? _timer;

  /// Логика генерации и проверки Судоку.
  final SudokuLogic _logic = SudokuLogic();

  /// Хранилище настроек и сохранений.
  SharedPreferences? _prefs;

  /// Создаёт контроллер игры и инициирует загрузку сохранения.
  GameNotifier() : super(GameState(board: [], solution: [], difficulty: Difficulty.easy)) {
    _initPrefs();
  }

  /// Инициализирует SharedPreferences и пытается загрузить сохранённую игру.
  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadGame();
    } catch (_) {
      // Игнорируем ошибки чтения/инициализации, чтобы приложение не падало.
    }
  }

  /// Запускает новую игру с выбранной [difficulty].
  void startNewGame(Difficulty difficulty) {
    // Общий таймер для измерения времени генерации.
    final totalWatch = Stopwatch()..start();
    // Таймер генерации полной решённой доски.
    final fullWatch = Stopwatch();
    // Таймер построения головоломки из решения.
    final puzzleWatch = Stopwatch();

    // Полная решённая доска.
    List<List<int>> fullBoard = [];
    // Доска с вырезанными клетками.
    List<List<int>> puzzle = [];
    // Сколько раз пробуем генерацию.
    int attempts = 0;
    // Реальное количество подсказок после генерации.
    int clueCount = 0;
    // Максимум попыток, чтобы не зависнуть.
    const int maxAttempts = 5;

    do {
      attempts++;

      // Генерируем полную доску.
      fullWatch
        ..reset()
        ..start();
      fullBoard = _logic.generateFullBoard();
      fullWatch.stop();

      // Создаём головоломку, удаляя клетки.
      puzzleWatch
        ..reset()
        ..start();
      puzzle = _logic.createPuzzle(fullBoard, difficulty.clues);
      puzzleWatch.stop();

      // Сверяем фактическое число подсказок.
      clueCount = _logic.countClues(puzzle);
    } while (clueCount != difficulty.clues && attempts < maxAttempts);

    totalWatch.stop();
    // Логируем время генерации для диагностики.
    debugPrint(
      'Sudoku new game ${difficulty.name}: full=${fullWatch.elapsedMilliseconds}ms, '
      'puzzle=${puzzleWatch.elapsedMilliseconds}ms, attempts=$attempts, '
      'clues=$clueCount, total=${totalWatch.elapsedMilliseconds}ms',
    );

    // Преобразуем числовую доску в модели клеток для UI.
    // r/c — индексы строки и столбца.
    final board = List.generate(
      9,
      (r) => List.generate(
        9,
        (c) => SudokuCell(
          value: puzzle[r][c],
          isInitial: puzzle[r][c] != 0,
        ),
      ),
    );

    // Обновляем состояние игры.
    state = GameState(
      board: board,
      solution: fullBoard,
      difficulty: difficulty,
      theme: state.theme,
      undoHistory: [],
      redoHistory: [],
      mistakes: 0,
      isGameOver: false,
    );
    _startTimer();
    _saveGame();
  }

  /// Запускает таймер, увеличивающий счётчик секунд.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // timer — экземпляр таймера (не используется напрямую).
      // Каждую секунду увеличиваем таймер в состоянии.
      state = state.copyWith(seconds: state.seconds + 1);
      // Периодически сохраняем игру.
      if (state.seconds % 5 == 0) _saveGame();
    });
  }

  /// Выбирает клетку по координатам [r]/[c].
  void selectCell(int r, int c) {
    state = state.copyWith(selectedRow: r, selectedCol: c);
  }

  /// Переключает режим заметок.
  void toggleNoteMode() {
    if (state.isGameOver) return;
    state = state.copyWith(isNoteMode: !state.isNoteMode);
  }

  /// Устанавливает новую тему оформления.
  void setTheme(GameTheme theme) {
    if (state.theme == theme) return;
    state = state.copyWith(theme: theme);
    _saveGame();
  }

  /// Вводит число [number] в выбранную клетку.
  ///
  /// [number] == 0 означает очистку клетки.
  void inputNumber(int number) {
    if (state.isGameOver) return;
    if (state.selectedRow == null || state.selectedCol == null) return;
    // Координаты выбранной клетки.
    final r = state.selectedRow!;
    final c = state.selectedCol!;

    // Нельзя менять исходные подсказки.
    if (state.board[r][c].isInitial) return;

    // Сохраняем состояние для undo.
    _saveToHistory();

    // Копия доски для безопасного изменения.
    final newBoard = state.board.map((row) => List<SudokuCell>.from(row)).toList();
    // Локальная копия числа ошибок.
    var mistakes = state.mistakes;

    if (state.isNoteMode && number != 0) {
      // Работаем с заметками (карандаш).
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
        // Очистка клетки.
        newBoard[r][c] = newBoard[r][c].copyWith(value: 0, notes: [], isError: false);
      } else {
        // Проверяем, совпадает ли введённое число с решением.
        final isError = state.solution[r][c] != number;
        if (isError) {
          // Увеличиваем счётчик ошибок, если это новая ошибка.
          final wasSameValue = state.board[r][c].value == number;
          final wasError = state.board[r][c].isError;
          if (!wasSameValue || !wasError) {
            mistakes += 1;
          }
        }
        newBoard[r][c] = newBoard[r][c].copyWith(value: number, notes: [], isError: isError);
      }
    }

    // Обновляем состояние и очищаем redo-историю.
    state = state.copyWith(board: newBoard, redoHistory: [], mistakes: mistakes);
    if (mistakes >= 3) {
      // Достигли лимита ошибок — игра окончена.
      _timer?.cancel();
      state = state.copyWith(isGameOver: true);
      _saveGame();
      return;
    }
    _checkWin();
    _saveGame();
  }

  /// Сохраняет текущее состояние доски в историю undo.
  void _saveToHistory() {
    // Копия текущей доски.
    final currentBoard = state.board.map((row) => List<SudokuCell>.from(row)).toList();
    // Новая история undo с добавлением текущей доски.
    final newHistory = List<List<List<SudokuCell>>>.from(state.undoHistory)..add(currentBoard);
    state = state.copyWith(undoHistory: newHistory);
  }

  /// Откатывает последнее действие (undo).
  void undo() {
    if (state.isGameOver) return;
    if (state.undoHistory.isEmpty) return;
    // Последняя версия доски из истории.
    final lastBoard = state.undoHistory.last;
    // История undo без последнего элемента.
    final newUndoHistory = List<List<List<SudokuCell>>>.from(state.undoHistory)..removeLast();
    // Добавляем текущее состояние в историю redo.
    final newRedoHistory = List<List<List<SudokuCell>>>.from(state.redoHistory)..add(state.board);

    state = state.copyWith(
      board: lastBoard,
      undoHistory: newUndoHistory,
      redoHistory: newRedoHistory,
    );
    _saveGame();
  }

  /// Повторяет отменённое действие (redo).
  void redo() {
    if (state.isGameOver) return;
    if (state.redoHistory.isEmpty) return;
    // Следующая доска для восстановления.
    final nextBoard = state.redoHistory.last;
    // История redo без последнего элемента.
    final newRedoHistory = List<List<List<SudokuCell>>>.from(state.redoHistory)..removeLast();
    // Добавляем текущее состояние в историю undo.
    final newUndoHistory = List<List<List<SudokuCell>>>.from(state.undoHistory)..add(state.board);

    state = state.copyWith(
      board: nextBoard,
      undoHistory: newUndoHistory,
      redoHistory: newUndoHistory,
    );
    _saveGame();
  }

  /// Заполняет выбранную клетку правильным числом (подсказка).
  void giveHint() {
    if (state.isGameOver) return;
    if (state.selectedRow == null || state.selectedCol == null) return;
    // Координаты выбранной клетки.
    final r = state.selectedRow!;
    final c = state.selectedCol!;

    // Не даём подсказку для исходных клеток или уже верных значений.
    if (state.board[r][c].isInitial ||
        (state.board[r][c].value == state.solution[r][c] && state.board[r][c].value != 0)) {
      return;
    }

    _saveToHistory();
    // Копия доски для изменения.
    final newBoard = state.board.map((row) => List<SudokuCell>.from(row)).toList();
    newBoard[r][c] = newBoard[r][c].copyWith(
      value: state.solution[r][c],
      notes: [],
      isError: false,
    );

    state = state.copyWith(board: newBoard, redoHistory: []);
    _checkWin();
    _saveGame();
  }

  /// Проверяет, заполнена ли доска корректно.
  void _checkWin() {
    if (state.board.isEmpty || state.solution.isEmpty) return;
    // Флаг успешного заполнения.
    bool complete = true;
    // r/c — индексы строки и столбца.
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

  /// Сохраняет состояние игры в SharedPreferences.
  Future<void> _saveGame() async {
    if (_prefs == null || state.board.isEmpty) return;
    // Сериализуем доску в простой JSON-формат.
    final boardData = state.board
        .map(
          (r) => r
              .map(
                (c) => {
                  'v': c.value,
                  'i': c.isInitial,
                  'e': c.isError,
                  'n': c.notes,
                },
              )
              .toList(),
        )
        .toList();

    await _prefs!.setString('board', jsonEncode(boardData));
    await _prefs!.setString('solution', jsonEncode(state.solution));
    await _prefs!.setInt('seconds', state.seconds);
    await _prefs!.setString('difficulty', state.difficulty.name);
    await _prefs!.setInt('mistakes', state.mistakes);
    await _prefs!.setString('theme', state.theme.name);
  }

  /// Загружает сохранённую игру из SharedPreferences.
  void _loadGame() {
    // Строка с сериализованной доской.
    final boardStr = _prefs?.getString('board');
    if (boardStr == null) return;

    try {
      // Восстанавливаем доску из JSON.
      final List<dynamic> boardData = jsonDecode(boardStr);
      final board = boardData
          .map(
            (r) => (r as List)
                .map(
                  (c) => SudokuCell(
                    value: c['v'],
                    isInitial: c['i'],
                    isError: c['e'],
                    notes: List<int>.from(c['n']),
                  ),
                )
                .toList(),
          )
          .toList();

      // Восстанавливаем решение.
      final solutionStr = _prefs?.getString('solution');
      final List<List<int>> solution =
          (jsonDecode(solutionStr!) as List).map((r) => List<int>.from(r)).toList();

      // Восстанавливаем прочие параметры.
      final diffStr = _prefs?.getString('difficulty');
      final diff = Difficulty.values
          .firstWhere((e) => e.name == diffStr, orElse: () => Difficulty.easy);
      final themeStr = _prefs?.getString('theme');
      final theme =
          GameTheme.values.firstWhere((e) => e.name == themeStr, orElse: () => GameTheme.red);
      final seconds = _prefs?.getInt('seconds') ?? 0;
      final mistakes = _prefs?.getInt('mistakes') ?? 0;

      state = GameState(
        board: board,
        solution: solution,
        difficulty: diff,
        theme: theme,
        seconds: seconds,
        mistakes: mistakes,
        isGameOver: mistakes >= 3,
      );
      if (!state.isGameOver) {
        _startTimer();
      }
    } catch (_) {
      // Если данные повреждены, просто игнорируем сохранение.
    }
  }

  @override
  void dispose() {
    // Останавливаем таймер, чтобы не было утечек.
    _timer?.cancel();
    super.dispose();
  }
}

/// Провайдер, через который UI получает доступ к состоянию игры.
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

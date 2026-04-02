/// Модель одной клетки Судоку, хранящая как значение, так и состояние UI.
class SudokuCell {
  /// Текущее значение клетки (0 — пустая клетка).
  final int value;

  /// Признак того, что клетка является исходной подсказкой и не редактируется.
  final bool isInitial;

  /// Список заметок (кандидатных чисел), введённых игроком.
  final List<int> notes;

  /// Признак ошибки (значение не совпадает с решением).
  final bool isError;

  /// Создаёт новую клетку Судоку.
  ///
  /// Все параметры имеют значения по умолчанию, чтобы можно было создавать пустую клетку.
  SudokuCell({
    this.value = 0,
    this.isInitial = false,
    this.notes = const [],
    this.isError = false,
  });

  /// Возвращает копию клетки с изменёнными полями.
  ///
  /// Удобно для неизменяемого подхода в состоянии приложения.
  SudokuCell copyWith({
    int? value,
    bool? isInitial,
    List<int>? notes,
    bool? isError,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      isInitial: isInitial ?? this.isInitial,
      notes: notes ?? this.notes,
      isError: isError ?? this.isError,
    );
  }
}

class SudokuCell {
  final int value;
  final bool isInitial;
  final List<int> notes;
  final bool isError;

  SudokuCell({
    this.value = 0,
    this.isInitial = false,
    this.notes = const [],
    this.isError = false,
  });

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

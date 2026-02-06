import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../widgets/difficulty_dialog.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final gridPadding = isPortrait ? 24.0 : 40.0;
    final availableWidth = isPortrait ? size.width - gridPadding * 2 : size.height * 0.7;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, gameState),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildGrid(ref, gameState, availableWidth),
                    const SizedBox(height: 30),
                    _buildControls(ref, gameState),
                    const SizedBox(height: 20),
                    _buildNumpad(ref, gameState),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
          Column(
            children: [
              Text(
                state.difficulty.name.toUpperCase(),
                style: const TextStyle(
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.peachAccent,
                ),
              ),
              Text(
                _formatTime(state.seconds),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(WidgetRef ref, GameState state, double gridWidth) {
    return Container(
      width: gridWidth,
      height: gridWidth,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textPrimary, width: 2),
      ),
      child: Column(
        children: List.generate(9, (r) => Expanded(
          child: Row(
            children: List.generate(9, (c) => Expanded(
              child: _buildCell(ref, state, r, c),
            )),
          ),
        )),
      ),
    );
  }

  Widget _buildCell(WidgetRef ref, GameState state, int r, int c) {
    final cell = state.board[r][c];
    final isSelected = state.selectedRow == r && state.selectedCol == c;
    
    // Thicker lines for 3x3 blocks
    final borderRight = (c + 1) % 3 == 0 && c < 8 ? 2.0 : 0.5;
    final borderBottom = (r + 1) % 3 == 0 && r < 8 ? 2.0 : 0.5;

    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).selectCell(r, c),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.peachLight : Colors.transparent,
          border: Border(
            right: BorderSide(color: AppColors.grayMedium, width: borderRight),
            bottom: BorderSide(color: AppColors.grayMedium, width: borderBottom),
          ),
        ),
        child: Center(
          child: cell.value != 0 
            ? Text(
                '${cell.value}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: cell.isInitial ? FontWeight.w600 : FontWeight.w300,
                  color: cell.isError ? AppColors.hardRed : AppColors.textPrimary,
                ),
              )
            : _buildNotes(cell.notes),
        ),
      ),
    );
  }

  Widget _buildNotes(List<int> notes) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(2),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        final n = index + 1;
        return Center(
          child: Text(
            notes.contains(n) ? '$n' : '',
            style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
        );
      }),
    );
  }

  Widget _buildControls(WidgetRef ref, GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _controlIcon(Icons.undo, 'undo', () {}),
        _controlIcon(Icons.history, 'history', () {}),
        _controlIcon(
          state.isNoteMode ? Icons.edit : Icons.edit_outlined,
          'notes',
          () => ref.read(gameProvider.notifier).toggleNoteMode(),
          isActive: state.isNoteMode,
        ),
        _controlIcon(Icons.lightbulb_outline, 'hint', () {}),
      ],
    );
  }

  Widget _controlIcon(IconData icon, String label, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isActive ? AppColors.peachAccent : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.peachAccent : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad(WidgetRef ref, GameState state) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(9, (index) {
        final num = index + 1;
        return GestureDetector(
          onTap: () => ref.read(gameProvider.notifier).inputNumber(num),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$num',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: AppColors.peachAccent,
              ),
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              Expanded(
                child: isLandscape 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGrid(ref, gameState, size.height * 0.65),
                        _buildRightPanel(ref, gameState),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildGrid(ref, gameState, size.width * 0.85),
                          const SizedBox(height: 40),
                          _buildRightPanel(ref, gameState),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.title,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w200,
            letterSpacing: 8,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            Icon(Icons.format_paint_outlined, color: Colors.grey[400], size: 28),
            const SizedBox(width: 20),
            Icon(Icons.settings_outlined, color: Colors.grey[400], size: 28),
          ],
        ),
      ],
    );
  }

  Widget _buildGrid(WidgetRef ref, GameState state, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gridLines, width: 1),
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
    final isRelated = (state.selectedRow == r || state.selectedCol == c);

    final borderRight = (c + 1) % 3 == 0 && c < 8 ? 2.0 : 0.5;
    final borderBottom = (r + 1) % 3 == 0 && r < 8 ? 2.0 : 0.5;

    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).selectCell(r, c),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.peachMedium.withOpacity(0.5) 
              : (isRelated ? AppColors.gridHighlight : Colors.transparent),
          border: Border(
            right: BorderSide(color: AppColors.gridLines, width: borderRight),
            bottom: BorderSide(color: AppColors.gridLines, width: borderBottom),
          ),
        ),
        child: Center(
          child: cell.value != 0 
            ? Text(
                '${cell.value}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: cell.isInitial ? FontWeight.w400 : FontWeight.w300,
                  color: cell.isError ? Colors.red : AppColors.textPrimary,
                ),
              )
            : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildRightPanel(WidgetRef ref, GameState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNumpad(ref),
        const SizedBox(height: 32),
        _buildSmallMenuButton(AppStrings.newGame, onTap: () => Navigator.pop(ref.context)),
      ],
    );
  }

  Widget _buildNumpad(WidgetRef ref) {
    return Container(
      width: 200,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: List.generate(9, (index) => _buildNumpadButton(ref, index + 1)),
      ),
    );
  }

  Widget _buildNumpadButton(WidgetRef ref, int num) {
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).inputNumber(num),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner accents (red for numpad)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.hardRed.withOpacity(0.4), width: 1),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black12, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '$num',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMenuButton(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

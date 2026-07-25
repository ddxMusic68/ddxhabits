import 'package:flutter/material.dart';
import '../models/habit_grid.dart';
import '../utils/constants.dart';

class HabitGridWidget extends StatelessWidget {
  final HabitGrid grid;
  final Function(int) onFillSquare;
  final VoidCallback? onIncrement;
  final VoidCallback? onReset;

  const HabitGridWidget({
    super.key,
    required this.grid,
    required this.onFillSquare,
    this.onIncrement,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: grid.isComplete ? AppColors.mintLight : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    grid.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: grid.isComplete ? AppColors.mintDark : null,
                    ),
                  ),
                ),
                if (grid.isComplete)
                  const Icon(Icons.check_circle, color: AppColors.mintDark, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: grid.fillProgress,
                      minHeight: 12,
                      backgroundColor: AppColors.emptySquare,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        grid.isComplete ? AppColors.mintDark : AppColors.mint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${((grid.filledCount/grid.totalCount)*100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: grid.isComplete ? AppColors.mintDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid.columns,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: grid.boolList.length,
              itemBuilder: (context, index) {
                final filled = grid.boolList[index];
                final canAfford = grid.currentCredit >= grid.squareCost;
                return GestureDetector(
                  onTap: (filled || !canAfford || grid.isComplete)
                      ? null
                      : () => onFillSquare(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: filled ? AppColors.mintDark : AppColors.emptySquare,
                      borderRadius: BorderRadius.circular(4),
                      border: (!filled && canAfford && !grid.isComplete)
                          ? Border.all(color: AppColors.mintDark, width: 2)
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  grid.isComplete
                      ? 'Complete!'
                      : 'Unused: \$${grid.currentCredit.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: grid.isComplete ? AppColors.mintDark : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Total: \$${grid.totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: grid.isComplete ? AppColors.mintDark : AppColors.textSecondary,
                  ),
                ),
                if (!grid.isComplete)
                  IconButton(
                    onPressed: onIncrement,
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.mintDark,
                  ),
              ],
            ),
            if (grid.isComplete && onReset != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mintDark,
                      side: const BorderSide(color: AppColors.mintDark),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

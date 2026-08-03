import 'package:flutter/material.dart';
import '../models/goal_chain.dart';
import '../utils/constants.dart';

class GoalChainWidget extends StatelessWidget {
  final GoalChain chain;
  final VoidCallback? onComplete;
  final VoidCallback? onReset;
  final VoidCallback? onEdit;

  const GoalChainWidget({
    super.key,
    required this.chain,
    this.onComplete,
    this.onReset,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: chain.isComplete ? AppColors.mintLight : null,
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
                    chain.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: chain.isComplete ? AppColors.mintDark : onSurface,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.textSecondary,
                  ),
                if (chain.isComplete)
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
                      value: chain.progress,
                      minHeight: 12,
                      backgroundColor: AppColors.emptySquare,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        chain.isComplete ? AppColors.mintDark : AppColors.mint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${chain.completedCount} / ${chain.goalList.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: chain.isComplete ? AppColors.mintDark : onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (chain.goalList.isEmpty)
              Text(
                'No goals yet. Edit this chain to add goals.',
                style: TextStyle(color: onSurface.withValues(alpha: 0.5)),
              )
            else
              ...List.generate(chain.goalList.length, (index) {
                final goal = chain.goalList[index];
                final isCompleted = goal.isComplete;
                final isCurrent = index == chain.currentGoalIndex && !chain.isComplete;
                final onSurface = Theme.of(context).colorScheme.onSurface;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 32,
                        child: Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? AppColors.mintDark
                                    : isCurrent
                                        ? AppColors.mint
                                        : AppColors.emptySquare,
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : isCurrent
                                      ? const Icon(Icons.play_arrow, color: Colors.white, size: 16)
                                      : null,
                            ),
                            if (index < chain.goalList.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: isCompleted ? AppColors.mintDark : AppColors.emptySquare,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            goal.title,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted
                                  ? onSurface.withValues(alpha: 0.4)
                                  : isCurrent
                                      ? onSurface
                                      : onSurface.withValues(alpha: 0.7),
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),
            if (chain.isComplete)
              SizedBox(
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
              )
            else if (chain.currentGoal != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text('Complete: ${chain.currentGoal!.title}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintDark,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

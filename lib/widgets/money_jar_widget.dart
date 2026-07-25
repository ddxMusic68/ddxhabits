import 'package:flutter/material.dart';
import '../models/money_jar.dart';
import '../utils/constants.dart';

class MoneyJarWidget extends StatelessWidget {
  final MoneyJar jar;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onReset;

  const MoneyJarWidget({
    super.key,
    required this.jar,
    this.onAdd,
    this.onRemove,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: jar.isComplete ? AppColors.mintLight : null,
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
                    jar.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: jar.isComplete ? AppColors.mintDark : null,
                    ),
                  ),
                ),
                if (jar.isComplete)
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
                      value: jar.progress,
                      minHeight: 12,
                      backgroundColor: AppColors.emptySquare,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        jar.isComplete ? AppColors.mintDark : AppColors.mint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(jar.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: jar.isComplete ? AppColors.mintDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSource(),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildJar(),
                  ),
                  Expanded(
                    child: _buildTrash(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  jar.isComplete
                      ? 'Goal reached!'
                      : 'Unused: \$${jar.curAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: jar.isComplete ? AppColors.mintDark : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Goal: \$${jar.goalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: jar.isComplete ? AppColors.mintDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (jar.isComplete && onReset != null)
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

  Widget _buildSource() {
    return Draggable<String>(
      data: 'add',
      feedback: Material(
        color: Colors.transparent,
        child: _buildCoinPile(opacity: 0.8),
      ),
      childWhenDragging: _buildCoinPile(opacity: 0.3),
      child: _buildCoinPile(opacity: 1.0),
    );
  }

  Widget _buildCoinPile({required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.savings, size: 40, color: AppColors.mintDark),
          const SizedBox(height: 4),
          Text(
            '+\$${jar.increment.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.mintDark,
            ),
          ),
          const Text(
            '(hold & drag)',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJar() {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data == 'add' && !jar.isComplete,
      onAcceptWithDetails: (_) {
        onAdd?.call();
      },
      builder: (context, candidateData, rejectingData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering ? AppColors.mintDark : AppColors.emptySquare,
              width: isHovering ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (jar.useLiquidFill)
                _buildLiquidJar(isHovering)
              else
                _buildCoinJar(isHovering),
              if (jar.curAmount > 0 && !jar.isComplete)
                Positioned(
                  bottom: 8,
                  child: Draggable<String>(
                    data: 'remove',
                    feedback: Material(
                      color: Colors.transparent,
                      child: Text(
                        '\$${jar.curAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mintDark.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    childWhenDragging: Text(
                      '\$${jar.curAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '\$${jar.curAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  bottom: 8,
                  child: Text(
                    jar.isComplete ? 'Goal reached!' : '\$${jar.curAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: jar.isComplete ? AppColors.mintDark : AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiquidJar(bool isHovering) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _LiquidPainter(
            progress: jar.progress,
            color: isHovering ? AppColors.mint : AppColors.mintDark,
          ),
        ),
      ),
    );
  }

  Widget _buildCoinJar(bool isHovering) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.expand(
        child: ColoredBox(
          color: isHovering ? AppColors.mintLight : AppColors.background,
          child: _buildCoinStack(),
        ),
      ),
    );
  }

  Widget _buildCoinStack() {
    final coinCount = (jar.progress * 12).ceil().clamp(0, 12);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(coinCount, (index) {
        return Container(
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.mintDark,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildTrash() {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data == 'remove' && jar.curAmount > 0,
      onAcceptWithDetails: (_) {
        onRemove?.call();
      },
      builder: (context, candidateData, rejectingData) {
        final isHovering = candidateData.isNotEmpty;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              size: 40,
              color: isHovering ? Colors.red : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              '-\$${jar.increment.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isHovering ? Colors.red : AppColors.textSecondary,
              ),
            ),
            const Text(
              '(drop here)',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LiquidPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final fillHeight = size.height * progress;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height - fillHeight);

    final waveHeight = 6.0;
    final waveWidth = size.width;
    path.cubicTo(
      0,
      size.height - fillHeight - waveHeight,
      waveWidth / 4,
      size.height - fillHeight + waveHeight,
      waveWidth / 2,
      size.height - fillHeight,
    );
    path.cubicTo(
      waveWidth * 3 / 4,
      size.height - fillHeight - waveHeight,
      waveWidth,
      size.height - fillHeight + waveHeight,
      waveWidth,
      size.height - fillHeight,
    );

    path.lineTo(waveWidth, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

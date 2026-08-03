import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timed_habit.dart';
import '../utils/constants.dart';

class TimedHabitWidget extends StatefulWidget {
  final TimedHabit habit;
  final ValueChanged<int> onAddSession;
  final ValueChanged<int>? onRemoveSession;
  final VoidCallback? onReset;
  final VoidCallback? onEdit;

  const TimedHabitWidget({
    super.key,
    required this.habit,
    required this.onAddSession,
    this.onRemoveSession,
    this.onReset,
    this.onEdit,
  });

  @override
  State<TimedHabitWidget> createState() => _TimedHabitWidgetState();
}

class _TimedHabitWidgetState extends State<TimedHabitWidget> {
  Stopwatch? _stopwatch;
  Timer? _timer;
  int? _pendingSeconds;
  bool _showNewBest = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isRunning => _stopwatch?.isRunning ?? false;

  int get _displaySeconds {
    if (_isRunning) return _stopwatch!.elapsed.inSeconds;
    if (_pendingSeconds != null) return _pendingSeconds!;
    final best = widget.habit.bestTime;
    if (best != null) return best.inSeconds;
    return 0;
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _stopwatch = Stopwatch()..start();
      _pendingSeconds = null;
      _showNewBest = false;
      _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (mounted) setState(() {});
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _stopwatch?.stop();
      _pendingSeconds = _stopwatch?.elapsed.inSeconds ?? 0;
    });
  }

  void _discard() {
    setState(() {
      _pendingSeconds = null;
      _stopwatch = null;
    });
  }

  void _save() {
    final seconds = _pendingSeconds;
    if (seconds == null) return;
    final isNewBest = widget.habit.isNewBest(seconds);
    widget.onAddSession(seconds);
    setState(() {
      _pendingSeconds = null;
      _stopwatch = null;
      _showNewBest = isNewBest;
    });
  }

  String _format(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final best = widget.habit.bestTime;
    final sessions = widget.habit.sessions;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.mintDark, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.habit.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                ),
                if (widget.onEdit != null)
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  widget.habit.fasterIsBetter
                      ? Icons.trending_down
                      : Icons.trending_up,
                  size: 18,
                  color: AppColors.mintDark,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.habit.fasterIsBetter
                      ? 'Improvement: quicker is better'
                      : 'Improvement: longer is better',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    _format(_displaySeconds),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: _isRunning ? AppColors.mintDark : onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    _isRunning
                        ? 'LIVE'
                        : _pendingSeconds != null
                            ? 'NEW TIME — TAP SAVE TO RECORD'
                            : best != null
                                ? 'BEST TIME'
                                : 'NO TIMES YET',
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_showNewBest)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW BEST!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mintLight,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_isRunning)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coralDark,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else if (_pendingSeconds != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _discard,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Discard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mintDark,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintDark,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            if (sessions.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TIMES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Best: ${best != null ? _format(best.inSeconds) : '—'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mintDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._buildSessionRows(sessions, best),
            ],
            if (sessions.isNotEmpty && widget.onReset != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onReset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset all times'),
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

  List<Widget> _buildSessionRows(
    List<TimedSession> sessions,
    Duration? best,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final newestFirst = sessions.reversed.toList();
    final rows = <Widget>[];
    for (int i = 0; i < newestFirst.length; i++) {
      final session = newestFirst[i];
      final isBest = best != null && session.seconds == best.inSeconds;
      final originalIndex = sessions.length - 1 - i;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                isBest ? Icons.emoji_events : Icons.circle,
                size: 16,
                color: isBest ? AppColors.mintDark : AppColors.emptySquare,
              ),
              const SizedBox(width: 10),
              Text(
                _format(session.seconds),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isBest ? AppColors.mintDark : onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDate(session.timestamp),
                  style: TextStyle(
                    fontSize: 13,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              if (widget.onRemoveSession != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => widget.onRemoveSession!(originalIndex),
                ),
            ],
          ),
        ),
      );
    }
    return rows;
  }
}

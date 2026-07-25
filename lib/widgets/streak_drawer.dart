import 'package:flutter/material.dart';
import '../models/habit_journal.dart';
import '../utils/constants.dart';

class StreakDrawer extends StatefulWidget {
  final HabitJournal journal;

  const StreakDrawer({super.key, required this.journal});

  @override
  State<StreakDrawer> createState() => _StreakDrawerState();
}

class _StreakDrawerState extends State<StreakDrawer>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _widthAnimation = Tween<double>(begin: 0, end: 120).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final journal = widget.journal;
    final currentStreak = journal.currentStreak;
    final bestStreak = journal.bestStreak;
    final todayEntry = journal.getEntryForDate(DateTime.now());
    final didToday = todayEntry?.didAnything == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _widthAnimation,
          builder: (context, child) {
            return SizedBox(
              width: _widthAnimation.value,
              child: _widthAnimation.value > 10 ? child : const SizedBox.shrink(),
            );
          },
          child: _buildExpandedContent(currentStreak, bestStreak, didToday),
        ),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 20,
            height: 80,
            margin: const EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
              color: _isExpanded
                  ? AppColors.coralDark
                  : AppColors.coralDark.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
            ),
            child: Center(
              child: Icon(
                  _isExpanded ? Icons.chevron_right : Icons.chevron_left,
                  size: 16,
                  color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(int currentStreak, int bestStreak, bool didToday) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            '$currentStreak',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: didToday ? AppColors.textSecondary : AppColors.coralDark,
            ),
          ),
          Text(
            'days',
            style: TextStyle(
              fontSize: 12,
              color: didToday ? AppColors.textSecondary : AppColors.coralDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Best: $bestStreak',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

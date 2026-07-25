import 'package:flutter/material.dart';
import '../models/habit_journal.dart';
import '../screens/entry_screen.dart';
import '../utils/constants.dart';

class CalendarWidget extends StatefulWidget {
  final HabitJournal journal;
  final int journalIndex;

  const CalendarWidget({
    super.key,
    required this.journal,
    required this.journalIndex,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDayHeaders(),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            widget.journal.name,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: widget.journal.isGoodHabit ? AppColors.mintDark : AppColors.coralDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
              ),
              Text(
                '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: days.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final isGood = widget.journal.isGoodHabit;
    final daysWithEntries = widget.journal.getDaysWithEntries(
      _currentMonth.year,
      _currentMonth.month,
    );
    final daysWithBadHabit = isGood
        ? <int>{}
        : widget.journal.getDaysWithBadHabit(_currentMonth.year, _currentMonth.month);

    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final totalDays = lastDay.day;

    final today = DateTime.now();
    final isCurrentMonth = today.year == _currentMonth.year && today.month == _currentMonth.month;

    final dotColor = isGood ? AppColors.mintDark : AppColors.coralDark;

    final startDate = widget.journal.firstEntryDate;
    final isStartMonth = startDate != null &&
        startDate.year == _currentMonth.year && startDate.month == _currentMonth.month;
    final startDay = isStartMonth ? startDate.day : -1;

    final isViewBeforeStart = startDate != null &&
        (_currentMonth.year < startDate.year ||
            (_currentMonth.year == startDate.year && _currentMonth.month < startDate.month));
    final isViewAfterToday = _currentMonth.year > today.year ||
        (_currentMonth.year == today.year && _currentMonth.month > today.month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(((totalDays + firstWeekday - 1) / 7).ceil(), (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNumber = cellIndex - firstWeekday + 2;

              if (dayNumber < 1 || dayNumber > totalDays) {
                return const Expanded(child: SizedBox(height: 44));
              }

              final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final isToday = isCurrentMonth && dayNumber == today.day;

              final isBeforeStart = isViewBeforeStart ||
                  (isStartMonth && dayNumber < startDay) ||
                  (startDate != null && _currentMonth.year == startDate.year && _currentMonth.month == startDate.month && dayNumber < startDay);
              final isAfterToday = isViewAfterToday ||
                  (isCurrentMonth && dayNumber > today.day);
              final isGrayedOut = isBeforeStart || isAfterToday;
              final hasDot = isGood
                  ? daysWithEntries.contains(dayNumber)
                  : daysWithBadHabit.contains(dayNumber);

              final showTodayBorder = isToday;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EntryScreen(
                          journalIndex: widget.journalIndex,
                          date: date,
                          isGoodHabit: isGood,
                          journalName: widget.journal.name,
                        ),
                      ),
                    ).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: showTodayBorder
                          ? Border.all(color: Colors.black, width: 1)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isGrayedOut
                                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (hasDot && !isGrayedOut)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }
}

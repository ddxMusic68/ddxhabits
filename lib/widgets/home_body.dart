import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_item.dart';
import '../models/habit_journal.dart';
import '../providers/habit_tracker_provider.dart';
import '../screens/create_dialogs.dart';
import '../widgets/habit_grid_widget.dart';
import '../widgets/goal_chain_widget.dart';
import '../widgets/money_jar_widget.dart';
import '../widgets/habit_contract_widget.dart';
import '../widgets/timed_habit_widget.dart';
import '../widgets/calendar_widget.dart';
import '../utils/constants.dart';

class HomeBody extends StatelessWidget {
  final SelectedItem? selected;

  const HomeBody({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitTrackerProvider>(
      builder: (context, provider, child) {
        if (selected == null) return _buildEmpty('Select an item from the menu');
        switch (selected!.type) {
          case SelectedType.journal:
            return _buildJournal(context, provider);
          case SelectedType.grid:
            return _buildGrid(context, provider);
          case SelectedType.chain:
            return _buildChain(context, provider);
          case SelectedType.jar:
            return _buildJar(context, provider);
          case SelectedType.contract:
            return _buildContract(context, provider);
          case SelectedType.timed:
            return _buildTimed(context, provider);
        }
      },
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildJournal(BuildContext context, HabitTrackerProvider provider) {
    if (selected!.index >= provider.journals.length) {
      return _buildEmpty('Select a journal from the menu');
    }
    final journal = provider.journals[selected!.index];
    final calWidget = CalendarWidget(
      key: ValueKey('${selected!.index}_${journal.journalEntryList.length}'),
      journal: journal,
      journalIndex: selected!.index,
      onEdit: () => showAddJournalDialog(
        context,
        null,
        isGoodHabit: journal.isGoodHabit,
        initial: journal,
        initialIndex: selected!.index,
      ),
    );

    if (journal.isGoodHabit) {
      return SingleChildScrollView(child: calWidget);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          calWidget,
          _buildStreakBar(journal),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, HabitTrackerProvider provider) {
    if (selected!.index >= provider.grids.length) {
      return _buildEmpty('Select a grid from the menu');
    }
    final grid = provider.grids[selected!.index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HabitGridWidget(
        grid: grid,
        onFillSquare: (squareIndex) {
          provider.fillSquare(selected!.index, squareIndex);
        },
        onIncrement: () {
          provider.incrementGrid(selected!.index);
        },
        onReset: () {
          provider.resetGrid(selected!.index);
        },
        onEdit: () => showAddGridDialog(
          context,
          null,
          initial: grid,
          initialIndex: selected!.index,
        ),
      ),
    );
  }

  Widget _buildChain(BuildContext context, HabitTrackerProvider provider) {
    if (selected!.index >= provider.goalChains.length) {
      return _buildEmpty('Select a chain from the menu');
    }
    final chain = provider.goalChains[selected!.index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GoalChainWidget(
        chain: chain,
        onComplete: () {
          provider.completeGoalInChain(selected!.index);
        },
        onReset: () {
          provider.resetGoalChain(selected!.index);
        },
        onEdit: () => showAddChainDialog(
          context,
          null,
          initial: chain,
          initialIndex: selected!.index,
        ),
      ),
    );
  }

  Widget _buildJar(BuildContext context, HabitTrackerProvider provider) {
    if (selected!.index >= provider.moneyJars.length) {
      return _buildEmpty('Select a jar from the menu');
    }
    final jar = provider.moneyJars[selected!.index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MoneyJarWidget(
        jar: jar,
        onAdd: () {
          provider.addToJar(selected!.index);
        },
        onRemove: () {
          provider.removeFromJar(selected!.index);
        },
        onReset: () {
          provider.resetMoneyJar(selected!.index);
        },
        onEdit: () => showAddJarDialog(
          context,
          null,
          initial: jar,
          initialIndex: selected!.index,
        ),
      ),
    );
  }

  Widget _buildContract(BuildContext context, HabitTrackerProvider provider) {
    if (selected!.index >= provider.contracts.length) {
      return _buildEmpty('Select a contract from the menu');
    }
    final contract = provider.contracts[selected!.index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HabitContractWidget(
        contract: contract,
        onEdit: () => showAddContractDialog(
          context,
          null,
          initial: contract,
          initialIndex: selected!.index,
        ),
      ),
    );
  }

  Widget _buildTimed(BuildContext context, HabitTrackerProvider provider) {
    if (selected!.index >= provider.timedHabits.length) {
      return _buildEmpty('Select a timed habit from the menu');
    }
    final habit = provider.timedHabits[selected!.index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TimedHabitWidget(
        habit: habit,
        onAddSession: (seconds) {
          provider.addTimedSession(selected!.index, seconds);
        },
        onRemoveSession: (sessionIndex) {
          provider.removeTimedSession(selected!.index, sessionIndex);
        },
        onReset: () {
          provider.resetTimedHabit(selected!.index);
        },
        onEdit: () => showAddTimedHabitDialog(
          context,
          null,
          initial: habit,
          initialIndex: selected!.index,
        ),
      ),
    );
  }

  Widget _buildStreakBar(HabitJournal journal) {
    final currentStreak = journal.currentStreak;
    final bestStreak = journal.bestStreak;
    final todayEntry = journal.getEntryForDate(DateTime.now());
    final didToday = todayEntry?.didAnything == true;

    final goals = [
      (target: 7, label: '7d'),
      (target: 30, label: '30d'),
      (target: 90, label: '90d'),
    ];

    Widget buildGoalColumn(int streak, {required Color color}) {
      return Column(
        children: goals.map((g) {
          final reached = streak >= g.target;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  reached ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: reached ? color : AppColors.emptySquare,
                ),
                const SizedBox(width: 6),
                Text(
                  g.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: reached ? color : AppColors.emptySquare,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.emptySquare)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                '$currentStreak',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: didToday ? AppColors.textSecondary : const Color.fromARGB(255, 1, 124, 7),
                ),
              ),
              Text(
                'days without',
                style: TextStyle(
                  fontSize: 12,
                  color: didToday ? AppColors.textSecondary : const Color.fromARGB(255, 1, 99, 5),
                ),
              ),
              const SizedBox(height: 8),
              buildGoalColumn(currentStreak, color: didToday ? AppColors.textSecondary : AppColors.coralDark),
            ],
          ),
          const SizedBox(width: 48),
          Column(
            children: [
              Text(
                '$bestStreak',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const Text(
                'best',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              buildGoalColumn(bestStreak, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

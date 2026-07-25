import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_item.dart';
import '../models/habit_journal.dart';
import '../providers/habit_tracker_provider.dart';
import '../utils/constants.dart';

class AppDrawer extends StatelessWidget {
  final SelectedItem? selected;
  final ValueChanged<SelectedItem> onSelect;

  const AppDrawer({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitTrackerProvider>(
      builder: (context, provider, child) {
        return Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'ddxHabits',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mintDark,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      if (provider.journals.any((j) => j.isGoodHabit)) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text(
                            'GOOD HABIT JOURNAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mintDark,
                            ),
                          ),
                        ),
                        ..._buildJournalItems(context, provider, isGoodHabit: true),
                      ],
                      if (provider.journals.any((j) => !j.isGoodHabit)) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            'BAD HABIT JOURNAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coralDark,
                            ),
                          ),
                        ),
                        ..._buildJournalItems(context, provider, isGoodHabit: false),
                      ],
                      if (provider.grids.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            'HABIT GRIDS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ..._buildGridItems(context, provider),
                      ],
                      if (provider.goalChains.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            'GOAL CHAINS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ..._buildChainItems(context, provider),
                      ],
                      if (provider.moneyJars.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            'MONEY JARS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ..._buildJarItems(context, provider),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGridItems(BuildContext context, HabitTrackerProvider provider) {
    final sortedIndices = List<int>.generate(provider.grids.length, (i) => i);
    sortedIndices.sort((a, b) {
      final aComplete = provider.grids[a].isComplete;
      final bComplete = provider.grids[b].isComplete;
      if (aComplete == bComplete) return 0;
      return aComplete ? 1 : -1;
    });

    return sortedIndices.map((originalIndex) {
      final grid = provider.grids[originalIndex];
      final isSelected = selected?.type == SelectedType.grid && selected?.index == originalIndex;
      return ListTile(
        leading: grid.isComplete
            ? const Icon(Icons.check_circle, color: AppColors.mintDark, size: 20)
            : const Icon(Icons.grid_view, size: 20),
        title: Text(
          grid.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.mintDark : null,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.mintLight,
        onTap: () {
          onSelect(SelectedItem(SelectedType.grid, originalIndex));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> _buildChainItems(BuildContext context, HabitTrackerProvider provider) {
    final sortedIndices = List<int>.generate(provider.goalChains.length, (i) => i);
    sortedIndices.sort((a, b) {
      final aComplete = provider.goalChains[a].isComplete;
      final bComplete = provider.goalChains[b].isComplete;
      if (aComplete == bComplete) return 0;
      return aComplete ? 1 : -1;
    });

    return sortedIndices.map((originalIndex) {
      final chain = provider.goalChains[originalIndex];
      final isSelected = selected?.type == SelectedType.chain && selected?.index == originalIndex;
      return ListTile(
        leading: chain.isComplete
            ? const Icon(Icons.check_circle, color: AppColors.mintDark, size: 20)
            : const Icon(Icons.linear_scale, size: 20),
        title: Text(
          chain.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.mintDark : null,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.mintLight,
        onTap: () {
          onSelect(SelectedItem(SelectedType.chain, originalIndex));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> _buildJarItems(BuildContext context, HabitTrackerProvider provider) {
    final sortedIndices = List<int>.generate(provider.moneyJars.length, (i) => i);
    sortedIndices.sort((a, b) {
      final aComplete = provider.moneyJars[a].isComplete;
      final bComplete = provider.moneyJars[b].isComplete;
      if (aComplete == bComplete) return 0;
      return aComplete ? 1 : -1;
    });

    return sortedIndices.map((originalIndex) {
      final jar = provider.moneyJars[originalIndex];
      final isSelected = selected?.type == SelectedType.jar && selected?.index == originalIndex;
      return ListTile(
        leading: jar.isComplete
            ? const Icon(Icons.check_circle, color: AppColors.mintDark, size: 20)
            : const Icon(Icons.savings, size: 20),
        title: Text(
          jar.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.mintDark : null,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.mintLight,
        onTap: () {
          onSelect(SelectedItem(SelectedType.jar, originalIndex));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> _buildJournalItems(BuildContext context, HabitTrackerProvider provider, {required bool isGoodHabit}) {
    final filtered = <MapEntry<int, HabitJournal>>[];
    for (int i = 0; i < provider.journals.length; i++) {
      if (provider.journals[i].isGoodHabit == isGoodHabit) {
        filtered.add(MapEntry(i, provider.journals[i]));
      }
    }
    return filtered.map((entry) {
      final index = entry.key;
      final journal = entry.value;
      final isSelected = selected?.type == SelectedType.journal && selected?.index == index;
      final accentColor = isGoodHabit ? AppColors.mintDark : AppColors.coralDark;
      final bgColor = isGoodHabit ? AppColors.mintLight : AppColors.coralLight;
      return ListTile(
        leading: Icon(
          isGoodHabit ? Icons.check_circle_outline : Icons.warning_amber,
          size: 20,
          color: accentColor,
        ),
        title: Text(
          journal.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? accentColor : null,
          ),
        ),
        selected: isSelected,
        selectedTileColor: bgColor,
        onTap: () {
          onSelect(SelectedItem(SelectedType.journal, index));
          Navigator.pop(context);
        },
      );
    }).toList();
  }
}

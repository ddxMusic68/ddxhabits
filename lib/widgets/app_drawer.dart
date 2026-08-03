import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_item.dart';
import '../models/habit_journal.dart';
import '../providers/habit_tracker_provider.dart';
import '../utils/constants.dart';

class AppDrawer extends StatelessWidget {
  final SelectedItem? selected;
  final ValueChanged<SelectedItem> onSelect;
  final ValueChanged<SelectedItem>? onDelete;

  const AppDrawer({
    super.key,
    required this.selected,
    required this.onSelect,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitTrackerProvider>(
      builder: (context, provider, child) {
        return Drawer(
          child: SafeArea(
            child: ListView(
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
                if (provider.contracts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      'HABIT CONTRACTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ..._buildContractItems(context, provider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGridItems(
    BuildContext context,
    HabitTrackerProvider provider,
  ) {
    final sortedIndices = List<int>.generate(provider.grids.length, (i) => i);
    sortedIndices.sort((a, b) {
      final aComplete = provider.grids[a].isComplete;
      final bComplete = provider.grids[b].isComplete;
      if (aComplete == bComplete) return 0;
      return aComplete ? 1 : -1;
    });

    return sortedIndices.map((originalIndex) {
      final grid = provider.grids[originalIndex];
      final isSelected =
          selected?.type == SelectedType.grid &&
          selected?.index == originalIndex;
      return ListTile(
        leading: grid.isComplete
            ? const Icon(
                Icons.check_circle,
                color: AppColors.mintDark,
                size: 20,
              )
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
        trailing: _deleteButton(context, provider, SelectedType.grid, originalIndex),
        onTap: () {
          onSelect(SelectedItem(SelectedType.grid, originalIndex));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> _buildChainItems(
    BuildContext context,
    HabitTrackerProvider provider,
  ) {
    final sortedIndices = List<int>.generate(
      provider.goalChains.length,
      (i) => i,
    );
    sortedIndices.sort((a, b) {
      final aComplete = provider.goalChains[a].isComplete;
      final bComplete = provider.goalChains[b].isComplete;
      if (aComplete == bComplete) return 0;
      return aComplete ? 1 : -1;
    });

    return sortedIndices.map((originalIndex) {
      final chain = provider.goalChains[originalIndex];
      final isSelected =
          selected?.type == SelectedType.chain &&
          selected?.index == originalIndex;
      return ListTile(
        leading: chain.isComplete
            ? const Icon(
                Icons.check_circle,
                color: AppColors.mintDark,
                size: 20,
              )
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
        trailing: _deleteButton(context, provider, SelectedType.chain, originalIndex),
        onTap: () {
          onSelect(SelectedItem(SelectedType.chain, originalIndex));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> _buildJarItems(
    BuildContext context,
    HabitTrackerProvider provider,
  ) {
    final sortedIndices = List<int>.generate(
      provider.moneyJars.length,
      (i) => i,
    );
    sortedIndices.sort((a, b) {
      final aComplete = provider.moneyJars[a].isComplete;
      final bComplete = provider.moneyJars[b].isComplete;
      if (aComplete == bComplete) return 0;
      return aComplete ? 1 : -1;
    });

    return sortedIndices.map((originalIndex) {
      final jar = provider.moneyJars[originalIndex];
      final isSelected =
          selected?.type == SelectedType.jar &&
          selected?.index == originalIndex;
      return ListTile(
        leading: jar.isComplete
            ? const Icon(
                Icons.check_circle,
                color: AppColors.mintDark,
                size: 20,
              )
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
        trailing: _deleteButton(context, provider, SelectedType.jar, originalIndex),
        onTap: () {
          onSelect(SelectedItem(SelectedType.jar, originalIndex));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> _buildContractItems(
    BuildContext context,
    HabitTrackerProvider provider,
  ) {
    return List.generate(provider.contracts.length, (index) {
      final contract = provider.contracts[index];
      final isSelected =
          selected?.type == SelectedType.contract && selected?.index == index;
      return ListTile(
        leading: const Icon(Icons.description, size: 20),
        title: Text(
          contract.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.mintDark : null,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.mintLight,
        trailing: _deleteButton(context, provider, SelectedType.contract, index),
        onTap: () {
          onSelect(SelectedItem(SelectedType.contract, index));
          Navigator.pop(context);
        },
      );
    });
  }

  List<Widget> _buildJournalItems(
    BuildContext context,
    HabitTrackerProvider provider, {
    required bool isGoodHabit,
  }) {
    final filtered = <MapEntry<int, HabitJournal>>[];
    for (int i = 0; i < provider.journals.length; i++) {
      if (provider.journals[i].isGoodHabit == isGoodHabit) {
        filtered.add(MapEntry(i, provider.journals[i]));
      }
    }
    return filtered.map((entry) {
      final index = entry.key;
      final journal = entry.value;
      final isSelected =
          selected?.type == SelectedType.journal && selected?.index == index;
      final accentColor = isGoodHabit
          ? AppColors.mintDark
          : AppColors.coralDark;
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
        trailing: _deleteButton(context, provider, SelectedType.journal, index),
        onTap: () {
          onSelect(SelectedItem(SelectedType.journal, index));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  Widget _deleteButton(
    BuildContext context,
    HabitTrackerProvider provider,
    SelectedType type,
    int index,
  ) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, size: 20),
      tooltip: 'Delete',
      onPressed: () => _confirmDelete(context, provider, type, index),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HabitTrackerProvider provider,
    SelectedType type,
    int index,
  ) async {
    final label = _labelFor(provider, type, index);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Delete "$label"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    switch (type) {
      case SelectedType.grid:
        await provider.removeGrid(index);
        break;
      case SelectedType.chain:
        await provider.removeGoalChain(index);
        break;
      case SelectedType.jar:
        await provider.removeMoneyJar(index);
        break;
      case SelectedType.journal:
        await provider.removeJournal(index);
        break;
      case SelectedType.contract:
        await provider.removeContract(index);
        break;
    }
    onDelete?.call(SelectedItem(type, index));
  }

  String _labelFor(
    HabitTrackerProvider provider,
    SelectedType type,
    int index,
  ) {
    switch (type) {
      case SelectedType.grid:
        return provider.grids[index].name;
      case SelectedType.chain:
        return provider.goalChains[index].name;
      case SelectedType.jar:
        return provider.moneyJars[index].name;
      case SelectedType.journal:
        return provider.journals[index].name;
      case SelectedType.contract:
        return provider.contracts[index].name;
    }
  }
}

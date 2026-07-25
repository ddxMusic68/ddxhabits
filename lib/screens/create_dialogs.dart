import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_item.dart';
import '../models/habit_grid.dart';
import '../models/goal_chain.dart';
import '../models/goal.dart';
import '../models/money_jar.dart';
import '../providers/habit_tracker_provider.dart';
import '../utils/constants.dart';

void showCreateChoiceDialog(BuildContext context, ValueChanged<SelectedItem> onCreated) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Create New',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view, color: AppColors.mintDark),
            title: const Text('Habit Grid'),
            subtitle: const Text('Track progress with a visual grid'),
            onTap: () {
              Navigator.pop(context);
              showAddGridDialog(context, onCreated);
            },
          ),
          ListTile(
            leading: const Icon(Icons.linear_scale, color: AppColors.mintDark),
            title: const Text('Goal Chain'),
            subtitle: const Text('Achieve goals step by step'),
            onTap: () {
              Navigator.pop(context);
              showAddChainDialog(context, onCreated);
            },
          ),
          ListTile(
            leading: const Icon(Icons.savings, color: AppColors.mintDark),
            title: const Text('Money Jar'),
            subtitle: const Text('Save toward a goal visually'),
            onTap: () {
              Navigator.pop(context);
              showAddJarDialog(context, onCreated);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline, color: AppColors.mintDark),
            title: const Text('Good Habit Journal'),
            subtitle: const Text('Track positive daily habits'),
            onTap: () {
              Navigator.pop(context);
              showAddJournalDialog(context, onCreated, isGoodHabit: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber, color: AppColors.coralDark),
            title: const Text('Bad Habit Journal'),
            subtitle: const Text('Track habits you want to break'),
            onTap: () {
              Navigator.pop(context);
              showAddJournalDialog(context, onCreated, isGoodHabit: false);
            },
          ),
        ],
      ),
    ),
  );
}

void showAddGridDialog(BuildContext context, ValueChanged<SelectedItem> onCreated) {
  final nameController = TextEditingController();
  final countController = TextEditingController(text: '10');
  final costController = TextEditingController(text: '1.00');
  final incrementController = TextEditingController(text: '1.00');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New Habit Grid'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: countController,
            decoration: const InputDecoration(labelText: 'Total Squares'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: costController,
            decoration: const InputDecoration(labelText: 'Square Cost'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: incrementController,
            decoration: const InputDecoration(labelText: 'Increment Amount'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text;
            final count = int.tryParse(countController.text) ?? 10;
            final cost = double.tryParse(costController.text) ?? 1.0;
            final increment = double.tryParse(incrementController.text) ?? 1.0;

            if (name.isNotEmpty) {
              final provider = context.read<HabitTrackerProvider>();
              final grid = HabitGrid(
                name: name,
                totalCount: count.toDouble(),
                squareCost: cost,
                countIncrement: increment,
              );
              provider.addGrid(grid);
              onCreated(SelectedItem(SelectedType.grid, provider.grids.length - 1));
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

void showAddChainDialog(BuildContext context, ValueChanged<SelectedItem> onCreated) {
  final nameController = TextEditingController();
  final goalControllers = <TextEditingController>[];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('New Goal Chain'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Chain Name'),
              ),
              const SizedBox(height: 16),
              if (goalControllers.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Goals', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ...List.generate(goalControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${goalControllers[index].text}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              goalControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 8),
              _AddGoalField(
                onAdd: (title) {
                  setDialogState(() {
                    goalControllers.add(TextEditingController(text: title));
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text;
              if (name.isEmpty || goalControllers.isEmpty) return;

              final provider = context.read<HabitTrackerProvider>();
              final chain = GoalChain(
                name: name,
                goalList: goalControllers.map((c) => Goal(title: c.text)).toList(),
              );
              provider.addGoalChain(chain);
              onCreated(SelectedItem(SelectedType.chain, provider.goalChains.length - 1));
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}

void showAddJarDialog(BuildContext context, ValueChanged<SelectedItem> onCreated) {
  final nameController = TextEditingController();
  final incrementController = TextEditingController(text: '1.00');
  final goalController = TextEditingController(text: '10.00');
  bool useLiquid = true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('New Money Jar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Jar Name'),
              ),
              TextField(
                controller: incrementController,
                decoration: const InputDecoration(labelText: 'Increment Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: goalController,
                decoration: const InputDecoration(labelText: 'Goal Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Liquid fill'),
                subtitle: const Text('Toggle between liquid wave or stacked coins'),
                value: useLiquid,
                onChanged: (val) => setDialogState(() => useLiquid = val),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.mintDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text;
              final increment = double.tryParse(incrementController.text) ?? 1.0;
              final goal = double.tryParse(goalController.text) ?? 10.0;

              if (name.isNotEmpty) {
                final provider = context.read<HabitTrackerProvider>();
                final jar = MoneyJar(
                  name: name,
                  increment: increment,
                  goalAmount: goal,
                  useLiquidFill: useLiquid,
                );
                provider.addMoneyJar(jar);
                onCreated(SelectedItem(SelectedType.jar, provider.moneyJars.length - 1));
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}

void showAddJournalDialog(BuildContext context, ValueChanged<SelectedItem> onCreated, {required bool isGoodHabit}) {
  final nameController = TextEditingController();
  final label = isGoodHabit ? 'Good Habit' : 'Bad Habit';
  final accentColor = isGoodHabit ? AppColors.mintDark : AppColors.coralDark;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('New $label Journal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: '$label Name'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text;

            if (name.isNotEmpty) {
              final provider = context.read<HabitTrackerProvider>();
              provider.addJournal(name, isGoodHabit: isGoodHabit);
              onCreated(SelectedItem(SelectedType.journal, provider.journals.length - 1));
              Navigator.pop(context);
            }
          },
          child: Text('Create', style: TextStyle(color: accentColor)),
        ),
      ],
    ),
  );
}

class _AddGoalField extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _AddGoalField({required this.onAdd});

  @override
  State<_AddGoalField> createState() => _AddGoalFieldState();
}

class _AddGoalFieldState extends State<_AddGoalField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Add a goal',
              isDense: true,
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                widget.onAdd(value.trim());
                _controller.clear();
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.mintDark),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onAdd(_controller.text.trim());
              _controller.clear();
            }
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_item.dart';
import '../models/habit_grid.dart';
import '../models/goal_chain.dart';
import '../models/goal.dart';
import '../models/money_jar.dart';
import '../models/habit_contract.dart';
import '../models/habit_journal.dart';
import '../models/timed_habit.dart';
import '../providers/habit_tracker_provider.dart';
import '../utils/constants.dart';

void showCreateChoiceDialog(
  BuildContext context,
  ValueChanged<SelectedItem> onCreated,
) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
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
              leading: const Icon(
                Icons.linear_scale,
                color: AppColors.mintDark,
              ),
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
              leading: const Icon(
                Icons.check_circle_outline,
                color: AppColors.mintDark,
              ),
              title: const Text('Good Habit Journal'),
              subtitle: const Text('Track positive daily habits'),
              onTap: () {
                Navigator.pop(context);
                showAddJournalDialog(context, onCreated, isGoodHabit: true);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.warning_amber,
                color: AppColors.coralDark,
              ),
              title: const Text('Bad Habit Journal'),
              subtitle: const Text('Track habits you want to break'),
              onTap: () {
                Navigator.pop(context);
                showAddJournalDialog(context, onCreated, isGoodHabit: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.mintDark),
              title: const Text('Habit Contract'),
              subtitle: const Text(
                'Commit to a habit with a time, place, and consequence',
              ),
              onTap: () {
                Navigator.pop(context);
                showAddContractDialog(context, onCreated);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined, color: AppColors.mintDark),
              title: const Text('Timed Habit'),
              subtitle: const Text('Time yourself and beat your best'),
              onTap: () {
                Navigator.pop(context);
                showAddTimedHabitDialog(context, onCreated);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void showAddGridDialog(
  BuildContext context,
  ValueChanged<SelectedItem>? onCreated, {
  HabitGrid? initial,
  int initialIndex = -1,
}) {
  final isEdit = initial != null;
  final nameController = TextEditingController(text: initial?.name ?? '');
  final countController = TextEditingController(
    text: initial != null ? initial.totalCount.toInt().toString() : '10',
  );
  final costController = TextEditingController(
    text: initial != null ? initial.squareCost.toStringAsFixed(2) : '1.00',
  );
  final incrementController = TextEditingController(
    text: initial != null ? initial.countIncrement.toStringAsFixed(2) : '1.00',
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isEdit ? 'Edit Habit Grid' : 'New Habit Grid'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
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
                decoration: const InputDecoration(
                  labelText: 'Increment Amount',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
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
            final count = int.tryParse(countController.text) ?? 10;
            final cost = double.tryParse(costController.text) ?? 1.0;
            final increment = double.tryParse(incrementController.text) ?? 1.0;

            if (name.isNotEmpty) {
              final provider = context.read<HabitTrackerProvider>();
              if (isEdit) {
                provider.updateGrid(
                  initialIndex,
                  name: name,
                  totalCount: count.toDouble(),
                  squareCost: cost,
                  countIncrement: increment,
                );
              } else {
                final grid = HabitGrid(
                  name: name,
                  totalCount: count.toDouble(),
                  squareCost: cost,
                  countIncrement: increment,
                );
                provider.addGrid(grid);
                onCreated?.call(
                  SelectedItem(SelectedType.grid, provider.grids.length - 1),
                );
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    ),
  );
}

void showAddChainDialog(
  BuildContext context,
  ValueChanged<SelectedItem>? onCreated, {
  GoalChain? initial,
  int initialIndex = -1,
}) {
  final isEdit = initial != null;
  final nameController = TextEditingController(text: initial?.name ?? '');
  final goalControllers = <TextEditingController>[
    if (initial != null)
      ...initial.goalList.map((g) => TextEditingController(text: g.title)),
  ];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(isEdit ? 'Edit Goal Chain' : 'New Goal Chain'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
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
                    child: Text(
                      'Goals',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(goalControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: goalControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Goal ${index + 1}',
                                isDense: true,
                              ),
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
              final goalList = goalControllers
                  .map((c) => Goal(title: c.text.trim()))
                  .where((g) => g.title.isNotEmpty)
                  .toList();
              if (goalList.isEmpty) return;

              if (isEdit) {
                provider.updateGoalChain(initialIndex,
                    name: name, goalList: goalList);
              } else {
                final chain = GoalChain(name: name, goalList: goalList);
                provider.addGoalChain(chain);
                onCreated?.call(
                  SelectedItem(
                    SelectedType.chain,
                    provider.goalChains.length - 1,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    ),
  );
}

void showAddJarDialog(
  BuildContext context,
  ValueChanged<SelectedItem>? onCreated, {
  MoneyJar? initial,
  int initialIndex = -1,
}) {
  final isEdit = initial != null;
  final nameController = TextEditingController(text: initial?.name ?? '');
  final incrementController = TextEditingController(
    text: initial != null
        ? initial.increment.toStringAsFixed(2)
        : '1.00',
  );
  final goalController = TextEditingController(
    text: initial != null
        ? initial.goalAmount.toStringAsFixed(2)
        : '10.00',
  );
  bool useLiquid = initial?.useLiquidFill ?? true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(isEdit ? 'Edit Money Jar' : 'New Money Jar'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Jar Name'),
                ),
                TextField(
                  controller: incrementController,
                  decoration: const InputDecoration(
                    labelText: 'Increment Amount',
                  ),
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
                  subtitle: const Text(
                    'Toggle between liquid wave or stacked coins',
                  ),
                  value: useLiquid,
                  onChanged: (val) => setDialogState(() => useLiquid = val),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.mintDark,
                ),
              ],
            ),
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
              final increment =
                  double.tryParse(incrementController.text) ?? 1.0;
              final goal = double.tryParse(goalController.text) ?? 10.0;

              if (name.isNotEmpty) {
                final provider = context.read<HabitTrackerProvider>();
                if (isEdit) {
                  provider.updateMoneyJar(
                    initialIndex,
                    name: name,
                    increment: increment,
                    goalAmount: goal,
                    useLiquidFill: useLiquid,
                  );
                } else {
                  final jar = MoneyJar(
                    name: name,
                    increment: increment,
                    goalAmount: goal,
                    useLiquidFill: useLiquid,
                  );
                  provider.addMoneyJar(jar);
                  onCreated?.call(
                    SelectedItem(SelectedType.jar, provider.moneyJars.length - 1),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    ),
  );
}

void showAddContractDialog(
  BuildContext context,
  ValueChanged<SelectedItem>? onCreated, {
  HabitContract? initial,
  int initialIndex = -1,
}) {
  final isEdit = initial != null;
  final nameController = TextEditingController(text: initial?.name ?? '');
  final timeController = TextEditingController(text: initial?.time ?? '');
  final placeController = TextEditingController(text: initial?.place ?? '');
  final consequenceController = TextEditingController(
    text: initial?.consequence ?? '',
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isEdit ? 'Edit Habit Contract' : 'New Habit Contract'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Habit'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'e.g. 6:00 AM',
                ),
              ),
              TextField(
                controller: placeController,
                decoration: const InputDecoration(
                  labelText: 'Place',
                  hintText: 'e.g. Gym',
                ),
              ),
              TextField(
                controller: consequenceController,
                decoration: const InputDecoration(
                  labelText: 'Consequence',
                  hintText: 'e.g. Donate \$10',
                ),
              ),
            ],
          ),
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
            if (name.isNotEmpty) {
              final provider = context.read<HabitTrackerProvider>();
              if (isEdit) {
                provider.updateContract(
                  initialIndex,
                  name: name,
                  time: timeController.text.trim(),
                  place: placeController.text.trim(),
                  consequence: consequenceController.text.trim(),
                );
              } else {
                final contract = HabitContract(
                  name: name,
                  time: timeController.text.trim(),
                  place: placeController.text.trim(),
                  consequence: consequenceController.text.trim(),
                );
                provider.addContract(contract);
                onCreated?.call(
                  SelectedItem(
                    SelectedType.contract,
                    provider.contracts.length - 1,
                  ),
                );
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    ),
  );
}

void showAddJournalDialog(
  BuildContext context,
  ValueChanged<SelectedItem>? onCreated, {
  required bool isGoodHabit,
  HabitJournal? initial,
  int initialIndex = -1,
}) {
  final isEdit = initial != null;
  final nameController = TextEditingController(text: initial?.name ?? '');
  final label = isGoodHabit ? 'Good Habit' : 'Bad Habit';
  final accentColor = isGoodHabit ? AppColors.mintDark : AppColors.coralDark;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isEdit ? 'Edit $label Journal' : 'New $label Journal'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '$label Name'),
              ),
            ],
          ),
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

            if (name.isNotEmpty) {
              final provider = context.read<HabitTrackerProvider>();
              if (isEdit) {
                provider.updateJournal(initialIndex, name);
              } else {
                provider.addJournal(name, isGoodHabit: isGoodHabit);
                onCreated?.call(
                  SelectedItem(
                    SelectedType.journal,
                    provider.journals.length - 1,
                  ),
                );
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEdit ? 'Save' : 'Create',
              style: TextStyle(color: accentColor)),
        ),
      ],
    ),
  );
}

void showAddTimedHabitDialog(
  BuildContext context,
  ValueChanged<SelectedItem>? onCreated, {
  TimedHabit? initial,
  int initialIndex = -1,
}) {
  final isEdit = initial != null;
  final nameController = TextEditingController(text: initial?.name ?? '');
  bool fasterIsBetter = initial?.fasterIsBetter ?? true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(isEdit ? 'Edit Timed Habit' : 'New Timed Habit'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Habit'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Improvement means:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RadioGroup<bool>(
                  groupValue: fasterIsBetter,
                  onChanged: (val) =>
                      setDialogState(() => fasterIsBetter = val ?? true),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<bool>(
                        title: Text('Getting quicker'),
                        subtitle: Text(
                          'e.g. running a distance — a shorter time is better',
                        ),
                        value: true,
                        activeColor: AppColors.mintDark,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<bool>(
                        title: Text('Going longer'),
                        subtitle: Text(
                          'e.g. a core exercise — a longer time is better',
                        ),
                        value: false,
                        activeColor: AppColors.mintDark,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
              if (name.isNotEmpty) {
                final provider = context.read<HabitTrackerProvider>();
                if (isEdit) {
                  provider.updateTimedHabit(
                    initialIndex,
                    name: name,
                    fasterIsBetter: fasterIsBetter,
                  );
                } else {
                  final habit = TimedHabit(
                    name: name,
                    fasterIsBetter: fasterIsBetter,
                  );
                  provider.addTimedHabit(habit);
                  onCreated?.call(
                    SelectedItem(
                      SelectedType.timed,
                      provider.timedHabits.length - 1,
                    ),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
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

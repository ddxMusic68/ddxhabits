import 'package:flutter/foundation.dart';
import '../models/habit_grid.dart';
import '../models/goal_chain.dart';
import '../models/money_jar.dart';
import '../models/habit_journal.dart';
import '../models/habit_contract.dart';
import '../models/timed_habit.dart';
import '../models/goal.dart';
import '../models/journal_entry.dart';
import '../models/journal_sub_entry.dart';
import '../services/database_service.dart';

class HabitTrackerProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<HabitGrid> _grids = [];
  List<GoalChain> _goalChains = [];
  List<MoneyJar> _moneyJars = [];
  List<HabitJournal> _journals = [];
  List<HabitContract> _contracts = [];
  List<TimedHabit> _timedHabits = [];

  List<HabitGrid> get grids => _grids;
  List<GoalChain> get goalChains => _goalChains;
  List<MoneyJar> get moneyJars => _moneyJars;
  List<HabitJournal> get journals => _journals;
  List<HabitContract> get contracts => _contracts;
  List<TimedHabit> get timedHabits => _timedHabits;

  Future<void> loadAll() async {
    _grids = await _databaseService.loadHabitGrids();
    _goalChains = await _databaseService.loadGoalChains();
    _moneyJars = await _databaseService.loadMoneyJars();
    _journals = await _databaseService.loadJournals();
    _contracts = await _databaseService.loadContracts();
    _timedHabits = await _databaseService.loadTimedHabits();
    notifyListeners();
  }

  // --- Habit Grid CRUD ---

  Future<void> addGrid(HabitGrid grid) async {
    _grids.add(grid);
    await _databaseService.saveHabitGrids(_grids);
    notifyListeners();
  }

  Future<void> incrementGrid(int gridIndex) async {
    if (gridIndex >= 0 && gridIndex < _grids.length) {
      _grids[gridIndex].incrementCredit();
      await _databaseService.saveHabitGrids(_grids);
      notifyListeners();
    }
  }

  Future<void> fillSquare(int gridIndex, int squareIndex) async {
    if (gridIndex >= 0 && gridIndex < _grids.length) {
      _grids[gridIndex].fillSquare(squareIndex);
      await _databaseService.saveHabitGrids(_grids);
      notifyListeners();
    }
  }

  Future<void> removeGrid(int index) async {
    if (index >= 0 && index < _grids.length) {
      final removed = _grids[index].name;
      _grids.removeAt(index);
      await _databaseService.saveHabitGrids(_grids);
      await _databaseService.recordDeletion(DatabaseService.gridsFileName, removed);
      notifyListeners();
    }
  }

  Future<void> resetGrid(int index) async {
    if (index >= 0 && index < _grids.length) {
      _grids[index].reset();
      await _databaseService.saveHabitGrids(_grids);
      notifyListeners();
    }
  }

  Future<void> updateGrid(
    int index, {
    required String name,
    required double totalCount,
    required double countIncrement,
    required double squareCost,
  }) async {
    if (index < 0 || index >= _grids.length) return;
    final grid = _grids[index];
    final oldName = grid.name;

    final newCount = totalCount.toInt().clamp(1, 10000);
    if (grid.boolList.length != newCount) {
      final newList = List<bool>.filled(newCount, false);
      final copyLen = newCount < grid.boolList.length
          ? newCount
          : grid.boolList.length;
      for (int i = 0; i < copyLen; i++) {
        newList[i] = grid.boolList[i];
      }
      grid.boolList = newList;
    }
    grid.name = name;
    grid.totalCount = totalCount;
    grid.countIncrement = countIncrement;
    grid.squareCost = squareCost;
    grid.updatedAt = DateTime.now();
    if (grid.filledCount >= grid.totalCount) {
      grid.markComplete();
    } else {
      grid.isComplete = false;
    }

    await _databaseService.saveHabitGrids(_grids);
    if (oldName != name) {
      await _databaseService.recordDeletion(DatabaseService.gridsFileName, oldName);
    }
    notifyListeners();
  }

  // --- Goal Chain CRUD ---

  Future<void> addGoalChain(GoalChain chain) async {
    _goalChains.add(chain);
    await _databaseService.saveGoalChains(_goalChains);
    notifyListeners();
  }

  Future<void> completeGoalInChain(int chainIndex) async {
    if (chainIndex >= 0 && chainIndex < _goalChains.length) {
      _goalChains[chainIndex].completeCurrentGoal();
      await _databaseService.saveGoalChains(_goalChains);
      notifyListeners();
    }
  }

  Future<void> removeGoalChain(int index) async {
    if (index >= 0 && index < _goalChains.length) {
      final removed = _goalChains[index].name;
      _goalChains.removeAt(index);
      await _databaseService.saveGoalChains(_goalChains);
      await _databaseService.recordDeletion(DatabaseService.chainsFileName, removed);
      notifyListeners();
    }
  }

  Future<void> resetGoalChain(int index) async {
    if (index >= 0 && index < _goalChains.length) {
      _goalChains[index].reset();
      await _databaseService.saveGoalChains(_goalChains);
      notifyListeners();
    }
  }

  Future<void> updateGoalChain(
    int index, {
    required String name,
    required List<Goal> goalList,
  }) async {
    if (index < 0 || index >= _goalChains.length) return;
    final chain = _goalChains[index];
    final oldName = chain.name;

    final oldByTitle = <String, bool>{};
    for (final goal in chain.goalList) {
      oldByTitle[goal.title] = oldByTitle[goal.title] == true || goal.isComplete;
    }
    for (final goal in goalList) {
      if (oldByTitle[goal.title] == true) {
        goal.isComplete = true;
      }
    }

    chain.name = name;
    chain.goalList = goalList;
    chain.updatedAt = DateTime.now();
    if (goalList.isNotEmpty && goalList.every((g) => g.isComplete)) {
      chain.markComplete();
    } else {
      chain.isComplete = false;
    }

    await _databaseService.saveGoalChains(_goalChains);
    if (oldName != name) {
      await _databaseService.recordDeletion(DatabaseService.chainsFileName, oldName);
    }
    notifyListeners();
  }

  // --- Money Jar CRUD ---

  Future<void> addMoneyJar(MoneyJar jar) async {
    _moneyJars.add(jar);
    await _databaseService.saveMoneyJars(_moneyJars);
    notifyListeners();
  }

  Future<void> addToJar(int jarIndex) async {
    if (jarIndex >= 0 && jarIndex < _moneyJars.length) {
      _moneyJars[jarIndex].addToJar();
      await _databaseService.saveMoneyJars(_moneyJars);
      notifyListeners();
    }
  }

  Future<void> removeFromJar(int jarIndex) async {
    if (jarIndex >= 0 && jarIndex < _moneyJars.length) {
      _moneyJars[jarIndex].removeFromJar();
      await _databaseService.saveMoneyJars(_moneyJars);
      notifyListeners();
    }
  }

  Future<void> removeMoneyJar(int index) async {
    if (index >= 0 && index < _moneyJars.length) {
      final removed = _moneyJars[index].name;
      _moneyJars.removeAt(index);
      await _databaseService.saveMoneyJars(_moneyJars);
      await _databaseService.recordDeletion(DatabaseService.jarsFileName, removed);
      notifyListeners();
    }
  }

  Future<void> resetMoneyJar(int index) async {
    if (index >= 0 && index < _moneyJars.length) {
      _moneyJars[index].reset();
      await _databaseService.saveMoneyJars(_moneyJars);
      notifyListeners();
    }
  }

  Future<void> updateMoneyJar(
    int index, {
    required String name,
    required double increment,
    required double goalAmount,
    required bool useLiquidFill,
  }) async {
    if (index < 0 || index >= _moneyJars.length) return;
    final jar = _moneyJars[index];
    final oldName = jar.name;

    jar.name = name;
    jar.increment = increment;
    jar.goalAmount = goalAmount;
    jar.useLiquidFill = useLiquidFill;
    if (jar.curAmount > goalAmount) {
      jar.curAmount = goalAmount;
    }
    jar.updatedAt = DateTime.now();
    jar.isComplete = jar.curAmount >= goalAmount;

    await _databaseService.saveMoneyJars(_moneyJars);
    if (oldName != name) {
      await _databaseService.recordDeletion(DatabaseService.jarsFileName, oldName);
    }
    notifyListeners();
  }

  // --- Journal CRUD ---

  Future<void> addJournal(String name, {bool isGoodHabit = true}) async {
    final journal = HabitJournal(name: name, isGoodHabit: isGoodHabit);
    _journals.add(journal);
    await _databaseService.saveJournals(_journals);
    notifyListeners();
  }

  Future<void> saveJournalEntry(int journalIndex, JournalEntry entry) async {
    if (journalIndex >= 0 && journalIndex < _journals.length) {
      await _databaseService.saveJournals(_journals);
      notifyListeners();
    }
  }

  Future<void> removeJournalEntry(int journalIndex, int entryIndex) async {
    if (journalIndex >= 0 && journalIndex < _journals.length) {
      _journals[journalIndex].removeEntry(entryIndex);
      await _databaseService.saveJournals(_journals);
      notifyListeners();
    }
  }

  Future<void> removeJournal(int index) async {
    if (index >= 0 && index < _journals.length) {
      final removed = _journals[index].name;
      _journals.removeAt(index);
      await _databaseService.saveJournals(_journals);
      await _databaseService.recordDeletion(DatabaseService.journalsFileName, removed);
      notifyListeners();
    }
  }

  Future<void> updateJournal(int index, String name) async {
    if (index < 0 || index >= _journals.length) return;
    final journal = _journals[index];
    final oldName = journal.name;

    journal.name = name;
    journal.updatedAt = DateTime.now();

    await _databaseService.saveJournals(_journals);
    if (oldName != name) {
      await _databaseService.recordDeletion(DatabaseService.journalsFileName, oldName);
    }
    notifyListeners();
  }

  JournalEntry? getJournalEntryForDate(int journalIndex, DateTime date) {
    if (journalIndex < 0 || journalIndex >= _journals.length) return null;
    return _journals[journalIndex].getEntryForDate(date);
  }

  JournalEntry getOrCreateJournalEntryForDate(int journalIndex, DateTime date) {
    if (journalIndex < 0 || journalIndex >= _journals.length) {
      return JournalEntry(date: date);
    }
    return _journals[journalIndex].getOrCreateEntryForDate(date);
  }

  Future<void> addSubEntry(int journalIndex, JournalEntry entry) async {
    entry.entries.add(JournalSubEntry(timestamp: DateTime.now()));
    await _databaseService.saveJournals(_journals);
    notifyListeners();
  }

  Future<void> removeSubEntry(int journalIndex, JournalEntry entry, int subIndex) async {
    if (subIndex >= 0 && subIndex < entry.entries.length) {
      entry.entries.removeAt(subIndex);
      await _databaseService.saveJournals(_journals);
      notifyListeners();
    }
  }

  Future<void> saveSubEntryText(int journalIndex, JournalEntry entry, int subIndex, String text) async {
    if (subIndex >= 0 && subIndex < entry.entries.length) {
      entry.entries[subIndex].text = text;
      await _databaseService.saveJournals(_journals);
      notifyListeners();
    }
  }

  Future<void> removeEmptyJournalEntry(int journalIndex, JournalEntry entry) async {
    if (journalIndex < 0 || journalIndex >= _journals.length) return;
    if (entry.entries.isEmpty) {
      final journal = _journals[journalIndex];
      final idx = journal.journalEntryList.indexOf(entry);
      if (idx >= 0) {
        journal.removeEntry(idx);
        await _databaseService.saveJournals(_journals);
        notifyListeners();
      }
    }
  }

  // --- Habit Contract CRUD ---

  Future<void> addContract(HabitContract contract) async {
    _contracts.add(contract);
    await _databaseService.saveContracts(_contracts);
    notifyListeners();
  }

  Future<void> removeContract(int index) async {
    if (index >= 0 && index < _contracts.length) {
      final removed = _contracts[index].name;
      _contracts.removeAt(index);
      await _databaseService.saveContracts(_contracts);
      await _databaseService.recordDeletion(DatabaseService.contractsFileName, removed);
      notifyListeners();
    }
  }

  Future<void> updateContract(
    int index, {
    required String name,
    required String time,
    required String place,
    required String consequence,
  }) async {
    if (index < 0 || index >= _contracts.length) return;
    final contract = _contracts[index];
    final oldName = contract.name;

    contract.name = name;
    contract.time = time;
    contract.place = place;
    contract.consequence = consequence;
    contract.updatedAt = DateTime.now();

    await _databaseService.saveContracts(_contracts);
    if (oldName != name) {
      await _databaseService.recordDeletion(DatabaseService.contractsFileName, oldName);
    }
    notifyListeners();
  }

  // --- Timed Habit CRUD ---

  Future<void> addTimedHabit(TimedHabit habit) async {
    _timedHabits.add(habit);
    await _databaseService.saveTimedHabits(_timedHabits);
    notifyListeners();
  }

  Future<void> removeTimedHabit(int index) async {
    if (index >= 0 && index < _timedHabits.length) {
      final removed = _timedHabits[index].name;
      _timedHabits.removeAt(index);
      await _databaseService.saveTimedHabits(_timedHabits);
      await _databaseService.recordDeletion(DatabaseService.timedHabitsFileName, removed);
      notifyListeners();
    }
  }

  Future<void> updateTimedHabit(
    int index, {
    required String name,
    required bool fasterIsBetter,
  }) async {
    if (index < 0 || index >= _timedHabits.length) return;
    final habit = _timedHabits[index];
    final oldName = habit.name;

    habit.name = name;
    habit.fasterIsBetter = fasterIsBetter;
    habit.updatedAt = DateTime.now();

    await _databaseService.saveTimedHabits(_timedHabits);
    if (oldName != name) {
      await _databaseService.recordDeletion(DatabaseService.timedHabitsFileName, oldName);
    }
    notifyListeners();
  }

  Future<void> addTimedSession(int index, int seconds) async {
    if (index < 0 || index >= _timedHabits.length) return;
    _timedHabits[index].addSession(seconds);
    await _databaseService.saveTimedHabits(_timedHabits);
    notifyListeners();
  }

  Future<void> removeTimedSession(int index, int sessionIndex) async {
    if (index < 0 || index >= _timedHabits.length) return;
    _timedHabits[index].removeSession(sessionIndex);
    await _databaseService.saveTimedHabits(_timedHabits);
    notifyListeners();
  }

  Future<void> resetTimedHabit(int index) async {
    if (index >= 0 && index < _timedHabits.length) {
      _timedHabits[index].reset();
      await _databaseService.saveTimedHabits(_timedHabits);
      notifyListeners();
    }
  }

  // --- All Data ---

  Future<void> clearAll() async {
    final grids = _grids.map((g) => g.name).toList();
    final chains = _goalChains.map((c) => c.name).toList();
    final jars = _moneyJars.map((j) => j.name).toList();
    final journals = _journals.map((j) => j.name).toList();
    final contracts = _contracts.map((c) => c.name).toList();
    final timedHabits = _timedHabits.map((t) => t.name).toList();

    _grids.clear();
    _goalChains.clear();
    _moneyJars.clear();
    _journals.clear();
    _contracts.clear();
    _timedHabits.clear();
    await _databaseService.saveHabitGrids(_grids);
    await _databaseService.saveGoalChains(_goalChains);
    await _databaseService.saveMoneyJars(_moneyJars);
    await _databaseService.saveJournals(_journals);
    await _databaseService.saveContracts(_contracts);
    await _databaseService.saveTimedHabits(_timedHabits);

    for (final name in grids) {
      await _databaseService.recordDeletion(DatabaseService.gridsFileName, name);
    }
    for (final name in chains) {
      await _databaseService.recordDeletion(DatabaseService.chainsFileName, name);
    }
    for (final name in jars) {
      await _databaseService.recordDeletion(DatabaseService.jarsFileName, name);
    }
    for (final name in journals) {
      await _databaseService.recordDeletion(DatabaseService.journalsFileName, name);
    }
    for (final name in contracts) {
      await _databaseService.recordDeletion(DatabaseService.contractsFileName, name);
    }
    for (final name in timedHabits) {
      await _databaseService.recordDeletion(DatabaseService.timedHabitsFileName, name);
    }
    notifyListeners();
  }
}

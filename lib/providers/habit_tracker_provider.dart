import 'package:flutter/foundation.dart';
import '../models/habit_grid.dart';
import '../models/goal_chain.dart';
import '../models/money_jar.dart';
import '../models/habit_journal.dart';
import '../models/journal_entry.dart';
import '../models/journal_sub_entry.dart';
import '../services/database_service.dart';

class HabitTrackerProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<HabitGrid> _grids = [];
  List<GoalChain> _goalChains = [];
  List<MoneyJar> _moneyJars = [];
  List<HabitJournal> _journals = [];

  List<HabitGrid> get grids => _grids;
  List<GoalChain> get goalChains => _goalChains;
  List<MoneyJar> get moneyJars => _moneyJars;
  List<HabitJournal> get journals => _journals;

  Future<void> loadAll() async {
    _grids = await _databaseService.loadHabitGrids();
    _goalChains = await _databaseService.loadGoalChains();
    _moneyJars = await _databaseService.loadMoneyJars();
    _journals = await _databaseService.loadJournals();
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
      _grids.removeAt(index);
      await _databaseService.saveHabitGrids(_grids);
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
      _goalChains.removeAt(index);
      await _databaseService.saveGoalChains(_goalChains);
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
      _moneyJars.removeAt(index);
      await _databaseService.saveMoneyJars(_moneyJars);
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
      _journals.removeAt(index);
      await _databaseService.saveJournals(_journals);
      notifyListeners();
    }
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

  // --- All Data ---

  Future<void> clearAll() async {
    _grids.clear();
    _goalChains.clear();
    _moneyJars.clear();
    _journals.clear();
    await _databaseService.saveHabitGrids(_grids);
    await _databaseService.saveGoalChains(_goalChains);
    await _databaseService.saveMoneyJars(_moneyJars);
    await _databaseService.saveJournals(_journals);
    notifyListeners();
  }
}

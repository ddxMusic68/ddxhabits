import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/habit_grid.dart';
import '../models/goal_chain.dart';
import '../models/money_jar.dart';
import '../models/habit_journal.dart';

class DatabaseService {
  static const _gridsFileName = 'habit_grids.json';
  static const _chainsFileName = 'goal_chains.json';
  static const _jarsFileName = 'money_jars.json';
  static const _journalsFileName = 'habit_journals.json';

  Future<File> _getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<void> saveHabitGrids(List<HabitGrid> grids) async {
    final file = await _getFile(_gridsFileName);
    final json = grids.map((g) => g.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  Future<List<HabitGrid>> loadHabitGrids() async {
    try {
      final file = await _getFile(_gridsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => HabitGrid.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveGoalChains(List<GoalChain> chains) async {
    final file = await _getFile(_chainsFileName);
    final json = chains.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  Future<List<GoalChain>> loadGoalChains() async {
    try {
      final file = await _getFile(_chainsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => GoalChain.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMoneyJars(List<MoneyJar> jars) async {
    final file = await _getFile(_jarsFileName);
    final json = jars.map((j) => j.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  Future<List<MoneyJar>> loadMoneyJars() async {
    try {
      final file = await _getFile(_jarsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => MoneyJar.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveJournals(List<HabitJournal> journals) async {
    final file = await _getFile(_journalsFileName);
    final json = journals.map((j) => j.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  Future<List<HabitJournal>> loadJournals() async {
    try {
      final file = await _getFile(_journalsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => HabitJournal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
}

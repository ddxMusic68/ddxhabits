import 'dart:convert';
import 'dart:io';
import '../models/habit_grid.dart';
import '../models/goal_chain.dart';
import '../models/money_jar.dart';
import '../models/habit_journal.dart';
import '../models/habit_contract.dart';
import '../models/deletion_tombstone.dart';
import '../utils/path_helper.dart';
import 'sync_service.dart';

class DatabaseService {
  static const gridsFileName = 'habit_grids.json';
  static const chainsFileName = 'goal_chains.json';
  static const jarsFileName = 'money_jars.json';
  static const journalsFileName = 'habit_journals.json';
  static const contractsFileName = 'habit_contracts.json';
  static const tombstonesFileName = 'tombstones.json';

  final SyncService _syncService = SyncService();

  Future<File> _getFile(String fileName) async {
    final directory = await getStoragePath();
    return File('$directory/$fileName');
  }

  void _syncInBackground(String fileName) {
    _syncService.syncFile(fileName);
  }

  Future<void> saveHabitGrids(List<HabitGrid> grids) async {
    final file = await _getFile(gridsFileName);
    final json = grids.map((g) => g.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
    _syncInBackground(gridsFileName);
  }

  Future<List<HabitGrid>> loadHabitGrids() async {
    try {
      final file = await _getFile(gridsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => HabitGrid.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveGoalChains(List<GoalChain> chains) async {
    final file = await _getFile(chainsFileName);
    final json = chains.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
    _syncInBackground(chainsFileName);
  }

  Future<List<GoalChain>> loadGoalChains() async {
    try {
      final file = await _getFile(chainsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => GoalChain.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMoneyJars(List<MoneyJar> jars) async {
    final file = await _getFile(jarsFileName);
    final json = jars.map((j) => j.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
    _syncInBackground(jarsFileName);
  }

  Future<List<MoneyJar>> loadMoneyJars() async {
    try {
      final file = await _getFile(jarsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => MoneyJar.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveJournals(List<HabitJournal> journals) async {
    final file = await _getFile(journalsFileName);
    final json = journals.map((j) => j.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
    _syncInBackground(journalsFileName);
  }

  Future<List<HabitJournal>> loadJournals() async {
    try {
      final file = await _getFile(journalsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => HabitJournal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveContracts(List<HabitContract> contracts) async {
    final file = await _getFile(contractsFileName);
    final json = contracts.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
    _syncInBackground(contractsFileName);
  }

  Future<List<HabitContract>> loadContracts() async {
    try {
      final file = await _getFile(contractsFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => HabitContract.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTombstones(List<DeletionTombstone> tombstones) async {
    final file = await _getFile(tombstonesFileName);
    final json = tombstones.map((t) => t.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
    _syncInBackground(tombstonesFileName);
  }

  Future<List<DeletionTombstone>> loadTombstones() async {
    try {
      final file = await _getFile(tombstonesFileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as List<dynamic>;
      return json.map((e) => DeletionTombstone.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> recordDeletion(String fileName, String name) async {
    final tombstones = await loadTombstones();
    tombstones.add(DeletionTombstone(
      fileName: fileName,
      name: name,
      deletedAt: DateTime.now(),
    ));
    await saveTombstones(tombstones);
  }
}


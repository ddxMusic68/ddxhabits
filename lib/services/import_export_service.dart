import 'dart:convert';
import 'dart:io';
import '../utils/path_helper.dart';

class ImportExportService {
  static const _fileNames = [
    'habit_grids.json',
    'goal_chains.json',
    'money_jars.json',
    'habit_journals.json',
    'habit_contracts.json',
    'timed_habits.json',
    'tombstones.json',
  ];

  Future<Map<String, dynamic>> exportAll() async {
    final dir = await getStoragePath();
    final data = <String, dynamic>{};
    for (final name in _fileNames) {
      final file = File('$dir/$name');
      if (await file.exists()) {
        data[name] = jsonDecode(await file.readAsString());
      } else {
        data[name] = [];
      }
    }
    return data;
  }

  Future<String> exportAllAsString() async {
    final data = await exportAll();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importAll(String jsonData) async {
    final data = jsonDecode(jsonData);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid export file format');
    }
    final dir = await getStoragePath();
    for (final name in _fileNames) {
      if (data.containsKey(name)) {
        final file = File('$dir/$name');
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(data[name]),
        );
      }
    }
  }
}

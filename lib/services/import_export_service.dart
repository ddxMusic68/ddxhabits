import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/habit_grid.dart';

class ImportExportService {
  Future<File> get _habitFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/habit_grids.json');
  }

  Future<String> exportData() async {
    final file = await _habitFile;
    if (!await file.exists()) {
      throw Exception('No data to export');
    }
    return file.readAsString();
  }

  Future<void> importData(String jsonData) async {
    final json = jsonDecode(jsonData);
    if (json is! List) {
      throw Exception('Invalid data format');
    }
    // Validate each item can be parsed as a HabitGrid
    for (final item in json) {
      HabitGrid.fromJson(item as Map<String, dynamic>);
    }
    // Save the validated data
    final file = await _habitFile;
    await file.writeAsString(jsonData);
  }

  Future<String> getExportPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/ddxhabits_export.json';
  }

  Future<void> saveExportToFile(String jsonData) async {
    final path = await getExportPath();
    final file = File(path);
    await file.writeAsString(jsonData);
  }

  Future<String> loadImportFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }
    return file.readAsString();
  }
}

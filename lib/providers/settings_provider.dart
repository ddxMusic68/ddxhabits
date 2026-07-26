import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/sync_service.dart';

enum AppThemeMode { light, dark, system }

class SettingsProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isDropboxAuthenticated = false;

  AppThemeMode get themeMode => _themeMode;
  bool get isDropboxAuthenticated => _isDropboxAuthenticated;

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  Future<void> refreshDropboxStatus() async {
    _isDropboxAuthenticated = await _syncService.isAuthenticated;
    notifyListeners();
  }

  Future<void> disconnectDropbox() async {
    await _syncService.logout();
    _isDropboxAuthenticated = false;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    try {
      final file = await _file;
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      _themeMode = AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      );
      notifyListeners();
    } catch (e) {
      // Use defaults
    }
    await refreshDropboxStatus();
  }

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/settings.json');
  }

  Future<void> _saveSettings() async {
    final file = await _file;
    final json = {
      'themeMode': _themeMode.name,
    };
    await file.writeAsString(jsonEncode(json));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/habit_tracker_provider.dart';
import '../services/import_export_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              const _SectionHeader(title: 'Appearance'),
              RadioGroup<AppThemeMode>(
                groupValue: settings.themeMode,
                onChanged: (mode) {
                  if (mode != null) settings.setThemeMode(mode);
                },
                child: Column(
                  children: [
                    _ThemeTile(
                      title: 'System',
                      value: AppThemeMode.system,
                    ),
                    _ThemeTile(
                      title: 'Light',
                      value: AppThemeMode.light,
                    ),
                    _ThemeTile(
                      title: 'Dark',
                      value: AppThemeMode.dark,
                    ),
                  ],
                ),
              ),
              const Divider(),
              const _SectionHeader(title: 'Sync'),
              SwitchListTile(
                title: const Text('Dropbox Sync'),
                subtitle: const Text('Sync data with Dropbox'),
                value: settings.dropboxSyncEnabled,
                onChanged: (_) => settings.toggleDropboxSync(),
                activeThumbColor: AppColors.mintDark,
              ),
              const Divider(),
              const _SectionHeader(title: 'Data'),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Export Data'),
                subtitle: const Text('Save habit data to file'),
                onTap: () => _exportData(context),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Import Data'),
                subtitle: const Text('Load habit data from file'),
                onTap: () => _importData(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Delete all habit grids'),
                onTap: () => _confirmClearData(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final service = ImportExportService();
      final data = await service.exportData();
      final path = await service.getExportPath();
      await service.saveExportToFile(data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to:\n$path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final service = ImportExportService();
      final path = await service.getExportPath();
      final data = await service.loadImportFromFile(path);
      await service.importData(data);
      if (context.mounted) {
        context.read<HabitTrackerProvider>().loadAll();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all habit grids. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitTrackerProvider>().clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String title;
  final AppThemeMode value;

  const _ThemeTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<AppThemeMode>(
          value: value,
        ),
        Text(title),
      ],
    );
  }
}

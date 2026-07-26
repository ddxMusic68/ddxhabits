import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/habit_tracker_provider.dart';
import '../services/import_export_service.dart';
import '../services/sync_service.dart';
import '../screens/dropbox_setup_screen.dart';
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
              if (settings.isDropboxAuthenticated) ...[
                ListTile(
                  leading: const Icon(Icons.cloud_done, color: AppColors.mintDark),
                  title: const Text('Dropbox Connected'),
                  subtitle: const Text('Data syncs automatically on every save'),
                  trailing: TextButton(
                    onPressed: () => _syncNow(context, settings),
                    child: const Text('Sync Now'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.link_off),
                  title: const Text('Disconnect'),
                  onTap: () => _confirmDisconnect(context, settings),
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.cloud_off),
                  title: const Text('Connect to Dropbox'),
                  subtitle: const Text('Sync data across devices'),
                  onTap: () => _connectDropbox(context, settings),
                ),
              ],
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
                leading: const Icon(Icons.phone_android, color: Colors.red),
                title: const Text('Clear Local Data', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Delete all data on this device'),
                onTap: () => _confirmClearLocal(context),
              ),
              if (settings.isDropboxAuthenticated)
                ListTile(
                  leading: const Icon(Icons.cloud_off, color: Colors.red),
                  title: const Text('Clear Cloud Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Delete all data from Dropbox'),
                  onTap: () => _confirmClearCloud(context, settings),
                ),
              const Divider(),
              const _VersionTile(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _connectDropbox(BuildContext context, SettingsProvider settings) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const DropboxSetupScreen()),
    );
    if (result == true) {
      await settings.refreshDropboxStatus();
    }
  }

  Future<void> _syncNow(BuildContext context, SettingsProvider settings) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing...')),
    );
    try {
      await SyncService().fullSync();
      if (context.mounted) {
        Provider.of<HabitTrackerProvider>(context, listen: false).loadAll();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync complete')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
  }

  void _confirmDisconnect(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Dropbox?'),
        content: const Text('Data will no longer sync across devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              settings.disconnectDropbox();
              Navigator.pop(context);
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final service = ImportExportService();
      final data = await service.exportAllAsString();
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Data',
        fileName: 'ddxhabits_export.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return;
      await File(result).writeAsString(data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to:\n$result')),
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;
      final file = File(result.files.single.path!);
      final data = await file.readAsString();
      final service = ImportExportService();
      await service.importAll(data);
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

  void _confirmClearLocal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data?'),
        content: const Text('This will delete all data on this device. This cannot be undone.'),
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
                const SnackBar(content: Text('Local data cleared')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmClearCloud(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cloud Data?'),
        content: const Text('This will delete all data from Dropbox. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await SyncService().deleteAllRemote();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cloud data cleared')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to clear cloud data: $e')),
                  );
                }
              }
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

class _VersionTile extends StatelessWidget {
  const _VersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        final buildNumber = snapshot.data?.buildNumber ?? '';
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Version'),
          subtitle: Text('v$version+$buildNumber'),
        );
      },
    );
  }
}

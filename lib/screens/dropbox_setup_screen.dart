import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sync_service.dart';
import '../utils/constants.dart';

class DropboxSetupScreen extends StatefulWidget {
  const DropboxSetupScreen({super.key});

  @override
  State<DropboxSetupScreen> createState() => _DropboxSetupScreenState();
}

class _DropboxSetupScreenState extends State<DropboxSetupScreen> {
  final _syncService = SyncService();
  final _appKeyController = TextEditingController();
  final _codeController = TextEditingController();
  bool _hasAppKey = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAppKey();
  }

  Future<void> _loadAppKey() async {
    final key = await _syncService.getAppKey();
    if (key != null && key.isNotEmpty) {
      setState(() {
        _appKeyController.text = key;
        _hasAppKey = true;
      });
    }
  }

  @override
  void dispose() {
    _appKeyController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _authorize() async {
    final appKey = _appKeyController.text.trim();
    if (appKey.isEmpty) {
      _showError('Please enter your App Key');
      return;
    }

    setState(() => _loading = true);
    try {
      final authUrl = _syncService.getAuthUrl(appKey);
      final uri = Uri.parse(authUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() {
        _hasAppKey = true;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Could not open browser: $e');
    }
  }

  Future<void> _connect() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showError('Please paste the authorization code');
      return;
    }

    setState(() => _loading = true);
    try {
      await _syncService.exchangeCodeAndSave(_appKeyController.text.trim(), code);
      setState(() => _loading = false);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to connect: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.coralDark,
        action: SnackBarAction(
          label: 'Copy',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: message));
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Dropbox')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 1: Enter your Dropbox App Key',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Create an app at dropbox.com/developers if you don\'t have one.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _appKeyController,
              decoration: const InputDecoration(
                hintText: 'App Key',
                border: OutlineInputBorder(),
              ),
              enabled: !_hasAppKey,
            ),
            const SizedBox(height: 16),
            if (!_hasAppKey)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _authorize,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintDark,
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Authorize'),
                ),
              ),
            if (_hasAppKey) ...[
              const SizedBox(height: 32),
              const Text(
                'Step 2: Paste the authorization code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Copy the code from the browser and paste it below.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'Authorization code',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _hasAppKey = false;
                          _codeController.clear();
                        });
                      },
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mintDark,
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Connect'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import '../utils/path_helper.dart';

class SyncService {
  static const String _accessTokenKey = 'dropbox_access_token';
  static const String _refreshTokenKey = 'dropbox_refresh_token';
  static const String _appKeyKey = 'dropbox_app_key';
  static const String _remoteBasePath = '';

  final Dio _dio = Dio();
  String? _currentCodeVerifier;

  // --- App Key ---

  Future<void> saveAppKey(String appKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appKeyKey, appKey);
  }

  Future<String?> getAppKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appKeyKey);
  }

  Future<void> clearAppKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appKeyKey);
  }

  // --- PKCE ---

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // --- Auth ---

  Future<bool> get isAuthenticated async {
    final token = await _getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> _saveTokens(String accessToken, String? refreshToken, {int? expiresIn}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    final seconds = expiresIn ?? 14400;
    final expiry = DateTime.now().add(Duration(seconds: seconds));
    await prefs.setString('dropbox_token_expiry', expiry.toIso8601String());
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<void> authenticate(String appKey) async {
    _currentCodeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(_currentCodeVerifier!);

    final authUrl = Uri.parse(
      'https://www.dropbox.com/oauth2/authorize'
      '?client_id=$appKey'
      '&response_type=code'
      '&token_access_type=offline'
      '&scope=files.content.write+files.content.read'
      '&code_challenge=$codeChallenge'
      '&code_challenge_method=S256',
    );

    if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open browser');
    }
  }

  String getAuthUrl(String appKey) {
    _currentCodeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(_currentCodeVerifier!);

    return 'https://www.dropbox.com/oauth2/authorize'
        '?client_id=$appKey'
        '&response_type=code'
        '&token_access_type=offline'
        '&scope=files.content.write+files.content.read'
        '&code_challenge=$codeChallenge'
        '&code_challenge_method=S256';
  }

  Future<void> exchangeCodeAndSave(String appKey, String code) async {
    final tokenData = await _exchangeCode(appKey, code);
    await _saveTokens(
      tokenData['access_token']!,
      tokenData['refresh_token'],
      expiresIn: tokenData['expires_in'] as int?,
    );
    await saveAppKey(appKey);
  }

  Future<Map<String, dynamic>> _exchangeCode(String appKey, String code) async {
    if (_currentCodeVerifier == null) {
      throw Exception('No code verifier — call authenticate() first');
    }

    final response = await _dio.post(
      'https://api.dropbox.com/oauth2/token',
      data: {
        'code': code,
        'grant_type': 'authorization_code',
        'client_id': appKey,
        'code_verifier': _currentCodeVerifier,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    _currentCodeVerifier = null;
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> _refreshAccessToken(String appKey) async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');

    final response = await _dio.post(
      'https://api.dropbox.com/oauth2/token',
      data: {
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
        'client_id': appKey,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = response.data;
    await _saveTokens(
      data['access_token'] as String,
      null,
      expiresIn: data['expires_in'] as int?,
    );
  }

  Future<void> logout() async {
    await _clearTokens();
    await clearAppKey();
  }

  // --- HTTP Helpers ---

  Future<String> _requireToken() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return token;
  }

  Options _authOptions(String token) => Options(
        headers: {'Authorization': 'Bearer $token'},
      );

  // --- File Operations ---

  Future<void> uploadFile(String localPath, String remotePath) async {
    final token = await _requireToken();
    final file = File(localPath);
    final data = await file.readAsBytes();

    await _dio.post(
      'https://content.dropboxapi.com/2/files/upload',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/octet-stream',
          'Dropbox-API-Arg': jsonEncode({
            'path': '$_remoteBasePath$remotePath',
            'mode': 'overwrite',
          }),
        },
      ),
    );
  }

  Future<List<int>> downloadFile(String remotePath) async {
    final token = await _requireToken();
    final response = await _dio.post<ResponseBody>(
      'https://content.dropboxapi.com/2/files/download',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': '',
          'Dropbox-API-Arg': jsonEncode({
            'path': '$_remoteBasePath$remotePath',
          }),
        },
        responseType: ResponseType.stream,
      ),
    );

    final stream = response.data!.stream;
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  Future<List<String>> listFiles(String remotePath) async {
    final token = await _requireToken();
    final response = await _dio.post(
      'https://api.dropboxapi.com/2/files/list_folder',
      data: {'path': '$_remoteBasePath$remotePath'},
      options: _authOptions(token),
    );

    final entries = response.data['entries'] as List;
    return entries
        .where((e) => e['.tag'] == 'file')
        .map<String>((e) => e['name'] as String)
        .toList();
  }

  Future<void> deleteFile(String remotePath) async {
    final token = await _requireToken();
    await _dio.post(
      'https://api.dropboxapi.com/2/files/delete_v2',
      data: {'path': '$_remoteBasePath$remotePath'},
      options: _authOptions(token),
    );
  }

  Future<void> deleteAllRemote() async {
    for (final fileName in _syncFiles) {
      try {
        await deleteFile('/$fileName');
      } catch (_) {}
    }
  }

  Future<void> createFolder(String remotePath) async {
    final token = await _requireToken();
    await _dio.post(
      'https://api.dropboxapi.com/2/files/create_folder_v2',
      data: {'path': '$_remoteBasePath$remotePath'},
      options: _authOptions(token),
    );
  }

  // --- Sync Operations ---

  Future<void> syncJsonFile(String localPath) async {
    final appKey = await getAppKey();
    if (appKey == null) return;

    if (await _isTokenExpired()) {
      await _refreshAccessToken(appKey);
    }

    await uploadFile(localPath, '/journal_data.json');
  }

  Future<void> syncMediaFile(String localPath) async {
    final appKey = await getAppKey();
    if (appKey == null) return;

    if (await _isTokenExpired()) {
      await _refreshAccessToken(appKey);
    }

    final fileName = p.basename(localPath);
    await uploadFile(localPath, '/media/$fileName');
  }

  Future<String?> downloadJsonFile(String localPath) async {
    final appKey = await getAppKey();
    if (appKey == null) return null;

    if (await _isTokenExpired()) {
      await _refreshAccessToken(appKey);
    }

    try {
      final bytes = await downloadFile('/journal_data.json');
      final file = File(localPath);
      await file.writeAsBytes(bytes);
      return localPath;
    } catch (_) {
      return null;
    }
  }

  Future<void> downloadMediaFiles(String localMediaDir) async {
    final appKey = await getAppKey();
    if (appKey == null) return;

    if (await _isTokenExpired()) {
      await _refreshAccessToken(appKey);
    }

    try {
      final remoteFiles = await listFiles('/media');
      final localDir = Directory(localMediaDir);
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      for (final fileName in remoteFiles) {
        final localFile = File(p.join(localMediaDir, fileName));
        if (!await localFile.exists()) {
          final bytes = await downloadFile('/media/$fileName');
          await localFile.writeAsBytes(bytes);
        }
      }
    } catch (_) {
      // Folder might not exist yet
    }
  }

  Future<bool> _isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('dropbox_token_expiry');
    if (expiryStr == null) return true;
    final expiry = DateTime.parse(expiryStr);
    return DateTime.now().isAfter(expiry);
  }

  // --- ddxHabits Sync ---

  static const _syncFiles = [
    'habit_grids.json',
    'goal_chains.json',
    'money_jars.json',
    'habit_journals.json',
    'habit_contracts.json',
    'timed_habits.json',
    'tombstones.json',
  ];

  Future<String> _getLocalPath(String fileName) async {
    final directory = await getStoragePath();
    return '$directory/$fileName';
  }

  Future<void> syncFile(String localFileName) async {
    try {
      final appKey = await getAppKey();
      if (appKey == null) return;

      if (await _isTokenExpired()) {
        await _refreshAccessToken(appKey);
      }

      final localPath = await _getLocalPath(localFileName);
      final file = File(localPath);
      if (await file.exists()) {
        await uploadFile(localPath, '/$localFileName');
      }
    } catch (_) {
      // Non-blocking — don't let sync failures break the app
    }
  }

  Future<void> fullSync() async {
    final appKey = await getAppKey();
    if (appKey == null) return;

    if (await _isTokenExpired()) {
      await _refreshAccessToken(appKey);
    }

    // First sync tombstones so deletions are honored by data merges below.
    final tombstones = await _syncTombstones();

    for (final fileName in _syncFiles) {
      if (fileName == 'tombstones.json') continue;

      final localPath = await _getLocalPath(fileName);
      final localFile = File(localPath);

      // Try to download remote version
      try {
        final bytes = await downloadFile('/$fileName');
        final remoteJson = utf8.decode(bytes);

        if (await localFile.exists()) {
          final localJson = await localFile.readAsString();
          if (localJson != remoteJson) {
            // Merge keeping both sides, then drop tombstoned items.
            final localData = jsonDecode(localJson);
            final remoteData = jsonDecode(remoteJson);
            final merged = _mergeLists(localData, remoteData);
            final filtered = _removeTombstoned(merged, tombstones, fileName);
            await localFile.writeAsString(jsonEncode(filtered));
          }
        } else {
          final data = jsonDecode(remoteJson);
          final filtered = _removeTombstoned(data, tombstones, fileName);
          await localFile.writeAsString(jsonEncode(filtered));
        }
      } catch (_) {
        // Remote file might not exist yet
      }

      // Upload local version
      try {
        if (await localFile.exists()) {
          await uploadFile(localPath, '/$fileName');
        }
      } catch (_) {
        try {
          await createFolder('');
        } catch (_) {}
        try {
          if (await localFile.exists()) {
            await uploadFile(localPath, '/$fileName');
          }
        } catch (_) {}
      }
    }
  }

  /// Downloads remote tombstones, merges with local, saves merged, uploads.
  /// Returns the merged tombstone list as raw maps keyed for filtering.
  Future<List<Map<String, dynamic>>> _syncTombstones() async {
    const fileName = 'tombstones.json';
    final localPath = await _getLocalPath(fileName);
    final localFile = File(localPath);

    List<Map<String, dynamic>> localList = [];
    if (await localFile.exists()) {
      final localJson = await localFile.readAsString();
      final decoded = jsonDecode(localJson);
      if (decoded is List) {
        localList = decoded.map((e) => e as Map<String, dynamic>).toList();
      }
    }

    List<Map<String, dynamic>> remoteList = [];
    try {
      final bytes = await downloadFile('/$fileName');
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is List) {
        remoteList = decoded.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {
      // Remote file might not exist yet
    }

    final merged = _mergeTombstones(localList, remoteList);
    await localFile.writeAsString(jsonEncode(merged));

    try {
      await uploadFile(localPath, '/$fileName');
    } catch (_) {
      try {
        await createFolder('');
      } catch (_) {}
      try {
        await uploadFile(localPath, '/$fileName');
      } catch (_) {}
    }

    return merged;
  }

  List<Map<String, dynamic>> _mergeTombstones(
    List<Map<String, dynamic>> local,
    List<Map<String, dynamic>> remote,
  ) {
    final map = <String, Map<String, dynamic>>{};
    for (final t in [...local, ...remote]) {
      final key = '${t['fileName']}|${t['name']}';
      final existing = map[key];
      if (existing == null) {
        map[key] = t;
      } else {
        final existingTime = DateTime.parse(existing['deletedAt'] as String);
        final newTime = DateTime.parse(t['deletedAt'] as String);
        if (newTime.isAfter(existingTime)) {
          map[key] = t;
        }
      }
    }
    return map.values.toList();
  }

  dynamic _removeTombstoned(
    dynamic data,
    List<Map<String, dynamic>> tombstones,
    String fileName,
  ) {
    if (data is! List) return data;

    final tombstoneTimes = <String, DateTime>{};
    for (final t in tombstones) {
      if (t['fileName'] == fileName && t['name'] is String) {
        tombstoneTimes[t['name'] as String] =
            DateTime.parse(t['deletedAt'] as String);
      }
    }
    if (tombstoneTimes.isEmpty) return data;

    return data.where((item) {
      if (item is! Map<String, dynamic>) return true;
      final name = item['name'];
      if (name is! String) return true;
      final deletedAt = tombstoneTimes[name];
      if (deletedAt == null) return true;
      final itemUpdated = item['updatedAt'] as String?;
      if (itemUpdated == null) return false;
      final updated = DateTime.parse(itemUpdated);
      // Keep items updated after the deletion (re-created habit survives).
      return updated.isAfter(deletedAt);
    }).toList();
  }

  dynamic _mergeLists(dynamic local, dynamic remote) {
    if (local == null) return remote;
    if (remote == null) return local;
    if (local is List && remote is List) {
      final localMap = <String, dynamic>{};
      for (final item in local) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          localMap[item['name'] as String] = item;
        }
      }
      for (final item in remote) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          final name = item['name'] as String;
          final existing = localMap[name];
          if (existing == null) {
            localMap[name] = item;
          } else {
            final localUpdated = DateTime.parse(existing['updatedAt'] as String);
            final remoteUpdated = DateTime.parse(item['updatedAt'] as String);
            if (remoteUpdated.isAfter(localUpdated)) {
              localMap[name] = item;
            }
          }
        }
      }
      return localMap.values.toList();
    }
    return local;
  }
}

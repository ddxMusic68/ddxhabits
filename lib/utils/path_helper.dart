import 'dart:io';

Future<String> getStoragePath() async {
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  final storageDir = Directory('$exeDir/storage');
  if (!await storageDir.exists()) {
    await storageDir.create(recursive: true);
  }
  return storageDir.path;
}

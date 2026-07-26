import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getStoragePath() async {
  if (Platform.isAndroid || Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    final storageDir = Directory('${directory.path}/storage');
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    return storageDir.path;
  }
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  final storageDir = Directory('$exeDir/storage');
  if (!await storageDir.exists()) {
    await storageDir.create(recursive: true);
  }
  return storageDir.path;
}

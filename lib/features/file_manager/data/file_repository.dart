import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileRepository {
  Future<Directory> getWorkspaceDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final ordokuDir = Directory('${docsDir.path}/OrdoKu_Workspace');
    if (!await ordokuDir.exists()) {
      await ordokuDir.create(recursive: true);
    }
    return ordokuDir;
  }

  Future<List<FileSystemEntity>> listFiles() async {
    final dir = await getWorkspaceDirectory();
    final List<FileSystemEntity> files = [];
    await for (var entity in dir.list(recursive: false)) {
      files.add(entity);
    }
    // Sort by last modified (newest first)
    files.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified);
    });
    return files;
  }

  Future<File> createEmptyDocument(String name, String extension) async {
    final dir = await getWorkspaceDirectory();
    // Generate unique filename
    var fileName = '$name.$extension';
    var file = File('${dir.path}${Platform.pathSeparator}$fileName');
    int counter = 1;
    while (await file.exists()) {
      fileName = '$name $counter.$extension';
      file = File('${dir.path}${Platform.pathSeparator}$fileName');
      counter++;
    }
    await file.writeAsString('{}');
    return file;
  }
  
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> readFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }

  Future<void> writeToFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  Future<void> importFile(String sourcePath) async {
    final workspaceDir = await getWorkspaceDirectory();
    final sourceFile = File(sourcePath);
    final fileName = sourcePath.split(Platform.pathSeparator).last;
    final destPath = '${workspaceDir.path}${Platform.pathSeparator}$fileName';
    await sourceFile.copy(destPath);
  }
}

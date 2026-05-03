import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ordoku/features/file_manager/data/file_repository.dart';

final fileRepositoryProvider = Provider((ref) => FileRepository());

class FileManagerNotifier extends AsyncNotifier<List<FileSystemEntity>> {
  @override
  FutureOr<List<FileSystemEntity>> build() async {
    return _fetchFiles();
  }

  Future<List<FileSystemEntity>> _fetchFiles() async {
    final repo = ref.read(fileRepositoryProvider);
    final entities = await repo.listFiles();
    final validExtensions = ['.ordw', '.ords', '.ordp', '.ordd', '.ordn', '.pdf'];
    return entities.whereType<File>().where((file) {
      return validExtensions.any((ext) => file.path.endsWith(ext));
    }).toList();
  }

  Future<void> refreshFiles() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFiles());
  }

  Future<File> createDocument(String name, String type) async {
    final repo = ref.read(fileRepositoryProvider);
    final file = await repo.createEmptyDocument(name, type);
    await refreshFiles();
    return file;
  }

  Future<void> pickAndImportFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final repo = ref.read(fileRepositoryProvider);
      await repo.importFile(result.files.single.path!);
      await refreshFiles();
    }
  }

  Future<void> deleteFile(String path) async {
    final repo = ref.read(fileRepositoryProvider);
    await repo.deleteFile(path);
    await refreshFiles();
  }
}

final fileManagerNotifierProvider = AsyncNotifierProvider<FileManagerNotifier, List<FileSystemEntity>>(
  () => FileManagerNotifier(),
);

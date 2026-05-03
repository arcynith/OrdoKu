import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordoku/features/file_manager/domain/file_manager_provider.dart';
import 'package:ordoku/core/engines/autosave_engine.dart';

class WriterNotifier extends Notifier<QuillController> {
  String? _currentFilePath;
  final AutosaveEngine _autosave = AutosaveEngine();

  @override
  QuillController build() {
    final controller = QuillController.basic();
    controller.document.changes.listen((_) {
      _autosave.run(() => saveFile());
    });
    return controller;
  }

  Future<void> loadFile(String path) async {
    _currentFilePath = path;
    final repo = ref.read(fileRepositoryProvider);
    final content = await repo.readFile(path);
    
    if (content.isNotEmpty && content != '{}') {
      try {
        final jsonDelta = jsonDecode(content);
        final doc = Document.fromJson(jsonDelta);
        final controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
        controller.document.changes.listen((_) {
          _autosave.run(() => saveFile());
        });
        state = controller;
      } catch (e) {
        // If it's invalid JSON or corrupted, just start fresh
        final controller = QuillController.basic();
        controller.document.changes.listen((_) {
          _autosave.run(() => saveFile());
        });
        state = controller;
      }
    } else {
      final controller = QuillController.basic();
      controller.document.changes.listen((_) {
        _autosave.run(() => saveFile());
      });
      state = controller;
    }
  }

  Future<void> saveFile() async {
    if (_currentFilePath == null) return;
    
    final repo = ref.read(fileRepositoryProvider);
    final delta = state.document.toDelta();
    final jsonContent = jsonEncode(delta.toJson());
    
    await repo.writeToFile(_currentFilePath!, jsonContent);
  }

  void disposeController() {
    state.dispose();
  }
}

final writerNotifierProvider = NotifierProvider<WriterNotifier, QuillController>(
  () => WriterNotifier(),
);

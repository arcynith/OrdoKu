import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordoku/features/file_manager/domain/file_manager_provider.dart';
import 'package:ordoku/core/engines/undo_redo_engine.dart';
import 'package:ordoku/core/engines/autosave_engine.dart';

class NoteData {
  final String content;
  final List<String> tags;

  NoteData({required this.content, this.tags = const []});

  factory NoteData.empty() => NoteData(content: '');

  Map<String, dynamic> toJson() => {
        'content': content,
        'tags': tags,
      };

  factory NoteData.fromJson(Map<String, dynamic> json) => NoteData(
        content: json['content'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
      );
}

class NotesNotifier extends Notifier<NoteData> {
  String? _currentFilePath;
  final HistoryManager<NoteData> _history = HistoryManager<NoteData>();
  final AutosaveEngine _autosave = AutosaveEngine();

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  @override
  NoteData build() {
    final initial = NoteData.empty();
    _history.record(initial);
    return initial;
  }

  Future<void> loadFile(String path) async {
    _currentFilePath = path;
    final repo = ref.read(fileRepositoryProvider);
    final content = await repo.readFile(path);

    if (content.isNotEmpty && content != '{}') {
      try {
        final jsonMap = jsonDecode(content);
        state = NoteData.fromJson(jsonMap);
        _history.clear();
        _history.record(state);
      } catch (e) {
        state = NoteData.empty();
        _history.clear();
        _history.record(state);
      }
    } else {
      state = NoteData.empty();
      _history.clear();
      _history.record(state);
    }
  }

  Future<void> saveFile() async {
    if (_currentFilePath == null) return;
    final repo = ref.read(fileRepositoryProvider);
    final jsonContent = jsonEncode(state.toJson());
    await repo.writeToFile(_currentFilePath!, jsonContent);
  }

  void updateContent(String newContent) {
    final newState = NoteData(content: newContent, tags: state.tags);
    _history.record(newState);
    state = newState;
    _autosave.run(() => saveFile());
  }

  void addTag(String tag) {
    if (!state.tags.contains(tag)) {
      final newTags = List<String>.from(state.tags)..add(tag);
      final newState = NoteData(content: state.content, tags: newTags);
      _history.record(newState);
      state = newState;
      _autosave.run(() => saveFile());
    }
  }

  void undo() {
    final prev = _history.undo();
    if (prev != null) {
      state = prev;
      _autosave.run(() => saveFile());
    }
  }

  void redo() {
    final next = _history.redo();
    if (next != null) {
      state = next;
      _autosave.run(() => saveFile());
    }
  }
}

final notesNotifierProvider = NotifierProvider<NotesNotifier, NoteData>(
  () => NotesNotifier(),
);

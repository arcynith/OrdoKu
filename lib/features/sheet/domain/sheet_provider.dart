import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordoku/features/file_manager/domain/file_manager_provider.dart';
import 'package:ordoku/core/engines/undo_redo_engine.dart';
import 'package:ordoku/core/engines/autosave_engine.dart';

class SheetData {
  final List<List<String>> cells;

  SheetData(this.cells);

  factory SheetData.empty(int rows, int cols) {
    return SheetData(List.generate(rows, (_) => List.generate(cols, (_) => '')));
  }

  SheetData copy() {
    return SheetData(cells.map((row) => List<String>.from(row)).toList());
  }
}

class SheetNotifier extends Notifier<SheetData> {
  String? _currentFilePath;
  static const int _defaultRows = 50;
  static const int _defaultCols = 26; // A-Z
  final HistoryManager<SheetData> _history = HistoryManager<SheetData>();
  final AutosaveEngine _autosave = AutosaveEngine();

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  @override
  SheetData build() {
    final initial = SheetData.empty(_defaultRows, _defaultCols);
    _history.record(initial);
    return initial;
  }

  Future<void> loadFile(String path) async {
    _currentFilePath = path;
    final repo = ref.read(fileRepositoryProvider);
    final content = await repo.readFile(path);
    
    if (content.isNotEmpty && content != '{}') {
      try {
        final List<dynamic> jsonList = jsonDecode(content);
        final cells = jsonList.map((row) => (row as List).map((e) => e.toString()).toList()).toList();
        state = SheetData(cells);
        _history.clear();
        _history.record(state);
      } catch (e) {
        state = SheetData.empty(_defaultRows, _defaultCols);
        _history.clear();
        _history.record(state);
      }
    } else {
      state = SheetData.empty(_defaultRows, _defaultCols);
      _history.clear();
      _history.record(state);
    }
  }

  Future<void> saveFile() async {
    if (_currentFilePath == null) return;
    
    final repo = ref.read(fileRepositoryProvider);
    final jsonContent = jsonEncode(state.cells);
    await repo.writeToFile(_currentFilePath!, jsonContent);
  }

  void updateCell(int row, int col, String value) {
    final newData = state.copy();
    if (row < newData.cells.length && col < newData.cells[row].length) {
      newData.cells[row][col] = value;
      state = newData;
      _history.record(newData);
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

  String evaluateCell(int row, int col) {
    final raw = state.cells[row][col];
    if (raw.startsWith('=')) {
      // Basic math evaluator for MVP (e.g. =SUM)
      // For now, just return the raw string or a mock result
      if (raw.startsWith('=SUM(')) {
        return 'SUM_RESULT';
      }
      return raw; // Replace with an actual parser later
    }
    return raw;
  }
}

final sheetNotifierProvider = NotifierProvider<SheetNotifier, SheetData>(
  () => SheetNotifier(),
);

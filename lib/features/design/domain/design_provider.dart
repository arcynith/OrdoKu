import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordoku/features/file_manager/domain/file_manager_provider.dart';
import 'package:ordoku/core/engines/undo_redo_engine.dart';
import 'package:ordoku/core/engines/autosave_engine.dart';

class DesignObject {
  final String id;
  final String type; // 'rect', 'circle', 'text'
  double x;
  double y;
  double width;
  double height;
  String color;
  String content;

  DesignObject({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    this.content = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'color': color,
        'content': content,
      };

  factory DesignObject.fromJson(Map<String, dynamic> json) => DesignObject(
        id: json['id'],
        type: json['type'],
        x: json['x'],
        y: json['y'],
        width: json['width'],
        height: json['height'],
        color: json['color'],
        content: json['content'] ?? '',
      );

  DesignObject copyWith({double? x, double? y}) {
    return DesignObject(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width,
      height: height,
      color: color,
      content: content,
    );
  }
}

class DesignData {
  final List<DesignObject> objects;
  final String? selectedObjectId;

  DesignData({required this.objects, this.selectedObjectId});

  factory DesignData.empty() => DesignData(objects: []);

  factory DesignData.fromJson(Map<String, dynamic> json) => DesignData(
        objects: (json['objects'] as List).map((o) => DesignObject.fromJson(o)).toList(),
      );

  DesignData copyWith({List<DesignObject>? objects, String? selectedObjectId}) {
    return DesignData(
      objects: objects ?? this.objects,
      selectedObjectId: selectedObjectId ?? this.selectedObjectId,
    );
  }
}

class DesignNotifier extends Notifier<DesignData> {
  String? _currentFilePath;
  final HistoryManager<DesignData> _history = HistoryManager<DesignData>();
  final AutosaveEngine _autosave = AutosaveEngine();

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  @override
  DesignData build() {
    final initial = DesignData.empty();
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
        state = DesignData.fromJson(jsonMap);
        _history.clear();
        _history.record(state);
      } catch (e) {
        state = DesignData.empty();
        _history.clear();
        _history.record(state);
      }
    } else {
      state = DesignData.empty();
      _history.clear();
      _history.record(state);
    }
  }

  Future<void> saveFile() async {
    if (_currentFilePath == null) return;
    final repo = ref.read(fileRepositoryProvider);
    final jsonContent = jsonEncode({
      'objects': state.objects.map((o) => o.toJson()).toList(),
    });
    await repo.writeToFile(_currentFilePath!, jsonContent);
  }

  void addObject(String type) {
    final newObject = DesignObject(
      id: 'obj_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      x: 150,
      y: 150,
      width: type == 'text' ? 200 : 100,
      height: type == 'text' ? 50 : 100,
      color: '0xFF3B82F6', // Default blue
      content: type == 'text' ? 'New Text' : '',
    );
    
    final newState = state.copyWith(
      objects: [...state.objects, newObject],
      selectedObjectId: newObject.id,
    );
    _history.record(newState);
    state = newState;
    _autosave.run(() => saveFile());
  }

  void selectObject(String id) {
    state = state.copyWith(selectedObjectId: id);
  }

  void updateObjectPosition(String id, double x, double y) {
    final updatedObjects = state.objects.map((obj) {
      if (obj.id == id) {
        return obj.copyWith(x: x, y: y);
      }
      return obj;
    }).toList();
    
    final newState = state.copyWith(objects: updatedObjects);
    _history.record(newState);
    state = newState;
    _autosave.run(() => saveFile());
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

final designNotifierProvider = NotifierProvider<DesignNotifier, DesignData>(
  () => DesignNotifier(),
);

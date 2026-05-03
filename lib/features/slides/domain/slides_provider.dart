import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordoku/features/file_manager/domain/file_manager_provider.dart';
import 'package:ordoku/core/engines/autosave_engine.dart';

class SlideObject {
  final String id;
  final String type; // 'text', 'shape', 'image'
  final String content;
  double x;
  double y;
  double width;
  double height;

  SlideObject({required this.id, required this.type, required this.content, required this.x, required this.y, required this.width, required this.height});

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'content': content, 'x': x, 'y': y, 'width': width, 'height': height,
  };

  factory SlideObject.fromJson(Map<String, dynamic> json) => SlideObject(
    id: json['id'], type: json['type'], content: json['content'],
    x: json['x'], y: json['y'], width: json['width'], height: json['height'],
  );
}

class Slide {
  final String id;
  final List<SlideObject> objects;

  Slide({required this.id, required this.objects});

  Map<String, dynamic> toJson() => {
    'id': id, 'objects': objects.map((o) => o.toJson()).toList(),
  };

  factory Slide.fromJson(Map<String, dynamic> json) => Slide(
    id: json['id'],
    objects: (json['objects'] as List).map((o) => SlideObject.fromJson(o)).toList(),
  );
}

class PresentationData {
  final List<Slide> slides;
  int selectedIndex;

  PresentationData({required this.slides, this.selectedIndex = 0});

  factory PresentationData.empty() {
    return PresentationData(slides: [Slide(id: 'slide_1', objects: [])]);
  }
}

class SlidesNotifier extends Notifier<PresentationData> {
  String? _currentFilePath;
  final AutosaveEngine _autosave = AutosaveEngine();

  @override
  PresentationData build() {
    return PresentationData.empty();
  }

  Future<void> loadFile(String path) async {
    _currentFilePath = path;
    final repo = ref.read(fileRepositoryProvider);
    final content = await repo.readFile(path);
    
    if (content.isNotEmpty && content != '{}') {
      try {
        final List<dynamic> jsonList = jsonDecode(content);
        final slides = jsonList.map((s) => Slide.fromJson(s)).toList();
        state = PresentationData(slides: slides);
      } catch (e) {
        state = PresentationData.empty();
      }
    } else {
      state = PresentationData.empty();
    }
  }

  Future<void> saveFile() async {
    if (_currentFilePath == null) return;
    final repo = ref.read(fileRepositoryProvider);
    final jsonContent = jsonEncode(state.slides.map((s) => s.toJson()).toList());
    await repo.writeToFile(_currentFilePath!, jsonContent);
  }

  void addSlide() {
    final newSlides = List<Slide>.from(state.slides)..add(Slide(id: 'slide_${DateTime.now().millisecondsSinceEpoch}', objects: []));
    state = PresentationData(slides: newSlides, selectedIndex: newSlides.length - 1);
    _autosave.run(() => saveFile());
  }

  void selectSlide(int index) {
    state = PresentationData(slides: state.slides, selectedIndex: index);
  }

  void addObjectToCurrentSlide(String type, String content) {
    if (state.slides.isEmpty) return;
    
    final currentSlide = state.slides[state.selectedIndex];
    final newObject = SlideObject(
      id: 'obj_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      content: content,
      x: 100, y: 100, width: 200, height: 100,
    );
    
    final newObjects = List<SlideObject>.from(currentSlide.objects)..add(newObject);
    final newSlide = Slide(id: currentSlide.id, objects: newObjects);
    
    final newSlides = List<Slide>.from(state.slides);
    newSlides[state.selectedIndex] = newSlide;
    
    state = PresentationData(slides: newSlides, selectedIndex: state.selectedIndex);
    _autosave.run(() => saveFile());
  }
}

final slidesNotifierProvider = NotifierProvider<SlidesNotifier, PresentationData>(
  () => SlidesNotifier(),
);

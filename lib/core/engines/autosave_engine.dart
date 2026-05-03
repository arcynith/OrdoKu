import 'dart:async';
import 'package:flutter/foundation.dart';

class AutosaveEngine {
  final Duration delay;
  Timer? _timer;

  AutosaveEngine({this.delay = const Duration(seconds: 2)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

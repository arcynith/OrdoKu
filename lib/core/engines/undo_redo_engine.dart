class HistoryManager<T> {
  final List<T> _history = [];
  int _currentIndex = -1;
  final int maxHistory;

  HistoryManager({this.maxHistory = 50});

  bool get canUndo => _currentIndex > 0;
  bool get canRedo => _currentIndex < _history.length - 1;

  void record(T state) {
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    _history.add(state);
    
    if (_history.length > maxHistory) {
      _history.removeAt(0);
    } else {
      _currentIndex++;
    }
  }

  T? undo() {
    if (canUndo) {
      _currentIndex--;
      return _history[_currentIndex];
    }
    return null;
  }

  T? redo() {
    if (canRedo) {
      _currentIndex++;
      return _history[_currentIndex];
    }
    return null;
  }
  
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}

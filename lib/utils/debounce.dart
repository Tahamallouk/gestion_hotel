import 'dart:async';

/// Debounce helper to delay function execution
class Debounce {
  Timer? _timer;
  final Duration duration;

  Debounce({required this.duration});

  /// Call [func] with [args] after [duration]
  /// If called again before [duration] expires, previous call is cancelled
  void call(Function() func) {
    _timer?.cancel();
    _timer = Timer(duration, func);
  }

  /// Cancel pending debounce
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose debounce (should be called on dispose)
  void dispose() {
    _timer?.cancel();
  }
}

/// Extension method for easier debounce usage
extension DebounceExtension on Function() {
  /// Execute this function with debounce
  Debounce debounce(Duration duration) {
    return Debounce(duration: duration)..call(this);
  }
}

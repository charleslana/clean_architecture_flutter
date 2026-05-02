import 'package:flutter/foundation.dart';

import 'result.dart';

/// Facade that wraps an action exposed by a ViewModel so a View can:
///   - trigger it,
///   - observe whether it is running,
///   - observe its last [Result] (success/error),
///   - prevent re-entrancy while running.
///
/// Reference: https://docs.flutter.dev/app-architecture/design-patterns/command
abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  Result<T>? get result => _result;

  bool get completed => _result is Ok;
  bool get error => _result is Error;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(Future<Result<T>> Function() action) async {
    if (_running) return;
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// A Command that takes no arguments.
final class Command0<T> extends Command<T> {
  Command0(this._action);
  final Future<Result<T>> Function() _action;

  Future<void> execute() => _execute(_action);
}

/// A Command that takes a single argument.
final class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final Future<Result<T>> Function(A) _action;

  Future<void> execute(A argument) => _execute(() => _action(argument));
}

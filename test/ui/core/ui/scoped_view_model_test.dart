import 'package:clean_architecture_flutter/ui/core/ui/scoped_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterVm extends ChangeNotifier {
  int builds = 0;
  bool _disposed = false;
  bool get disposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

void main() {
  group('ScopedViewModel', () {
    testWidgets('creates the VM exactly once across rebuilds', (tester) async {
      var createCalls = 0;

      Widget harness() => MaterialApp(
        home: ScopedViewModel<_CounterVm>(
          create: (_) {
            createCalls++;
            return _CounterVm();
          },
          builder: (_, vm) => Text('build #${++vm.builds}'),
        ),
      );

      await tester.pumpWidget(harness());
      await tester.pumpWidget(harness());
      await tester.pumpWidget(harness());

      expect(createCalls, 1);
    });

    testWidgets('disposes the VM when the widget is removed', (tester) async {
      late _CounterVm captured;

      await tester.pumpWidget(
        MaterialApp(
          home: ScopedViewModel<_CounterVm>(
            create: (_) {
              captured = _CounterVm();
              return captured;
            },
            builder: (_, _) => const SizedBox(),
          ),
        ),
      );

      expect(captured.disposed, isFalse);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(captured.disposed, isTrue);
    });

    testWidgets('passes the same VM instance to builder on every rebuild', (
      tester,
    ) async {
      final seen = <_CounterVm>{};

      Widget harness() => MaterialApp(
        home: ScopedViewModel<_CounterVm>(
          create: (_) => _CounterVm(),
          builder: (_, vm) {
            seen.add(vm);
            return const SizedBox();
          },
        ),
      );

      await tester.pumpWidget(harness());
      await tester.pumpWidget(harness());
      await tester.pumpWidget(harness());

      expect(seen.length, 1, reason: 'identical VM across rebuilds');
    });
  });
}

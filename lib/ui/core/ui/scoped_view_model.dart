import 'package:flutter/widgets.dart';

class ScopedViewModel<T extends ChangeNotifier> extends StatefulWidget {
  const ScopedViewModel({
    super.key,
    required this.create,
    required this.builder,
  });

  final T Function(BuildContext context) create;

  final Widget Function(BuildContext context, T viewModel) builder;

  @override
  State<ScopedViewModel<T>> createState() => _ScopedViewModelState<T>();
}

class _ScopedViewModelState<T extends ChangeNotifier>
    extends State<ScopedViewModel<T>> {
  late final T _vm = widget.create(context);

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _vm);
}

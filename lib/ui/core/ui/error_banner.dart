import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/services/http/error_injector.dart';

/// Persistent debug strip rendered by the [ShellRoute] on top of every
/// screen. Lets the user pick the active [ErrorMode] at runtime so the View's
/// error handling can be exercised against simulated 4xx/5xx, timeouts and
/// "no internet" — without ever leaving the app.
///
/// After picking an error, pull-to-refresh on a list (or re-enter the
/// screen) to trigger a new request and watch the error path light up.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final injector = context.watch<ErrorInjector>();
    final theme = Theme.of(context);
    final active = injector.mode.isActive;

    final foreground = active
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: active
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(
              active ? Icons.warning_amber_rounded : Icons.bug_report_outlined,
              size: 18,
              color: foreground,
            ),
            const SizedBox(width: 8),
            Text('Simulate error:', style: TextStyle(color: foreground)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ErrorMode>(
                  isExpanded: true,
                  value: injector.mode,
                  style: TextStyle(color: foreground),
                  iconEnabledColor: foreground,
                  dropdownColor: theme.colorScheme.surface,
                  onChanged: (mode) {
                    if (mode != null) injector.mode = mode;
                  },
                  items: [
                    for (final mode in ErrorMode.values)
                      DropdownMenuItem(value: mode, child: Text(mode.label)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Generic error placeholder reused by every screen.
///
/// Following the architecture guide: Views only contain layout/presentation
/// logic — the decision to display this widget belongs to the screen, but the
/// "what does an error look like?" detail is centralized here.
class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    super.key,
    required this.message,
    this.detail,
    required this.onRetry,
  });

  final String message;
  final String? detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../domain/models/album.dart';
import '../../../utils/error_message.dart';
import '../../../utils/result.dart';
import '../../core/ui/default_app_bar.dart';
import '../view_models/create_album_step2_viewmodel.dart';

class CreateAlbumStep2Screen extends StatelessWidget {
  const CreateAlbumStep2Screen({super.key, required this.viewModel});

  final CreateAlbumStep2ViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final draft = viewModel.draft;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const DefaultAppBar(title: 'New album · Step 2 of 2'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Review and confirm:', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReadOnlyField(label: 'User ID', value: '${draft.userId}'),
                    const SizedBox(height: 12),
                    _ReadOnlyField(label: 'Title', value: draft.title),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: viewModel.create,
              builder: (context, _) {
                final running = viewModel.create.running;
                final result = viewModel.create.result;
                final hadError = viewModel.create.error;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      icon: running
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(running ? 'Creating…' : 'Confirm'),
                      onPressed: running ? null : () => _onSubmit(context),
                    ),
                    if (hadError && result is Error<Album>) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Failed: ${errorMessageFor(result.error)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context) async {
    await viewModel.create.execute();
    if (!context.mounted) return;

    if (viewModel.create.completed) {
      context.go(Routes.adminAlbums);
    }
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

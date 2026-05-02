import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../domain/models/album.dart';
import '../../../utils/error_message.dart';
import '../../../utils/result.dart';
import '../../core/ui/default_app_bar.dart';
import '../../core/ui/error_indicator.dart';
import '../view_models/edit_album_viewmodel.dart';

/// Edit screen — single page, PUT (replace) on save.
///
/// On mount, the ViewModel's `load` command fetches the album so the form
/// can start populated. On save, we await the `save` command (PUT) and only
/// navigate back on success.
class EditAlbumScreen extends StatefulWidget {
  const EditAlbumScreen({super.key, required this.viewModel});

  final EditAlbumViewModel viewModel;

  @override
  State<EditAlbumScreen> createState() => _EditAlbumScreenState();
}

class _EditAlbumScreenState extends State<EditAlbumScreen> {
  final _userIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load.addListener(_populateOnLoad);
  }

  @override
  void dispose() {
    widget.viewModel.load.removeListener(_populateOnLoad);
    _userIdController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// When the load command finishes, copy the fetched album into the text
  /// controllers — only once (subsequent re-loads shouldn't blow away the
  /// user's edits in progress).
  void _populateOnLoad() {
    if (_populated) return;
    final album = widget.viewModel.album;
    if (album == null) return;
    _userIdController.text = '${album.userId}';
    _titleController.text = album.title;
    _populated = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'Edit album'),
      body: ListenableBuilder(
        listenable: widget.viewModel.load,
        builder: (context, _) {
          if (widget.viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.load.error || widget.viewModel.album == null) {
            final result = widget.viewModel.load.result;
            final exception = result is Error<Album> ? result.error : null;
            return ErrorIndicator(
              message: 'Could not load this album.',
              detail: errorMessageFor(exception),
              onRetry: widget.viewModel.load.execute,
            );
          }
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _userIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null || n <= 0) return 'Enter a positive integer';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: widget.viewModel.save,
              builder: (context, _) {
                final running = widget.viewModel.save.running;
                final result = widget.viewModel.save.result;
                final hadError = widget.viewModel.save.error;

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
                          : const Icon(Icons.save),
                      label: Text(running ? 'Saving…' : 'Save'),
                      onPressed: running ? null : _onSubmit,
                    ),
                    if (hadError && result is Error<Album>) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Failed: ${errorMessageFor(result.error)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
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

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updated = Album(
      id: widget.viewModel.album!.id,
      userId: int.parse(_userIdController.text),
      title: _titleController.text.trim(),
    );

    await widget.viewModel.save.execute(updated);
    if (!mounted) return;

    if (widget.viewModel.save.completed) {
      context.go(Routes.adminAlbums);
    }
  }
}

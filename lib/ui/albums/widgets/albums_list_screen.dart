import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../domain/models/album.dart';
import '../../../utils/error_message.dart';
import '../../../utils/result.dart';
import '../../core/ui/default_app_bar.dart';
import '../../core/ui/error_indicator.dart';
import '../view_models/albums_list_viewmodel.dart';

class AlbumsListScreen extends StatelessWidget {
  const AlbumsListScreen({super.key, required this.viewModel});

  final AlbumsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'Albums'),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        onPressed: () => context.push(Routes.adminAlbumsCreate),
      ),
      body: ListenableBuilder(
        listenable: viewModel.load,
        builder: (context, _) {
          if (viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.load.error) {
            final result = viewModel.load.result;
            final exception = result is Error<List<Album>>
                ? result.error
                : null;
            return ErrorIndicator(
              message: 'Could not load albums.',
              detail: errorMessageFor(exception),
              onRetry: viewModel.load.execute,
            );
          }
          return ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final albums = viewModel.albums;
              return RefreshIndicator(
                onRefresh: viewModel.load.execute,
                child: ListView.separated(
                  itemCount: albums.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return ListTile(
                      title: Text(
                        album.title.isEmpty ? '(no title)' : album.title,
                      ),
                      subtitle: Text('user #${album.userId} · id ${album.id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                context.push(Routes.adminAlbumsEdit(album.id)),
                          ),
                          _DeleteButton(viewModel: viewModel, album: album),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.viewModel, required this.album});

  final AlbumsListViewModel viewModel;
  final Album album;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.delete,
      builder: (context, _) {
        final running = viewModel.delete.running;
        return IconButton(
          tooltip: 'Delete',
          icon: running
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline),
          onPressed: running ? null : () => _confirmAndDelete(context),
        );
      },
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete album #${album.id}?'),
        content: const Text(
          'This is fake — JSONPlaceholder will not really delete it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    await viewModel.delete.execute(album.id);
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../domain/models/post.dart';
import '../../../utils/error_message.dart';
import '../../../utils/result.dart';
import '../../core/ui/default_app_bar.dart';
import '../../core/ui/error_indicator.dart';
import '../view_models/posts_list_viewmodel.dart';

/// Posts list View.
///
/// Per the architecture guide, the View:
///   - receives a single [PostsListViewModel] via constructor injection,
///   - renders state read from the ViewModel,
///   - delegates user actions to ViewModel commands (no business logic here).
class PostsListScreen extends StatelessWidget {
  const PostsListScreen({super.key, required this.viewModel});

  final PostsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'Posts'),
      body: ListenableBuilder(
        listenable: viewModel.load,
        builder: (context, _) {
          if (viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.load.error) {
            final result = viewModel.load.result;
            final exception = result is Error<List<Post>> ? result.error : null;
            return ErrorIndicator(
              message: 'Could not load posts.',
              detail: errorMessageFor(exception),
              onRetry: viewModel.load.execute,
            );
          }
          return ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final posts = viewModel.posts;
              return RefreshIndicator(
                onRefresh: viewModel.load.execute,
                child: ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      title: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.postDetail(post.id)),
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

import 'package:flutter/material.dart';

import '../../../domain/models/comment.dart';
import '../../../domain/models/post.dart';
import '../../../utils/error_message.dart';
import '../../../utils/result.dart';
import '../../core/ui/default_app_bar.dart';
import '../../core/ui/error_indicator.dart';
import '../view_models/post_detail_viewmodel.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.viewModel});

  final PostDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'Post'),
      body: ListenableBuilder(
        listenable: viewModel.loadPost,
        builder: (context, _) {
          if (viewModel.loadPost.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.loadPost.error || viewModel.post == null) {
            final result = viewModel.loadPost.result;
            final exception = result is Error<Post> ? result.error : null;
            return ErrorIndicator(
              message: 'Could not load this post.',
              detail: errorMessageFor(exception),
              onRetry: viewModel.loadPost.execute,
            );
          }
          final post = viewModel.post!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'By user #${post.userId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 32),
              Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              Text('Comments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _CommentsSection(viewModel: viewModel),
            ],
          );
        },
      ),
    );
  }
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({required this.viewModel});

  final PostDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.loadComments,
      builder: (context, _) {
        if (viewModel.loadComments.running) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (viewModel.loadComments.error) {
          final result = viewModel.loadComments.result;
          final exception = result is Error<List<Comment>>
              ? result.error
              : null;
          return ErrorIndicator(
            message: 'Could not load comments.',
            detail: errorMessageFor(exception),
            onRetry: viewModel.loadComments.execute,
          );
        }
        final comments = viewModel.comments;
        if (comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No comments yet.'),
          );
        }
        return Column(
          children: [
            for (final comment in comments)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    comment.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(comment.body),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

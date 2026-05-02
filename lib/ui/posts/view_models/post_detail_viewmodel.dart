import 'package:flutter/foundation.dart';

import '../../../data/repositories/comments/comments_repository.dart';
import '../../../data/repositories/posts/posts_repository.dart';
import '../../../domain/models/comment.dart';
import '../../../domain/models/post.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel for the post detail screen.
///
/// Two independent commands run in parallel from the constructor:
///   - [loadPost] fetches the post itself,
///   - [loadComments] fetches its comments.
///
/// Splitting them lets the View show "post ready, comments still loading" —
/// a nicer perceived performance than waiting for both. Each command also
/// has its own error state, so a comments failure doesn't hide the post.
class PostDetailViewModel extends ChangeNotifier {
  PostDetailViewModel({
    required PostsRepository postsRepository,
    required CommentsRepository commentsRepository,
    required int postId,
  }) : _postsRepository = postsRepository,
       _commentsRepository = commentsRepository,
       _postId = postId {
    loadPost = Command0(_loadPost)..execute();
    loadComments = Command0(_loadComments)..execute();
  }

  final PostsRepository _postsRepository;
  final CommentsRepository _commentsRepository;
  final int _postId;

  Post? _post;
  Post? get post => _post;

  List<Comment> _comments = const [];
  List<Comment> get comments => _comments;

  late final Command0<Post> loadPost;
  late final Command0<List<Comment>> loadComments;

  Future<Result<Post>> _loadPost() async {
    final result = await _postsRepository.getPost(_postId);
    if (result is Ok<Post>) {
      _post = result.value;
    }
    notifyListeners();
    return result;
  }

  Future<Result<List<Comment>>> _loadComments() async {
    final result = await _commentsRepository.getCommentsForPost(_postId);
    if (result is Ok<List<Comment>>) {
      _comments = result.value;
    }
    notifyListeners();
    return result;
  }
}

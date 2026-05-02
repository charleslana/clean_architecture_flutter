import 'package:flutter/foundation.dart';

import '../../../data/repositories/posts/posts_repository.dart';
import '../../../domain/models/post.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel for the posts list screen.
///
/// Responsibilities (per the architecture guide):
///   1. Retrieve data from the repository.
///   2. Hold UI state (the list of [Post]s).
///   3. Expose [Command]s the View can call in response to user actions.
class PostsListViewModel extends ChangeNotifier {
  PostsListViewModel({required PostsRepository postsRepository})
    : _postsRepository = postsRepository {
    load = Command0(_load)..execute();
  }

  final PostsRepository _postsRepository;

  List<Post> _posts = const [];
  List<Post> get posts => _posts;

  late final Command0<List<Post>> load;

  Future<Result<List<Post>>> _load() async {
    final result = await _postsRepository.getPosts();
    switch (result) {
      case Ok<List<Post>>():
        _posts = result.value;
      case Error<List<Post>>():
        _posts = const [];
    }
    notifyListeners();
    return result;
  }
}

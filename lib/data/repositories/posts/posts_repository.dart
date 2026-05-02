import '../../../domain/models/post.dart';
import '../../../utils/result.dart';

/// Source of truth for [Post] data, exposed as an abstract class so the
/// implementation can be swapped (remote, local, fake) without touching the
/// ViewModels that depend on it.
abstract class PostsRepository {
  Future<Result<List<Post>>> getPosts();
  Future<Result<Post>> getPost(int id);
}

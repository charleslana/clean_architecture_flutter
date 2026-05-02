import '../../../domain/models/post.dart';
import '../../../utils/result.dart';

abstract class PostsRepository {
  Future<Result<List<Post>>> getPosts();
  Future<Result<Post>> getPost(int id);
}

import '../../../domain/models/comment.dart';
import '../../../utils/result.dart';

abstract class CommentsRepository {
  Future<Result<List<Comment>>> getCommentsForPost(int postId);
}

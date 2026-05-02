import '../../../domain/models/comment.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import 'comments_repository.dart';

class CommentsRepositoryRemote implements CommentsRepository {
  CommentsRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<Comment>>> getCommentsForPost(int postId) async {
    try {
      final dtos = await _apiClient.getCommentsForPost(postId);
      final comments = dtos
          .map((dto) => dto.toDomain())
          .toList(growable: false);
      return Result.ok(comments);
    } on Object catch (e) {
      return Result.error(e);
    }
  }
}

import '../../../domain/models/post.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import 'posts_repository.dart';

/// Remote implementation of [PostsRepository] that:
///   - delegates network calls to [ApiClient],
///   - converts API DTOs to domain models,
///   - converts thrown exceptions into [Result.error] so the UI never has to
///     deal with `try/catch`.
class PostsRepositoryRemote implements PostsRepository {
  PostsRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<Post>>> getPosts() async {
    try {
      final dtos = await _apiClient.getPosts();
      final posts = dtos.map((dto) => dto.toDomain()).toList(growable: false);
      return Result.ok(posts);
    } on Object catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Post>> getPost(int id) async {
    try {
      final dto = await _apiClient.getPost(id);
      return Result.ok(dto.toDomain());
    } on Object catch (e) {
      return Result.error(e);
    }
  }
}

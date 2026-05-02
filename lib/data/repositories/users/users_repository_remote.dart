import '../../../domain/models/user.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import 'users_repository.dart';

class UsersRepositoryRemote implements UsersRepository {
  UsersRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<User>>> getUsers() async {
    try {
      final dtos = await _apiClient.getUsers();
      final users = dtos.map((dto) => dto.toDomain()).toList(growable: false);
      return Result.ok(users);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> getUser(int id) async {
    try {
      final dto = await _apiClient.getUser(id);
      return Result.ok(dto.toDomain());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}

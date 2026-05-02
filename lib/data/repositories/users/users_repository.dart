import '../../../domain/models/user.dart';
import '../../../utils/result.dart';

abstract class UsersRepository {
  Future<Result<List<User>>> getUsers();
  Future<Result<User>> getUser(int id);
}

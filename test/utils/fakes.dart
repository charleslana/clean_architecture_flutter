import 'package:clean_architecture_flutter/data/repositories/auth/auth_repository.dart';
import 'package:clean_architecture_flutter/data/repositories/comments/comments_repository.dart';
import 'package:clean_architecture_flutter/data/repositories/posts/posts_repository.dart';
import 'package:clean_architecture_flutter/data/repositories/users/users_repository.dart';
import 'package:clean_architecture_flutter/data/services/http/http_service.dart';
import 'package:clean_architecture_flutter/domain/models/comment.dart';
import 'package:clean_architecture_flutter/domain/models/post.dart';
import 'package:clean_architecture_flutter/domain/models/user.dart';
import 'package:clean_architecture_flutter/utils/result.dart';

const Post fakePost1 = Post(
  id: 1,
  userId: 10,
  title: 'first',
  body: 'body of first',
);

const Post fakePost2 = Post(
  id: 2,
  userId: 10,
  title: 'second',
  body: 'body of second',
);

const User fakeUser1 = User(
  id: 1,
  name: 'Alice',
  username: 'alice',
  email: 'alice@example.com',
  phone: '111',
  website: 'alice.example.com',
  company: (name: 'Acme', catchPhrase: 'just do it'),
  address: (city: 'Paris', street: 'Rue', suite: '1A'),
);

const User fakeUser2 = User(
  id: 2,
  name: 'Bob',
  username: 'bob',
  email: 'bob@example.com',
  phone: '222',
  website: 'bob.example.com',
  company: (name: 'Globex', catchPhrase: 'innovate'),
  address: (city: 'Berlin', street: 'Strasse', suite: '2B'),
);

const Comment fakeComment1 = Comment(
  id: 1,
  postId: 1,
  name: 'first comment',
  email: 'a@x.com',
  body: 'body of first comment',
);

const Comment fakeComment2 = Comment(
  id: 2,
  postId: 1,
  name: 'second comment',
  email: 'b@x.com',
  body: 'body of second comment',
);

class FakePostsRepository implements PostsRepository {
  FakePostsRepository({
    this.posts = const [fakePost1, fakePost2],
    this.fail = false,
  });

  final List<Post> posts;
  bool fail;

  int getPostsCalls = 0;
  int getPostCalls = 0;

  @override
  Future<Result<List<Post>>> getPosts() async {
    getPostsCalls++;
    if (fail) return Result.error(Exception('boom'));
    return Result.ok(posts);
  }

  @override
  Future<Result<Post>> getPost(int id) async {
    getPostCalls++;
    if (fail) return Result.error(Exception('boom'));
    final match = posts.where((p) => p.id == id);
    if (match.isEmpty) return Result.error(Exception('not found'));
    return Result.ok(match.first);
  }
}

class FakeUsersRepository implements UsersRepository {
  FakeUsersRepository({
    this.users = const [fakeUser1, fakeUser2],
    this.fail = false,
  });

  final List<User> users;
  bool fail;

  int getUsersCalls = 0;

  @override
  Future<Result<List<User>>> getUsers() async {
    getUsersCalls++;
    if (fail) return Result.error(Exception('boom'));
    return Result.ok(users);
  }

  @override
  Future<Result<User>> getUser(int id) async {
    if (fail) return Result.error(Exception('boom'));
    final match = users.where((u) => u.id == id);
    if (match.isEmpty) return Result.error(Exception('not found'));
    return Result.ok(match.first);
  }
}

class FakeCommentsRepository implements CommentsRepository {
  FakeCommentsRepository({
    this.comments = const [fakeComment1, fakeComment2],
    this.fail = false,
  });

  final List<Comment> comments;
  bool fail;

  int getCommentsForPostCalls = 0;

  @override
  Future<Result<List<Comment>>> getCommentsForPost(int postId) async {
    getCommentsForPostCalls++;
    if (fail) return Result.error(Exception('boom'));
    return Result.ok(
      comments.where((c) => c.postId == postId).toList(growable: false),
    );
  }
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({
    bool isAuthenticated = false,
    String? username,
    this.acceptedUsername = 'admin',
    this.acceptedPassword = 'admin',
  }) : _isAuthenticated = isAuthenticated,
       _username = username;

  final String acceptedUsername;
  final String acceptedPassword;

  bool _isAuthenticated;
  String? _username;

  int loginCalls = 0;
  int logoutCalls = 0;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  String? get username => _username;

  @override
  Future<Result<void>> login({
    required String username,
    required String password,
  }) async {
    loginCalls++;
    if (username == acceptedUsername && password == acceptedPassword) {
      _isAuthenticated = true;
      _username = username;
      notifyListeners();
      return const Result.ok(null);
    }
    return const Result<void>.error(InvalidCredentialsException());
  }

  @override
  void logout() {
    logoutCalls++;
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    _username = null;
    notifyListeners();
  }
}

class FakeHttpService implements HttpService {
  FakeHttpService({required this.onGet});

  final Future<HttpResponse> Function(Uri url) onGet;

  @override
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers}) =>
      onGet(url);

  @override
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => throw UnimplementedError('FakeHttpService.post not used in tests');

  @override
  Future<HttpResponse> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => throw UnimplementedError('FakeHttpService.put not used in tests');

  @override
  Future<HttpResponse> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => throw UnimplementedError('FakeHttpService.patch not used in tests');

  @override
  Future<HttpResponse> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => throw UnimplementedError('FakeHttpService.delete not used in tests');

  @override
  void close() {}
}

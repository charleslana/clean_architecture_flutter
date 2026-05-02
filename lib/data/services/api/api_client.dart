import 'dart:convert';

import '../http/http_service.dart';
import 'model/comment_api_model.dart';
import 'model/post_api_model.dart';
import 'model/user_api_model.dart';

/// Stateless service that wraps the JSONPlaceholder REST API.
///
/// Talks to the network through [HttpService] (not `package:http` directly),
/// so swapping HTTP libraries is a single-file change.
class ApiClient {
  ApiClient({required HttpService httpService, Uri? baseUrl})
    : _http = httpService,
      _baseUrl = baseUrl ?? Uri.parse('https://jsonplaceholder.typicode.com');

  final HttpService _http;
  final Uri _baseUrl;

  Future<List<PostApiModel>> getPosts() async {
    final response = await _http.get(_baseUrl.resolve('/posts'));
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to load posts');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((dynamic e) => PostApiModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<PostApiModel> getPost(int id) async {
    final response = await _http.get(_baseUrl.resolve('/posts/$id'));
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to load post $id');
    }
    return PostApiModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<UserApiModel>> getUsers() async {
    final response = await _http.get(_baseUrl.resolve('/users'));
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to load users');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((dynamic e) => UserApiModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<UserApiModel> getUser(int id) async {
    final response = await _http.get(_baseUrl.resolve('/users/$id'));
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to load user $id');
    }
    return UserApiModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<CommentApiModel>> getCommentsForPost(int postId) async {
    final response = await _http.get(
      _baseUrl.resolve('/posts/$postId/comments'),
    );
    if (!response.isSuccessful) {
      throw HttpException(
        response.statusCode,
        'Failed to load comments for post $postId',
      );
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((dynamic e) => CommentApiModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}

class HttpException implements Exception {
  const HttpException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'HttpException($statusCode): $message';
}

import 'dart:convert';

import '../http/http_service.dart';
import 'model/album_api_model.dart';
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

  // ── Albums ───────────────────────────────────────────────────────────────
  // Note: JSONPlaceholder's POST/PATCH/PUT/DELETE are *fake* — the server
  // returns realistic responses but nothing is persisted. Useful to exercise
  // the full HTTP surface (`HttpService.post/put/patch/delete`).

  Future<List<AlbumApiModel>> getAlbums() async {
    final response = await _http.get(_baseUrl.resolve('/albums'));
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to load albums');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((dynamic e) => AlbumApiModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<AlbumApiModel> getAlbum(int id) async {
    final response = await _http.get(_baseUrl.resolve('/albums/$id'));
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to load album $id');
    }
    return AlbumApiModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AlbumApiModel> createAlbum({
    required int userId,
    String? title,
  }) async {
    final body = <String, Object>{'userId': userId};
    if (title != null) body['title'] = title;
    final response = await _http.post(_baseUrl.resolve('/albums'), body: body);
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to create album');
    }
    return AlbumApiModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AlbumApiModel> patchAlbum(int id, {int? userId, String? title}) async {
    final body = <String, Object>{};
    if (userId != null) body['userId'] = userId;
    if (title != null) body['title'] = title;
    final response = await _http.patch(
      _baseUrl.resolve('/albums/$id'),
      body: body,
    );
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to patch album $id');
    }
    return AlbumApiModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AlbumApiModel> replaceAlbum({
    required int id,
    required int userId,
    required String title,
  }) async {
    final body = <String, Object>{'id': id, 'userId': userId, 'title': title};
    final response = await _http.put(
      _baseUrl.resolve('/albums/$id'),
      body: body,
    );
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to replace album $id');
    }
    return AlbumApiModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteAlbum(int id) async {
    final response = await _http.delete(_baseUrl.resolve('/albums/$id'));
    if (!response.isSuccessful) {
      throw HttpException(response.statusCode, 'Failed to delete album $id');
    }
  }
}

class HttpException implements Exception {
  const HttpException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'HttpException($statusCode): $message';
}

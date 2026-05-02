import '../../../domain/models/album.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import 'albums_repository.dart';

class AlbumsRepositoryRemote implements AlbumsRepository {
  AlbumsRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<Album>>> getAlbums() async {
    try {
      final dtos = await _apiClient.getAlbums();
      final albums = dtos.map((dto) => dto.toDomain()).toList(growable: false);
      return Result.ok(albums);
    } on Object catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Album>> getAlbum(int id) async {
    try {
      final dto = await _apiClient.getAlbum(id);
      return Result.ok(dto.toDomain());
    } on Object catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Album>> createAlbum({
    required int userId,
    String? title,
  }) async {
    try {
      final dto = await _apiClient.createAlbum(userId: userId, title: title);
      return Result.ok(dto.toDomain());
    } on Object catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Album>> patchAlbum(int id, {int? userId, String? title}) async {
    try {
      final dto = await _apiClient.patchAlbum(id, userId: userId, title: title);
      return Result.ok(dto.toDomain());
    } on Object catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Album>> replaceAlbum(Album album) async {
    try {
      final dto = await _apiClient.replaceAlbum(
        id: album.id,
        userId: album.userId,
        title: album.title,
      );
      return Result.ok(dto.toDomain());
    } on Object catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteAlbum(int id) async {
    try {
      await _apiClient.deleteAlbum(id);
      return const Result.ok(null);
    } on Object catch (e) {
      return Result.error(e);
    }
  }
}

import '../../../domain/models/album.dart';
import '../../../utils/result.dart';

abstract class AlbumsRepository {
  Future<Result<List<Album>>> getAlbums();
  Future<Result<Album>> getAlbum(int id);

  Future<Result<Album>> createAlbum({required int userId, String? title});

  Future<Result<Album>> patchAlbum(int id, {int? userId, String? title});

  Future<Result<Album>> replaceAlbum(Album album);

  Future<Result<void>> deleteAlbum(int id);
}

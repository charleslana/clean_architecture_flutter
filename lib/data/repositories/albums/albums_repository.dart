import '../../../domain/models/album.dart';
import '../../../utils/result.dart';

abstract class AlbumsRepository {
  Future<Result<List<Album>>> getAlbums();
  Future<Result<Album>> getAlbum(int id);

  /// Step 1 of the create flow — only `userId` is required. Returns the
  /// freshly-created [Album] (which carries the new `id` the next step needs).
  Future<Result<Album>> createAlbum({required int userId, String? title});

  /// Step 2 of the create flow — patches the title on top of what step 1
  /// produced.
  Future<Result<Album>> patchAlbum(int id, {int? userId, String? title});

  /// Edit screen — replaces the whole album in one shot (PUT).
  Future<Result<Album>> replaceAlbum(Album album);

  Future<Result<void>> deleteAlbum(int id);
}

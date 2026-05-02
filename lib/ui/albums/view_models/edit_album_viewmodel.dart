import 'package:flutter/foundation.dart';

import '../../../data/repositories/albums/albums_repository.dart';
import '../../../domain/models/album.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel for the single-screen edit flow (PUT — full replace).
///
/// Two commands:
///   - [load] — fetches the album by id so the form starts populated.
///   - [save] — replaces the album with whatever the user typed (PUT).
class EditAlbumViewModel extends ChangeNotifier {
  EditAlbumViewModel({
    required AlbumsRepository albumsRepository,
    required int albumId,
  }) : _albumsRepository = albumsRepository,
       _albumId = albumId {
    load = Command0(_load)..execute();
    save = Command1(_save);
  }

  final AlbumsRepository _albumsRepository;
  final int _albumId;

  Album? _album;
  Album? get album => _album;

  late final Command0<Album> load;
  late final Command1<Album, Album> save;

  Future<Result<Album>> _load() async {
    final result = await _albumsRepository.getAlbum(_albumId);
    if (result is Ok<Album>) {
      _album = result.value;
    }
    notifyListeners();
    return result;
  }

  Future<Result<Album>> _save(Album album) async {
    return _albumsRepository.replaceAlbum(album);
  }
}

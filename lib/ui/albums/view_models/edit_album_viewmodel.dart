import 'package:flutter/foundation.dart';

import '../../../data/repositories/albums/albums_repository.dart';
import '../../../domain/models/album.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

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

  @override
  void dispose() {
    load.dispose();
    save.dispose();
    super.dispose();
  }
}

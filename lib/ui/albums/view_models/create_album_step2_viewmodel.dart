import 'package:flutter/foundation.dart';

import '../../../data/repositories/albums/albums_repository.dart';
import '../../../domain/models/album.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../album_draft.dart';

class CreateAlbumStep2ViewModel extends ChangeNotifier {
  CreateAlbumStep2ViewModel({
    required AlbumsRepository albumsRepository,
    required AlbumDraft draft,
  }) : _albumsRepository = albumsRepository,
       _draft = draft {
    create = Command0(_create);
  }

  final AlbumsRepository _albumsRepository;
  final AlbumDraft _draft;

  AlbumDraft get draft => _draft;

  late final Command0<Album> create;

  Future<Result<Album>> _create() async {
    return _albumsRepository.createAlbum(
      userId: _draft.userId,
      title: _draft.title,
    );
  }

  @override
  void dispose() {
    create.dispose();
    super.dispose();
  }
}

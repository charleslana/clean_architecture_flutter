import 'package:flutter/foundation.dart';

import '../../../data/repositories/albums/albums_repository.dart';
import '../../../domain/models/album.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../album_draft.dart';

/// ViewModel for **step 2** of the create flow (the confirmation screen).
///
/// Receives the [AlbumDraft] collected by step 1 (passed in via `extra`) and
/// owns the `create` [Command0] that POSTs to `/albums` when the user
/// confirms. The screen "waits the response" right here: it `await`s the
/// command, then navigates to the albums list **only on success**.
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
}

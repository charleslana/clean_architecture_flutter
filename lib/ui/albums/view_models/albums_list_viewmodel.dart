import 'package:flutter/foundation.dart';

import '../../../data/repositories/albums/albums_repository.dart';
import '../../../domain/models/album.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class AlbumsListViewModel extends ChangeNotifier {
  AlbumsListViewModel({required AlbumsRepository albumsRepository})
    : _albumsRepository = albumsRepository {
    load = Command0(_load)..execute();
    delete = Command1(_delete);
  }

  final AlbumsRepository _albumsRepository;

  List<Album> _albums = const [];
  List<Album> get albums => _albums;

  late final Command0<List<Album>> load;
  late final Command1<void, int> delete;

  Future<Result<List<Album>>> _load() async {
    final result = await _albumsRepository.getAlbums();
    if (result is Ok<List<Album>>) {
      _albums = result.value;
    } else {
      _albums = const [];
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _delete(int id) async {
    final result = await _albumsRepository.deleteAlbum(id);
    if (result is Ok<void>) {
      await load.execute();
    }
    return result;
  }

  @override
  void dispose() {
    load.dispose();
    delete.dispose();
    super.dispose();
  }
}

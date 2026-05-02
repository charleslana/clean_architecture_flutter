import 'package:flutter/foundation.dart';

@immutable
class AlbumDraft {
  const AlbumDraft({required this.userId, required this.title});

  final int userId;
  final String title;
}

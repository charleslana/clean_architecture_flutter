import 'package:flutter/foundation.dart';

/// Carries the form values from step 1 (form) to step 2 (confirmation) of
/// the album-create flow.
///
/// Passed through `go_router`'s `extra` (in-memory, **not** part of the URL).
/// Note: `extra` is lost if the user refreshes the page on web or kills the
/// app — so it's perfect for short-lived flows like this one, but never the
/// place to put state you'd need to recover.
@immutable
class AlbumDraft {
  const AlbumDraft({required this.userId, required this.title});

  final int userId;
  final String title;
}

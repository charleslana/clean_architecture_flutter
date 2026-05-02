import 'package:flutter/foundation.dart';

/// Domain model that represents a Post in the UI/business layers.
///
/// Domain models are written by hand here to keep the sample free of code
/// generation. In a real app, prefer `freezed` or `built_value` as recommended
/// by the Flutter architecture guide.
@immutable
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          other.id == id &&
          other.userId == userId &&
          other.title == title &&
          other.body == body;

  @override
  int get hashCode => Object.hash(id, userId, title, body);
}

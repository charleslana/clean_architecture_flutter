import 'package:flutter/foundation.dart';

@immutable
class Album {
  const Album({required this.id, required this.userId, required this.title});

  final int id;
  final int userId;
  final String title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          other.id == id &&
          other.userId == userId &&
          other.title == title;

  @override
  int get hashCode => Object.hash(id, userId, title);
}

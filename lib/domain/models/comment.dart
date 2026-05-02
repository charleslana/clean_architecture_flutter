import 'package:flutter/foundation.dart';

@immutable
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          other.id == id &&
          other.postId == postId &&
          other.name == name &&
          other.email == email &&
          other.body == body;

  @override
  int get hashCode => Object.hash(id, postId, name, email, body);
}

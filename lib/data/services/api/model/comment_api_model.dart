import '../../../../domain/models/comment.dart';

class CommentApiModel {
  const CommentApiModel({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory CommentApiModel.fromJson(Map<String, dynamic> json) =>
      CommentApiModel(
        id: json['id'] as int,
        postId: json['postId'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        body: json['body'] as String,
      );

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Comment toDomain() =>
      Comment(id: id, postId: postId, name: name, email: email, body: body);
}

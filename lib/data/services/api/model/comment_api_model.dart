import '../../../../domain/models/comment.dart';
import '../json_field.dart';

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
        id: jsonRequired<int>(json, 'id'),
        postId: jsonRequired<int>(json, 'postId'),
        name: jsonRequired<String>(json, 'name'),
        email: jsonRequired<String>(json, 'email'),
        body: jsonRequired<String>(json, 'body'),
      );

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Comment toDomain() =>
      Comment(id: id, postId: postId, name: name, email: email, body: body);
}

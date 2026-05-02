import '../../../../domain/models/post.dart';

/// API model that maps directly to the JSON shape returned by the
/// JSONPlaceholder `/posts` endpoint.
///
/// The architecture guide recommends keeping the API model separate from the
/// domain model so that backend changes do not leak into the UI/business code.
class PostApiModel {
  const PostApiModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory PostApiModel.fromJson(Map<String, dynamic> json) => PostApiModel(
    id: json['id'] as int,
    userId: json['userId'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
  );

  final int id;
  final int userId;
  final String title;
  final String body;

  Post toDomain() => Post(id: id, userId: userId, title: title, body: body);
}

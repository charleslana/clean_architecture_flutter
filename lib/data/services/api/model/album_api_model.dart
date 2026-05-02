import '../../../../domain/models/album.dart';
import '../json_field.dart';

class AlbumApiModel {
  const AlbumApiModel({
    required this.id,
    required this.userId,
    required this.title,
  });

  factory AlbumApiModel.fromJson(Map<String, dynamic> json) => AlbumApiModel(
    id: jsonRequired<int>(json, 'id'),
    userId: jsonRequired<int>(json, 'userId'),
    // The fake API may return the album right after a POST without a
    // title (since step 1 of the create flow only sends `userId`).
    title: jsonOptional<String>(json, 'title') ?? '',
  );

  final int id;
  final int userId;
  final String title;

  Album toDomain() => Album(id: id, userId: userId, title: title);
}

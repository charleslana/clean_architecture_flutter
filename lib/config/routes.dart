abstract final class Routes {
  static const String home = '/';
  static const String posts = '/posts';
  static const String users = '/users';
  static String postDetail(int id) => '/posts/$id';
  static const String postDetailPattern = '/posts/:id';

  static const String login = '/login';

  static const String adminHome = '/admin';
  static const String adminAlbums = '/admin/albums';
  static const String adminAlbumsCreate = '/admin/albums/new';

  static const String adminAlbumsCreateStep2 = '/admin/albums/new/step2';
  static String adminAlbumsEdit(int id) => '/admin/albums/$id/edit';
  static const String adminAlbumsEditPattern = '/admin/albums/:id/edit';
}

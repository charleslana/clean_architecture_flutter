/// Single source of truth for the route paths used across the app.
abstract final class Routes {
  static const String home = '/';
  static const String posts = '/posts';
  static const String users = '/users';
  static String postDetail(int id) => '/posts/$id';
  static const String postDetailPattern = '/posts/:id';

  // Auth (mock)
  static const String login = '/login';

  // Admin — albums CRUD (gated by the auth redirect)
  static const String adminHome = '/admin';
  static const String adminAlbums = '/admin/albums';
  static const String adminAlbumsCreate = '/admin/albums/new';
  // Step 2 doesn't carry an id — the form data is passed in-memory through
  // go_router's `extra`, so the URL is fixed.
  static const String adminAlbumsCreateStep2 = '/admin/albums/new/step2';
  static String adminAlbumsEdit(int id) => '/admin/albums/$id/edit';
  static const String adminAlbumsEditPattern = '/admin/albums/:id/edit';
}

/// Single source of truth for the route paths used across the app.
abstract final class Routes {
  static const String home = '/';
  static const String posts = '/posts';
  static const String users = '/users';
  static String postDetail(int id) => '/posts/$id';
  static const String postDetailPattern = '/posts/:id';
}

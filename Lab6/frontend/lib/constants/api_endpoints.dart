class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:5000/api';
  // Nếu chạy Chrome thì đổi thành "http://localhost:5000/api".

  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  static const String profile = '/Auth/profile';
  static const String users = '/Users';
  static String userById(int id) => '/Users/$id';
  static String activateUser(int id) => '/Users/$id/activate';
  static const String currentUser = '/Users/me';
  static const String changePassword = '/Users/me/change-password';
}

import 'package:shared_preferences/shared_preferences.dart';

// Phiên đăng nhập hiện tại: token JWT và thông tin người dùng, được lưu lại để mở app không phải đăng nhập lại
class Session {
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _fullNameKey = 'auth_full_name';

  static String? token;
  static String? username;
  static String? fullName;

  static bool get isLoggedIn => token != null;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    username = prefs.getString(_usernameKey);
    fullName = prefs.getString(_fullNameKey);
  }

  static Future<void> save({
    required String newToken,
    required String newUsername,
    required String newFullName,
  }) async {
    token = newToken;
    username = newUsername;
    fullName = newFullName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    await prefs.setString(_usernameKey, newUsername);
    await prefs.setString(_fullNameKey, newFullName);
  }

  static Future<void> clear() async {
    token = null;
    username = null;
    fullName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_fullNameKey);
  }
}

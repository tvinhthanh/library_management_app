import 'dart:convert';

import 'package:frontend_library/core/api/api_client.dart';
import 'package:frontend_library/core/auth/session.dart';

class AuthResult {
  final bool ok;
  final String message;

  const AuthResult(this.ok, this.message);
}

class AuthService {
  static Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await ApiClient.post(
        authUri('register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "fullName": fullName,
        }),
      );
      return _handleAuthResponse(response.statusCode, response.body, 'Đăng ký thất bại.');
    } catch (_) {
      return const AuthResult(false, 'Không kết nối được tới máy chủ.');
    }
  }

  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        authUri('login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      return _handleAuthResponse(response.statusCode, response.body, 'Đăng nhập thất bại.');
    } catch (_) {
      return const AuthResult(false, 'Không kết nối được tới máy chủ.');
    }
  }

  // Khi mở app: nếu có token đã lưu thì hỏi server xem còn hợp lệ không
  static Future<bool> restoreSession() async {
    if (!Session.isLoggedIn) return false;

    try {
      final response = await ApiClient.get(authUri('me'));
      if (response.statusCode == 200) return true;
      if (response.statusCode == 401) await Session.clear();
      return false;
    } catch (_) {
      // Lỗi mạng: giữ token để lần sau thử lại, nhưng chưa vào được app lúc này
      return false;
    }
  }

  static Future<void> logout() => Session.clear();

  static Future<AuthResult> _handleAuthResponse(
    int statusCode,
    String body,
    String fallbackMessage,
  ) async {
    final data = _tryDecode(body);

    if (statusCode == 200 || statusCode == 201) {
      await Session.save(
        newToken: data['token'] as String,
        newUsername: data['username'] as String,
        newFullName: data['fullName'] as String,
      );
      return const AuthResult(true, '');
    }

    return AuthResult(false, (data['message'] as String?) ?? fallbackMessage);
  }

  static Map<String, dynamic> _tryDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  }
}

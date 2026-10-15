import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_library/core/api/constants.dart';
import 'package:frontend_library/core/auth/session.dart';

// Dùng để đưa người dùng về màn đăng nhập khi token hết hạn hoặc không hợp lệ
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// Bọc các lệnh gọi http: tự gắn Authorization: Bearer <token> và xử lý 401 ở một chỗ duy nhất
class ApiClient {
  static Future<http.Response> get(Uri uri, {Map<String, String>? headers}) =>
      _send('GET', uri, headers: headers);

  static Future<http.Response> post(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _send('POST', uri, headers: headers, body: body);

  static Future<http.Response> put(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _send('PUT', uri, headers: headers, body: body);

  static Future<http.Response> delete(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _send('DELETE', uri, headers: headers, body: body);

  static Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final allHeaders = <String, String>{...?headers};
    if (Session.token != null) {
      allHeaders['Authorization'] = 'Bearer ${Session.token}';
    }

    final http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: allHeaders);
        break;
      case 'POST':
        response = await http.post(uri, headers: allHeaders, body: body);
        break;
      case 'PUT':
        response = await http.put(uri, headers: allHeaders, body: body);
        break;
      default:
        response = await http.delete(uri, headers: allHeaders, body: body);
    }

    // Token hết hạn hoặc bị thu hồi: xoá phiên và quay về đăng nhập (trừ chính các API auth)
    final isAuthEndpoint = uri.path.contains('/auth/');
    if (response.statusCode == 401 && !isAuthEndpoint && Session.isLoggedIn) {
      await Session.clear();
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    }

    return response;
  }
}

// Địa chỉ API dùng chung cho màn đăng nhập/đăng ký
Uri authUri(String path) => Uri.parse('$apiBaseUrl/auth/$path');

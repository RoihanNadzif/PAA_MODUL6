import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modul7/config/api_config.dart';
import 'package:modul7/models/user_model.dart';

class AuthService {
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    if (role != null) {
      await prefs.setString('role', role);
    }
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final user = UserModel.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      // Simpan token
      await saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        role: user.role,
      );

      return {
        'user': user,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw Exception(body['message'] ?? 'Login gagal');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.authPrefix}/register',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 201) {
      final data = body['data'];
      final user = UserModel.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      // Simpan token
      await saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        role: user.role,
      );

      return {
        'user': user,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw Exception(body['message'] ?? 'Registrasi gagal');
    }
  }

  static Future<void> logout() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.authPrefix}/logout',
      );
      final headers = await _authHeaders();
      await http.post(url, headers: headers);
    } catch (e) {
      print("error logout : $e");
    }
    await clearTokens();
  }
}

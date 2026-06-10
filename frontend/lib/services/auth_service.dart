import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:8080';
  static String? token;

  static Future<bool> login(String usuario, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario': usuario, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Map<String, String> get headersAuth => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get headersPublic => {
    'Content-Type': 'application/json',
  };
}
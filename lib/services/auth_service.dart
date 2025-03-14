import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String email,
    required String email2,
    required String password,
    required String password2,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "email": email,
        "email_confirmation": email2,
        "password": password,
        "password_confirmation": password2,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "message": responseBody["message"]};
    } else if (response.statusCode == 422) {
      return {
        "success": false,
        "errors": responseBody["errors"],
        "error_fields": responseBody["error_fields"]
      };
    } else {
      return {"success": false, "message": "Error en el servidor"};
    }
  }

  static loginUser(String email, String password) {

  }
}

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String email,
    required String email2,
    required String password,
    required String password2,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
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
        return {
          "success": true,
          "message": responseBody["message"] ?? "Registro exitoso",
        };
      }
      if (response.statusCode == 422) {
        return {
          "success": false,
          "errors": responseBody["errors"] ?? {},
          "error_fields": responseBody["error_fields"] ?? []
        };
      }
      return {
        "success": false,
        "message": responseBody["message"] ?? "Error desconocido en el servidor"
      };
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: "remember_token", value: responseBody["token"]);
        await _storage.write(key: "user", value: jsonEncode(responseBody["user"]));

        return {"success": true, "user": responseBody["user"], "message": responseBody["message"]};
      } else if (response.statusCode == 422) {
        return {
          "success": false,
          "errors": responseBody["errors"],
          "error_fields": responseBody["error_fields"],
        };
      } else {
        return {"success": false, "message": responseBody["message"] ?? "Error en el servidor"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }


  static Future<Map<String, dynamic>> checkToken() async {
    String? token = await _storage.read(key: "remember_token");

    if (token == null) {
      return {"success": false, "message": "No hay token guardado"};
    }

    final url = Uri.parse('$baseUrl/checkToken');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({"token": token}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "user": responseBody["user"]};
    } else {
      await logout();
      return {"success": false, "message": responseBody["message"]};
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: "remember_token");
    await _storage.delete(key: "user");
  }
}

import 'package:greenroof_app/models/login_result.dart';
import 'package:greenroof_app/models/usuario.dart';
import 'package:greenroof_app/services/token_docodificador.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';

  static Future<void> _saveTokenAndRole(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    final role = TokenDecoder.decodeToken(token).role;
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<Usuario?> getUsuarioFromToken() async {
    final token = await getToken();
    return token != null ? TokenDecoder.decodeToken(token) : null;
  }

  static Future<LoginResult> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse(
          'https://greenroofapi-production.up.railway.app/api/Usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final token = jsonResponse['token'];
      await _saveTokenAndRole(token);
      var usuario = await getUsuarioFromToken();

      return LoginResult(sucesso: true, usuario: usuario);
    } else {
      return LoginResult(sucesso: false);
    }
  }

  static Future<bool> trocarSenha({
    required String email,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(
          'https://greenroofapi-production.up.railway.app/api/Usuarios/trocar-senha'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'email': email,
        'senhaAtual': senhaAtual,
        'novaSenha': novaSenha,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }
}

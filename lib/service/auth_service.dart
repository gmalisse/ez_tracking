import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class IAuthService {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<Map<String, dynamic>> register(
    String name,
    String surname,
    String login,
    String email,
    String password,
  );
}

class AuthService implements IAuthService {
  final String loginUrl =
      "https://mobile-ios-login.zani0x03.eti.br/api/auth/login";
  final String registerUrl =
      "https://mobile-ios-login.zani0x03.eti.br/api/register";

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
          "sistemaId": "f1f78c83-e114-462b-b7e3-ac38bbb9eddc",
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Falha no login: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String surname,
    String login,
    String email,
    String password,
  ) async {
    try {
      final body = {
        "name": name,
        "surname": surname,
        "login": login,
        "email": email,
        "password": password,
        "sistemaId": "f1f78c83-e114-462b-b7e3-ac38bbb9eddc",
      };

      print("DEBUG - Enviando para registro: $body");

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("DEBUG - Status code: ${response.statusCode}");
      print("DEBUG - Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tenta decodificar como JSON
        try {
          return jsonDecode(response.body);
        } catch (e) {
          // Se falhar, retorna um objeto simples indicando sucesso
          print("DEBUG - Resposta não é JSON válido, retornando sucesso");
          return {
            "success": true,
            "message": response.body,
            "name": name,
            "email": email,
          };
        }
      } else {
        final errorBody = response.body;
        throw Exception(
          "Falha no registro: ${response.statusCode}\n$errorBody",
        );
      }
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }
}

// --- IMPLEMENTAÇÃO MOCK ---
class AuthServiceMock implements IAuthService {
  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Simula um atraso de rede de 1 segundo
    await Future.delayed(const Duration(seconds: 1));

    if (username == "admin" && password == "admin") {
      return {
        "access_token":
            "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lk...", // seu token aqui
        "expires_in": 299,
        "refresh_expires_in": 1799,
        "refresh_token": "eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiw...",
        "token_type": "Bearer",
        "session_state": "7da70210-f7c6-49fa-87ca-cfe03f78d885",
        "scope": "profile email",
      };
    } else {
      throw Exception("Usuário ou senha inválidos (Mock)");
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String surname,
    String login,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "id": 1,
      "name": name,
      "surname": surname,
      "login": login,
      "email": email,
    };
  }
}

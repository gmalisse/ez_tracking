import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gameplay.dart';
import 'auth_storage.dart';

class GameplayService {
  final String baseUrl =
      "https://mobile-ios-login.zani0x03.eti.br/api/gameplay";

  /// Criar uma nova gameplay (sincroniza com API)
  Future<Map<String, dynamic>> create(Gameplay gameplay) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        throw Exception("Usuário não autenticado");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'usersId': gameplay.usersId,
          'jogosId': gameplay.jogosId,
          'horasJogadas': gameplay.horasJogadas,
          'dataInicio': gameplay.dataInicio.toIso8601String(),
          'dataFim': gameplay.dataFim?.toIso8601String(),
          'zerado': gameplay.zerado,
          'console': gameplay.console,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Erro ao criar gameplay: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao criar gameplay: $e");
    }
  }

  /// Buscar gameplays do usuário autenticado
  Future<List<Map<String, dynamic>>> getByCurrentUser() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        throw Exception("Usuário não autenticado");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Erro ao buscar gameplays: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro ao buscar gameplays: $e");
    }
  }

  /// Atualizar uma gameplay
  Future<Map<String, dynamic>> update(Gameplay gameplay) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        throw Exception("Usuário não autenticado");
      }

      final response = await http.put(
        Uri.parse('$baseUrl/${gameplay.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'usersId': gameplay.usersId,
          'jogosId': gameplay.jogosId,
          'horasJogadas': gameplay.horasJogadas,
          'dataInicio': gameplay.dataInicio.toIso8601String(),
          'dataFim': gameplay.dataFim?.toIso8601String(),
          'zerado': gameplay.zerado,
          'console': gameplay.console,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Erro ao atualizar gameplay: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro ao atualizar gameplay: $e");
    }
  }

  /// Deletar uma gameplay
  Future<void> delete(int id) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        throw Exception("Usuário não autenticado");
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Erro ao deletar gameplay: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro ao deletar gameplay: $e");
    }
  }
}

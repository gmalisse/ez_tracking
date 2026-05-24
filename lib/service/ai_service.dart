import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ez_tracking/service/auth_storage.dart';
import 'dart:developer' as developer;

class AIService {
  final String chatUrl =
      "https://mobile-ios-ia.zani0x03.eti.br/api/ai/chat";

  Future<String> sendMessage(String prompt) async {
    try {
      // Recupera o token armazenado
      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Usuário não autenticado. Token não encontrado.");
      }

      print('[AIService] sending request to $chatUrl');
      print('[AIService] prompt: ${prompt.length > 200 ? prompt.substring(0,200) + '...' : prompt}');

    // Debug
      print('[AIService] token: $token');


      const systemPrompt = """
        Você é a IA assistente do aplicativo EZ Tracking, uma plataforma de gerenciamento de jogatinas inspirada em apps como Backloggd. Seu objetivo é ajudar usuários a organizar seus registros de jogos e perguntas sobre o uso do app.

        O app permite:
        - Registrar jogos;
        - Atualizar progresso;
        - Gerenciar backlog;
        - Visualizar estatísticas;
        - Editar e remover jogatinas.

        Na tela inicial ("Meus jogos"), o usuário vê:
        - Nome;
        - Capa;
        - Plataforma;
        - Lista de jogos em cards.

        No perfil:
        - Quantidade de jogos;
        - Horas totais;
        - Console favorito;
        - Jogo mais jogado;
        - Nome do usuário.

        Regras de comportamento:
        1. Seja útil, amigável e direto.
        2. Fale como um assistente gamer moderno.
        3. Use linguagem natural e clara.
        4. Ajude com recomendações, organização de backlog, análise de estatísticas e progresso de gameplay.
        5. Nunca invente dados ou funcionalidades inexistentes.
        6. Explique funcionalidades do app quando necessário.
        7. Mantenha respostas curtas para perguntas simples e mais detalhadas para análises.
        8. Você não controla o banco de dados nem executa ações automaticamente.
        """;

      final fullPrompt = "$systemPrompt\nUsuário: $prompt";

      final response = await http.post(
        Uri.parse(chatUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'prompt': fullPrompt}),
      );

      print('[AIService] status: ${response.statusCode}');
      print('[AIService] body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tenta decodificar JSON
        try {
          final responseData = jsonDecode(response.body);

          // Tenta vários campos comuns que a API pode retornar
          final candidates = [
            'response',
            'message',
            'data',
            'result',
            'text',
            'answer',
          ];

          for (final key in candidates) {
            if (responseData is Map && responseData.containsKey(key)) {
              final v = responseData[key];
              if (v is String) return v;
              if (v is Map && v.containsKey('text')) return v['text'].toString();
              return v.toString();
            }
          }

          // Se não encontrou chaves, retorna o JSON como string
          return responseData.toString();
        } catch (e) {
          // Não é JSON — retorna o corpo cru
          return response.body;
        }
      } else {
        throw Exception(
          "Erro na API: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao enviar mensagem: $e");
    }
  }
}

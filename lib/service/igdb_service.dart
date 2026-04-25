import 'dart:convert';
import '../models/igdb_jogo.dart';
import '../models/igdb_plataforma.dart';
import 'package:http/http.dart' as http;

class IGDBService {
  final String clientId = 'rybth7fraoqknnzp7nlau6y1r76tgl';
  final String token = 'qw3h2g9q28u3kp3l4k9840psl91zk2';

  Future<List<IGDBGame>> getGames(String query) async {
    final url = Uri.parse('https://api.igdb.com/v4/games');

    final body =
        '''
      fields name;
      search "$query";
      limit 50;
    ''';

    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => IGDBGame.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar jogos');
    }
  }

  Future<List<IGDBGame>> getPopularGames() async {
    final url = Uri.parse('https://api.igdb.com/v4/games');

    final body = '''
      fields name, rating;
      sort rating desc;
      limit 50;
    ''';

    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => IGDBGame.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar jogos populares');
    }
  }

  Future<List<IGDBPlataforma>> searchPlatforms(String query) async {
    final url = Uri.parse('https://api.igdb.com/v4/platforms');

    final body =
        '''
      fields id, name;
      search "$query";
      limit 10;
    ''';

    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro IGDB (${response.statusCode}): ${response.body}');
    }
    final data = json.decode(response.body) as List;
    return data.map((e) => IGDBPlataforma.fromJson(e)).toList();
  }

  Future<List<int>> getPlatformIdsForGame(int gameId) async {
    final url = Uri.parse('https://api.igdb.com/v4/games');

    final body =
        '''
      fields platforms;
      where id = $gameId;
      limit 1;
    ''';

    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar plataformas do jogo: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as List;
    if (data.isEmpty) return [];

    final platforms = data.first['platforms'];
    if (platforms == null) return [];
    return List<int>.from(platforms.cast<int>());
  }

  Future<List<IGDBPlataforma>> getPlatformsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final url = Uri.parse('https://api.igdb.com/v4/platforms');
    final idList = ids.join(',');

    final body =
        '''
      fields id, name;
      where id = ($idList);
      limit ${ids.length};
    ''';

    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar plataformas por ID: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as List;
    return data.map((e) => IGDBPlataforma.fromJson(e)).toList();
  }

  Future<List<IGDBPlataforma>> popularPlatforms() async {
    final url = Uri.parse('https://api.igdb.com/v4/platforms');

    final body = '''
      fields id,name;
      limit 10;
    ''';

    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar plataformas: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as List;

    return data.map((e) => IGDBPlataforma.fromJson(e)).toList();
  }
}

import 'package:ez_tracking/models/igdb_jogo.dart';
import 'package:ez_tracking/models/igdb_plataforma.dart';
import 'package:ez_tracking/service/igdb_service.dart';

class IGDBRepository {
  final IGDBService service;

  IGDBRepository(this.service);

  Future<List<IGDBGame>> search(String query) {
    return service.getGames(query);
  }

  Future<List<IGDBGame>> popular() {
    return service.getPopularGames();
  }

  Future<List<IGDBPlataforma>> searchPlatforms(String query) {
    return service.searchPlatforms(query);
  }

  Future<List<IGDBPlataforma>> popularPlatforms() {
    return service.popularPlatforms();
  }
}
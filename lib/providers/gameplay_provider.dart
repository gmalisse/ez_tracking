import 'package:flutter/material.dart';
import '../models/gameplay.dart';
import '../repositories/gameplay_repository.dart';

class GameplayProvider extends ChangeNotifier {
  final GameplayRepository _repository = GameplayRepository();

  List<Gameplay> _gameplays = [];
  bool _isLoading = false;
  String? _error;

  List<Gameplay> get gameplays => _gameplays;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carregar gameplays do usuário autenticado (banco local)
  Future<void> loadUserGameplays(int userId) async {
    print('[GameplayProvider] loadUserGameplays START userId=$userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gameplays = await _repository.getByUserId(userId);
      _isLoading = false;
      print(
        '[GameplayProvider] loaded ${_gameplays.length} gameplays for userId=$userId',
      );
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar gameplays: $e';
      _isLoading = false;
      print('[GameplayProvider] load ERROR for userId=$userId: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Criar nova gameplay (salva apenas localmente)
  Future<void> createGameplay(Gameplay gameplay) async {
    try {
      await _repository.create(gameplay);
      _gameplays.add(gameplay);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao criar gameplay: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Atualizar gameplay (atualiza apenas localmente)
  Future<void> updateGameplay(Gameplay gameplay) async {
    try {
      await _repository.update(gameplay);
      final index = _gameplays.indexWhere((g) => g.id == gameplay.id);
      if (index != -1) {
        _gameplays[index] = gameplay;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao atualizar gameplay: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Deletar gameplay (deleta apenas localmente)
  Future<void> deleteGameplay(int id) async {
    try {
      await _repository.delete(id);
      _gameplays.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar gameplay: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

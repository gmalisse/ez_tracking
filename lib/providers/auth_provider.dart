import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../service/auth_service.dart';
import '../service/auth_storage.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // Inicializar ao criar o provider
  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final token = await AuthStorage.getToken();
    final userId = await AuthStorage.getUserId();

    if (token != null && userId != null) {
      _token = token;
      final user = await _userRepository.getById(userId);
      _user = user;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String surname,
    required String login,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Registra na API
      final apiResponse = await _authService.register(
        name,
        surname,
        login,
        email,
        password,
      );

      // Cria usuário local com dados da API
      // Se a API retornar ID, usa; senão, gera um automático
      final userId = apiResponse['id'] != null
          ? apiResponse['id'] as int
          : DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final user = User(
        id: userId,
        nome: name,
        email: email,
        senha: password,
        dataNascimento: DateTime.now(),
      );

      // Salva no banco local
      try {
        await _userRepository.create(user);
        _user = user;
      } catch (dbError) {
        print("Erro ao salvar usuário no banco: $dbError");
        // Se já existe, apenas atualiza
        _user = user;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Faz login na API
      final apiResponse = await _authService.login(username, password);

      // Extrai token
      _token = apiResponse['access_token'] as String?;

      // Busca ou cria usuário local
      User? user = await _userRepository.getByEmail(username);

      if (user == null) {
        // Se não existe, cria um novo usuário local com dados básicos
        user = User(
          nome: username,
          email: username,
          senha: password,
          dataNascimento: DateTime.now(),
        );
        await _userRepository.create(user);
        user = await _userRepository.getByEmail(username);
      }

      _user = user;

      // Salva token e userId no armazenamento persistente
      if (_user?.id != null && _token != null) {
        await AuthStorage.saveToken(_token!, _user!.id!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;
    _isLoading = false;
    await AuthStorage.clearAuth();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

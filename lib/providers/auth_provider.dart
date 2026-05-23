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
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // Inicializar ao criar o provider
  AuthProvider() {
    print('[AuthProvider] constructor');
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    print('[AuthProvider] _initializeAuth START');
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getUserId();
      print('[AuthProvider] got token=$token userId=$userId');

      if (token != null && userId != null) {
        _token = token;
        final user = await _userRepository.getById(userId);
        _user = user;
        print('[AuthProvider] restored user id=${user?.id}',);
      }
    } catch (e) {
      print('[AuthProvider] _initializeAuth ERROR: $e',
      );
    }

    _isInitialized = true;
    notifyListeners();
    print('[AuthProvider] _initializeAuth END');
  }

  Future<bool> register({
    required String name,
    required String surname,
    required String login,
    required String email,
    required String password,
  }) async {
    print('[AuthProvider] register START name=$name email=$email');
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

      // Cria usuário local com dados do registro
      final userId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

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
        _user = user;
      }

      _isLoading = false;
      print('[AuthProvider] register SUCCESS userId=${user.id}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      _isLoading = false;
      print('[AuthProvider] register ERROR: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    print('[AuthProvider] login START username=$username');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Faz login na API e recebe token
      final apiResponse = await _authService.login(username, password);
      _token = apiResponse['access_token'] as String?;
      print('[AuthProvider] login got token=$_token');

      // Busca usuário local por email (username é geralmente o email)
      User? user = await _userRepository.getByEmail(username);

      // Se não encontrar, cria um usuário local mínimo
      if (user == null) {
        final userId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        user = User(
          id: userId,
          nome: username,
          email: username,
          senha: password,
          dataNascimento: DateTime.now(),
        );
        await _userRepository.create(user);
        user = await _userRepository.getByEmail(username);
      }

      _user = user;
      print('[AuthProvider] login resolved user id=${user?.id}');

      // Salva token e userId em SharedPreferences
      if (_user?.id != null && _token != null) {
        await AuthStorage.saveToken(_token!, _user!.id!);
        print('[AuthProvider] saved token and userId=${_user!.id!}');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      _isLoading = false;
      print('[AuthProvider] login ERROR: $_error');
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

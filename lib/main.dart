import 'package:ez_tracking/models/igdb_jogo.dart';
import 'package:ez_tracking/models/igdb_plataforma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import '../models/gameplay.dart';
import '../models/jogo.dart';
import '../models/userdata.dart';
import '../repositories/gameplay_repository.dart';
import '../repositories/igdb_repository.dart';
import '../repositories/jogo_repository.dart';
import '../repositories/userdata_repository.dart';
import '../service/igdb_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'service/auth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/gameplay_provider.dart';

void main() {
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  print('[main] starting app');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('[MyApp] build()');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameplayProvider()),
      ],
      child: MaterialApp(
        title: 'Login',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF121212), // fundo
        ),
        home: const LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    final authProvider = context.read<AuthProvider>();

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha usuário e senha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // fecha loading

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erro no login'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);
    const inputColor = Color(0xFF1E1E1E);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.png', height: 100, width: 250),
              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nome de usuário', style: TextStyle(color: green)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Senha', style: TextStyle(color: green)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddUserPage()),
                  );
                },
                child: const Text(
                  'Ou cadastre-se',
                  style: TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final authProvider = context.read<AuthProvider>();

    if (_firstNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await authProvider.register(
        name: _firstNameController.text.trim(),
        surname: _lastNameController.text.trim(),
        login: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso! Redirecionando...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Aguarda um pouco antes de voltar para o login
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cadastro: ${authProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no cadastro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);
    const inputColor = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
        title: const Text(
          'Cadastro',
          style: TextStyle(fontFamily: 'Orbitron', color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crie sua conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: green,
                    fontFamily: 'Orbitron',
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nome',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sobrenome',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nome de usuário',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Senha',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final JogoRepository _jogoRepository = JogoRepository();
  final IGDBRepository _igdbRepository = IGDBRepository(IGDBService());
  Map<int, Jogo> _jogosById = {};
  Map<int, String?> _coverUrlsById = {};
  int? _loadedUserId;

  @override
  void initState() {
    super.initState();
    // Carrega jogos uma única vez
    _loadJogos();
  }

  Future<void> _loadJogos() async {
    final jogos = await _jogoRepository.getAll();
    final jogosMap = {for (var jogo in jogos) jogo.id!: jogo};
    setState(() {
      _jogosById = jogosMap;
    });
  }

  Future<void> _refreshJogos() async {
    await _loadJogos();
  }

  Future<String?> _getCoverUrl(int jogoId) async {
    // Se já está no cache, retorna
    if (_coverUrlsById.containsKey(jogoId)) {
      return _coverUrlsById[jogoId];
    }

    // Caso contrário, busca da API
    try {
      final url = await _igdbRepository.getCoverForGame(jogoId);
      setState(() {
        _coverUrlsById[jogoId] = url;
      });
      return url;
    } catch (e) {
      print('Erro ao buscar cover do jogo $jogoId: $e');
      setState(() {
        _coverUrlsById[jogoId] = null;
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);

    // Watch do authProvider para pegar userId
    final authProvider = context.watch<AuthProvider>();
    final gameplayProvider = context.watch<GameplayProvider>();

    final currentUserId = authProvider.user?.id;

    // Se não tem usuário, não carrega gameplays
    if (currentUserId == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Carregar gameplays **uma vez por usuário** para evitar loop infinito
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
        '[HomePage] addPostFrameCallback currentUserId=$currentUserId loadedUserId=$_loadedUserId',
      );
      if (currentUserId != null && _loadedUserId != currentUserId) {
        _loadedUserId = currentUserId;
        print('[HomePage] calling loadUserGameplays for userId=$currentUserId');
        gameplayProvider.loadUserGameplays(currentUserId);
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.green, size: 30),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Image.asset(
          'assets/logo.png',
          height: 50,
          width: 150,
          fit: BoxFit.contain,
          alignment: Alignment.topLeft,
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Lista de páginas
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.white),
                    title: const Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text(
                      'Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.logout();
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Orbitron',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meus jogos',
              style: TextStyle(
                color: green,
                fontSize: 24,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<GameplayProvider>(
                builder: (context, gameplayProvider, _) {
                  if (gameplayProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (gameplayProvider.gameplays.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma gameplay salva ainda.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: gameplayProvider.gameplays.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final gameplay = gameplayProvider.gameplays[index];
                      final jogo = _jogosById[gameplay.jogosId];
                      final title = jogo?.nome ?? 'Jogo desconhecido';

                      return ListTile(
                        leading: FutureBuilder<String?>(
                          future: _getCoverUrl(gameplay.jogosId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  snapshot.data!,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1E1E),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                            return Container(
                              width: 50,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        tileColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          gameplay.console,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    title: const Text(
                                      'Confirmar exclusão',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Deseja realmente excluir "$title"?',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(dialogContext);
                                          try {
                                            await gameplayProvider
                                                .deleteGameplay(gameplay.id!);
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Gameplay excluída com sucesso',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Erro ao excluir: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Excluir',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddGamePage(gameplay: gameplay, jogo: jogo),
                            ),
                          );

                          if (result == true) {
                            await _refreshJogos();
                            final gameplayProvider = context
                                .read<GameplayProvider>();
                            final authProvider = context.read<AuthProvider>();
                            final userId = authProvider.user?.id;
                            if (userId != null) {
                              await gameplayProvider.loadUserGameplays(userId);
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGamePage()),
          );

          if (result == true) {
            await _refreshJogos();
            final gameplayProvider = context.read<GameplayProvider>();
            final authProvider = context.read<AuthProvider>();
            final userId = authProvider.user?.id;
            if (userId != null) {
              await gameplayProvider.loadUserGameplays(userId);
            }
          }
        },
        backgroundColor: green,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final JogoRepository _jogoRepository = JogoRepository();
  final UserDataRepository _userDataRepository = UserDataRepository();
  Map<int, Jogo> _jogosById = {};
  int? _loadedUserId;

  @override
  void initState() {
    super.initState();
    _loadJogos();
  }

  Future<void> _loadJogos() async {
    final jogos = await _jogoRepository.getAll();
    final jogosMap = {for (var jogo in jogos) jogo.id!: jogo};
    setState(() {
      _jogosById = jogosMap;
    });
  }

  Future<void> _updateUserProfile() async {
    final authProvider = context.read<AuthProvider>();
    final gameplayProvider = context.read<GameplayProvider>();
    final currentUserId = authProvider.user?.id;

    if (currentUserId == null) return;

    final gameplays = gameplayProvider.gameplays;

    final jogosJogados = gameplays.map((g) => g.jogosId).toSet().length;
    final totalHoras = gameplays.fold<double>(
      0.0,
      (sum, g) => sum + g.horasJogadas,
    );

    String generoFavorito = 'Não definido';
    if (gameplays.isNotEmpty) {
      final consoleCount = <String, int>{};
      for (final gameplay in gameplays) {
        consoleCount[gameplay.console] =
            (consoleCount[gameplay.console] ?? 0) + 1;
      }
      generoFavorito = consoleCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    String jogoMaisHoras = 'Nenhum';
    if (gameplays.isNotEmpty) {
      final hoursByJogo = <int, double>{};
      for (final gameplay in gameplays) {
        hoursByJogo[gameplay.jogosId] =
            (hoursByJogo[gameplay.jogosId] ?? 0.0) + gameplay.horasJogadas;
      }
      final best = hoursByJogo.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      jogoMaisHoras = _jogosById[best.key]?.nome ?? 'Jogo desconhecido';
    }

    final userData = UserData(
      id: currentUserId,
      userId: currentUserId,
      jogosJogados: jogosJogados,
      totalHoras: totalHoras,
      generoFavorito: generoFavorito,
      jogoMaisHoras: jogoMaisHoras,
    );

    final existingUserData = await _userDataRepository.getByUserId(
      currentUserId,
    );
    if (existingUserData == null) {
      await _userDataRepository.create(userData);
    } else {
      await _userDataRepository.update(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);
    final authProvider = context.watch<AuthProvider>();
    final gameplayProvider = context.watch<GameplayProvider>();
    final userName = authProvider.user?.nome ?? 'Usuário';
    final currentUserId = authProvider.user?.id;

    // Carregar gameplays e atualizar perfil apenas uma vez por usuário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
        '[ProfilePage] addPostFrameCallback currentUserId=$currentUserId loadedUserId=$_loadedUserId',
      );
      if (currentUserId != null && _loadedUserId != currentUserId) {
        _loadedUserId = currentUserId;
        print(
          '[ProfilePage] triggering loadUserGameplays and updateUserProfile for userId=$currentUserId',
        );
        if (gameplayProvider.gameplays.isEmpty && !gameplayProvider.isLoading) {
          gameplayProvider.loadUserGameplays(currentUserId);
        }
        _updateUserProfile();
      }
    });

    final gameplays = gameplayProvider.gameplays;
    final jogosJogados = gameplays.map((g) => g.jogosId).toSet().length;
    final totalHoras = gameplays.fold<double>(
      0.0,
      (sum, g) => sum + g.horasJogadas,
    );

    String generoFavorito = 'Não definido';
    if (gameplays.isNotEmpty) {
      final consoleCount = <String, int>{};
      for (final gameplay in gameplays) {
        consoleCount[gameplay.console] =
            (consoleCount[gameplay.console] ?? 0) + 1;
      }
      generoFavorito = consoleCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    String jogoMaisHoras = 'Nenhum';
    if (gameplays.isNotEmpty) {
      final hoursByJogo = <int, double>{};
      for (final gameplay in gameplays) {
        hoursByJogo[gameplay.jogosId] =
            (hoursByJogo[gameplay.jogosId] ?? 0.0) + gameplay.horasJogadas;
      }
      final best = hoursByJogo.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      jogoMaisHoras = _jogosById[best.key]?.nome ?? 'Jogo desconhecido';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
        title: const Text(
          'Perfil',
          style: TextStyle(fontFamily: 'Orbitron', color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 52,
              backgroundColor: green,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: const AssetImage('assets/logo.png'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Orbitron',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            if (gameplayProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _profileStat('Jogos jogados', '$jogosJogados', green),
              _profileStat(
                'Total de horas',
                totalHoras.toStringAsFixed(1),
                green,
              ),
              _profileStat('Console favorito', generoFavorito, green),
              _profileStat('Jogo com mais horas', jogoMaisHoras, green),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _profileStat(String label, String value, Color green) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: green.withAlpha((0.4 * 255).round())),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontFamily: 'Orbitron'),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class AddGamePage extends StatefulWidget {
  final Gameplay? gameplay;
  final Jogo? jogo;

  const AddGamePage({super.key, this.gameplay, this.jogo});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  IGDBGame? _selectedValue;
  IGDBPlataforma? _plataformaValue;
  List<IGDBPlataforma> _platformOptions = [];
  bool _isLoadingPlatforms = false;
  bool _hasLoadedPlatforms = false;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCompleted = false;
  int _rating = 0;

  @override
  void initState() {
    super.initState();

    final gameplay = widget.gameplay;
    if (gameplay != null) {
      _selectedValue = IGDBGame(
        id: gameplay.jogosId,
        name: widget.jogo?.nome ?? 'Jogo',
      );
      _hoursController.text = gameplay.horasJogadas.toString();
      _startDate = gameplay.dataInicio;
      _startDateController.text =
          '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}';
      if (gameplay.dataFim != null) {
        _endDate = gameplay.dataFim;
        _endDateController.text =
            '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}';
      }
      _isCompleted = gameplay.zerado;
      _rating = gameplay.rating;
      _loadPlatformsForSelectedGame(selectedPlatformName: gameplay.console);
    }
  }

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final IGDBRepository igdbRepository = IGDBRepository(IGDBService());
  final JogoRepository jogoRepository = JogoRepository();

  Future<void> _loadPlatformsForSelectedGame({
    String? selectedPlatformName,
  }) async {
    if (_selectedValue?.id == null) return;

    setState(() {
      _isLoadingPlatforms = true;
      _hasLoadedPlatforms = false;
      _platformOptions = [];
      _plataformaValue = null;
    });

    try {
      final platformIds = await igdbRepository.getPlatformIdsForGame(
        _selectedValue!.id!,
      );
      final platforms = await igdbRepository.getPlatformsByIds(platformIds);
      setState(() {
        _platformOptions = platforms;
        if (selectedPlatformName != null) {
          final match = platforms
              .where((platform) => platform.name == selectedPlatformName)
              .toList();
          if (match.isNotEmpty) {
            _plataformaValue = match.first;
          }
        }
      });
    } catch (_) {
      setState(() {
        _platformOptions = [];
      });
    } finally {
      setState(() {
        _isLoadingPlatforms = false;
        _hasLoadedPlatforms = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: now,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF12964A),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';

      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = formatted;
        } else {
          _endDate = picked;
          _endDateController.text = formatted;
        }
      });
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);
    const inputColor = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
        title: Text(
          widget.gameplay != null ? 'Editar jogo' : 'Adicionar jogo',
          style: const TextStyle(fontFamily: 'Orbitron', color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                if (widget.gameplay == null) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Jogo',
                      style: TextStyle(color: green, fontFamily: 'Orbitron'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownSearch<IGDBGame>(
                    compareFn: (a, b) => a.id == b.id,

                    items: (filter, loadProps) async {
                      if (filter.isEmpty) {
                        return await igdbRepository.popular();
                      }
                      return await igdbRepository.search(filter);
                    },

                    itemAsString: (game) => game.name,

                    onSelected: (game) {
                      setState(() {
                        _selectedValue = game;
                        _plataformaValue = null;
                        _platformOptions = [];
                        _hasLoadedPlatforms = false;
                      });
                      _loadPlatformsForSelectedGame();
                    },

                    popupProps: PopupProps.modalBottomSheet(
                      showSearchBox: true,
                    ),

                    dropdownBuilder: (context, selectedItem) {
                      return Text(
                        selectedItem?.name ?? 'Selecione um jogo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Plataforma',
                                style: TextStyle(
                                  color: green,
                                  fontFamily: 'Orbitron',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownSearch<IGDBPlataforma>(
                              compareFn: (a, b) => a.id == b.id,
                              items: (filter, loadProps) async {
                                if (_selectedValue == null) {
                                  return [];
                                }

                                if (!_hasLoadedPlatforms &&
                                    !_isLoadingPlatforms) {
                                  await _loadPlatformsForSelectedGame();
                                }

                                if (filter.isEmpty) {
                                  return _platformOptions;
                                }

                                return _platformOptions
                                    .where(
                                      (platform) => platform.name
                                          .toLowerCase()
                                          .contains(filter.toLowerCase()),
                                    )
                                    .toList();
                              },
                              itemAsString: (platform) => platform.name,
                              onSelected: (platform) {
                                setState(() {
                                  _plataformaValue = platform;
                                });
                              },
                              popupProps: PopupProps.modalBottomSheet(
                                showSearchBox: true,
                              ),
                              dropdownBuilder: (context, selectedItem) {
                                if (_selectedValue == null) {
                                  return const Text(
                                    'Selecione um jogo primeiro',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  );
                                }

                                if (_isLoadingPlatforms) {
                                  return const Text(
                                    'Carregando plataformas...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  );
                                }

                                return Text(
                                  selectedItem?.name ??
                                      'Selecione uma plataforma',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                );
                              },
                              decoratorProps: const DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: inputColor,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              enabled: _selectedValue != null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _isCompleted,
                            activeColor: green,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value!;
                              });
                            },
                          ),
                          const Text(
                            'Jogo concluído',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Orbitron',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  // Modo edição: mostrar jogo e plataforma como texto
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jogo',
                          style: TextStyle(
                            color: green,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.jogo?.nome ?? 'Jogo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Plataforma',
                                    style: TextStyle(
                                      color: green,
                                      fontFamily: 'Orbitron',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.gameplay?.console ?? 'Plataforma',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _isCompleted,
                                  activeColor: green,
                                  onChanged: (value) {
                                    setState(() {
                                      _isCompleted = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'Jogo concluído',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Orbitron',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Horas jogadas',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Início da jogatina',
                              style: TextStyle(
                                color: green,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _startDateController,
                            readOnly: true,
                            onTap: () => _selectDate(context, true),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Selecione a data',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: inputColor,
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Fim da jogatina',
                              style: TextStyle(
                                color: green,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _endDateController,
                            readOnly: true,
                            onTap: () => _selectDate(context, false),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Selecione a data',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: inputColor,
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sua nota para o jogo',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      iconSize: 32,
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: index < _rating ? Colors.amber : Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    final currentUserId = authProvider.user?.id ?? 1;

                    if (widget.gameplay == null) {
                      // Modo adicionar: validar jogo e plataforma
                      if (_selectedValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione um jogo.')),
                        );
                        return;
                      }

                      if (_plataformaValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecione uma plataforma.'),
                          ),
                        );
                        return;
                      }
                    }

                    if (_startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione a data de início.'),
                        ),
                      );
                      return;
                    }

                    final selectedGame = widget.gameplay != null
                        ? IGDBGame(
                            id: widget.gameplay!.jogosId,
                            name: widget.jogo!.nome,
                          )
                        : _selectedValue!;
                    final selectedPlatform = widget.gameplay != null
                        ? IGDBPlataforma(id: 0, name: widget.gameplay!.console)
                        : _plataformaValue!;

                    final jogo = Jogo(
                      id: selectedGame.id,
                      nome: selectedGame.name,
                    );

                    final existingJogo = await jogoRepository.getById(
                      selectedGame.id!,
                    );
                    if (existingJogo == null) {
                      await jogoRepository.create(jogo);
                    }

                    final gameplay = Gameplay(
                      id:
                          widget.gameplay?.id ??
                          DateTime.now().millisecondsSinceEpoch,
                      usersId: currentUserId,
                      jogosId: selectedGame.id!,
                      horasJogadas:
                          double.tryParse(
                            _hoursController.text.replaceAll(',', '.'),
                          ) ??
                          0.0,
                      dataInicio: _startDate!,
                      dataFim: _endDate,
                      zerado: _isCompleted,
                      console: selectedPlatform.name,
                      rating: _rating,
                    );

                    final gameplayProvider = context.read<GameplayProvider>();

                    try {
                      if (widget.gameplay != null) {
                        await gameplayProvider.updateGameplay(gameplay);
                      } else {
                        await gameplayProvider.createGameplay(gameplay);
                      }

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gameplay salva com sucesso.'),
                        ),
                      );
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao salvar gameplay: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:ez_tracking/models/igdb_jogo.dart';
import 'package:ez_tracking/models/igdb_plataforma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/igdb_jogo.dart';
import '../repositories/igdb_repository.dart';
import '../repositories/jogo_repository.dart';
import '../service/igdb_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              Image.asset(
                'assets/logo.png',
                height: 100,
                width: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(color: green, fontFamily: 'Orbitron'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
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

              // SENHA
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Senha',
                  style: TextStyle(color: green, fontFamily: 'Orbitron'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
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

              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                    MaterialPageRoute(
                      builder: (context) => const AddUserPage(),
                    ),
                  );
                },
                child: const Text(
                  'Ou cadastre-se',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Orbitron',
                  ),
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
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _selectedDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
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
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);
    const inputColor = Color(0xFF1E1E1E);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cadastro de Usuário',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data de Nascimento',
                    style: TextStyle(color: green, fontFamily: 'Orbitron'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  onTap: () => _selectDate(context),
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

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
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

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);

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
                onPressed: () {
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
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meus jogos',
                      style: TextStyle(
                        color: green,
                        fontSize: 24,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddGamePage()),
                );
              },
              backgroundColor: green,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
          ),
        ],
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
            const Text(
              'Nome do Usuário',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Orbitron',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _profileStat('Jogos jogados', '...', green),
            _profileStat('Total de horas', '...', green),
            _profileStat('Gênero favorito', '...', green),
            _profileStat('Jogo com mais horas', '...', green),
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

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF12964A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontFamily: 'Orbitron', color: Colors.green),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome',
              style: TextStyle(color: Colors.white70, fontFamily: 'Orbitron'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontFamily: 'Orbitron'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddGamePage extends StatefulWidget {
  const AddGamePage({super.key});

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

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final IGDBRepository igdbRepository = IGDBRepository(IGDBService());
  final JogoRepository jogoRepository = JogoRepository();

  Future<void> _loadPlatformsForSelectedGame() async {
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
        title: const Text(
          'Adicionar jogo',
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
                const SizedBox(height: 12),

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

                  popupProps: PopupProps.modalBottomSheet(showSearchBox: true),

                  dropdownBuilder: (context, selectedItem) {
                    return Text(
                      selectedItem?.name ?? 'Selecione um jogo',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
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

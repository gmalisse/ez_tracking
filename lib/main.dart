import 'package:flutter/material.dart';

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
              const Text(
                'Ou cadastre-se',
                style: TextStyle(color: Colors.white70, fontFamily: 'Orbitron'),
              ),
            ],
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
            Container(
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
              onPressed: () {},
              backgroundColor: green,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

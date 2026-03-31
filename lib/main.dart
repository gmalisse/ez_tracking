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
      theme: ThemeData.dark(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EMAIL
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: TextStyle(color: Color.fromRGBO(57, 255, 20, 1), fontFamily: 'Orbitron'), ),
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Color.fromRGBO(40, 40, 40, 1),
                  filled: true,
                ),
              ),

              const SizedBox(height: 16),

              // SENHA
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Senha', style: TextStyle(color: Color.fromRGBO(57, 255, 20, 1), fontFamily: 'Orbitron'), ),
                
              ),
              const SizedBox(height: 8),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Color.fromRGBO(40, 40, 40, 1),
                  filled: true,
                ),
              ),

              const SizedBox(height: 24),

              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(16, 96, 2, 1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Login', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontFamily: 'Orbitron'), ),
                ),
              ),

              const SizedBox(height: 16),

              // TEXTO FINAL
              const Text('Ou cadastre-se', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontFamily: 'Orbitron'), ),
            ],
          ),
        ),
      ),
    );
  }
}
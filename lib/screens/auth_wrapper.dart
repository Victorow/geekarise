import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Importe seu serviço
import 'home_screen.dart';
import 'login_screen.dart'; // Agora deve encontrar a classe

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // CORRIGIDO: Removido o underscore '_' do nome da variável local.
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges, // Ouve o stream
      builder: (context, snapshot) {
        // Se estiver carregando, mostra um loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Se tem usuário logado, mostra a HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen(); // Ou a tela principal do seu app
        }
        // Se não tem usuário, mostra a LoginScreen
        else {
          return const LoginScreen();
        }
      },
    );
  }
}
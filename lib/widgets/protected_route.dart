import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Seu serviço de autenticação
// Não precisamos da LoginScreen aqui, o Navigator cuidará disso

class ProtectedRoute extends StatelessWidget {
  final Widget child; // A tela que queremos proteger

  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService(); // Instancia o serviço
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      // Se o usuário está logado, mostra a tela protegida
      return child;
    } else {
      // Se não está logado, redireciona para a tela de login
      // Usamos addPostFrameCallback para garantir que a navegação ocorra após o build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Pega a rota atual para poder redirecionar de volta após o login
        final currentRoute = ModalRoute.of(context)?.settings.name;
        
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login', // Nome da sua rota de login
          (route) => false, // Remove todas as rotas anteriores
          arguments: {'redirectTo': currentRoute}, // Passa a rota de origem como argumento
        );
      });
      // Mostra um loader enquanto o redirecionamento ocorre
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
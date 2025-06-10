import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// --- Imports das Telas ---
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/endereco_screen.dart';
import 'screens/pagamento_screen.dart';
import 'screens/login_screen.dart'; // Tela unificada de Login e Registro
import 'screens/orders_screen.dart';

// A importação para register_screen foi removida, pois não é mais necessária.

void main() async {
  // Garante que o Flutter está pronto antes de inicializar o Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geek Arise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2c3e50),
          primary: const Color(0xFF2c3e50),
          secondary: const Color(0xFF3498db),
        ),
        useMaterial3: true,
        fontFamily: 'Montserrat',
      ),
      // A tela inicial continua sendo a HomeScreen. O ProtectedRoute cuidará do redirecionamento.
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/explorar': (context) => const ExploreScreen(),
        // A rota de login agora aponta para a nossa nova tela unificada.
        '/login': (context) => const LoginScreen(),
        
        // --- ROTAS PROTEGIDAS ---
        // Usam o widget ProtectedRoute para verificar se o usuário está logado.
        '/carrinho': (context) => const ProtectedRoute(child: CartScreen()),
        '/endereco': (context) => const ProtectedRoute(child: EnderecoScreen()),
        '/pagamento': (context) => const ProtectedRoute(child: PagamentoScreen()),
        '/pedidos': (context) => const ProtectedRoute(child: OrdersScreen()),
        
        // A rota '/register' foi removida.
      },
    );
  }
}

// --- WIDGET PARA PROTEGER ROTAS ---
// Verifica se o usuário está logado antes de mostrar a tela desejada.
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica, mostra um indicador de progresso.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Se o usuário está logado, mostra a tela solicitada.
        if (snapshot.hasData) {
          return child;
        }

        // Se não está logado, redireciona para a tela de login.
        // Usamos um Future para navegar de forma segura após o build.
        Future.microtask(() {
          if (context.mounted) {
            // Pega o nome da rota que o usuário tentou acessar (ex: '/carrinho')
            final attemptedRoute = ModalRoute.of(context)?.settings.name;
            Navigator.pushReplacementNamed(
              context,
              '/login',
              // Passa a rota original como argumento para que a tela de login
              // saiba para onde voltar após o sucesso.
              arguments: {'redirectTo': attemptedRoute},
            );
          }
        });

        // Mostra um loader enquanto a navegação ocorre.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

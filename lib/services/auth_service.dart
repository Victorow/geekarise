import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // <-- ADICIONADO: Para usar debugPrint

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // CORRIGIDO: Usando debugPrint em vez de print
      debugPrint('Erro de Cadastro: ${e.message} (Código: ${e.code})');
      // Você pode querer retornar o erro aqui ou lançá-lo para a UI tratar
      return null;
    } catch (e) {
      debugPrint('Erro inesperado no Cadastro: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // CORRIGIDO: Usando debugPrint em vez de print
      debugPrint('Erro de Login: ${e.message} (Código: ${e.code})');
      // Você pode querer retornar o erro aqui ou lançá-lo para a UI tratar
      return null;
    } catch (e) {
      debugPrint('Erro inesperado no Login: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
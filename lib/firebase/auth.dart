import 'package:firebase_auth/firebase_auth.dart';

/// Сервис, через который осуществляется аутентификация (Firebase).
class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  /// Текущий аутентифицированный пользователь.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Уведомляет про изменения аутентификации.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Попытка входа пользователя с указанным адресом электронной почты и паролем.
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async => await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

  /// Попытка создать новую учетную запись пользователя с указанным адресом электронной почты и паролем.
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async => await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

  /// Выписывает текущего пользователя.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
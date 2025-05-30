import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Регистрация с email/паролем
  Future<User?> signUp(String email, String password) async {
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _sendEmailVerification(creds.user!);
      return creds.user;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e.code);
    }
  }

  // Вход
  Future<User?> signIn(String email, String password) async {
    try {
      final creds = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!creds.user!.emailVerified) {
        await _sendEmailVerification(creds.user!);
        throw 'Подтвердите email (письмо отправлено)';
      }
      return creds.user;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e.code);
    }
  }

  // Восстановление пароля
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e.code);
    }
  }

  // Отправка письма с подтверждением
  Future<void> _sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  // Обработка ошибок
  String _parseAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Некорректный email';
      case 'user-disabled':
        return 'Аккаунт отключен';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Email уже занят';
      case 'weak-password':
        return 'Пароль слишком простой';
      default:
        return 'Ошибка авторизации';
    }
  }
}
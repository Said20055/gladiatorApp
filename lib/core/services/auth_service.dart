import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Регистрация с email/паролем

  Future<User?> signUp(String email, String password, String fullName) async {
    try {
      // 1. Создаем пользователя в Firebase Auth
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = creds.user;
      if (user == null) return null;

      // 2. Сохраняем профиль с использованием модели
      final userProfile = UserProfile(
        uid: user.uid,
        fullName: fullName,
        email: email,
        photoUrl: null,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toMap());

      await _sendEmailVerification(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e.code);
    } catch (e) {
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // Вход
  Future<SignInResult> signIn(String email, String password) async {
    try {
      final creds = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = creds.user!;

      if (!user.emailVerified) {
        await _sendEmailVerification(user);
        return SignInResult(user: user, isVerified: false);
      }

      return SignInResult(user: user, isVerified: true);
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e.code);
    }
  }

//Выход
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e.code);
    } catch (e) {
      throw Exception('Не удалось выйти из аккаунта: $e');
    }
  }


  Future<bool> isAdminUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('admins').doc(user.uid).get();
    return doc.exists;
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
class SignInResult {
  final User user;
  final bool isVerified;

  SignInResult({required this.user, required this.isVerified});
}
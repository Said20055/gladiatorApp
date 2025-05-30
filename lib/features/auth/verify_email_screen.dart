import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isEmailVerified = false;
  bool _isLoading = true;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    // Слушаем изменения статуса верификации
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        user.reload().then((_) {
          if (mounted) {
            setState(() {
              _isEmailVerified = user.emailVerified;
              _isLoading = false;
            });
          }
        });
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        _isEmailVerified = user.emailVerified;
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !_isResending) {
      setState(() => _isResending = true);
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Письмо отправлено повторно')),
        );
      } finally {
        if (mounted) {
          setState(() => _isResending = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение email'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: _isEmailVerified
            ? _buildVerifiedContent()
            : _buildNotVerifiedContent(),
      ),
    );
  }

  Widget _buildNotVerifiedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.email_outlined,
          size: 80,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 30),
        const Text(
          'Проверьте вашу почту',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Мы отправили письмо с ссылкой для подтверждения на ваш email',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isResending ? null : _resendVerificationEmail,
          child: _isResending
              ? const CircularProgressIndicator()
              : const Text('Отправить повторно'),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            _auth.signOut();
            Navigator.popUntil(
                context, (route) => route.settings.name == '/login');
          },
          child: const Text('Войти с другим email'),
        ),
      ],
    );
  }

  Widget _buildVerifiedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 30),
        const Text(
          'Email подтверждён!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Теперь вы можете пользоваться всеми функциями приложения',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('Продолжить'),
        ),
      ],
    );
  }
}
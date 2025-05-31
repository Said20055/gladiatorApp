import 'dart:async';

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
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Проверяем сразу при открытии
    _checkEmailVerification();

    // Периодическая проверка каждые 3 секунды
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !_isEmailVerified) {
      await user.reload();
      if (mounted) {
        setState(() {
          _isEmailVerified = user.emailVerified;
          _isLoading = false;
        });

        // Если email подтвержден, переходим на главный экран

      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !_isResending) {
      setState(() => _isResending = true);
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Письмо отправлено повторно'),
            duration: Duration(seconds: 3),
          ),
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
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEmailVerified ? Icons.verified : Icons.email_outlined,
              size: 80,
              color: _isEmailVerified ? Colors.green : Colors.black,
            ),
            const SizedBox(height: 30),
            Text(
              _isEmailVerified
                  ? 'Email подтверждён!'
                  : 'Проверьте вашу почту',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _isEmailVerified
                  ? 'Теперь вы можете пользоваться всеми функциями приложения'
                  : 'Мы отправили письмо с ссылкой для подтверждения на ваш email',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            if (!_isEmailVerified) ...[
              ElevatedButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Ваш цвет
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isResending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Отправить повторно'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  _auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                child: const Text(
                  'Войти с другим email',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
            if (_isEmailVerified)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Ваш цвет
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Продолжить'),
              ),

          ],
        ),
      ),
    );
  }
}
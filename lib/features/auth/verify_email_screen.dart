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
  final Color _primaryColor = const Color(0xFFE53935); // Красный акцент

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
    _checkEmailVerification();
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
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !_isResending) {
      setState(() => _isResending = true);
      try {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Письмо отправлено повторно'),
              backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isResending = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Подтверждение email'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: _primaryColor,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEmailVerified ? Icons.verified : Icons.email_outlined,
              size: 80,
              color: _isEmailVerified
                  ? Colors.green
                  : theme.textTheme.titleLarge?.color,
            ),
            const SizedBox(height: 30),
            Text(
              _isEmailVerified
                  ? 'Email подтверждён!'
                  : 'Проверьте вашу почту',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _isEmailVerified
                  ? 'Теперь вы можете пользоваться всеми функциями приложения'
                  : 'Мы отправили письмо с ссылкой для подтверждения на ваш email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 30),
            if (!_isEmailVerified) ...[
              ElevatedButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isResending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Отправить повторно'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  _auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
                child: Text(
                  'Войти с другим email',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
            if (_isEmailVerified)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Продолжить'),
              ),
          ],
        ),
      ),
    );
  }
}
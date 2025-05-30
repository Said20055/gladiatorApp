import 'package:flutter/material.dart';
import 'package:gladiatorapp/features/auth/login_screen.dart';
import 'package:gladiatorapp/features/auth/registration_screen.dart';
import 'package:gladiatorapp/features/auth/verify_email_screen.dart';
import 'package:gladiatorapp/features/auth/forgot_pw_screen.dart';
import 'package:gladiatorapp/features/onboarding_screen.dart';
import 'package:gladiatorapp/features/home/home_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/register': (context) => const RegistrationScreen(),
  '/verify-email': (context) => const VerifyEmailScreen(),
};

import 'package:flutter/material.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/features/auth/login_screen.dart';
import 'package:gladiatorapp/features/auth/registration_screen.dart';
import 'package:gladiatorapp/features/auth/verify_email_screen.dart';
import 'package:gladiatorapp/features/auth/forgot_pw_screen.dart';
import 'package:gladiatorapp/features/home/home_screen.dart';
import 'package:gladiatorapp/features/home/profile_screen.dart';
import 'package:gladiatorapp/features/payments/subscription_screen.dart';
import 'package:gladiatorapp/features/home/edit_profile_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/register': (context) => const RegistrationScreen(),
  '/verify-email': (context) => const VerifyEmailScreen(),
  '/forgot-password': (context) => const ForgotPasswordScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/subscription': (context) => const SubscriptionScreen(),
  '/edit-profile': (context) {
    final profile = ModalRoute.of(context)?.settings.arguments as UserProfile?;
    if (profile == null) {
      Navigator.pop(context); // Закрыть экран, если профиля нет.
      return const SizedBox.shrink(); // Заглушка.
    }
    return EditProfileScreen(initialProfile: profile);
  },
};
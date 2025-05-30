import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions;
import 'package:gladiatorapp/features//onboarding_screen.dart';
import 'package:gladiatorapp/features/auth/registration_screen.dart';
import 'package:gladiatorapp/features/auth/login_screen.dart';
import 'package:gladiatorapp/features/home/home_screen.dart';
import 'package:gladiatorapp/core/routes.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: appRoutes,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const OnboardingScreen();
          }
          if (snapshot.hasData) {
            // Пользователь авторизован
            return const OnboardingScreen();
          } else {
            // Пользователь не авторизован
            return const LoginScreen();
          }
        },
      ),
    ),
  );

}
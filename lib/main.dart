import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gladiatorapp/features/onboarding_screen.dart';
import 'package:gladiatorapp/features/auth/login_screen.dart';
import 'package:gladiatorapp/features/home/home_screen.dart';
import 'package:gladiatorapp/core/routes.dart';

import 'core/app_theme.dart';
import 'core/provider.dart';
import 'core/services/auth_service.dart';
import 'features/admin/admin_dashboard_screen.dart';


void main() async {
  await dotenv.load(fileName: 'assets/.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      _isLoading = false;
    });

    if (_isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(), // Светлая тема
            darkTheme: ThemeData.dark(), // Темная тема
            themeMode: themeProvider.themeMode, // Используем текущий режим из ThemeProvider
            routes: appRoutes,
            home: StreamBuilder<User?>(
              // Остальной код остается без изменений
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData) {
                  return FutureBuilder<bool>(
                    future: AuthService().isAdminUser(),
                    builder: (context, adminSnapshot) {
                      if (adminSnapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (adminSnapshot.hasData && adminSnapshot.data == true) {
                        return AdminDashboardScreen();
                      }

                      return const HomeScreen();
                    },
                  );
                }

                return _isFirstLaunch
                    ? const OnboardingScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
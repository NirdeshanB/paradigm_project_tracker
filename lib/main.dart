import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'models/user.dart' as app_user;
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/config_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ParadigmProjectsApp());
}

class ParadigmProjectsApp extends StatelessWidget {
  const ParadigmProjectsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ConfigService>(create: (_) => ConfigService()),
        StreamProvider<app_user.User?>(
          create: (_) => AuthService().currentAppUserStream,
          initialData: null,
        ),
      ],
      child: Consumer<ThemeProvider>(
        child: const AuthGate(),
        builder: (context, themeProvider, childWidget) {
          return MaterialApp(
            title: 'Paradigm Projects',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: childWidget,
          );
        },
      ),
    );
  }
}

/// Decides whether to show Login or Dashboard
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFirebaseInitialized = false;
    try {
      Firebase.app();
      isFirebaseInitialized = true;
    } catch (_) {}

    if (!isFirebaseInitialized) {
      // Return login screen for tests where Firebase is not initialized
      return const LoginScreen();
    }

    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          );
        }

        // Logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Not logged in
        return const LoginScreen();
      },
    );
  }
}

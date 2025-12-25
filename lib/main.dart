import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:gestion_hotel/providers/auth_provider.dart';
import 'package:gestion_hotel/providers/booking_provider_legacy.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/screens/auth/login_screen.dart';
import 'package:gestion_hotel/features/app_shell/app_shell.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable debug overflow indicators in release mode
  debugPaintSizeEnabled = false;
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase initialisé');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion Hôtel',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: _themeMode,
      locale: const Locale('fr'),
      home: _MyAppHome(
        onThemeModeChanged: _setThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class _MyAppHome extends StatelessWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const _MyAppHome({
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return AppShell(
            onThemeModeChanged: onThemeModeChanged,
            currentThemeMode: currentThemeMode,
          );
        }
        return const LoginScreen();
      },
    );
  }
}

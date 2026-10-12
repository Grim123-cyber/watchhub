import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'theme_controller.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WatchHubApp());
}

class WatchHubApp extends StatelessWidget {
  const WatchHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController =
        ThemeController.instance;

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'WatchHub',

          themeMode: themeController.themeMode,

          // LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey.shade100,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            cardColor: Colors.white,

            inputDecorationTheme:
                const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
            ),

            elevatedButtonTheme:
                ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            bottomNavigationBarTheme:
                const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
          ),

          // DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor:
                const Color(0xFF121212),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            cardColor: const Color(0xFF1E1E1E),

            inputDecorationTheme:
                const InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFF1E1E1E),
            ),

            elevatedButtonTheme:
                ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            bottomNavigationBarTheme:
                const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
          ),

          // PASS THE THEME CONTROLLER TO SPLASH SCREEN
          home: const SplashScreen(),
        );
      },
    );
  }
}
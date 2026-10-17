
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'theme_controller.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/watchhub_theme.dart';

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

          // Preserve the user's light/dark mode selection.
          themeMode: themeController.themeMode,

          // Purple light theme.
          theme: WatchHubTheme.lightTheme,

          // Purple dark theme.
          darkTheme: WatchHubTheme.darkTheme,

          // Keep the existing app entry point.
          home: const SplashScreen(),
        );
      },
    );
  }
}

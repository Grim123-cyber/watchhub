
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../products/products_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color purple = Color(0xFF7C3AED);
  static const Color lavender = Color(0xFFC084FC);
  static const Color background = Color(0xFF10051F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final isPhone = width < 600;
          final isShort = height < 600;

          return Stack(
            fit: StackFit.expand,
            children: [
              // FULL-SCREEN BACKGROUND IMAGE
              Image.asset(
                'assets/images/watchhub_splash.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),

              // DARK GRADIENT OVERLAY
              // Keeps the background visible while making
              // the text and buttons easier to read.
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.12),
                      background.withValues(alpha: 0.55),
                      background.withValues(alpha: 0.94),
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // CONTENT OVER THE BACKGROUND IMAGE
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 700,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isPhone ? 24 : 48,
                        vertical: isShort ? 10 : 24,
                      ),
                      child: Column(
                        children: [
                          // Flexible empty space above the slogan.
                          const Spacer(flex: 3),

                          // LUXURY-STYLE BRAND SLOGAN
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Purple decorative accent
                              Container(
                                width: 46,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: lavender,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: purple.withValues(
                                        alpha: 0.8,
                                      ),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isShort ? 10 : 18),

                              // First line: elegant and light
                              Text(
                                'YOUR TIME.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isPhone ? 30 : 46,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: isPhone ? 3 : 7,
                                  height: 1.15,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 14,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),

                              // Second line: bold lavender
                              Text(
                                'YOUR STYLE.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFD8B4FE),
                                  fontSize: isPhone ? 30 : 46,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: isPhone ? 2 : 4,
                                  height: 1.2,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 14,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isShort ? 10 : 16),

                              // Thin divider
                              Container(
                                width: 180,
                                height: 1,
                                color: Colors.white.withValues(
                                  alpha: 0.4,
                                ),
                              ),

                              SizedBox(height: isShort ? 8 : 14),

                              // Premium supporting text
                              Text(
                                'TIMELESS ELEGANCE.\n'
                                'MADE FOR YOUR MOMENT.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(
                                    alpha: 0.92,
                                  ),
                                  fontSize: isPhone ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: isPhone ? 1.5 : 3,
                                  height: 1.8,
                                ),
                              ),
                            ],
                          ),

                          // Space between the slogan and buttons
                          const Spacer(flex: 2),

                          // RESPONSIVE BUTTONS
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 400,
                            ),
                            child: Column(
                              children: [
                                // EXPLORE WATCHES
                                SizedBox(
                                  width: double.infinity,
                                  height: isShort ? 46 : 54,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ProductsScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: purple,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: purple.withValues(
                                        alpha: 0.45,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Explore Watches',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // SIGN IN
                                SizedBox(
                                  width: double.infinity,
                                  height: isShort ? 44 : 50,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: lavender,
                                        width: 1.5,
                                      ),
                                      backgroundColor:
                                          Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isShort ? 8 : 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

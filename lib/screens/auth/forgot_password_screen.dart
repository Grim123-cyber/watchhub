
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Please enter your email address.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Check your inbox.',
          ),
          backgroundColor: Color(0xFF6500F5),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
          message = 'No account was found with this email.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Something went wrong. Please try again.';
      }

      showMessage(message);
    } catch (_) {
      showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6500F5),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF241044),
              Color(0xFF10051F),
              Color(0xFF080018),
            ],
          ),
        ),
        child: Stack(
          children: [
            const _PasswordGlow(
              alignment: Alignment.topRight,
              size: 320,
            ),
            const _PasswordGlow(
              alignment: Alignment.bottomLeft,
              size: 280,
            ),
            SafeArea(
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 8,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back to login',
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 500,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.06,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7200FF)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 45,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                // WatchHub logo
                                Center(
                                  child: Image.asset(
                                    'assets/images/watchhub_logo.png',
                                    width: 220,
                                    height: 100,
                                    fit: BoxFit.contain,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return const Column(
                                        children: [
                                          Icon(
                                            Icons.watch_outlined,
                                            color: Color(0xFFC084FC),
                                            size: 42,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'WATCHHUB',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight:
                                                  FontWeight.w900,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Lock icon
                                Center(
                                  child: Container(
                                    width: 82,
                                    height: 82,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF7200FF)
                                              .withValues(alpha: 0.30),
                                          const Color(0xFFC084FC)
                                              .withValues(alpha: 0.10),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFC084FC)
                                            .withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.lock_reset_rounded,
                                      color: Color(0xFFC084FC),
                                      size: 42,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                const Text(
                                  'Forgot Password?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 29,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  'No worries! Enter the email address '
                                  'connected to your WatchHub account. '
                                  'We will send you a link to reset '
                                  'your password.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFC9BEDF),
                                    fontSize: 14,
                                    height: 1.7,
                                  ),
                                ),

                                const SizedBox(height: 30),

                                const Text(
                                  'EMAIL ADDRESS',
                                  style: TextStyle(
                                    color: Color(0xFFD5C8EE),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextField(
                                  controller: emailController,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) {
                                    if (!isLoading) {
                                      resetPassword();
                                    }
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9588AC),
                                      fontSize: 13,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFFC084FC),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.06,
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.16,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFC084FC),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // Send reset email button
                                Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6500F5),
                                        Color(0xFF9A38FF),
                                        Color(0xFFC084FC),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7200FF)
                                            .withValues(alpha: 0.25),
                                        blurRadius: 18,
                                        offset: const Offset(0, 7),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.transparent,
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 23,
                                            height: 23,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Send Reset Email',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.bold,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Center(
                                  child: TextButton.icon(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Back to Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xFFC084FC),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'YOUR TIME. YOUR STYLE.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF9588AC),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordGlow extends StatelessWidget {
  final Alignment alignment;
  final double size;

  const _PasswordGlow({
    required this.alignment,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF7200FF).withValues(alpha: 0.20),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

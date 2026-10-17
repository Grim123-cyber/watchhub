
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  static const Color royalPurple = Color(0xFF4C1D95);
  static const Color brightPurple = Color(0xFF7C3AED);
  static const Color palePurple = Color(0xFFF5F3FF);

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadUserInformation();
  }

  Future<void> loadUserInformation() async {
    final User? user = auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> document =
          await db.collection('users').doc(user.uid).get();

      if (document.exists) {
        final Map<String, dynamic> data =
            document.data() ?? {};

        firstNameController.text =
            data['firstName']?.toString() ?? '';

        lastNameController.text =
            data['lastName']?.toString() ?? '';

        emailController.text =
            data['email']?.toString() ?? user.email ?? '';
      } else {
        emailController.text = user.email ?? '';
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load your information: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveInformation() async {
    final User? user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to update your information.'),
        ),
      );
      return;
    }

    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your first name and last name.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await db.collection('users').doc(user.uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Personal information updated successfully!',
          ),
          backgroundColor: royalPurple,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update information: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: brightPurple),
      filled: true,
      fillColor: palePurple.withValues(alpha: 0.55),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: brightPurple.withValues(alpha: 0.18),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: brightPurple,
          width: 1.8,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        backgroundColor: royalPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Personal Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: brightPurple,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // WatchHub logo
                      Center(
                        child: Container(
                          width: 94,
                          height: 94,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: royalPurple.withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/watchhub_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.watch,
                                size: 52,
                                color: royalPurple,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Your Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: royalPurple,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Keep your personal details up to date.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: brightPurple.withValues(
                              alpha: 0.12,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: royalPurple.withValues(
                                alpha: 0.06,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  color: brightPurple,
                                  size: 25,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Personal Details',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: royalPurple,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            TextField(
                              controller: firstNameController,
                              textCapitalization:
                                  TextCapitalization.words,
                              decoration: buildInputDecoration(
                                label: 'First Name',
                                icon: Icons.person_outline,
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextField(
                              controller: lastNameController,
                              textCapitalization:
                                  TextCapitalization.words,
                              decoration: buildInputDecoration(
                                label: 'Last Name',
                                icon: Icons.person_outline,
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextField(
                              controller: emailController,
                              readOnly: true,
                              keyboardType: TextInputType.emailAddress,
                              decoration: buildInputDecoration(
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 15,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Your email address cannot be changed here.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed:
                                    isSaving ? null : saveInformation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: royalPurple,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      royalPurple.withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: Text(
                                  isSaving
                                      ? 'Saving Changes...'
                                      : 'Save Changes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.watch_outlined,
                            size: 17,
                            color: brightPurple,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'WatchHub • Your Time. Your Style.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: royalPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

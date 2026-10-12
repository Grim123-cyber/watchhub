import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log out. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Profile'),
        ),
        body: const Center(
          child: Text('No user is currently logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: StreamBuilder<
                DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final Map<String, dynamic> data =
                    snapshot.data?.data() ?? {};

                final String firstName =
                    (data['firstName'] ?? '').toString().trim();

                final String lastName =
                    (data['lastName'] ?? '').toString().trim();

                final String fullName =
                    '$firstName $lastName'.trim();

                final String name = fullName.isNotEmpty
                    ? fullName
                    : (user.displayName?.trim().isNotEmpty == true
                        ? user.displayName!
                        : 'Administrator');

                final String email =
                    (data['email'] ?? user.email ?? 'No email available')
                        .toString();

                final String role =
                    (data['role'] ?? 'admin').toString();

                return Column(
                  children: [
                    const SizedBox(height: 20),

                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.blue,
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 42,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'WatchHub Administrator',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: const Text('Full Name'),
                            subtitle: Text(name),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email Address'),
                            subtitle: Text(email),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('Account Role'),
                            subtitle: Text(role),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme_controller.dart';
import '../personal_information/personal_information_screen.dart';
import '../help_support/help_support_screen.dart';
import '../orders/orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    final ThemeController themeController =
        ThemeController.instance;

    final bool isDarkMode =
        themeController.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // PROFILE IMAGE
            CircleAvatar(
              radius: 55,
              backgroundColor:
                  Colors.blue.shade100,
              child: const Icon(
                Icons.person,
                size: 65,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 15),

            // USER EMAIL
            Text(
              user?.email ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // ACCOUNT
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                    ),
                    title: const Text(
                      'Personal Information',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PersonalInformationScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.shopping_bag_outlined,
                    ),
                    title: const Text(
                      'My Orders',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // APPEARANCE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // DARK MODE TOGGLE
            Card(
              child: ListTile(
                leading: Icon(
                  isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: isDarkMode
                      ? Colors.amber
                      : Colors.orange,
                ),

                title: const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  isDarkMode
                      ? 'Dark mode is currently ON'
                      : 'Light mode is currently ON',
                ),

                trailing: Switch(
                  value: isDarkMode,
                  onChanged:
                      themeController.toggleTheme,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // OTHER
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Other',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                    ),
                    title: const Text(
                      'Help & Support',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                    ),
                    title: const Text(
                      'About WatchHub',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName:
                            'WatchHub',
                        applicationVersion:
                            '1.0.0',
                        applicationLegalese:
                            'WatchHub E-Commerce Application',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // LOGOUT
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth
                      .instance
                      .signOut();

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.of(context)
                      .popUntil(
                    (route) =>
                        route.isFirst,
                  );
                },

                icon: const Icon(
                  Icons.logout,
                ),

                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
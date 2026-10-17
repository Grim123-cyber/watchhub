
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme_controller.dart';
import '../personal_information/personal_information_screen.dart';
import '../help_support/help_support_screen.dart';
import '../orders/orders_screen.dart';

const Color profilePurple = Color(0xFF4C1D95);
const Color profileBrightPurple = Color(0xFF7C3AED);
const Color profilePalePurple = Color(0xFFF5F3FF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController themeController = ThemeController.instance;

  @override
  void initState() {
    super.initState();
    themeController.addListener(_refreshTheme);
  }

  void _refreshTheme() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    themeController.removeListener(_refreshTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = themeController.isDarkMode;
    final Color textColor =
        isDarkMode ? Colors.white : profilePurple;
    final Color cardColor =
        isDarkMode ? const Color(0xFF241638) : Colors.white;
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF171126) : const Color(0xFFF9F7FC);
    final Color secondaryTextColor =
        isDarkMode ? Colors.white70 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: profilePurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/watchhub_logo.png',
              width: 75,
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.watch, size: 30);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'My Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // PROFILE HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        profilePurple,
                        profileBrightPurple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white70,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 43,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 55,
                            color: profilePurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user?.displayName?.isNotEmpty == true
                            ? user!.displayName!
                            : 'WatchHub Customer',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? 'No email available',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.watch,
                              color: Colors.white,
                              size: 17,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Your Time. Your Style.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _sectionHeading('Account', textColor),

                const SizedBox(height: 10),

                _menuCard(
                  cardColor: cardColor,
                  children: [
                    _menuTile(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      subtitle: 'View and manage your details',
                      textColor: textColor,
                      subtitleColor: secondaryTextColor,
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
                    _divider(isDarkMode),
                    _menuTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      subtitle: 'View your purchases and order status',
                      textColor: textColor,
                      subtitleColor: secondaryTextColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const OrdersScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                _sectionHeading('Appearance', textColor),

                const SizedBox(height: 10),

                _menuCard(
                  cardColor: cardColor,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: profileBrightPurple.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: isDarkMode
                              ? Colors.amber
                              : Colors.orange,
                        ),
                      ),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        isDarkMode
                            ? 'Dark mode is currently ON'
                            : 'Light mode is currently ON',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),
                      trailing: Switch(
                        value: isDarkMode,
                        activeThumbColor: profileBrightPurple,
                        onChanged: (value) {
                          themeController.toggleTheme(value);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                _sectionHeading('Other', textColor),

                const SizedBox(height: 10),

                _menuCard(
                  cardColor: cardColor,
                  children: [
                    _menuTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help with your WatchHub account',
                      textColor: textColor,
                      subtitleColor: secondaryTextColor,
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
                    _divider(isDarkMode),
                    _menuTile(
                      icon: Icons.info_outline,
                      title: 'About WatchHub',
                      subtitle: 'Learn about our application',
                      textColor: textColor,
                      subtitleColor: secondaryTextColor,
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'WatchHub',
                          applicationVersion: '1.0.0',
                          applicationIcon: Image.asset(
                            'assets/images/watchhub_logo.png',
                            width: 55,
                            height: 55,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.watch,
                                size: 45,
                                color: profilePurple,
                              );
                            },
                          ),
                          applicationLegalese:
                              'WatchHub E-Commerce Application',
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // LOGOUT
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      if (!context.mounted) return;

                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'WATCHHUB  •  YOUR TIME. YOUR STYLE.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _menuCard({
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDarkMode) {
    return Divider(
      height: 1,
      indent: 65,
      color: isDarkMode
          ? Colors.white12
          : Colors.grey.shade200,
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: profileBrightPurple.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: profileBrightPurple,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: subtitleColor,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 15,
        color: subtitleColor,
      ),
      onTap: onTap,
    );
  }
}

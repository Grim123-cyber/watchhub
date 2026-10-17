
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../auth/login_screen.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'admin_profile_screen.dart';

const Color brandPurple = Color(0xFF4C1D95);
const Color brightPurple = Color(0xFF7C3AED);
const Color palePurple = Color(0xFFF5F3FF);
const Color pageBackground = Color(0xFFF8F5FF);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  final AdminService adminService = AdminService();

  bool isCheckingAdmin = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    try {
      final result = await adminService.isAdmin();

      if (!mounted) return;

      setState(() {
        isAdmin = result;
        isCheckingAdmin = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isAdmin = false;
        isCheckingAdmin = false;
      });
    }
  }

  void openAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );
  }

  void openAdminProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminProfileScreen(),
      ),
    );
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(
        'Unable to log out. Please try again.',
        isError: true,
      );
    }
  }

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : brandPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> deleteProduct(
    String productId,
    String productName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to delete "$productName"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      if (!mounted) return;
      showMessage('Product deleted successfully.');
    } catch (e) {
      if (!mounted) return;
      showMessage(
        'Failed to delete product: $e',
        isError: true,
      );
    }
  }

  Future<void> deleteUser(
    String userId,
    String email,
    String role,
  ) async {
    if (adminService.currentUser?.uid == userId) {
      showMessage(
        'You cannot delete your own admin account.',
        isError: true,
      );
      return;
    }

    if (role.toLowerCase() == 'admin') {
      showMessage(
        'Admin accounts cannot be deleted from this dashboard.',
        isError: true,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete User Profile?'),
          content: Text(
            'Are you sure you want to delete the Firestore profile for:\n\n'
            '$email\n\n'
            'This does not delete the Firebase Authentication account.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();

      if (!mounted) return;
      showMessage('User profile deleted successfully.');
    } catch (e) {
      if (!mounted) return;
      showMessage(
        'Failed to delete user: $e',
        isError: true,
      );
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      showMessage('Order status changed to $newStatus.');
    } catch (e) {
      if (!mounted) return;
      showMessage(
        'Failed to update order: $e',
        isError: true,
      );
    }
  }

  String formatPrice(dynamic value) {
    final amount = value is num ? value : 0;
    final digits = amount.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return '₦${buffer.toString()}';
  }

  String validOrderStatus(String status) {
    const statuses = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];

    return statuses.contains(status) ? status : 'Pending';
  }

  Widget buildLogo({
    double height = 40,
    double width = 105,
    Color fallbackColor = Colors.white,
  }) {
    return Image.asset(
      'assets/images/watchhub_logo.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          'WatchHub',
          style: TextStyle(
            color: fallbackColor,
            fontWeight: FontWeight.w900,
            fontSize: 19,
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAdmin) {
      return const Scaffold(
        backgroundColor: pageBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: brandPurple,
          ),
        ),
      );
    }

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: buildLogo(),
          backgroundColor: brandPurple,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: brandPurple,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You do not have permission to access this page.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [brandPurple, brightPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            buildLogo(),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Admin Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: openAdminProfile,
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: logOut,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 22,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // WELCOME BANNER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [brandPurple, brightPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: brandPurple.withValues(alpha: 0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Opacity(
                                opacity: 0.18,
                                child: buildLogo(
                                  height: 65,
                                  width: 100,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'WELCOME BACK',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Welcome, Admin!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Manage your WatchHub store in one place.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: brandPurple,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 13,
                                      ),
                                    ),
                                    onPressed: openAddProductScreen,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add New Product'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      _sectionTitle(
                        'Store Statistics',
                        'A quick look at your store',
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: isWide ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isWide ? 1.45 : 1.3,
                        children: [
                          StreamBuilder<int>(
                            stream: adminService.getUserCount(),
                            builder: (context, snapshot) =>
                                _buildStatCard(
                              title: 'Users',
                              value: '${snapshot.data ?? 0}',
                              icon: Icons.people_alt_outlined,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: adminService.getProductCount(),
                            builder: (context, snapshot) =>
                                _buildStatCard(
                              title: 'Products',
                              value: '${snapshot.data ?? 0}',
                              icon: Icons.watch_outlined,
                              color: brandPurple,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: adminService.getOrderCount(),
                            builder: (context, snapshot) =>
                                _buildStatCard(
                              title: 'Orders',
                              value: '${snapshot.data ?? 0}',
                              icon: Icons.shopping_bag_outlined,
                              color: const Color(0xFF059669),
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: adminService.getSupportCount(),
                            builder: (context, snapshot) =>
                                _buildStatCard(
                              title: 'Support',
                              value: '${snapshot.data ?? 0}',
                              icon: Icons.support_agent,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      // USERS
                      _sectionTitle(
                        'Customers & Users',
                        'View registered accounts',
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: adminService.getUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _loadingCard();
                          }

                          if (snapshot.hasError) {
                            return _emptyCard(
                              'Unable to load users.',
                              Icons.error_outline,
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _emptyCard(
                              'No users found.',
                              Icons.people_outline,
                            );
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;

                              final firstName =
                                  data['firstName']?.toString() ?? '';
                              final lastName =
                                  data['lastName']?.toString() ?? '';
                              final email =
                                  data['email']?.toString() ?? '';
                              final role =
                                  data['role']?.toString() ?? 'customer';
                              final isUserAdmin =
                                  role.toLowerCase() == 'admin';

                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: Color(0xFFE9E1F7),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: palePurple,
                                    child: Icon(
                                      Icons.person_outline,
                                      color: brandPurple,
                                    ),
                                  ),
                                  title: Text(
                                    '$firstName $lastName'.trim().isEmpty
                                        ? 'Unnamed User'
                                        : '$firstName $lastName'.trim(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(email),
                                  trailing: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 4,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isUserAdmin
                                              ? const Color(0xFFFEE2E2)
                                              : palePurple,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          role,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isUserAdmin
                                                ? Colors.red.shade700
                                                : brandPurple,
                                          ),
                                        ),
                                      ),
                                      if (!isUserAdmin)
                                        IconButton(
                                          tooltip: 'Delete User Profile',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => deleteUser(
                                            doc.id,
                                            email,
                                            role,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 34),

                      // PRODUCTS
                      _sectionTitle(
                        'Product Management',
                        'Edit or remove watches from your store',
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: adminService.getProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _loadingCard();
                          }

                          if (snapshot.hasError) {
                            return _emptyCard(
                              'Unable to load products.',
                              Icons.error_outline,
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _emptyCard(
                              'No products found. Add your first watch!',
                              Icons.watch_outlined,
                            );
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;

                              final name =
                                  data['name']?.toString() ??
                                      'Unnamed Product';
                              final category =
                                  data['category']?.toString() ?? '';
                              final price = data['price'];
                              final imageUrl =
                                  data['imageUrl']?.toString() ?? '';

                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: Color(0xFFE9E1F7),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 62,
                                      height: 68,
                                      color: palePurple,
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) =>
                                                  const Icon(
                                                Icons.watch_outlined,
                                                color: brandPurple,
                                                size: 32,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.watch_outlined,
                                              color: brandPurple,
                                              size: 32,
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      '$category\n${formatPrice(price)}',
                                      style: const TextStyle(height: 1.5),
                                    ),
                                  ),
                                  isThreeLine: true,
                                  trailing: Wrap(
                                    spacing: 0,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit Product',
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: brightPurple,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EditProductScreen(
                                                productId: doc.id,
                                                productData: data,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        tooltip: 'Delete Product',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => deleteProduct(
                                          doc.id,
                                          name,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 34),

                      // ORDERS
                      _sectionTitle(
                        'Order Management',
                        'Track purchases and update delivery status',
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: adminService.getOrders(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _loadingCard();
                          }

                          if (snapshot.hasError) {
                            return _emptyCard(
                              'Unable to load orders.',
                              Icons.error_outline,
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _emptyCard(
                              'No orders found.',
                              Icons.shopping_bag_outlined,
                            );
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;

                              final userId =
                                  data['userId']?.toString() ?? '';
                              final total = data['total'];
                              final status = validOrderStatus(
                                data['status']?.toString() ?? 'Pending',
                              );

                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: Color(0xFFE9E1F7),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: palePurple,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: brandPurple,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Order ${doc.id}',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Customer: $userId',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Total: ${formatPrice(total)}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: brandPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      DropdownButtonFormField<String>(
                                        initialValue: status,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText: 'Order Status',
                                          prefixIcon: const Icon(
                                            Icons.local_shipping_outlined,
                                          ),
                                          filled: true,
                                          fillColor: palePurple,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Pending',
                                            child: Text('Pending'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Processing',
                                            child: Text('Processing'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Shipped',
                                            child: Text('Shipped'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Delivered',
                                            child: Text('Delivered'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Cancelled',
                                            child: Text('Cancelled'),
                                          ),
                                        ],
                                        onChanged: (newStatus) {
                                          if (newStatus == null ||
                                              newStatus == status) {
                                            return;
                                          }

                                          updateOrderStatus(
                                            doc.id,
                                            newStatus,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 34),

                      // SUPPORT MESSAGES
                      _sectionTitle(
                        'Support Messages',
                        'Messages submitted by customers',
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: adminService.getSupportMessages(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _loadingCard();
                          }

                          if (snapshot.hasError) {
                            return _emptyCard(
                              'Unable to load support messages.',
                              Icons.error_outline,
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _emptyCard(
                              'No support messages found.',
                              Icons.support_agent,
                            );
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;

                              final subject =
                                  data['subject']?.toString() ??
                                      'No Subject';
                              final message =
                                  data['message']?.toString() ?? '';
                              final email =
                                  data['userEmail']?.toString() ?? '';
                              final status =
                                  data['status']?.toString() ?? 'Open';

                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: Color(0xFFE9E1F7),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(14),
                                  leading: const CircleAvatar(
                                    backgroundColor: palePurple,
                                    child: Icon(
                                      Icons.support_agent,
                                      color: brandPurple,
                                    ),
                                  ),
                                  title: Text(
                                    subject,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text('$message\n$email'),
                                  ),
                                  isThreeLine: true,
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3D6),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // BRANDED FOOTER
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              buildLogo(
                                height: 48,
                                width: 165,
                                fallbackColor: brandPurple,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'ADMIN PANEL',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Your Time. Your Style.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: brandPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9E1F7),
        ),
        boxShadow: [
          BoxShadow(
            color: brandPurple.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 25,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: brandPurple,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return const Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Center(
          child: CircularProgressIndicator(
            color: brandPurple,
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(String message, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE9E1F7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                icon,
                size: 35,
                color: brightPurple,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/admin_service.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import 'admin_profile_screen.dart';

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

  // =========================================================
  // CHECK ADMIN
  // =========================================================

  Future<void> checkAdmin() async {
    bool result = await adminService.isAdmin();

    if (!mounted) return;

    setState(() {
      isAdmin = result;
      isCheckingAdmin = false;
    });
  }

  // =========================================================
  // ADD PRODUCT
  // =========================================================

  void openAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }

  // =========================================================
  // DELETE PRODUCT
  // =========================================================

  Future<void> deleteProduct(
    String productId,
    String productName,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product?',
          ),
          content: Text(
            'Are you sure you want to delete "$productName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product deleted successfully. 🗑️',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete product: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // DELETE USER
  // =========================================================

  Future<void> deleteUser(
    String userId,
    String email,
    String role,
  ) async {
    // Prevent the admin from deleting their own account
    if (adminService.currentUser?.uid == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You cannot delete your own admin account.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prevent deleting another admin
    if (role == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Admin accounts cannot be deleted from this dashboard.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete User?',
          ),
          content: Text(
            'This will remove the user profile for:\n\n$email\n\n'
            'The Firebase Authentication account will not be deleted from the client app.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User profile deleted successfully. 🗑️',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete user: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // UPDATE ORDER STATUS
  // =========================================================

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order status changed to $newStatus. 📦',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update order: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------
    // CHECKING ADMIN
    // -------------------------------------------------------

    if (isCheckingAdmin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // -------------------------------------------------------
    // ACCESS DENIED
    // -------------------------------------------------------

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'You do not have permission to access this page.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // -------------------------------------------------------
    // ADMIN DASHBOARD
    // -------------------------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Admin Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProfileScreen(),
                ),
              );
            },
          ),

          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // =================================================
            // WELCOME
            // =================================================

            const Text(
              'Welcome, Admin 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage your WatchHub store from here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // ADD PRODUCT
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed:
                    openAddProductScreen,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Add New Product',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // STATISTICS
            // =================================================

            const Text(
              'Store Statistics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [

                // USERS
                StreamBuilder<int>(
                  stream:
                      adminService.getUserCount(),
                  builder:
                      (context, snapshot) {
                    return _buildStatCard(
                      title: 'Users',
                      value:
                          '${snapshot.data ?? 0}',
                      icon: Icons.people,
                    );
                  },
                ),

                // PRODUCTS
                StreamBuilder<int>(
                  stream:
                      adminService.getProductCount(),
                  builder:
                      (context, snapshot) {
                    return _buildStatCard(
                      title: 'Products',
                      value:
                          '${snapshot.data ?? 0}',
                      icon: Icons.watch,
                    );
                  },
                ),

                // ORDERS
                StreamBuilder<int>(
                  stream:
                      adminService.getOrderCount(),
                  builder:
                      (context, snapshot) {
                    return _buildStatCard(
                      title: 'Orders',
                      value:
                          '${snapshot.data ?? 0}',
                      icon:
                          Icons.shopping_bag,
                    );
                  },
                ),

                // SUPPORT
                StreamBuilder<int>(
                  stream:
                      adminService.getSupportCount(),
                  builder:
                      (context, snapshot) {
                    return _buildStatCard(
                      title: 'Support',
                      value:
                          '${snapshot.data ?? 0}',
                      icon:
                          Icons.support_agent,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 35),

            // =================================================
            // USERS
            // =================================================

            const Text(
              'Users',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream:
                  adminService.getUsers(),
              builder:
                  (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'Unable to load users.',
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'No users found.',
                  );
                }

                return Column(
                  children:
                      snapshot.data!.docs.map((doc) {

                    Map<String, dynamic> data =
                        doc.data()
                            as Map<String, dynamic>;

                    String firstName =
                        data['firstName'] ?? '';

                    String lastName =
                        data['lastName'] ?? '';

                    String email =
                        data['email'] ?? '';

                    String role =
                        data['role'] ??
                            'customer';

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(

                        leading:
                            const CircleAvatar(
                          child:
                              Icon(Icons.person),
                        ),

                        title: Text(
                          '$firstName $lastName',
                        ),

                        subtitle: Text(
                          email,
                        ),

                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [

                            Text(
                              role,
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color: role ==
                                        'admin'
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            if (role != 'admin')
                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red,
                                ),
                                tooltip:
                                    'Delete User',
                                onPressed: () {
                                  deleteUser(
                                    doc.id,
                                    email,
                                    role,
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

            const SizedBox(height: 35),

            // =================================================
            // PRODUCTS
            // =================================================

            const Text(
              'Products',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream:
                  adminService.getProducts(),
              builder:
                  (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'Unable to load products.',
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'No products found.',
                  );
                }

                return Column(
                  children:
                      snapshot.data!.docs.map((doc) {

                    Map<String, dynamic> data =
                        doc.data()
                            as Map<String, dynamic>;

                    String name =
                        data['name'] ??
                            'Unnamed Product';

                    int price =
                        data['price'] ?? 0;

                    String category =
                        data['category'] ?? '';

                    String imageUrl =
                        data['imageUrl'] ?? '';

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: ListTile(

                        // -----------------------------
                        // PRODUCT IMAGE
                        // -----------------------------

                        leading: SizedBox(
                          width: 55,
                          height: 55,
                          child:
                              imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        8,
                                      ),
                                      child:
                                          Image.network(
                                        imageUrl,
                                        fit:
                                            BoxFit.cover,
                                        errorBuilder:
                                            (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.watch,
                                            size: 35,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.watch,
                                      size: 35,
                                    ),
                        ),

                        // -----------------------------
                        // PRODUCT INFORMATION
                        // -----------------------------

                        title: Text(
                          name,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '$category\n₦$price',
                        ),

                        isThreeLine: true,

                        // -----------------------------
                        // EDIT + DELETE
                        // -----------------------------

                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [

                            // EDIT
                            IconButton(
                              icon:
                                  const Icon(
                                Icons.edit,
                                color:
                                    Colors.blue,
                              ),
                              tooltip:
                                  'Edit Product',
                              onPressed: () {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            EditProductScreen(
                                      productId:
                                          doc.id,
                                      productData:
                                          data,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // DELETE
                            IconButton(
                              icon:
                                  const Icon(
                                Icons.delete,
                                color:
                                    Colors.red,
                              ),
                              tooltip:
                                  'Delete Product',
                              onPressed: () {
                                deleteProduct(
                                  doc.id,
                                  name,
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

            const SizedBox(height: 35),

            // =================================================
            // ORDERS
            // =================================================

            const Text(
              'Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream:
                  adminService.getOrders(),
              builder:
                  (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'Unable to load orders.',
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'No orders found.',
                  );
                }

                return Column(
                  children:
                      snapshot.data!.docs.map((doc) {

                    Map<String, dynamic> data =
                        doc.data()
                            as Map<String, dynamic>;

                    String userId =
                        data['userId'] ?? '';

                    int total =
                        data['total'] ?? 0;

                    String status =
                        data['status'] ??
                            'Pending';

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Row(
                              children: [

                                const Icon(
                                  Icons
                                      .shopping_bag,
                                  size: 35,
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [

                                      Text(
                                        'Order ${doc.id}',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        'User: $userId',
                                      ),

                                      Text(
                                        'Total: ₦$total',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            const Text(
                              'Order Status',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            DropdownButtonFormField<
                                String>(
                              value:
                                  _validOrderStatus(
                                status,
                              ),
                              decoration:
                                  InputDecoration(
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                                prefixIcon:
                                    const Icon(
                                  Icons
                                      .local_shipping,
                                ),
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value:
                                      'Pending',
                                  child: Text(
                                    'Pending',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      'Processing',
                                  child: Text(
                                    'Processing',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      'Shipped',
                                  child: Text(
                                    'Shipped',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      'Delivered',
                                  child: Text(
                                    'Delivered',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      'Cancelled',
                                  child: Text(
                                    'Cancelled',
                                  ),
                                ),
                              ],

                              onChanged:
                                  (newStatus) {

                                if (newStatus ==
                                    null) {
                                  return;
                                }

                                if (newStatus ==
                                    status) {
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

            const SizedBox(height: 35),

            // =================================================
            // SUPPORT
            // =================================================

            const Text(
              'Support Messages',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream:
                  adminService
                      .getSupportMessages(),
              builder:
                  (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'Unable to load support messages.',
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'No support messages found.',
                  );
                }

                return Column(
                  children:
                      snapshot.data!.docs.map((doc) {

                    Map<String, dynamic> data =
                        doc.data()
                            as Map<String, dynamic>;

                    String subject =
                        data['subject'] ??
                            'No Subject';

                    String message =
                        data['message'] ?? '';

                    String email =
                        data['userEmail'] ?? '';

                    String status =
                        data['status'] ?? 'Open';

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(

                        leading:
                            const Icon(
                          Icons.support_agent,
                        ),

                        title: Text(
                          subject,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '$message\n$email',
                        ),

                        isThreeLine: true,

                        trailing: Text(
                          status,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.orange,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ORDER STATUS VALIDATION
  // =========================================================

  String _validOrderStatus(String status) {
    const validStatuses = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];

    if (validStatuses.contains(status)) {
      return status;
    }

    return 'Pending';
  }

  // =========================================================
  // STATISTICS CARD
  // =========================================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [

            Icon(
              icon,
              size: 35,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
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
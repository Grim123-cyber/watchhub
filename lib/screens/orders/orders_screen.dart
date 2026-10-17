
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/order_service.dart';

const Color ordersPurple = Color(0xFF4C1D95);
const Color ordersBrightPurple = Color(0xFF7C3AED);
const Color ordersPalePurple = Color(0xFFF5F3FF);

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String formatPrice(int price) {
    return '₦${price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}';
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.deepPurple;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange.shade800;
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Date unavailable';

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: ordersPurple,
        foregroundColor: Colors.white,
        title: Row(
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
            const SizedBox(width: 10),
            const Text(
              'My Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderService.getMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: ordersBrightPurple,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 55,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load your orders.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: const BoxDecoration(
                        color: ordersPalePurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 70,
                        color: ordersBrightPurple,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: ordersPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your watch purchases will appear here.\nYour next favourite timepiece awaits!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.6,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Continue Shopping'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ordersPurple,
                        side: const BorderSide(
                          color: ordersBrightPurple,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final documents = snapshot.data!.docs;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];

                  final data =
                      document.data() as Map<String, dynamic>;

                  final String orderId = document.id;

                  final int total =
                      (data['total'] as num?)?.toInt() ?? 0;

                  final String status =
                      (data['status'] ?? 'Pending').toString();

                  final List<dynamic> items =
                      data['items'] is List ? data['items'] : [];

                  final Timestamp? createdAt =
                      data['createdAt'] as Timestamp?;

                  final Color badgeColor = statusColor(status);

                  final String shortOrderId = orderId.substring(
                    0,
                    orderId.length > 8 ? 8 : orderId.length,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ordersPalePurple,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  color: ordersBrightPurple,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ordersPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '#$shortOrderId',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Date: ${formatDate(createdAt)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 30),

                          const Text(
                            'Items Ordered',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ordersPurple,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (items.isEmpty)
                            Text(
                              'Order item details are unavailable.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            )
                          else
                            ...items.map((item) {
                              final Map<String, dynamic> product =
                                  item is Map<String, dynamic>
                                      ? item
                                      : Map<String, dynamic>.from(item as Map);

                              final String name =
                                  (product['name'] ?? 'Unknown Product')
                                      .toString();

                              final int price =
                                  (product['price'] as num?)?.toInt() ?? 0;

                              final int quantity =
                                  (product['quantity'] as num?)?.toInt() ?? 1;

                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.watch_outlined,
                                      color: ordersBrightPurple,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '$name × $quantity',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatPrice(price * quantity),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                          const Divider(height: 24),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Order Total',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatPrice(total),
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: ordersPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

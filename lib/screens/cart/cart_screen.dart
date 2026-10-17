
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../orders/orders_screen.dart';

const Color cartPurple = Color(0xFF4C1D95);
const Color cartBrightPurple = Color(0xFF7C3AED);
const Color cartPalePurple = Color(0xFFF5F3FF);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService();
  final OrderService orderService = OrderService();

  bool isCheckingOut = false;

  String formatPrice(int price) {
    return '₦${price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}';
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : cartPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> removeItem(String productId) async {
    try {
      await cartService.removeFromCart(productId);
      showMessage('Item removed from cart.');
    } catch (e) {
      showMessage('Could not remove item. Please try again.',
          error: true);
    }
  }

  Future<void> checkout(
    List<QueryDocumentSnapshot> documents,
  ) async {
    if (documents.isEmpty || isCheckingOut) return;

    setState(() {
      isCheckingOut = true;
    });

    try {
      final List<Map<String, dynamic>> items = [];
      int total = 0;

      for (final document in documents) {
        final data = document.data() as Map<String, dynamic>;

        final String productId =
            (data['productId'] ?? document.id).toString();

        final String name =
            (data['name'] ?? 'Unknown Product').toString();

        final int price =
            (data['price'] as num?)?.toInt() ?? 0;

        final int quantity =
            (data['quantity'] as num?)?.toInt() ?? 1;

        items.add({
          'productId': productId,
          'name': name,
          'price': price,
          'quantity': quantity,
        });

        total += price * quantity;
      }

      final String orderId = await orderService.createOrder(
        items: items,
        total: total,
      );

      for (final document in documents) {
        await cartService.removeFromCart(document.id);
      }

      if (!mounted) return;

      showMessage('Order created successfully! ID: $orderId');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OrdersScreen(),
        ),
      );
    } catch (e) {
      showMessage(
        'Checkout failed. Please try again.\n$e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isCheckingOut = false;
        });
      }
    }
  }

  Widget buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: cartPalePurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 75,
                color: cartBrightPurple,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is waiting!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cartPurple,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You have not added any watches yet.\nFind a timepiece that matches your style.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Continue Shopping'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cartPurple,
                side: const BorderSide(color: cartBrightPurple),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartItem(QueryDocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    final String productId =
        (data['productId'] ?? document.id).toString();

    final String name =
        (data['name'] ?? 'Unknown Product').toString();

    final int price =
        (data['price'] as num?)?.toInt() ?? 0;

    final int quantity =
        (data['quantity'] as num?)?.toInt() ?? 1;

    final String imageUrl =
        (data['imageUrl'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 85,
                height: 95,
                color: cartPalePurple,
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.watch_outlined,
                        size: 48,
                        color: cartBrightPurple,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.watch_outlined,
                            size: 48,
                            color: cartBrightPurple,
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cartPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(price),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: cartBrightPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Quantity: $quantity',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Subtotal: ${formatPrice(price * quantity)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove item',
              onPressed: () => removeItem(productId),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: cartPurple,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/images/watchhub_logo.png',
              width: 70,
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.watch, size: 30);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'My Cart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartService.getCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: cartBrightPurple),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'We could not load your cart.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return buildEmptyCart();
          }

          final documents = snapshot.data!.docs;
          int total = 0;

          for (final document in documents) {
            final data = document.data() as Map<String, dynamic>;
            final int price =
                (data['price'] as num?)?.toInt() ?? 0;
            final int quantity =
                (data['quantity'] as num?)?.toInt() ?? 1;

            total += price * quantity;
          }

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          '${documents.length} item(s) in your cart',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...documents.map(buildCartItem),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatPrice(total),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: cartPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Shipping and any additional charges will be shown at checkout if applicable.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: isCheckingOut
                                ? null
                                : () => checkout(documents),
                            icon: isCheckingOut
                                ? const SizedBox(
                                    height: 21,
                                    width: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_outline),
                            label: Text(
                              isCheckingOut
                                  ? 'Creating Order...'
                                  : 'Proceed to Checkout',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cartPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color checkoutPurple = Color(0xFF4C1D95);
const Color checkoutBrightPurple = Color(0xFF7C3AED);
const Color checkoutPalePurple = Color(0xFFF5F3FF);

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final String name;
  final int price;
  final String imageUrl;

  const CheckoutScreen({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  int quantity = 1;
  bool isPlacingOrder = false;

  String selectedPayment = 'Demo Card Payment';

  String formatPrice(int price) {
    return '₦${price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}';
  }

  int get totalPrice => widget.price * quantity;

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Colors.red.shade700 : checkoutPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildPaymentOption({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final bool isSelected = selectedPayment == title;

    return InkWell(
      onTap: isPlacingOrder
          ? null
          : () {
              setState(() {
                selectedPayment = title;
              });
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? checkoutPalePurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? checkoutBrightPurple
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: checkoutPalePurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: checkoutBrightPurple,
                size: 27,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: checkoutPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: selectedPayment,
              activeColor: checkoutBrightPurple,
              onChanged: isPlacingOrder
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        selectedPayment = value;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> placeOrder() async {
    if (isPlacingOrder) return;

    final User? user = auth.currentUser;

    if (user == null) {
      showMessage(
        'Please log in before placing an order.',
        error: true,
      );
      return;
    }

    if (quantity < 1 || widget.price <= 0) {
      showMessage(
        'This order has an invalid quantity or price.',
        error: true,
      );
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      await db.collection('orders').add({
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'items': [
          {
            'productId': widget.productId,
            'name': widget.name,
            'price': widget.price,
            'quantity': quantity,
            'imageUrl': widget.imageUrl,
          },
        ],
        'total': totalPrice,

        // Demo payment information only.
        'paymentMethod': selectedPayment,
        'paymentStatus': 'Simulated',
        'isDemoPayment': true,

        // Keep the normal order status for order management.
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      final bool? continueShopping = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: checkoutPalePurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 65,
                    color: checkoutBrightPurple,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Demo Payment Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: checkoutPurple,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your demo order has been created successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 14),
                _confirmationRow(
                  'Order total',
                  formatPrice(totalPrice),
                ),
                const SizedBox(height: 8),
                _confirmationRow(
                  'Payment method',
                  selectedPayment,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Demo only. No real payment was made, '
                    'and no money was charged.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: checkoutPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (continueShopping == true) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      showMessage(
        'Unable to place order. Please try again.\n$error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  Widget _confirmationRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: checkoutPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProductImage() {
    return Container(
      width: 110,
      height: 115,
      decoration: BoxDecoration(
        color: checkoutPalePurple,
        borderRadius: BorderRadius.circular(14),
      ),
      child: widget.imageUrl.trim().isEmpty
          ? const Icon(
              Icons.watch_outlined,
              size: 60,
              color: checkoutBrightPurple,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.watch_outlined,
                    size: 60,
                    color: checkoutBrightPurple,
                  );
                },
              ),
            ),
    );
  }

  Widget buildSummaryRow(
    String title,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: bold ? 20 : 15,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: checkoutPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: checkoutPurple,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/watchhub_logo.png',
              height: 38,
              width: 75,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.watch, size: 30);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Checkout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle('Order Summary'),
                const SizedBox(height: 16),

                Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProductImage(),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: checkoutPurple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatPrice(widget.price),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: checkoutBrightPurple,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: quantity > 1 &&
                                            !isPlacingOrder
                                        ? () {
                                            setState(() => quantity--);
                                          }
                                        : null,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: checkoutBrightPurple,
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: !isPlacingOrder
                                        ? () {
                                            setState(() => quantity++);
                                          }
                                        : null,
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                    color: checkoutBrightPurple,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                buildSectionTitle('Payment Summary'),
                const SizedBox(height: 14),

                Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        buildSummaryRow(
                          'Price per watch',
                          formatPrice(widget.price),
                        ),
                        buildSummaryRow(
                          'Quantity',
                          '$quantity',
                        ),
                        const Divider(height: 25),
                        buildSummaryRow(
                          'Total',
                          formatPrice(totalPrice),
                          bold: true,
                          valueColor: checkoutPurple,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                buildSectionTitle('Choose Payment Method'),
                const SizedBox(height: 8),
                Text(
                  'Select a demo option to continue.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),

                buildPaymentOption(
                  title: 'Demo Card Payment',
                  description: 'Simulated card payment',
                  icon: Icons.credit_card,
                ),

                buildPaymentOption(
                  title: 'Demo Bank Transfer',
                  description: 'Simulated bank transfer',
                  icon: Icons.account_balance,
                ),

                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.shade200,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.brown,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'DEMO PAYMENT ONLY. No real card details '
                          'are collected. No money will be charged '
                          'or transferred.',
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isPlacingOrder ? null : placeOrder,
                    icon: isPlacingOrder
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      isPlacingOrder
                          ? 'Creating Demo Order...'
                          : 'Pay ${formatPrice(totalPrice)} (Demo)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: checkoutPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'WATCHHUB • YOUR TIME. YOUR STYLE.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: checkoutPurple,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
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
}
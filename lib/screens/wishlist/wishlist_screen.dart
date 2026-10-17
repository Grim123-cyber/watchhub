
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/wishlist_service.dart';

const Color wishlistPurple = Color(0xFF4C1D95);
const Color wishlistBrightPurple = Color(0xFF7C3AED);
const Color wishlistPalePurple = Color(0xFFF5F3FF);

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService wishlistService = WishlistService();

  Future<void> removeItem(String productId) async {
    try {
      await wishlistService.removeFromWishlist(productId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from your wishlist.'),
          backgroundColor: wishlistPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not remove item: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String formatPrice(int price) {
    return '₦${price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: wishlistPurple,
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
            const Expanded(
              child: Text(
                'My Wishlist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: wishlistService.getWishlist(),
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: wishlistBrightPurple,
              ),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 55,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load your wishlist.',
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

          // EMPTY WISHLIST
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
                        color: wishlistPalePurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 70,
                        color: wishlistBrightPurple,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Your wishlist is empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: wishlistPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Save the watches you love and keep\nyour favourite timepieces close.',
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
                        foregroundColor: wishlistPurple,
                        side: const BorderSide(
                          color: wishlistBrightPurple,
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

                  final String productId =
                      (data['productId'] ?? document.id).toString();

                  final String name =
                      (data['name'] ?? 'Unknown Product').toString();

                  final int price =
                      (data['price'] as num?)?.toInt() ?? 0;

                  final String imageUrl =
                      (data['imageUrl'] ?? '').toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // WATCH IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 90,
                              height: 100,
                              color: wishlistPalePurple,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.watch,
                                          size: 48,
                                          color: wishlistBrightPurple,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.watch,
                                      size: 48,
                                      color: wishlistBrightPurple,
                                    ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // PRODUCT DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: wishlistPurple,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatPrice(price),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: wishlistBrightPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      size: 15,
                                      color: wishlistBrightPurple,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        'Saved to wishlist',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // REMOVE BUTTON
                          IconButton(
                            tooltip: 'Remove from wishlist',
                            onPressed: () => removeItem(productId),
                            icon: const Icon(
                              Icons.favorite,
                              color: wishlistBrightPurple,
                              size: 27,
                            ),
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

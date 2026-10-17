
import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';

import '../cart/cart_screen.dart';
import '../reviews/reviews_screen.dart';
import '../checkout/checkout_screen.dart';

const Color brandPurple = Color(0xFF4C1D95);
const Color brightPurple = Color(0xFF7C3AED);
const Color palePurple = Color(0xFFF5F3FF);

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String name;
  final int price;
  final String category;
  final String description;
  final String imageUrl;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  final CartService cartService = CartService();
  final WishlistService wishlistService = WishlistService();

  bool isAddingToCart = false;
  bool isAddingToWishlist = false;
  bool isWishlisted = false;

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
        backgroundColor: error ? Colors.red.shade700 : brandPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> addToCart() async {
    if (isAddingToCart) return;

    setState(() => isAddingToCart = true);

    try {
      await cartService.addToCart(
        productId: widget.productId,
        name: widget.name,
        price: widget.price,
      );

      showMessage('${widget.name} added to cart!');
    } catch (e) {
      showMessage('Could not add product to cart. Please try again.',
          error: true);
    } finally {
      if (mounted) {
        setState(() => isAddingToCart = false);
      }
    }
  }

  Future<void> addToWishlist() async {
    if (isAddingToWishlist) return;

    setState(() => isAddingToWishlist = true);

    try {
      await wishlistService.addToWishlist(
        productId: widget.productId,
        name: widget.name,
        price: widget.price,
      );

      if (!mounted) return;

      setState(() => isWishlisted = true);
      showMessage('${widget.name} added to wishlist!');
    } catch (e) {
      showMessage(
        'Could not update your wishlist. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isAddingToWishlist = false);
      }
    }
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
  }

  void openReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsScreen(
          productId: widget.productId,
          productName: widget.name,
        ),
      ),
    );
  }

  void buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          productId: widget.productId,
          name: widget.name,
          price: widget.price,
          imageUrl: widget.imageUrl,
        ),
      ),
    );
  }

  Widget buildProductImage() {
    return Container(
      width: double.infinity,
      height: 330,
      color: Colors.white,
      child: widget.imageUrl.trim().isEmpty
          ? _imagePlaceholder()
          : Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: CircularProgressIndicator(
                    color: brightPurple,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _imagePlaceholder();
              },
            ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: palePurple,
      child: const Center(
        child: Icon(
          Icons.watch_outlined,
          size: 130,
          color: brightPurple,
        ),
      ),
    );
  }

  Widget specificationRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: brandPurple,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: brandPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/watchhub_logo.png',
              height: 38,
              width: 75,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.watch,
                  size: 30,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Product Details',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add to wishlist',
            onPressed:
                isAddingToWishlist || isWishlisted
                    ? null
                    : addToWishlist,
            icon: isAddingToWishlist
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isWishlisted
                        ? Colors.pinkAccent
                        : Colors.white,
                  ),
          ),
          IconButton(
            tooltip: 'Open cart',
            onPressed: openCart,
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProductImage(),

                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          widget.category,
                          style: const TextStyle(
                            color: brandPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF241638),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        formatPrice(widget.price),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: brightPurple,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          ...List.generate(
                            4,
                            (index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 23,
                            ),
                          ),
                          const Icon(
                            Icons.star_border,
                            color: Colors.amber,
                            size: 23,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '4.0',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _sectionTitle('Description'),
                      const SizedBox(height: 10),

                      Text(
                        widget.description.trim().isEmpty
                            ? 'No description is available for this watch yet.'
                            : widget.description,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.7,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _sectionTitle('Specifications'),
                      const SizedBox(height: 10),

                      specificationRow('Category', widget.category),
                      specificationRow('Product ID', widget.productId),
                      specificationRow('Availability', 'In Stock'),
                      specificationRow('Shipping', 'Available'),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: openReviews,
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text(
                            'View Reviews',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: brandPurple,
                            side: const BorderSide(
                              color: brightPurple,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: isAddingToCart ? null : addToCart,
                          icon: isAddingToCart
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.shopping_cart),
                          label: Text(
                            isAddingToCart
                                ? 'Adding...'
                                : 'Add to Cart',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: buyNow,
                          icon: const Icon(Icons.bolt),
                          label: const Text(
                            'Buy Now',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: TextButton(
                          onPressed: openCart,
                          child: const Text(
                            'View Cart',
                            style: TextStyle(
                              color: brandPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Center(
                        child: Text(
                          'WATCHHUB  •  YOUR TIME. YOUR STYLE.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: brandPurple,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
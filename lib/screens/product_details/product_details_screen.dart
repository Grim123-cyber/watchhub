import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';

import '../cart/cart_screen.dart';
import '../reviews/reviews_screen.dart';
import '../checkout/checkout_screen.dart';

class ProductDetailsScreen
    extends StatefulWidget {
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
  final CartService cartService =
      CartService();

  final WishlistService wishlistService =
      WishlistService();

  bool isAddingToCart = false;
  bool isAddingToWishlist = false;

  String formatPrice(int price) {
    return '₦${price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}';
  }

  Future<void> addToCart() async {
    setState(() {
      isAddingToCart = true;
    });

    try {
      await cartService.addToCart(
        productId: widget.productId,
        name: widget.name,
        price: widget.price,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Product added to cart!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  Future<void> addToWishlist() async {
    setState(() {
      isAddingToWishlist = true;
    });

    try {
      await wishlistService.addToWishlist(
        productId: widget.productId,
        name: widget.name,
        price: widget.price,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Product added to wishlist!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isAddingToWishlist = false;
      });
    }
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CartScreen(),
      ),
    );
  }

  void openReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReviewsScreen(
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
    if (widget.imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 330,
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(
            Icons.watch,
            size: 160,
            color: Colors.blue,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 330,
      color: Colors.white,
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: Icon(
                Icons.watch,
                size: 160,
                color: Colors.blue,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget specificationRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color:
                    Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed:
                addToWishlist,
            icon: isAddingToWishlist
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.favorite_border,
                  ),
          ),
          IconButton(
            onPressed: openCart,
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // Product Image
            buildProductImage(),

            const SizedBox(height: 20),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // Category
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.blue.shade50,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      widget.category,
                      style: TextStyle(
                        color:
                            Colors.blue.shade700,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name
                  Text(
                    widget.name,
                    style:
                        const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Price
                  Text(
                    formatPrice(
                      widget.price,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(
                        4,
                        (index) =>
                            const Icon(
                          Icons.star,
                          color:
                              Colors.amber,
                          size: 25,
                        ),
                      ),
                      const Icon(
                        Icons.star_border,
                        color:
                            Colors.amber,
                        size: 25,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '4.0',
                        style: TextStyle(
                          color: Colors
                              .grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Specifications
                  const Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  specificationRow(
                    'Category',
                    widget.category,
                  ),

                  specificationRow(
                    'Product ID',
                    widget.productId,
                  ),

                  specificationRow(
                    'Availability',
                    'In Stock',
                  ),

                  specificationRow(
                    'Shipping',
                    'Available',
                  ),

                  const SizedBox(height: 25),

                  // Reviews
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          openReviews,
                      icon: const Icon(
                        Icons
                            .rate_review_outlined,
                      ),
                      label: const Text(
                        'View Reviews',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Add to Cart
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          isAddingToCart
                              ? null
                              : addToCart,
                      icon:
                          isAddingToCart
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .shopping_cart,
                                ),
                      label: Text(
                        isAddingToCart
                            ? 'Adding...'
                            : 'Add to Cart',
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Buy Now
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child:
                        ElevatedButton(
                      onPressed: buyNow,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                        foregroundColor:
                            Colors.white,
                      ),
                      child: const Text(
                        'Buy Now',
                        style:
                            TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // View Cart
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child:
                        TextButton(
                      onPressed:
                          openCart,
                      child:
                          const Text(
                        'View Cart',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
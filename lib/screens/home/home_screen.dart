
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/watchhub_theme.dart';
import '../products/products_screen.dart';
import '../product_details/product_details_screen.dart';
import '../cart/cart_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatPrice(int price) {
    return '₦${price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}';
  }

  int getPrice(dynamic price) {
    if (price is num) {
      return price.toInt();
    }

    return int.tryParse(price.toString()) ?? 0;
  }

  void openProducts({
    String? category,
    String? search,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          initialCategory: category,
          initialSearch: search,
        ),
      ),
    );
  }

  void searchProducts() {
    final String search = searchController.text.trim();

    openProducts(
      search: search.isEmpty ? null : search,
    );
  }

  Future<void> openCategory(String category) async {
    try {
      // Check both common spellings for Sports.
      Query<Map<String, dynamic>> query =
          db.collection('products');

      if (category == 'Sports') {
        final results = await Future.wait([
          query
              .where('category', isEqualTo: 'Sports')
              .limit(1)
              .get(),
          query
              .where('category', isEqualTo: 'Sport')
              .limit(1)
              .get(),
        ]);

        if (!mounted) return;

        if (results.every((result) => result.docs.isEmpty)) {
          showMessage(
            'No $category watches are available yet. '
            'Please check back soon!',
          );
          return;
        }

        openProducts(category: category);
        return;
      }

      final result = await query
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      if (!mounted) return;

      if (result.docs.isEmpty) {
        showMessage(
          'No $category watches are available yet. '
          'Please check back soon!',
        );
        return;
      }

      openProducts(category: category);
    } catch (_) {
      if (!mounted) return;

      showMessage(
        'Could not check $category watches. Please try again.',
      );
    }
  }

  void openProductDetails(
    String productId,
    Map<String, dynamic> data,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: productId,
          name: (data['name'] ?? 'Watch').toString(),
          price: getPrice(data['price']),
          category: (data['category'] ?? 'Watch').toString(),
          description: (data['description'] ?? '').toString(),
          imageUrl: (data['imageUrl'] ?? '').toString(),
        ),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WatchHubColors.royalPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Responsive product image. The supplied height is calculated
  // from the actual width available to each product card.
  Widget buildProductImage(
    String imageUrl, {
    required double height,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ColoredBox(
        color: WatchHubColors.softLavender,
        child: imageUrl.trim().isEmpty
            ? const Center(
                child: Icon(
                  Icons.watch_outlined,
                  size: 70,
                  color: WatchHubColors.electricPurple,
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: height,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(
                      color: WatchHubColors.electricPurple,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.watch_outlined,
                      size: 70,
                      color: WatchHubColors.electricPurple,
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Original purple promotional banner, with responsive sizing.
  Widget buildPurpleBanner() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double bannerPadding = screenWidth < 360 ? 18 : 24;
    final double headingSize = screenWidth < 360 ? 30 : 34;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(bannerPadding),
      decoration: BoxDecoration(
        gradient: WatchHubTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: WatchHubColors.electricPurple.withValues(
              alpha: 0.22,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: 0,
            child: Icon(
              Icons.watch_outlined,
              size: screenWidth < 360 ? 90 : 115,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: const Text(
                  '✦  TIMELESS ELEGANCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your Time.\nYour Style.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: headingSize,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Discover the perfect watch for every moment.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () => openProducts(),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Explore Watches'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: WatchHubColors.royalPurple,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCategory(String title, IconData icon) {
    return SizedBox(
      width: 104,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => openCategory(title),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: WatchHubColors.lavender.withValues(
                    alpha: 0.28,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: WatchHubColors.electricPurple.withValues(
                      alpha: 0.05,
                    ),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: WatchHubTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Each product card receives a calculated image height and total
  // tile height from buildProductGrid().
  Widget buildProductCard(
    String productId,
    Map<String, dynamic> data, {
    required double imageHeight,
  }) {
    final String name = (data['name'] ?? 'Watch').toString();
    final int price = getPrice(data['price']);
    final String category =
        (data['category'] ?? 'Watch').toString();
    final String imageUrl = (data['imageUrl'] ?? '').toString();

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openProductDetails(productId, data),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: WatchHubColors.lavender.withValues(
                alpha: 0.22,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
                child: buildProductImage(
                  imageUrl,
                  height: imageHeight,
                ),
              ),

              // Expanded uses the remaining height of the grid tile.
              // The grid reserves enough space for this section.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: WatchHubColors.electricPurple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatPrice(price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: WatchHubColors.electricPurple,
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
  }

  // Responsive featured-product grid.
  Widget buildProductGrid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
    double availableWidth,
  ) {
    final int columns;

    if (availableWidth >= 1200) {
      columns = 4;
    } else if (availableWidth >= 700) {
      columns = 3;
    } else {
      columns = 2;
    }

    const double spacing = 12;

    final double cardWidth =
        (availableWidth - spacing * (columns - 1)) / columns;

    // Keep the watches large enough to see, while allowing them
    // to shrink when there is less horizontal room.
    final double imageHeight =
        (cardWidth * 0.84).clamp(110.0, 180.0).toDouble();

    // Flutter scales Text widgets according to system settings.
    // Increase tile height as text scaling increases.
    final double textScale = MediaQuery.textScalerOf(context)
        .scale(1.0)
        .clamp(1.0, 2.0)
        .toDouble();

    // This explicitly reserves space for category, two-line name,
    // price, padding, and text scaling. It replaces the old fixed
    // aspect ratio that caused the 27px and 49px overflows.
    final double textAreaHeight = 140 * textScale;
    final double cardHeight = imageHeight + textAreaHeight;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: cardHeight,
      ),
      itemBuilder: (context, index) {
        final doc = products[index];

        return buildProductCard(
          doc.id,
          doc.data(),
          imageHeight: imageHeight,
        );
      },
    );
  }

  void openWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WishlistScreen(),
      ),
    );
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  Widget buildSectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget buildWatchHubLogo({
    double height = 42,
    double width = 140,
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
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double logoWidth = screenWidth < 360 ? 110 : 140;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: WatchHubColors.royalPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: buildWatchHubLogo(width: logoWidth),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: WatchHubTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            onPressed: openWishlist,
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          IconButton(
            tooltip: 'Shopping cart',
            onPressed: openCart,
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            screenWidth < 360 ? 12 : 16,
            20,
            screenWidth < 360 ? 12 : 16,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to WatchHub 👋',
                style: TextStyle(
                  fontSize: screenWidth < 360 ? 22 : 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Find the perfect watch for you.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? Colors.white70
                      : Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 22),

              buildPurpleBanner(),

              const SizedBox(height: 24),

              TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchProducts(),
                decoration: InputDecoration(
                  hintText: 'Search watches by name or category...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: WatchHubColors.electricPurple,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Search watches',
                    onPressed: searchProducts,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: WatchHubColors.electricPurple,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: WatchHubColors.lavender.withValues(
                        alpha: 0.30,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: WatchHubColors.electricPurple,
                      width: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              buildSectionHeading('Shop by Category'),
              const SizedBox(height: 14),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildCategory('Luxury', Icons.diamond_outlined),
                    buildCategory('Digital', Icons.watch_outlined),
                    buildCategory(
                      'Sports',
                      Icons.sports_soccer_outlined,
                    ),
                    buildCategory(
                      'Classic',
                      Icons.access_time_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Featured Watches',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => openProducts(),
                    child: const Text(
                      'View All  →',
                      style: TextStyle(
                        color: WatchHubColors.electricPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: db
                    .collection('products')
                    .limit(4)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: CircularProgressIndicator(
                          color: WatchHubColors.electricPurple,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 40,
                              color: WatchHubColors.electricPurple,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Unable to load products right now.',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {});
                              },
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final products = snapshot.data?.docs ?? [];

                  if (products.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: WatchHubColors.lavender.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.watch_outlined,
                            size: 48,
                            color: WatchHubColors.electricPurple,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Your next favourite watch awaits.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'New products will appear here once added.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return buildProductGrid(
                        products,
                        constraints.maxWidth,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    buildWatchHubLogo(
                      height: 55,
                      width: 180,
                      fallbackColor: WatchHubColors.electricPurple,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Your Time. Your Style.',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              selectedIndex = 0;
            });
          } else if (index == 1) {
            openWishlist();
          } else if (index == 2) {
            openCart();
          } else if (index == 3) {
            openProfile();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

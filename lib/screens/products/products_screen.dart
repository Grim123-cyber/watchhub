
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../product_details/product_details_screen.dart';

const Color productsPurple = Color(0xFF4C1D95);
const Color productsBrightPurple = Color(0xFF7C3AED);
const Color productsPalePurple = Color(0xFFF5F3FF);

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearch;

  const ProductsScreen({
    super.key,
    this.initialCategory,
    this.initialSearch,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController searchController =
      TextEditingController();

  final List<String> categories = [
    'All',
    'Luxury',
    'Digital',
    'Sports',
    'Classic',
  ];

  late String selectedCategory;

  @override
  void initState() {
    super.initState();

    final requestedCategory = widget.initialCategory ?? 'All';

    selectedCategory = categories.firstWhere(
      (category) =>
          category.toLowerCase() == requestedCategory.toLowerCase(),
      orElse: () => 'All',
    );

    searchController.text = widget.initialSearch ?? '';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  int getPrice(dynamic price) {
    if (price is num) {
      return price.toInt();
    }

    return int.tryParse(price?.toString() ?? '') ?? 0;
  }

  String formatPrice(int price) {
    return '₦${price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}';
  }

  bool matchesCategory(String productCategory) {
    if (selectedCategory == 'All') {
      return true;
    }

    final productValue = productCategory.trim().toLowerCase();
    final selectedValue = selectedCategory.trim().toLowerCase();

    if (selectedValue == 'sports') {
      return productValue == 'sports' || productValue == 'sport';
    }

    return productValue == selectedValue;
  }

  bool matchesSearch(Map<String, dynamic> data) {
    final searchText = searchController.text.trim().toLowerCase();

    if (searchText.isEmpty) {
      return true;
    }

    final name = (data['name'] ?? '').toString().toLowerCase();
    final category =
        (data['category'] ?? '').toString().toLowerCase();
    final description =
        (data['description'] ?? '').toString().toLowerCase();

    return name.contains(searchText) ||
        category.contains(searchText) ||
        description.contains(searchText);
  }

  void openProductDetails(
    String productId,
    Map<String, dynamic> data,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
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

  // Responsive product image with a placeholder and loading indicator.
  Widget buildProductImage(String imageUrl, double imageHeight) {
    return SizedBox(
      width: double.infinity,
      height: imageHeight,
      child: ColoredBox(
        color: productsPalePurple,
        child: imageUrl.trim().isEmpty
            ? const Center(
                child: Icon(
                  Icons.watch_outlined,
                  size: 48,
                  color: productsBrightPurple,
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: imageHeight,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: productsBrightPurple,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.watch_outlined,
                      size: 48,
                      color: productsBrightPurple,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget buildProductCard(
    String productId,
    Map<String, dynamic> data,
    double imageHeight,
  ) {
    final String name = (data['name'] ?? 'Watch').toString();
    final String category = (data['category'] ?? 'Watch').toString();
    final String imageUrl = (data['imageUrl'] ?? '').toString();
    final int price = getPrice(data['price']);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: productsPurple.withValues(alpha: 0.08),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: productsBrightPurple.withValues(alpha: 0.13),
        ),
      ),
      child: InkWell(
        onTap: () => openProductDetails(productId, data),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProductImage(imageUrl, imageHeight),

            // The content uses its natural height instead of an
            // artificially restricted title box.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: productsBrightPurple,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF241638),
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    const SizedBox(height: 5),

                    Text(
                      formatPrice(price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: productsPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyMessage(String message, String details) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.watch_off_outlined,
              size: 54,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: productsPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductGrid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;

            // Adjust the number of columns to the available width.
            final int columnCount;

            if (availableWidth >= 1200) {
              columnCount = 5;
            } else if (availableWidth >= 900) {
              columnCount = 4;
            } else if (availableWidth >= 600) {
              columnCount = 3;
            } else {
              columnCount = 2;
            }

            const double horizontalPadding = 10;
            const double spacing = 12;

            final double cardWidth =
                (availableWidth -
                    (horizontalPadding * 2) -
                    (spacing * (columnCount - 1))) /
                columnCount;

            final double imageHeight =
                (cardWidth * 0.70).clamp(100.0, 190.0).toDouble();

            // Reserve additional space for names, prices, padding,
            // and larger system font sizes to prevent bottom overflow.
            final double textScale =
                MediaQuery.textScalerOf(context)
                    .scale(1.0)
                    .clamp(1.0, 1.8)
                    .toDouble();

            final double cardHeight = imageHeight + (145 * textScale);

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                24,
              ),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: 14,

                // Explicit height prevents the old aspect-ratio
                // calculation from squeezing product card contents.
                mainAxisExtent: cardHeight,
              ),
              itemBuilder: (context, index) {
                final document = products[index];

                return buildProductCard(
                  document.id,
                  document.data(),
                  imageHeight,
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: productsPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Our Watches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search watches...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 21,
                    color: productsBrightPurple,
                  ),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, size: 19),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: productsBrightPurple,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Horizontal scrolling keeps all category options accessible
          // on narrow phone screens.
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final String category = categories[index];
                final bool isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    selectedColor: productsPurple,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? productsPurple
                          : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : productsPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: db.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: productsBrightPurple,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return buildEmptyMessage(
                    'Unable to load watches',
                    'Please check your connection and try again.',
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                final filteredProducts = documents.where((document) {
                  final data = document.data();

                  return matchesCategory(
                        (data['category'] ?? '').toString(),
                      ) &&
                      matchesSearch(data);
                }).toList();

                if (filteredProducts.isEmpty) {
                  final searchText = searchController.text.trim();

                  if (searchText.isNotEmpty) {
                    return buildEmptyMessage(
                      'No matching watches found',
                      'Try another product name or search term.',
                    );
                  }

                  if (selectedCategory != 'All') {
                    return buildEmptyMessage(
                      '$selectedCategory watches are not added yet',
                      'We are preparing this collection. Check back soon!',
                    );
                  }

                  return buildEmptyMessage(
                    'No watches available yet',
                    'New arrivals will appear here when they are added.',
                  );
                }

                return buildProductGrid(filteredProducts);
              },
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../product_details/product_details_screen.dart';

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

    return int.tryParse(price.toString()) ?? 0;
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

  Widget buildProductImage(String imageUrl, double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFF6F7F9),
      alignment: Alignment.center,
      child: imageUrl.trim().isEmpty
          ? const Icon(
              Icons.watch_outlined,
              size: 42,
              color: Colors.blueGrey,
            )
          : Image.network(
              imageUrl,
              width: double.infinity,
              height: height,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }

                return const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.watch_outlined,
                  size: 42,
                  color: Colors.blueGrey,
                );
              },
            ),
    );
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

  Widget buildProductCard(
    String productId,
    Map<String, dynamic> data,
    double imageHeight,
  ) {
    final name = (data['name'] ?? 'Watch').toString();
    final category = (data['category'] ?? 'Watch').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final price = getPrice(data['price']);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE8EAED),
          width: 0.6,
        ),
      ),
      child: InkWell(
        onTap: () => openProductDetails(productId, data),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProductImage(imageUrl, imageHeight),

            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  SizedBox(
                    height: 34,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    formatPrice(price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF16834A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
              size: 52,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductGrid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
    double availableWidth,
  ) {
    final double gridWidth =
        availableWidth > 1400 ? 1400 : availableWidth;

    final int columnCount;

    if (gridWidth >= 1100) {
      columnCount = 5;
    } else if (gridWidth >= 850) {
      columnCount = 4;
    } else if (gridWidth >= 560) {
      columnCount = 3;
    } else {
      columnCount = 2;
    }

    const double horizontalPadding = 8;
    const double spacing = 10;

    final double cardWidth =
        (gridWidth -
            (horizontalPadding * 2) -
            (spacing * (columnCount - 1))) /
        columnCount;

    final double imageHeight =
        (cardWidth * 0.72).clamp(96.0, 140.0).toDouble();

    // Calculate the card height from its actual contents.
    // This avoids large areas of unused space beneath each watch.
    final double cardHeight = imageHeight + 94;
    final double cardAspectRatio = cardWidth / cardHeight;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: GridView.builder(
          padding: const EdgeInsets.all(horizontalPadding),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 12,
            childAspectRatio: cardAspectRatio,
          ),
          itemBuilder: (context, index) {
            final doc = products[index];

            return buildProductCard(
              doc.id,
              doc.data(),
              imageHeight,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
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
              height: 46,
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search watches...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 21),
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
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(
                      color: Color(0xFFE3E6EA),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(
                      color: Color(0xFFE3E6EA),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: isSelected,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
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
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Unable to load watches. Please try again.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                final filteredProducts = documents.where((doc) {
                  final data = doc.data();

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
                      'Try another name or search term.',
                    );
                  }

                  if (selectedCategory != 'All') {
                    return buildEmptyMessage(
                      '$selectedCategory watches are not added yet',
                      'We are working on this collection. Please check back soon!',
                    );
                  }

                  return buildEmptyMessage(
                    'No watches available yet',
                    'Please check back soon for new arrivals.',
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return buildProductGrid(
                      filteredProducts,
                      constraints.maxWidth,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

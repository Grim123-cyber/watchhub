
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

    selectedCategory = widget.initialCategory ?? 'All';
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
      return productValue == 'sports' ||
          productValue == 'sport';
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

  Widget buildProductImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        height: 170,
        width: double.infinity,
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.watch,
          size: 75,
          color: Colors.blue,
        ),
      );
    }

    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: const Icon(
              Icons.watch,
              size: 75,
              color: Colors.blue,
            ),
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
  ) {
    final name = (data['name'] ?? 'Watch').toString();
    final category = (data['category'] ?? 'Watch').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final price = getPrice(data['price']);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => openProductDetails(productId, data),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: buildProductImage(imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(price),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      child: Column(
        children: [
          Icon(
            Icons.watch_off_outlined,
            size: 65,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            details,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Our Watches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search watches...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
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
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: db.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load watches. Please try again.',
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
                      '${selectedCategory} watches are not added yet',
                      'We are working on this collection. Please check back soon!',
                    );
                  }

                  return buildEmptyMessage(
                    'No watches available yet',
                    'Please check back soon for new arrivals.',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredProducts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    final doc = filteredProducts[index];

                    return buildProductCard(
                      doc.id,
                      doc.data(),
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

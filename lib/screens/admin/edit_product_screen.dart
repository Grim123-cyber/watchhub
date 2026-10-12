import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;

  String selectedCategory = 'Classic';
  bool isLoading = false;

  final List<String> categories = [
    'Classic',
    'Digital',
    'Luxury',
    'Sports',
    'Smartwatch',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.productData['name'] ?? '',
    );

    priceController = TextEditingController(
      text: '${widget.productData['price'] ?? ''}',
    );

    descriptionController = TextEditingController(
      text: widget.productData['description'] ?? '',
    );

    imageUrlController = TextEditingController(
      text: widget.productData['imageUrl'] ?? '',
    );

    String existingCategory =
        widget.productData['category'] ?? 'Classic';

    if (categories.contains(existingCategory)) {
      selectedCategory = existingCategory;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> updateProduct() async {
    String name = nameController.text.trim();
    String priceText = priceController.text.trim();
    String description = descriptionController.text.trim();
    String imageUrl = imageUrlController.text.trim();

    if (name.isEmpty ||
        priceText.isEmpty ||
        description.isEmpty ||
        imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    int? price = int.tryParse(priceText);

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price.'),
        ),
      );
      return;
    }

    Uri? imageUri = Uri.tryParse(imageUrl);

    if (imageUri == null ||
        !(imageUri.scheme == 'http' ||
            imageUri.scheme == 'https')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid image URL.',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': name,
        'price': price,
        'category': selectedCategory,
        'description': description,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product updated successfully! ✅',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update product: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget imagePreview() {
    String imageUrl =
        imageUrlController.text.trim();

    if (imageUrl.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 60,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder:
              (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.red,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Image could not be loaded',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
          loadingBuilder:
              (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              'Edit Watch',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Watch Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.watch),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Price',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: priceController,
              keyboardType:
                  TextInputType.number,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.money),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              items: categories.map(
                (category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding:
                      EdgeInsets.only(bottom: 60),
                  child: Icon(
                    Icons.description,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Image URL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  imageUrlController,
              keyboardType:
                  TextInputType.url,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    'Paste direct image URL',
                prefixIcon:
                    const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            imagePreview(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : updateProduct,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isLoading
                      ? 'Updating...'
                      : 'Save Changes',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
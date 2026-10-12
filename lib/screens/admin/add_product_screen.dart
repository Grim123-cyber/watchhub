import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const String cloudName = 'drvbbmrw';
  static const String uploadPreset = 'watchhub_unsigned';

  final List<String> categories = [
    'Luxury',
    'Digital',
    'Sports',
    'Classic',
  ];

  String selectedCategory = 'Luxury';

  XFile? selectedImage;
  Uint8List? selectedImageBytes;

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Select a watch image.
  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      final int fileSize = await image.length();

      if (fileSize > 8 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose an image smaller than 8 MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selection failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Upload the selected image to Cloudinary.
  Future<String> uploadImageToCloudinary() async {
    final XFile? image = selectedImage;
    final Uint8List? bytes = selectedImageBytes;

    if (image == null || bytes == null) {
      throw Exception('Please select a watch image first.');
    }

    final Uri uploadUri = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
      '$cloudName/image/upload',
    );

    final http.MultipartRequest request =
        http.MultipartRequest('POST', uploadUri);

    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = 'watchhub';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: image.name,
      ),
    );

    final http.StreamedResponse response = await request.send();

    final String responseBody =
        await response.stream.bytesToString();

    dynamic decoded;

    try {
      decoded = jsonDecode(responseBody);
    } catch (_) {
      throw Exception('Cloudinary returned an invalid response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Cloudinary upload failed.';

      if (decoded is Map && decoded['error'] is Map) {
        message = decoded['error']['message']?.toString() ?? message;
      }

      throw Exception(message);
    }

    if (decoded is! Map || decoded['secure_url'] == null) {
      throw Exception('Cloudinary did not return an image URL.');
    }

    return decoded['secure_url'].toString();
  }

  // Save the product and its Cloudinary image URL to Firestore.
  Future<void> saveProduct() async {
    if (isSaving) return;

    if (formKey.currentState == null ||
        !formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage == null || selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a watch image first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final int? price = int.tryParse(priceController.text.trim());

      if (price == null || price <= 0) {
        throw Exception('Please enter a valid price.');
      }

      final String imageUrl = await uploadImageToCloudinary();

      await firestore.collection('products').add({
        'name': nameController.text.trim(),
        'price': price,
        'category': selectedCategory,
        'description': descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Watch added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add watch: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Watch'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Watch Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  height: 220,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: buildImagePreview(),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: isSaving ? null : pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Watch Image'),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Watch Name',
                    hintText: 'e.g. Patek Philippe World Time 5131R',
                    prefixIcon: Icon(Icons.watch),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the watch name.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price in Naira (₦)',
                    hintText: 'e.g. 1500000',
                    prefixIcon: Icon(Icons.payments),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the price.';
                    }

                    final int? price = int.tryParse(value.trim());

                    if (price == null || price <= 0) {
                      return 'Enter a valid price greater than zero.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            selectedCategory = value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Watch Description',
                    hintText: 'Enter details about this watch...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : saveProduct,
                    icon: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      isSaving
                          ? 'Uploading and saving...'
                          : 'Add Watch to WatchHub',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Display the selected image without using the ! operator.
  Widget buildImagePreview() {
    final Uint8List? bytes = selectedImageBytes;

    if (bytes == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.watch,
            size: 75,
            color: Colors.blueGrey,
          ),
          SizedBox(height: 10),
          Text('No image selected'),
        ],
      );
    }

    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.broken_image,
            size: 60,
            color: Colors.red,
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Add a product
  Future<void> addProduct({
    required String name,
    required int price,
    required String category,
    required String description,
  }) async {
    await db.collection('products').add({
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all products
  Stream<QuerySnapshot> getProducts() {
    return db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
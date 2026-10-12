import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId {
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // Add product to cart
  Future<void> addToCart({
    required String productId,
    required String name,
    required int price,
  }) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .set({
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': 1,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user's cart
  Stream<QuerySnapshot> getCart() {
    return db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots();
  }

  // Remove product from cart
  Future<void> removeFromCart(String productId) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }
}
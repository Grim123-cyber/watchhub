import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId {
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // Add product to wishlist
  Future<void> addToWishlist({
    required String productId,
    required String name,
    required int price,
  }) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .set({
      'productId': productId,
      'name': name,
      'price': price,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get wishlist
  Stream<QuerySnapshot> getWishlist() {
    return db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots();
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId {
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  Future<void> addReview({
    required String productId,
    required String productName,
    required int rating,
    required String comment,
  }) async {
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await db.collection('reviews').add({
      'productId': productId,
      'productName': productName,
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getProductReviews(
    String productId,
  ) {
    return db
        .collection('reviews')
        .where(
          'productId',
          isEqualTo: productId,
        )
        .snapshots();
  }

  Future<void> deleteReview(
    String reviewId,
  ) async {
    await db
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }
}


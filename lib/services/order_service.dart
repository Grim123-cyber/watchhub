
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId {
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required int total,
  }) async {
    DocumentReference orderReference =
        await db.collection('orders').add({
      'userId': userId,
      'items': items,
      'total': total,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return orderReference.id;
  }

  Stream<QuerySnapshot> getMyOrders() {
    return db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
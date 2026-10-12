import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser {
    return auth.currentUser;
  }

  // Check if current user is an admin
  Future<bool> isAdmin() async {
    User? user = auth.currentUser;

    if (user == null) {
      return false;
    }

    DocumentSnapshot userDocument =
        await db.collection('users').doc(user.uid).get();

    if (!userDocument.exists) {
      return false;
    }

    Map<String, dynamic> data =
        userDocument.data() as Map<String, dynamic>;

    return data['role'] == 'admin';
  }

  // Get all users
  Stream<QuerySnapshot> getUsers() {
    return db.collection('users').snapshots();
  }

  // Get all products
  Stream<QuerySnapshot> getProducts() {
    return db.collection('products').snapshots();
  }

  // Get all orders
  Stream<QuerySnapshot> getOrders() {
    return db.collection('orders').snapshots();
  }

  // Get all support messages
  Stream<QuerySnapshot> getSupportMessages() {
    return db
        .collection('support_messages')
        .snapshots();
  }

  // Get number of users
  Stream<int> getUserCount() {
    return db
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get number of products
  Stream<int> getProductCount() {
    return db
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get number of orders
  Stream<int> getOrderCount() {
    return db
        .collection('orders')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get number of support messages
  Stream<int> getSupportCount() {
    return db
        .collection('support_messages')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
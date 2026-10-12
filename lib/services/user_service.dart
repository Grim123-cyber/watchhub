import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Create a user document
  Future<void> createUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await db.collection('users').doc(userId).set({
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
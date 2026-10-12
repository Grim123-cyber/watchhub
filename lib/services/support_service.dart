import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId {
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  Future<void> createSupportMessage({
    required String subject,
    required String message,
  }) async {
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await db.collection('support_messages').add({
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'subject': subject,
      'message': message,
      'status': 'Open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMySupportMessages() {
    return db
        .collection('support_messages')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .snapshots();
  }
}
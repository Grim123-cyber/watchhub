import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Add data to Firestore
  Future<void> addData(
    String collection,
    Map<String, dynamic> data,
  ) async {
    await db.collection(collection).add(data);
  }

  // Get data from Firestore
  Stream<QuerySnapshot> getData(String collection) {
    return db.collection(collection).snapshots();
  }
}
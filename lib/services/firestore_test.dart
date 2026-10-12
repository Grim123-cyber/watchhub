import 'firestore_service.dart';

Future<void> testFirestore() async {
  FirestoreService firestoreService = FirestoreService();

  await firestoreService.addData(
    'test',
    {
      'message': 'WatchHub Firestore is working!',
      'createdAt': DateTime.now(),
    },
  );
}
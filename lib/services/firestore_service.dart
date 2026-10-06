import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String password,
  }) async {
    await _db.collection("users").doc(uid).set({
      "name": name,
      "email": email,
      "password": password,

      "age": null,
      "gender": null,
      "height": null,
      "weight": null,
      "target": null,

      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
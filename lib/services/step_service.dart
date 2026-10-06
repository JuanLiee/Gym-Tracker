import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  String getTodayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> addSteps(int steps) async {
    if (steps <= 0) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('step_logs')
        .add({
      'steps': steps,
      'dateKey': getTodayKey(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

Stream<QuerySnapshot<Map<String, dynamic>>>
    watchTodaySteps() {
  return _firestore
      .collection('users')
      .doc(_uid)
      .collection('step_logs')
      .where(
        'dateKey',
        isEqualTo: getTodayKey(),
      )
      .snapshots();
}

  Future<void> deleteStepLog(String documentId) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('step_logs')
        .doc(documentId)
        .delete();
  }

  Future<int> getTodayTotalSteps() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('step_logs')
        .where(
          'dateKey',
          isEqualTo: getTodayKey(),
        )
        .get();

    int total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      total += (data['steps'] ?? 0) as int;
    }

    return total;
  }
}
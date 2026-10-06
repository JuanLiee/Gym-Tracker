import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutHistoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveWorkoutHistory({
    required String workoutName,
    required String duration,
    required int totalExercises,
    required int totalSets,
    required double totalVolume,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'workoutName': workoutName,
      'duration': duration,
      'totalExercises': totalExercises,
      'totalSets': totalSets,
      'totalVolume': totalVolume,
      'completedAt': Timestamp.now(),
    });
  }
}
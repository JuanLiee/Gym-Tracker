import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/workout_model.dart';

class WorkoutService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveWorkout(WorkoutModel workout) async {

    await firestore
        .collection("users")
        .doc(uid)
        .collection("workouts")
        .add(workout.toMap());

  }

  Stream<List<WorkoutModel>> getWorkouts() {

    return firestore
        .collection("users")
        .doc(uid)
        .collection("workouts")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs
          .map((doc) => WorkoutModel.fromDoc(doc))
          .toList();

    });

  }

  Future<void> deleteWorkout(String id) async {

    await firestore
        .collection("users")
        .doc(uid)
        .collection("workouts")
        .doc(id)
        .delete();

  }

}
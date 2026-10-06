import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  String id;
  String name;
  String style;
  List<Map<String, dynamic>> exercises;
  Timestamp createdAt;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.style,
    required this.exercises,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "style": style,
      "exercises": exercises,
      "createdAt": createdAt,
    };
  }

  factory WorkoutModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WorkoutModel(
      id: doc.id,
      name: data["name"],
      style: data["style"],
      exercises: List<Map<String, dynamic>>.from(data["exercises"]),
      createdAt: data["createdAt"],
    );
  }
}
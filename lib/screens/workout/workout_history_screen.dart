import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/workout_model.dart';
import '../../services/workout_service.dart';
import 'workout_detail_screen.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History"),
      ),
      body: StreamBuilder<List<WorkoutModel>>(
        stream: WorkoutService().getWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No workouts yet."),
            );
          }

          final workouts = snapshot.data!;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              return buildWorkoutCard(context, workouts[index]);
            },
          );
        },
      ),
    );
  }

  Widget buildWorkoutCard(BuildContext context, WorkoutModel workout) {
    final date = DateFormat('dd MMM yyyy').format(workout.createdAt.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.fitness_center,
            color: Colors.white,
          ),
        ),
        title: Text(
          workout.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏋 ${workout.style}'),
              const SizedBox(height: 4),
              Text('💪 ${workout.exercises.length} Exercises'),
              const SizedBox(height: 4),
              Text(
                '📅 $date',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(
                workout: workout,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/workout_model.dart';
import 'create_workout_screen.dart';
import 'workout_template_screen.dart';
import 'workout_history_screen.dart';
import 'workout_session_screen.dart';
import '../progress_screens.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          'Workout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('workouts')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _buildTodayWorkout(
                  context,
                  snapshot,
                ),

                const SizedBox(height: 30),

                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,

                  children: [
                    buildMenu(
                      context,
                      Icons.add,
                      'Create Workout',
                      Colors.blue,
                      const CreateWorkoutScreen(),
                    ),

                    buildMenu(
                      context,
                      Icons.menu_book,
                      'Templates',
                      Colors.orange,
                      const WorkoutTemplateScreen(),
                    ),

                    buildMenu(
                      context,
                      Icons.history,
                      'History',
                      Colors.green,
                      const WorkoutHistoryScreen(),
                    ),

                    buildMenu(
                      context,
                      Icons.bar_chart,
                      'Statistics',
                      Colors.deepPurple,
                      const ProgressScreen(),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Training Styles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _buildTrainingStyle(
                  context,
                  Icons.fitness_center,
                  'Normal Training',
                  'Traditional sets and reps',
                ),

                _buildTrainingStyle(
                  context,
                  Icons.trending_up,
                  'Pyramid',
                  'Increase weight every set',
                ),

                _buildTrainingStyle(
                  context,
                  Icons.swap_vert,
                  'Reverse Pyramid',
                  'Heavy to light',
                ),

                _buildTrainingStyle(
                  context,
                  Icons.flash_on,
                  'Superset',
                  'Two exercises without rest',
                ),

                _buildTrainingStyle(
                  context,
                  Icons.local_fire_department,
                  'Dropset',
                  'Reduce weight until failure',
                ),

                _buildTrainingStyle(
                  context,
                  Icons.favorite,
                  'Circuit',
                  'Multiple exercises continuously',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayWorkout(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot> snapshot,
  ) {
    if (!snapshot.hasData ||
        snapshot.data!.docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              "Today's Workout",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'No Workout Yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Create a workout to get started.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CreateWorkoutScreen(),
                    ),
                  );
                },

                child: const Text(
                  'CREATE WORKOUT',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final doc = snapshot.data!.docs.first;

    final data =
        doc.data() as Map<String, dynamic>;

    final workoutName =
        data['name'] ?? 'Workout';

    final style =
        data['style'] ?? 'Normal Training';

    final exercises =
        List<Map<String, dynamic>>.from(
      data['exercises'] ?? [],
    );

    final workout = WorkoutModel(
      id: doc.id,
      name: workoutName,
      style: style,
      exercises: exercises,
      createdAt:
          data['createdAt'] ?? Timestamp.now(),
    );

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Today's Workout",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            workoutName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$style • ${exercises.length} Exercises',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WorkoutSessionScreen(
                      workout: workout,
                    ),
                  ),
                );
              },

              child: const Text(
                'START WORKOUT',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenu(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 28,

              backgroundColor:
                  color.withValues(alpha: 0.15),

              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingStyle(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Colors.deepPurple.shade100,

          child: Icon(
            icon,
            color: Colors.deepPurple,
          ),
        ),

        title: Text(title),

        subtitle: Text(subtitle),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateWorkoutScreen(
                selectedStyle: title,
              ),
            ),
          );
        },
      ),
    );
  }
}
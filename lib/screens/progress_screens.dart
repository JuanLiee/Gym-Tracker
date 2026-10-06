import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .orderBy('completedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          final docs = snapshot.data?.docs ?? [];

          int totalWorkouts = docs.length;
          int totalSets = 0;
          double totalVolume = 0;
          int totalSeconds = 0;

          for (final doc in docs) {
            final data =
                doc.data() as Map<String, dynamic>;

            totalSets +=
                (data['totalSets'] ?? 0) as int;

            totalVolume +=
                (data['totalVolume'] ?? 0).toDouble();

            final duration =
                data['duration'] ?? '00:00';

            final parts = duration.split(':');

            if (parts.length == 2) {
              final minutes =
                  int.tryParse(parts[0]) ?? 0;

              final seconds =
                  int.tryParse(parts[1]) ?? 0;

              totalSeconds +=
                  (minutes * 60) + seconds;
            }
          }

          final hours = totalSeconds ~/ 3600;
          final minutes =
              (totalSeconds % 3600) ~/ 60;

          final workoutTime =
              hours > 0
                  ? '${hours}h ${minutes}m'
                  : '${minutes}m';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Keep track of your training progress.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        Icons.fitness_center,
                        'Total Workouts',
                        '$totalWorkouts',
                        Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: statCard(
                        Icons.repeat,
                        'Total Sets',
                        '$totalSets',
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        Icons.monitor_weight,
                        'Total Volume',
                        '${totalVolume.toStringAsFixed(0)} kg',
                        Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: statCard(
                        Icons.timer,
                        'Workout Time',
                        workoutTime,
                        Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Training Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          totalWorkouts == 0
                              ? 'No workouts completed yet.'
                              : 'You have completed '
                                  '$totalWorkouts workout'
                                  '${totalWorkouts == 1 ? '' : 's'}.',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Total volume: '
                          '${totalVolume.toStringAsFixed(0)} kg',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
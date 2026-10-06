import 'package:flutter/material.dart';

import '../../services/workout_services_history.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final String workoutName;
  final String duration;
  final int totalExercises;
  final int totalSets;
  final double totalVolume;

  const WorkoutSummaryScreen({
    super.key,
    required this.workoutName,
    required this.duration,
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Workout Summary',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              'Workout Complete 🎉',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              workoutName,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 35),

            Expanded(
              child: Card(
                elevation: 3,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,

                    children: [
                      buildItem(
                        Icons.timer,
                        'Duration',
                        duration,
                      ),

                      const Divider(),

                      buildItem(
                        Icons.fitness_center,
                        'Exercises',
                        totalExercises.toString(),
                      ),

                      const Divider(),

                      buildItem(
                        Icons.repeat,
                        'Completed Sets',
                        totalSets.toString(),
                      ),

                      const Divider(),

                      buildItem(
                        Icons.monitor_weight,
                        'Total Volume',
                        '${totalVolume.toStringAsFixed(0)} kg',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.save,
                ),

                label: const Text(
                  'SAVE WORKOUT',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                onPressed: () async {
                  try {
                    await WorkoutHistoryService()
                        .saveWorkoutHistory(
                      workoutName:
                          workoutName,
                      duration: duration,
                      totalExercises:
                          totalExercises,
                      totalSets:
                          totalSets,
                      totalVolume:
                          totalVolume,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Workout saved successfully!',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to save workout: $e',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  'BACK',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue,
          size: 30,
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
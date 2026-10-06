import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final String name = exercise['name'] ?? 'Exercise';

    final int sets =
        (exercise['sets'] ?? 0) as int;

    final int reps =
        (exercise['reps'] ?? 0) as int;

    final double weight =
        (exercise['weight'] ?? 0).toDouble();

    final double totalVolume =
        sets * reps * weight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Detail'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // Exercise Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius:
                    BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    name,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Exercise Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // Sets
            _buildInfoCard(
              icon: Icons.repeat,
              title: 'Sets',
              value: '$sets',
            ),

            // Reps
            _buildInfoCard(
              icon: Icons.fitness_center,
              title: 'Reps',
              value: '$reps',
            ),

            // Weight
            _buildInfoCard(
              icon: Icons.monitor_weight,
              title: 'Weight',
              value:
                  '${weight.toStringAsFixed(1)} kg',
            ),

            const SizedBox(height: 20),

            // Total Volume
            Card(
              elevation: 3,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          Colors.orange,

                      child: Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Text(
                        'Total Volume',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),

                    Text(
                      '${totalVolume.toStringAsFixed(0)} kg',

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Summary
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '$sets sets × '
                    '$reps reps × '
                    '${weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 6,
        ),

        leading: CircleAvatar(
          backgroundColor:
              Colors.blue.shade100,

          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
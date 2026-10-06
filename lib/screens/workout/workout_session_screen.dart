import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/workout_model.dart';
import 'workout_summary_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutSessionScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends State<WorkoutSessionScreen> {
  Timer? workoutTimer;
  Timer? restTimer;

  int currentExercise = 0;

  int workoutSeconds = 0;

  int restSeconds = 90;

  bool isResting = false;

  late List<bool> checkedSets;

  // Total hasil workout yang benar-benar diselesaikan
  int completedSetsTotal = 0;

  double completedVolumeTotal = 0;

  int completedExercises = 0;

  @override
  void initState() {
    super.initState();

    final firstExercise =
        widget.workout.exercises.first;

    checkedSets = List<bool>.filled(
      firstExercise['sets'] ?? 0,
      false,
    );

    workoutTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          workoutSeconds++;
        });
      },
    );
  }

  @override
  void dispose() {
    workoutTimer?.cancel();
    restTimer?.cancel();

    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void startRestTimer() {
    setState(() {
      isResting = true;
      restSeconds = 90;
    });

    restTimer?.cancel();

    restTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (restSeconds == 0) {
          timer.cancel();

          if (!mounted) return;

          setState(() {
            isResting = false;
          });
        } else {
          if (!mounted) return;

          setState(() {
            restSeconds--;
          });
        }
      },
    );
  }

  void completeCurrentExercise() {
    final exercise =
        widget.workout.exercises[currentExercise];

    final sets =
        (exercise['sets'] ?? 0) as int;

    final reps =
        (exercise['reps'] ?? 0) as int;

    final weight =
        (exercise['weight'] ?? 0).toDouble();

    // Hitung berapa set yang benar-benar dicentang
    final completedSets =
        checkedSets.where((set) => set).length;

    final volume =
        completedSets * reps * weight;

    completedSetsTotal += completedSets;

    completedVolumeTotal += volume;

    completedExercises++;
  }

  void goToNextExercise() {
    completeCurrentExercise();

    setState(() {
      currentExercise++;

      final nextExercise =
          widget.workout.exercises[currentExercise];

      checkedSets = List<bool>.filled(
        nextExercise['sets'] ?? 0,
        false,
      );

      isResting = false;
    });

    restTimer?.cancel();
  }

  void finishWorkout() {
    completeCurrentExercise();

    workoutTimer?.cancel();
    restTimer?.cancel();

    final duration = formatTime(workoutSeconds);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(
          workoutName: widget.workout.name,
          duration: duration,
          totalExercises: completedExercises,
          totalSets: completedSetsTotal,
          totalVolume: completedVolumeTotal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise =
        widget.workout.exercises[currentExercise];

    final totalExercise =
        widget.workout.exercises.length;

    final progress = totalExercise == 0
        ? 0.0
        : (currentExercise + 1) / totalExercise;

    final exerciseName =
        exercise['name'] ?? 'Exercise';

    final weight =
        (exercise['weight'] ?? 0).toDouble();

    final reps =
        exercise['reps'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              'Exercise ${currentExercise + 1} / $totalExercise',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            const SizedBox(height: 25),

            Center(
              child: Column(
                children: [
                  const Text(
                    'Workout Time',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    formatTime(workoutSeconds),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: Text(
                exerciseName,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                '$weight kg',
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                '$reps Reps',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Complete Your Sets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: checkedSets.length,

                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: checkedSets[index],

                    title: Text(
                      'Set ${index + 1}',
                    ),

                    onChanged: (value) {
                      setState(() {
                        checkedSets[index] =
                            value ?? false;
                      });

                      if (value == true) {
                        startRestTimer();
                      }
                    },
                  );
                },
              ),
            ),

            if (isResting)
              Card(
                color: Colors.orange.shade100,

                child: Padding(
                  padding:
                      const EdgeInsets.all(15),

                  child: Column(
                    children: [
                      const Text(
                        'REST TIME',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        formatTime(restSeconds),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      LinearProgressIndicator(
                        value: restSeconds / 90,
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,

                        child: OutlinedButton(
                          onPressed: () {
                            restTimer?.cancel();

                            setState(() {
                              isResting = false;
                            });
                          },

                          child:
                              const Text('SKIP REST'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                child: Text(
                  currentExercise ==
                          widget.workout.exercises
                                  .length -
                              1
                      ? 'FINISH WORKOUT'
                      : 'NEXT EXERCISE',

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                onPressed: () {
                  if (checkedSets.contains(false)) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Complete all sets first.',
                        ),
                      ),
                    );

                    return;
                  }

                  if (currentExercise <
                      widget.workout.exercises
                              .length -
                          1) {
                    goToNextExercise();
                  } else {
                    finishWorkout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/workout_model.dart';
import '../../services/workout_service.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final String? selectedStyle;

  const CreateWorkoutScreen({
    super.key,
    this.selectedStyle,
  });

  @override
  State<CreateWorkoutScreen> createState() =>
      _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState
    extends State<CreateWorkoutScreen> {
  final workoutNameController = TextEditingController();

  String selectedStyle = "Normal Training";

  final List<Map<String, dynamic>> exercises = [];

  @override
  void initState() {
    super.initState();

    selectedStyle =
        widget.selectedStyle ?? "Normal Training";
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    super.dispose();
  }

  void addExercise() {
    final nameController = TextEditingController();
    final setController = TextEditingController();
    final repController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Exercise Name",
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: setController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Sets",
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: repController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Reps",
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Weight (kg)",
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  exercises.add({
                    "name": nameController.text.trim(),
                    "sets":
                        int.tryParse(setController.text) ?? 0,
                    "reps":
                        int.tryParse(repController.text) ?? 0,
                    "weight":
                        double.tryParse(
                              weightController.text,
                            ) ??
                            0,
                  });
                });

                Navigator.pop(dialogContext);
              },
              child: const Text("ADD EXERCISE"),
            ),
          ],
        );
      },
    );
  }

  void deleteExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Create Workout"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Workout Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: workoutNameController,
              decoration: InputDecoration(
                hintText: "Example : Push Day",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Training Style",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedStyle,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: "Normal Training",
                  child: Text("🏋 Normal Training"),
                ),

                DropdownMenuItem(
                  value: "Pyramid",
                  child: Text("🏔 Pyramid"),
                ),

                DropdownMenuItem(
                  value: "Reverse Pyramid",
                  child: Text("⬇ Reverse Pyramid"),
                ),

                DropdownMenuItem(
                  value: "Superset",
                  child: Text("🔥 Superset"),
                ),

                DropdownMenuItem(
                  value: "Dropset",
                  child: Text("💥 Dropset"),
                ),

                DropdownMenuItem(
                  value: "Circuit",
                  child: Text("❤️ Circuit"),
                ),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedStyle = value;
                });
              },
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Exercises",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 15),

            if (exercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: const Center(
                  child: Text(
                    "No Exercise Added",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            if (exercises.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount: exercises.length,

                itemBuilder: (context, index) {
                  final exercise =
                      exercises[index];

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.fitness_center,
                        ),
                      ),

                      title: Text(
                        exercise["name"],
                      ),

                      subtitle: Text(
                        "${exercise["sets"]} Sets • "
                        "${exercise["reps"]} Reps • "
                        "${exercise["weight"]} kg",
                      ),

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),

                        onPressed: () {
                          deleteExercise(index);
                        },
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),

                label: const Text(
                  "SAVE WORKOUT",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                onPressed: () async {
                  if (workoutNameController
                      .text
                      .trim()
                      .isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter workout name.",
                        ),
                      ),
                    );

                    return;
                  }

                  if (exercises.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please add at least one exercise.",
                        ),
                      ),
                    );

                    return;
                  }

                  try {
                    final workout =
                        WorkoutModel(
                      id: "",
                      name: workoutNameController
                          .text
                          .trim(),
                      style: selectedStyle,
                      exercises: exercises,
                      createdAt:
                          Timestamp.now(),
                    );

                    await WorkoutService()
                        .saveWorkout(workout);

                    if (!mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Workout saved successfully!",
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content:
                            Text(e.toString()),
                      ),
                    );
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
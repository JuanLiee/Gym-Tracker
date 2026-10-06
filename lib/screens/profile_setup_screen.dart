import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  DateTime? selectedDate;

  String gender = "Male";
  String goal = "Bulking";

  bool isLoading = false;

  // Nilai yang diperbolehkan untuk dropdown
  static const List<String> validGenders = [
    "Male",
    "Female",
  ];

  static const List<String> validGoals = [
    "Bulking",
    "Cutting",
    "Maintain",
  ];

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!doc.exists || !mounted) return;

      final data = doc.data();

      if (data == null) return;

      setState(() {
        // =========================
        // NAME
        // =========================
        nameController.text =
            data["name"]?.toString() ?? "";

        // =========================
        // HEIGHT
        // =========================
        if (data["height"] != null) {
          heightController.text =
              data["height"].toString();
        }

        // =========================
        // WEIGHT
        // =========================
        if (data["weight"] != null) {
          weightController.text =
              data["weight"].toString();
        }

        // =========================
        // GENDER
        // =========================
        final savedGender =
            data["gender"]?.toString().trim();

        if (savedGender != null &&
            validGenders.contains(savedGender)) {
          gender = savedGender;
        } else {
          gender = "Male";
        }

        // =========================
        // FITNESS GOAL
        // =========================
        final savedGoal =
            data["goal"]?.toString().trim();

        if (savedGoal != null &&
            validGoals.contains(savedGoal)) {
          goal = savedGoal;
        } else {
          goal = "Bulking";
        }

        // =========================
        // DATE OF BIRTH
        // =========================
        final savedBirthDate =
            data["birthDate"]?.toString();

        if (savedBirthDate != null &&
            savedBirthDate.isNotEmpty) {
          selectedDate =
              DateTime.tryParse(savedBirthDate);
        }
      });
    } catch (e) {
      debugPrint("Failed to load profile: $e");
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2003),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveProfile() async {
    // =========================
    // VALIDATE EMPTY FIELDS
    // =========================
    if (nameController.text.trim().isEmpty ||
        selectedDate == null ||
        heightController.text.trim().isEmpty ||
        weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete your profile."),
        ),
      );
      return;
    }

    // =========================
    // VALIDATE NUMBERS
    // =========================
    final height =
        double.tryParse(heightController.text.trim());

    final weight =
        double.tryParse(weightController.text.trim());

    if (height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Height and weight must be valid numbers.",
          ),
        ),
      );
      return;
    }

    // =========================
    // VALIDATE DROPDOWN VALUES
    // =========================
    if (!validGenders.contains(gender)) {
      gender = "Male";
    }

    if (!validGoals.contains(goal)) {
      goal = "Bulking";
    }

    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not found.");
      }

      // =========================
      // SAVE TO FIRESTORE
      // =========================
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(
        {
          "name": nameController.text.trim(),
          "email": user.email,
          "birthDate":
              selectedDate!.toIso8601String(),
          "gender": gender,
          "height": height,
          "weight": weight,
          "goal": goal,
          "profileCompleted": true,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      // =========================
      // GO TO HOME
      // =========================
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save profile: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.account_circle,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 30),

            // =========================
            // FULL NAME
            // =========================
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon:
                    Icon(Icons.person),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // DATE OF BIRTH
            // =========================
            ElevatedButton.icon(
              onPressed: pickDate,
              icon: const Icon(
                Icons.calendar_today,
              ),
              label: Text(
                selectedDate == null
                    ? "Select Date of Birth"
                    : "${selectedDate!.day}/"
                      "${selectedDate!.month}/"
                      "${selectedDate!.year}",
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // HEIGHT
            // =========================
            TextField(
              controller: heightController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                prefixIcon:
                    Icon(Icons.height),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // WEIGHT
            // =========================
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                prefixIcon:
                    Icon(Icons.monitor_weight),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // GENDER
            // =========================
            DropdownButtonFormField<String>(
              value: validGenders.contains(gender)
                  ? gender
                  : "Male",

              decoration:
                  const InputDecoration(
                labelText: "Gender",
                border:
                    OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value: "Male",
                  child: Text("Male"),
                ),
                DropdownMenuItem(
                  value: "Female",
                  child: Text("Female"),
                ),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  gender = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // FITNESS GOAL
            // =========================
            DropdownButtonFormField<String>(
              value: validGoals.contains(goal)
                  ? goal
                  : "Bulking",

              decoration:
                  const InputDecoration(
                labelText: "Fitness Goal",
                border:
                    OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value: "Bulking",
                  child: Text("Bulking"),
                ),
                DropdownMenuItem(
                  value: "Cutting",
                  child: Text("Cutting"),
                ),
                DropdownMenuItem(
                  value: "Maintain",
                  child: Text(
                    "Maintain Weight",
                  ),
                ),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  goal = value;
                });
              },
            ),

            const SizedBox(height: 35),

            // =========================
            // SAVE BUTTON
            // =========================
            SizedBox(
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : saveProfile,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue,
                  foregroundColor:
                      Colors.white,
                ),

                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "SAVE PROFILE",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool _saving = false;

  String _name = "User";
  String _email = "";
  String _age = "-";
  String _height = "-";
  String _weight = "-";
  String _goal = "-";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        setState(() {
          _name = data['name']?.toString() ?? "User";
          _email = user.email ?? data['email']?.toString() ?? "";

          _age = data['age']?.toString() ?? "-";
          _height = data['height']?.toString() ?? "-";
          _weight = data['weight']?.toString() ?? "-";
          _goal = data['goal']?.toString() ?? "-";

          _loading = false;
        });
      } else {
        setState(() {
          _name = user.displayName ?? "User";
          _email = user.email ?? "";
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load profile: $e"),
        ),
      );
    }
  }

  // ============================================================
  // CALCULATE BMI
  // ============================================================

  double? _calculateBMI() {
    final height = double.tryParse(_height);
    final weight = double.tryParse(_weight);

    if (height == null || weight == null) {
      return null;
    }

    if (height <= 0 || weight <= 0) {
      return null;
    }

    final heightInMeter = height / 100;

    return weight / (heightInMeter * heightInMeter);
  }

  // ============================================================
  // BMI STATUS
  // ============================================================

  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 25) {
      return "Normal weight";
    } else if (bmi < 30) {
      return "Overweight";
    } else {
      return "Obesity";
    }
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  void _showEditProfile() {
    final nameController = TextEditingController(text: _name);

    final ageController = TextEditingController(
      text: _age == "-" ? "" : _age,
    );

    final heightController = TextEditingController(
      text: _height == "-" ? "" : _height,
    );

    final weightController = TextEditingController(
      text: _weight == "-" ? "" : _weight,
    );

    final goalController = TextEditingController(
      text: _goal == "-" ? "" : _goal,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // NAME
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 15),

                // AGE
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Age",
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixText: "years",
                  ),
                ),

                const SizedBox(height: 15),

                // HEIGHT
                TextField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Height",
                    prefixIcon: Icon(Icons.height),
                    suffixText: "cm",
                  ),
                ),

                const SizedBox(height: 15),

                // WEIGHT
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Weight",
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    suffixText: "kg",
                  ),
                ),

                const SizedBox(height: 15),

                // GOAL
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(
                    labelText: "Goal",
                    prefixIcon: Icon(Icons.flag_outlined),
                    hintText: "e.g. Build Muscle",
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
              onPressed: _saving
                  ? null
                  : () async {
                      await _saveProfile(
                        dialogContext,
                        nameController.text.trim(),
                        ageController.text.trim(),
                        heightController.text.trim(),
                        weightController.text.trim(),
                        goalController.text.trim(),
                      );
                    },

              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile(
    BuildContext dialogContext,
    String name,
    String age,
    String height,
    String weight,
    String goal,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty."),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': name,
          'age': age.isEmpty ? null : int.tryParse(age),
          'height': height.isEmpty ? null : double.tryParse(height),
          'weight': weight.isEmpty ? null : double.tryParse(weight),
          'goal': goal.isEmpty ? null : goal,
          'email': user.email,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        _name = name;
        _age = age.isEmpty ? "-" : age;
        _height = height.isEmpty ? "-" : height;
        _weight = weight.isEmpty ? "-" : weight;
        _goal = goal.isEmpty ? "-" : goal;
        _saving = false;
      });

      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
        ),
      );
    } catch (e) {
      debugPrint("Error saving profile: $e");

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
        ),
      );
    }
  }

  // ============================================================
  // PROFILE ROW
  // ============================================================

  Widget _profileRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBMI();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  // ==================================================
                  // PROFILE PICTURE
                  // ==================================================

                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // NAME
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // EMAIL
                  Text(
                    _email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // PERSONAL INFORMATION
                  // ==================================================

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      children: [

                        _profileRow(
                          icon: Icons.cake,
                          title: "Age",
                          value: _age == "-"
                              ? "-"
                              : "$_age years",
                        ),

                        const Divider(height: 1),

                        _profileRow(
                          icon: Icons.height,
                          title: "Height",
                          value: _height == "-"
                              ? "-"
                              : "$_height cm",
                        ),

                        const Divider(height: 1),

                        _profileRow(
                          icon: Icons.monitor_weight,
                          title: "Weight",
                          value: _weight == "-"
                              ? "-"
                              : "$_weight kg",
                        ),

                        const Divider(height: 1),

                        _profileRow(
                          icon: Icons.flag,
                          title: "Goal",
                          value: _goal,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // BMI STATUS
                  // ==================================================

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),

                      child: Row(
                        children: [

                          Container(
                            width: 55,
                            height: 55,

                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.monitor_weight_outlined,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Text(
                                  "BMI Status",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                if (bmi != null) ...[
                                  Text(
                                    "BMI ${bmi.toStringAsFixed(1)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    _getBMIStatus(bmi),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ] else
                                  Text(
                                    "Enter your height and weight",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // EDIT PROFILE BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      icon: const Icon(Icons.edit),

                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      onPressed: _showEditProfile,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
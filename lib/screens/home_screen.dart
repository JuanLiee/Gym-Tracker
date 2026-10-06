import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout/workout_screen.dart';
import 'workout/workout_detail_screen.dart';
import '../models/workout_model.dart';
import '../services/nutrition_service.dart';
import 'settings_screen.dart';
import 'progress_screens.dart';
import 'nutrition_screen.dart';
import 'steps_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  String name = "";
  String email = "";
  String gender = "";
  String goal = "";

  double height = 0;
  double weight = 0;

  int age = 0;
  int calories = 0;

  final NutritionService _nutritionService =
      NutritionService();

  static const int dailyStepGoal = 10000;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> loadUser() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        name = data["name"] ?? "";
        email = data["email"] ?? "";
        gender = data["gender"] ?? "";
        goal = data["goal"] ?? "";

        height =
            (data["height"] ?? 0).toDouble();

        weight =
            (data["weight"] ?? 0).toDouble();

        if (data["birthDate"] != null) {
          DateTime birth =
              DateTime.parse(
            data["birthDate"],
          );

          age =
              DateTime.now().year -
                  birth.year;

          if (DateTime.now().month <
                  birth.month ||
              (DateTime.now().month ==
                      birth.month &&
                  DateTime.now().day <
                      birth.day)) {
            age--;
          }
        }

        calculateCalories();
      }
    } catch (e) {
      debugPrint(
        "Load user error: $e",
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // CALCULATE DAILY CALORIES
  // ============================================================

  void calculateCalories() {
    if (height == 0 ||
        weight == 0 ||
        age == 0) {
      return;
    }

    double bmr;

    if (gender == "Male") {
      bmr =
          10 * weight +
          6.25 * height -
          5 * age +
          5;
    } else {
      bmr =
          10 * weight +
          6.25 * height -
          5 * age -
          161;
    }

    calories =
        (bmr * 1.55).round();

    if (goal == "Bulking") {
      calories += 300;
    }

    if (goal == "Cutting") {
      calories -= 300;
    }
  }

  // ============================================================
  // TODAY KEY
  // ============================================================

  String get todayKey {
    final now = DateTime.now();

    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,

        elevation: 0,

        automaticallyImplyLeading:
            false,

        title: const Text(
          "Gym Tracker",

          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.black,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // GREETING
            // ==================================================

            Text(
              "Hi, $name 👋",

              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              "Let's crush today's workout!",

              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // USER INFO
            // ==================================================

            Row(
              children: [

                Expanded(
                  child: infoCard(
                    Icons.monitor_weight,
                    "Weight",
                    "${weight.toStringAsFixed(0)} kg",
                    Colors.orange,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: infoCard(
                    Icons.height,
                    "Height",
                    "${height.toStringAsFixed(0)} cm",
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [

                Expanded(
                  child: infoCard(
                    Icons.flag,
                    "Goal",
                    goal,
                    Colors.green,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: infoCard(
                    Icons.cake,
                    "Age",
                    "$age Years",
                    Colors.deepPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // DAILY CALORIES TARGET
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(20),

              decoration:
                  BoxDecoration(
                color: Colors.blue,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons
                        .local_fire_department,

                    color:
                        Colors.orange,

                    size: 45,
                  ),

                  const SizedBox(
                    width: 20,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(
                          "Daily Calories",

                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          "$calories kcal",

                          style:
                              const TextStyle(
                            color:
                                Colors.white,

                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 24,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          goal,

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // TODAY'S WORKOUT
            // ==================================================

            const Text(
              "Today's Workout",

              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,

                fontSize: 22,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            StreamBuilder<
                QuerySnapshot>(
              stream: user == null
                  ? null
                  : FirebaseFirestore
                      .instance
                      .collection("users")
                      .doc(user.uid)
                      .collection("workouts")
                      .orderBy(
                        "createdAt",
                        descending: true,
                      )
                      .limit(1)
                      .snapshots(),

              builder:
                  (context, snapshot) {

                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        25,
                      ),

                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(20),

                      child: Text(
                        "Failed to load workout.",

                        style:
                            TextStyle(
                          color:
                              Colors.red.shade700,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs
                        .isEmpty) {

                  return Card(
                    elevation: 3,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: ListTile(
                      contentPadding:
                          const EdgeInsets
                              .all(18),

                      leading:
                          const CircleAvatar(
                        backgroundColor:
                            Colors.blue,

                        child: Icon(
                          Icons
                              .fitness_center,

                          color:
                              Colors.white,
                        ),
                      ),

                      title:
                          const Text(
                        "No Workout Yet",

                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle:
                          const Text(
                        "Create your first workout",
                      ),

                      trailing:
                          const Icon(
                        Icons
                            .arrow_forward_ios,
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const WorkoutScreen(),
                          ),
                        );
                      },
                    ),
                  );
                }

                final doc =
                    snapshot.data!
                        .docs.first;

                final data =
                    doc.data()
                        as Map<String,
                            dynamic>;

                final workout =
                    WorkoutModel(
                  id: doc.id,

                  name:
                      data["name"] ??
                          "Workout",

                  style:
                      data["style"] ??
                          "Normal Training",

                  exercises:
                      List<
                          Map<String,
                              dynamic>>.from(
                    data["exercises"] ??
                        [],
                  ),

                  createdAt:
                      data["createdAt"] ??
                          Timestamp.now(),
                );

                return Card(
                  elevation: 3,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),

                    leading:
                        const CircleAvatar(
                      radius: 25,

                      backgroundColor:
                          Colors.blue,

                      child: Icon(
                        Icons
                            .fitness_center,

                        color:
                            Colors.white,
                      ),
                    ),

                    title: Text(
                      workout.name,

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    subtitle: Text(
                      "${workout.style} • "
                      "${workout.exercises.length} Exercises",
                    ),

                    trailing:
                        const Icon(
                      Icons
                          .arrow_forward_ios,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutDetailScreen(
                            workout:
                                workout,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // TODAY'S NUTRITION
            // ==================================================

            const Text(
              "Today's Nutrition",

              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,

                fontSize: 22,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream:
                  _nutritionService
                      .watchTodayFoods(),

              builder:
                  (context, snapshot) {

                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {

                  return Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(20),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child:
                        const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {

                  return Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(20),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      "Failed to load nutrition.",

                      style:
                          TextStyle(
                        color:
                            Colors.red.shade700,
                      ),
                    ),
                  );
                }

                double
                    consumedCalories =
                    0;

                double
                    consumedProtein =
                    0;

                double
                    consumedCarbs =
                    0;

                double consumedFat =
                    0;

                final docs =
                    snapshot.data?.docs ??
                        [];

                for (final doc
                    in docs) {

                  final data =
                      doc.data();

                  consumedCalories +=
                      (data["calories"] ??
                              0)
                          .toDouble();

                  consumedProtein +=
                      (data["protein"] ??
                              0)
                          .toDouble();

                  consumedCarbs +=
                      (data["carbs"] ??
                              0)
                          .toDouble();

                  consumedFat +=
                      (data["fat"] ??
                              0)
                          .toDouble();
                }

                double
                    nutritionProgress =
                    0;

                if (calories > 0) {
                  nutritionProgress =
                      consumedCalories /
                          calories;
                }

                if (nutritionProgress >
                    1) {
                  nutritionProgress = 1;
                }

                return Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .all(20),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          const Text(
                            "Calories",

                            style:
                                TextStyle(
                              fontSize: 17,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            "${consumedCalories.toStringAsFixed(0)} / $calories kcal",

                            style:
                                TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),

                        child:
                            LinearProgressIndicator(
                          value:
                              nutritionProgress,

                          minHeight: 10,

                          backgroundColor:
                              Colors.deepPurple
                                  .withOpacity(
                            0.15,
                          ),

                          valueColor:
                              const AlwaysStoppedAnimation<
                                  Color>(
                            Colors.deepPurple,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          Text(
                            "Protein ${consumedProtein.toStringAsFixed(1)}g",
                          ),

                          Text(
                            "Carbs ${consumedCarbs.toStringAsFixed(1)}g",
                          ),

                          Text(
                            "Fat ${consumedFat.toStringAsFixed(1)}g",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // QUICK ACCESS
            // ==================================================

            const Text(
              "Quick Access",

              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,

                fontSize: 22,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            GridView.count(
              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: 1.15,

              children: [

                buildMenu(
                  context,
                  Icons.fitness_center,
                  "Workout",
                  Colors.blue,
                  const WorkoutScreen(),
                ),

                buildMenu(
                  context,
                  Icons.restaurant,
                  "Nutrition",
                  Colors.green,
                  const NutritionScreen(),
                ),

                buildMenu(
                  context,
                  Icons.show_chart,
                  "Progress",
                  Colors.orange,
                  const ProgressScreen(),
                ),

                buildMenu(
                  context,
                  Icons.directions_walk,
                  "Steps",
                  Colors.cyan,
                  const StepsScreen(),
                ),
              ],
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // TODAY'S PROGRESS
            // ==================================================

            const Text(
              "Today's Progress",

              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,

                fontSize: 22,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // REAL-TIME CALORIES + STEPS
            // ==================================================

            StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream:
                  _nutritionService
                      .watchTodayFoods(),

              builder:
                  (context,
                      nutritionSnapshot) {

                double
                    consumedCalories =
                    0;

                if (nutritionSnapshot
                    .hasData) {

                  for (final doc
                      in nutritionSnapshot
                          .data!.docs) {

                    final data =
                        doc.data();

                    consumedCalories +=
                        (data["calories"] ??
                                0)
                            .toDouble();
                  }
                }

                double
                    caloriePercentage =
                    0;

                if (calories > 0) {

                  caloriePercentage =
                      (consumedCalories /
                              calories) *
                          100;
                }

                if (caloriePercentage >
                    100) {
                  caloriePercentage =
                      100;
                }

                // ==========================================
                // STEPS STREAM
                // ==========================================

                return StreamBuilder<
                    QuerySnapshot<
                        Map<String,
                            dynamic>>>(
                  stream: user == null
                      ? null
                      : FirebaseFirestore
                          .instance
                          .collection(
                              "users")
                          .doc(user.uid)
                          .collection(
                              "step_logs")
                          .where(
                            "dateKey",
                            isEqualTo:
                                todayKey,
                          )
                          .snapshots(),

                  builder:
                      (context,
                          stepSnapshot) {

                    int totalSteps = 0;

                    if (stepSnapshot
                        .hasData) {

                      for (final doc
                          in stepSnapshot
                              .data!.docs) {

                        final data =
                            doc.data();

                        final value =
                            data["steps"];

                        if (value is int) {

                          totalSteps +=
                              value;

                        } else if (value
                            is num) {

                          totalSteps +=
                              value.toInt();
                        }
                      }
                    }

                    return Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(20),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Column(
                        children: [

                          // ====================================
                          // CALORIES
                          // ====================================

                          progressRow(
                            Icons.restaurant,

                            "Calories",

                            "${caloriePercentage.toStringAsFixed(0)}%",

                            Colors.green,
                          ),

                          const Divider(
                            height: 25,
                          ),

                          // ====================================
                          // STEPS
                          // ====================================

                          progressRow(
                            Icons.directions_walk,

                            "Steps",

                            "${formatNumber(totalSteps)} / ${formatNumber(dailyStepGoal)}",

                            Colors.cyan,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACCESS MENU
  // ============================================================

  Widget buildMenu(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget? page,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(20),

      onTap: () {

        if (page != null) {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        }
      },

      child: Container(

        decoration:
            BoxDecoration(
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
                  color.withOpacity(0.15),

              child: Icon(
                icon,

                color: color,

                size: 30,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              title,

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS ROW
  // ============================================================

  Widget progressRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [

        CircleAvatar(
          radius: 22,

          backgroundColor:
              color.withOpacity(0.15),

          child: Icon(
            icon,

            color: color,
          ),
        ),

        const SizedBox(
          width: 15,
        ),

        Expanded(
          child: Text(
            title,

            style:
                const TextStyle(
              fontSize: 16,
            ),
          ),
        ),

        Text(
          value,

          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,

            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // USER INFO CARD
  // ============================================================

  Widget infoCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(

      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(
              0.15,
            ),

            blurRadius: 8,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(

        children: [

          CircleAvatar(
            radius: 22,

            backgroundColor:
                color.withOpacity(0.15),

            child: Icon(
              icon,

              color: color,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,

            style:
                TextStyle(
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 17,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT NUMBER
  // ============================================================

  String formatNumber(
    int number,
  ) {
    return number
        .toString()
        .replaceAllMapped(
          RegExp(
            r'(\d)(?=(\d{3})+(?!\d))',
          ),
          (match) =>
              '${match.group(1)},',
        );
  }
}
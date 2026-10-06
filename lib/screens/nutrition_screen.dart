import 'package:flutter/material.dart';

import '../services/food_database_services.dart';
import '../services/nutrition_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final FoodDatabaseService _foodService = FoodDatabaseService();
  final NutritionService _nutritionService = NutritionService();

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _foods = [];

  bool _loading = true;

  // IMPORTANT:
  // Stream dibuat SATU KALI.
  // Jangan panggil watchTodayFoods() langsung di build().
  late final Stream _todayFoodsStream;

  @override
  void initState() {
    super.initState();

    _todayFoodsStream = _nutritionService.watchTodayFoods();

    _searchController.addListener(_onSearchChanged);

    _loadFoods();
  }

  // ============================================================
  // LOAD FOOD DATABASE
  // ============================================================

  Future<void> _loadFoods() async {
    try {
      final foods = await _foodService.loadFoods();

      if (!mounted) return;

      setState(() {
        _foods = foods;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load food database: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    if (!mounted) return;

    // Rebuild untuk menampilkan hasil search.
    //
    // Karena TextField + FocusNode + Controller tetap
    // merupakan widget yang sama, focus tidak hilang.
    setState(() {});
  }

  List<Map<String, dynamic>> get _filteredFoods {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return _foods.take(30).toList();
    }

    return _foods
        .where((food) {
          final name = food['name'].toString().toLowerCase();

          return name.contains(query);
        })
        .take(50)
        .toList();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void _clearSearch() {
    _searchController.clear();

    // Kembalikan focus ke search box.
    // Ini memastikan keyboard tetap terbuka.
    if (mounted) {
      _searchFocusNode.requestFocus();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);

    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          'Nutrition',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              // IMPORTANT:
              // Pakai stream yang dibuat di initState.
              // Jangan panggil watchTodayFoods() di sini.
              stream: _todayFoodsStream,

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                return _buildNutritionPage(docs);
              },
            ),
    );
  }

  // ============================================================
  // NUTRITION PAGE
  // ============================================================

  Widget _buildNutritionPage(List<dynamic> docs) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      totalCalories += _toDouble(data['calories']);
      totalProtein += _toDouble(data['protein']);
      totalCarbs += _toDouble(data['carbs']);
      totalFat += _toDouble(data['fat']);
    }

    return Column(
      children: [
        // ======================================================
        // SEARCH
        // ======================================================

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            10,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,

            textInputAction: TextInputAction.search,

            decoration: InputDecoration(
              hintText: 'Search food...',

              prefixIcon: const Icon(
                Icons.search,
              ),

              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,

              filled: true,
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // ======================================================
        // MAIN CONTENT
        // ======================================================

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =================================================
                // TODAY'S NUTRITION
                // =================================================

                const Text(
                  "Today's Nutrition",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _buildNutritionSummary(
                  totalCalories,
                  totalProtein,
                  totalCarbs,
                  totalFat,
                ),

                const SizedBox(height: 30),

                // =================================================
                // TODAY'S FOODS
                // =================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      "Today's Foods",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${docs.length} items',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                if (docs.isEmpty)
                  _buildEmptyFood(),

                if (docs.isNotEmpty)
                  ...docs.map(
                    (doc) => _buildTodayFood(doc),
                  ),

                const SizedBox(height: 30),

                // =================================================
                // ADD FOOD BUTTON
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.add,
                    ),

                    label: const Text(
                      'ADD FOOD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    onPressed: () {
                      _searchController.clear();

                      // Langsung fokus ke search.
                      // Keyboard akan muncul dan tetap aktif.
                      _searchFocusNode.requestFocus();
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // SEARCH RESULTS
                // =================================================

                if (_searchController.text.trim().isNotEmpty) ...[
                  const Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (_filteredFoods.isEmpty)
                    _buildNoSearchResult(),

                  if (_filteredFoods.isNotEmpty)
                    ..._filteredFoods.map(
                      (food) => _buildFoodCard(food),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildNutritionSummary(
    double calories,
    double protein,
    double carbs,
    double fat,
  ) {
    const double dailyTarget = 2500.0;

    double progress = calories / dailyTarget;

    if (progress > 1) {
      progress = 1;
    }

    if (progress < 0) {
      progress = 0;
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Calories',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '${calories.toStringAsFixed(0)} / '
                '${dailyTarget.toStringAsFixed(0)} kcal',

                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,

              backgroundColor:
                  Colors.deepPurple.withOpacity(0.15),

              valueColor:
                  const AlwaysStoppedAnimation(
                Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              _macroText(
                'Protein',
                protein,
              ),

              _macroText(
                'Carbs',
                carbs,
              ),

              _macroText(
                'Fat',
                fat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MACRO TEXT
  // ============================================================

  Widget _macroText(
    String title,
    double value,
  ) {
    return Text(
      '$title ${value.toStringAsFixed(1)}g',

      style: const TextStyle(
        fontSize: 14,
      ),
    );
  }

  // ============================================================
  // TODAY FOOD CARD
  // ============================================================

  Widget _buildTodayFood(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;

    final name =
        data['foodName']?.toString() ?? 'Food';

    final grams = _toDouble(data['grams']);
    final calories = _toDouble(data['calories']);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: const CircleAvatar(
          radius: 25,

          backgroundColor: Color(0xFFE8F5E9),

          child: Icon(
            Icons.restaurant,
            color: Colors.green,
          ),
        ),

        title: Text(
          name,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '${grams.toStringAsFixed(0)} g',
        ),

        trailing: Text(
          '${calories.toStringAsFixed(0)} kcal',

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyFood() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 50,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          const Text(
            'No food logged today',

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Search for food above and add it to your day.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO SEARCH RESULT
  // ============================================================

  Widget _buildNoSearchResult() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 50,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          const Text(
            'No food found',

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Try searching with a different food name.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOD SEARCH CARD
  // ============================================================

  Widget _buildFoodCard(
    Map<String, dynamic> food,
  ) {
    final name =
        food['name']?.toString() ?? 'Food';

    final calories =
        _toDouble(food['calories']);

    final protein =
        _toDouble(food['protein']);

    final carbs =
        _toDouble(food['carbs']);

    final fat =
        _toDouble(food['fat']);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: const CircleAvatar(
          radius: 28,

          backgroundColor: Color(0xFFE8F5E9),

          child: Icon(
            Icons.restaurant,
            color: Colors.green,
          ),
        ),

        title: Text(
          name,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '${calories.toStringAsFixed(0)} kcal • '
          'P ${protein.toStringAsFixed(1)}g • '
          'C ${carbs.toStringAsFixed(1)}g • '
          'F ${fat.toStringAsFixed(1)}g',
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: () {
          _showFoodDetails(food);
        },
      ),
    );
  }

  // ============================================================
  // FOOD DETAIL
  // ============================================================

  void _showFoodDetails(
    Map<String, dynamic> food,
  ) {
    final name =
        food['name']?.toString() ?? 'Food';

    final calories =
        _toDouble(food['calories']);

    final protein =
        _toDouble(food['protein']);

    final carbs =
        _toDouble(food['carbs']);

    final fat =
        _toDouble(food['fat']);

    final gramsController =
        TextEditingController(
      text: '100',
    );

    double grams = 100;

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            final multiplier =
                grams / 100;

            final calculatedCalories =
                calories * multiplier;

            final calculatedProtein =
                protein * multiplier;

            final calculatedCarbs =
                carbs * multiplier;

            final calculatedFat =
                fat * multiplier;

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,

                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        24,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // =================================================
                    // HANDLE
                    // =================================================

                    Center(
                      child: Container(
                        width: 45,
                        height: 5,

                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,

                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =================================================
                    // FOOD NAME
                    // =================================================

                    Text(
                      name,

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Amount',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // GRAMS
                    // =================================================

                    TextField(
                      controller: gramsController,

                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      decoration: InputDecoration(
                        suffixText: 'g',

                        filled: true,

                        fillColor:
                            Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),

                      onChanged: (value) {
                        final parsed =
                            double.tryParse(value);

                        if (parsed != null &&
                            parsed > 0) {
                          setSheetState(() {
                            grams = parsed;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // CALCULATED NUTRITION
                    // =================================================

                    _nutritionResult(
                      'Calories',
                      '${calculatedCalories.toStringAsFixed(0)} kcal',
                      Colors.orange,
                    ),

                    _nutritionResult(
                      'Protein',
                      '${calculatedProtein.toStringAsFixed(1)} g',
                      Colors.blue,
                    ),

                    _nutritionResult(
                      'Carbohydrate',
                      '${calculatedCarbs.toStringAsFixed(1)} g',
                      Colors.green,
                    ),

                    _nutritionResult(
                      'Fat',
                      '${calculatedFat.toStringAsFixed(1)} g',
                      Colors.purple,
                    ),

                    const SizedBox(height: 15),

                    // =================================================
                    // ADD TO TODAY
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add,
                        ),

                        label: const Text(
                          'ADD TO TODAY',

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        onPressed: () async {
                          // Jangan allow empty/invalid grams.
                          if (grams <= 0) {
                            return;
                          }

                          try {
                            await _nutritionService.addFood(
                              foodName: name,

                              grams: grams,

                              calories:
                                  calculatedCalories,

                              protein:
                                  calculatedProtein,

                              carbs:
                                  calculatedCarbs,

                              fat:
                                  calculatedFat,
                            );

                            if (!mounted) return;

                            Navigator.pop(
                              sheetContext,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$name added to today!',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to add food: $e',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      gramsController.dispose();
    });
  }

  // ============================================================
  // NUTRITION RESULT
  // ============================================================

  Widget _nutritionResult(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),

          Text(
            value,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NUMBER HELPER
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }
}
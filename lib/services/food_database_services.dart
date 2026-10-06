import 'dart:convert';

import 'package:flutter/services.dart';

class FoodDatabaseService {
  static List<Map<String, dynamic>>? _foods;

  Future<List<Map<String, dynamic>>> loadFoods() async {
    // Kalau data sudah pernah dimuat,
    // jangan load JSON lagi.
    if (_foods != null) {
      return _foods!;
    }

    // Baca foods.json dari assets
    final jsonString = await rootBundle.loadString(
      'assets/data/foods.json',
    );

    // Convert JSON String menjadi List
    final List<dynamic> data = jsonDecode(jsonString);

    // Convert setiap item menjadi Map
    _foods = data
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();

    return _foods!;
  }

  Future<List<Map<String, dynamic>>> searchFoods(
    String query,
  ) async {
    final foods = await loadFoods();

    final search = query.toLowerCase().trim();

    // Kalau search kosong, tampilkan semua
    if (search.isEmpty) {
      return foods;
    }

    // Cari berdasarkan nama makanan
    return foods.where((food) {
      final name = food['name']
          .toString()
          .toLowerCase();

      return name.contains(search);
    }).toList();
  }
}
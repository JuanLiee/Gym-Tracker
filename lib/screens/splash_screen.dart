import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ==========================================
    // CEK USER LOGIN
    // ==========================================
    final user = FirebaseAuth.instance.currentUser;

    // Belum login
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
      return;
    }

    // ==========================================
    // USER SUDAH LOGIN
    // CEK PROFILE FIRESTORE
    // ==========================================
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      // ==========================================
      // USER BELUM PUNYA DATA PROFILE
      // ==========================================
      if (!doc.exists || doc.data() == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileSetupScreen(),
          ),
        );
        return;
      }

      final data = doc.data()!;

      // ==========================================
      // CEK FLAG PROFILE COMPLETED
      // ==========================================
      if (data["profileCompleted"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
        return;
      }

      // ==========================================
      // UNTUK USER LAMA
      //
      // Kalau profileCompleted belum ada,
      // kita cek apakah data profile sebenarnya
      // sudah lengkap.
      // ==========================================
      final name = data["name"];
      final birthDate = data["birthDate"];
      final height = data["height"];
      final weight = data["weight"];
      final goal = data["goal"];

      final profileIsComplete =
          name != null &&
          name.toString().trim().isNotEmpty &&
          birthDate != null &&
          birthDate.toString().trim().isNotEmpty &&
          height != null &&
          weight != null &&
          goal != null &&
          goal.toString().trim().isNotEmpty;

      // ==========================================
      // PROFILE LAMA TERNYATA SUDAH LENGKAP
      // ==========================================
      if (profileIsComplete) {
        // Tandai sebagai completed supaya
        // pengecekan berikutnya lebih simpel.
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set(
          {
            "profileCompleted": true,
          },
          SetOptions(merge: true),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );

        return;
      }

      // ==========================================
      // PROFILE MEMANG BELUM LENGKAP
      // ==========================================
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        ),
      );
    } catch (e) {
      debugPrint("Splash error: $e");

      if (!mounted) return;

      // Jangan logout user hanya karena
      // ada masalah membaca Firestore.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
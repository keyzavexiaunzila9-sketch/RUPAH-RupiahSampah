import 'dart:async'; 
import 'package:flutter/material.dart'; 
import '../core/widget/rupah_wiedgets.dart'; 
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(milliseconds: 2800),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E8B57),
              Color(0xFFF5FAF8),
              Color(0xFF4FA3A5),
            ],
            stops: [
              0.0,
              0.52,
              1.0,
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/logo_rupah.png',
            width: 145,
            height: 145,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../auth/splash_screen.dart';

class RupahUserApp extends StatelessWidget {
  const RupahUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RUPAH - Pusat Kelola Sampah',
      theme: RupahTheme.light(),
      home: const SplashScreen(),
    );
  }
}
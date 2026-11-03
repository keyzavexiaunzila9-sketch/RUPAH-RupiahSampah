import 'package:flutter/material.dart';
import 'widgets/admin_navigation.dart';
import 'widgets/admin_widgets.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AdminColors.bg,
        body: const SafeArea(
          child: AdminNavigation(),
        ),
      ),
    );
  }
}
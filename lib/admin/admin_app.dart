
import 'package:flutter/material.dart';
import 'widgets/admin_navigation.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminNavigation(),
    );
  }
}

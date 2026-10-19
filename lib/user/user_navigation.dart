
import 'package:flutter/material.dart';
import 'widgets/user_bottom_nav.dart';
import 'screens/dashboard_screens.dart';
import 'screens/setor_sampah_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/profil_user_screen.dart';

class UserNavigation extends StatefulWidget {
  const UserNavigation({super.key});

  @override
  State<UserNavigation> createState() => _UserNavigationState();
}

class _UserNavigationState extends State<UserNavigation> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreens(),
      const SetorSampahScreen(),
      const RiwayatScreen(),
      const ProfilUserScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

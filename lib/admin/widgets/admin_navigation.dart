
import 'package:flutter/material.dart';

import '../screens/dashboard_admin_screen.dart';
import '../screens/verifikasi_setoran_screen.dart';
import '../screens/data_sampah_screen.dart';
import '../screens/data_kelas_screen.dart';
import '../screens/riwayat_admin_screen.dart';

import 'admin_bottom_nav.dart';

final ValueNotifier<int> adminTab = ValueNotifier<int>(0);

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({super.key});

  static const List<String> tabNames = [
    'Dashboard',
    'Verifikasi',
    'Data Sampah',
    'Data Kelas',
    'Riwayat',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: adminTab,
      builder: (context, index, child) {
        final pages = [
          DashboardAdminScreen(
            onOpenVerification: () {
              adminTab.value = 1;
            },
          ),
          const VerifikasiSetoranScreen(),
          const DataSampahScreen(),
          const DataKelasScreen(),
          const RiwayatAdminScreen(),
        ];

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: IndexedStack(
              index: index,
              children: pages,
            ),
          ),
          bottomNavigationBar: AdminBottomNav(
            currentIndex: index,
            onTap: (i) {
              adminTab.value = i;
            },
          ),
        );
      },
    );
  }
}

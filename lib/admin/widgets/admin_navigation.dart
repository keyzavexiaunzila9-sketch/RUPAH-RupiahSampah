import 'package:flutter/material.dart';

import '../screens/dashboard_admin_screen.dart';
import '../screens/data_kelas_screen.dart';
import '../screens/data_sampah_screen.dart';
import '../screens/riwayat_admin_screen.dart';
import '../screens/verifikasi_setoran_screen.dart';
import 'admin_bottom_nav.dart';

final ValueNotifier<int> adminTab = ValueNotifier<int>(0);

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: adminTab,
      builder: (context, index, child) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [
              DashboardAdminScreen(),
              VerifikasiSetoranScreen(),
              DataSampahScreen(),
              DataKelasScreen(),
              RiwayatAdminScreen(),
            ],
          ),
          bottomNavigationBar: AdminBottomNav(
            currentIndex: index,
            onTap: (i) => adminTab.value = i,
          ),
        );
      },
    );
  }
}
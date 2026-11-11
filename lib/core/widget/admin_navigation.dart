
import 'package:flutter/material.dart';

import 'package:flutter_application_1/admin/screens/dashboard_admin_screen.dart';
import 'package:flutter_application_1/admin/screens/verifikasi_setoran_screen.dart';
import 'package:flutter_application_1/admin/screens/data_sampah_screen.dart';
import 'package:flutter_application_1/admin/screens/data_kelas_screen.dart';
import 'package:flutter_application_1/admin/screens/riwayat_admin_screen.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    DashboardAdminScreen(
      onOpenVerification: () => _onTap(1),
    ),
    const VerifikasiSetoranScreen(),
    const DataSampahScreen(),
    const DataKelasScreen(),
    const RiwayatAdminScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RupahColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: RupahColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          child: Row(
            children: [
              _buildItem(
                0,
                Icons.dashboard_customize_rounded,
                'Dashboard',
              ),
              _buildItem(
                1,
                Icons.fact_check_rounded,
                'Verifikasi',
                showBadge: true,
              ),
              _buildItem(
                2,
                Icons.inventory_2_rounded,
                'Data Sampah',
              ),
              _buildItem(
                3,
                Icons.person_rounded,
                'Data Kelas',
              ),
              _buildItem(
                4,
                Icons.history_rounded,
                'Riwayat',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    int index,
    IconData icon,
    String label, {
    bool showBadge = false,
  }) {
    final bool active = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(index),
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: active
                  ? RupahColors.green
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 25,
                      color: active
                          ? Colors.white
                          : const Color(0xFF172D23),
                    ),
                    if (showBadge)
                      Positioned(
                        right: -10,
                        top: -7,
                        child: Container(
                          width: 19,
                          height: 19,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RupahTheme.body(
                    size: 10,
                    color: active
                        ? Colors.white
                        : const Color(0xFF26382F),
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

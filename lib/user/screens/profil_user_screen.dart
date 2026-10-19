import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widget/rupah_widgets.dart';
import '../../auth/login_screen.dart';

class ProfilUserScreen extends StatelessWidget {
  const ProfilUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 62,
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: RupahLogo(size: 44),
        ),
        title: Text(
          'Profil Kelas',
          style: RupahTheme.heading(
            size: 18,
            color: RupahColors.green,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 26),
        child: Column(
          children: [
            // Informasi kelas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RupahColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: RupahColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: RupahColors.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const RupahLogo(size: 38),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelas XI RPL 1',
                          style: RupahTheme.heading(size: 17),
                        ),
                        const SizedBox(height: 3),
                        const StatusPill(
                          text: 'Aktif dan Terverifikasi',
                          color: RupahColors.green,
                          background: RupahColors.softGreen,
                          icon: Icons.verified_rounded,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Wali Kelas: Bpk. Haryono, S.Kom',
                          style: RupahTheme.body(
                            size: 10,
                            color: RupahColors.muted,
                          ),
                        ),
                        Text(
                          'Ketua Adiwiyata: Ahmad Arfani',
                          style: RupahTheme.body(
                            size: 10,
                            color: RupahColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Statistik kelas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RupahColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: RupahColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _metric(
                      'Total Saldo Kelas',
                      'Rp 50.000',
                      Icons.account_balance_wallet_outlined,
                      RupahColors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metric(
                      'Sampah Terpilah',
                      '25 Kg',
                      Icons.recycling_rounded,
                      RupahColors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            // Informasi sekolah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RupahColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: RupahColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_outlined,
                        color: RupahColors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Informasi Sekolah',
                          style: RupahTheme.heading(size: 15),
                        ),
                      ),
                      const StatusPill(
                        text: 'Terverifikasi',
                        color: RupahColors.green,
                        background: RupahColors.softGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Institusi',
                    value: 'SMKN 8 MALANG',
                  ),
                  const InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Drop Point',
                    value: 'RUANG ADIWIYATA',
                  ),
                  const InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Jadwal',
                    value: 'Setiap Jumat, 09:00 - 10:30 WIB',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            RupahPrimaryButton(
              label: 'Keluar Akun Kelas',
              icon: Icons.logout_rounded,
              outlined: true,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 7),
          Text(
            label,
            style: RupahTheme.body(
              size: 9.5,
              color: RupahColors.muted,
            ),
          ),
          Text(
            value,
            style: RupahTheme.heading(
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
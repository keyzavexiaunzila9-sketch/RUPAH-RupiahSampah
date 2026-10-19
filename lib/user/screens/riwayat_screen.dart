import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widget/rupah_widgets.dart';
import 'detail_setoran_screen.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 62,
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: RupahLogo(size: 44),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Setor Kelas',
              style: RupahTheme.heading(
                size: 17,
                color: RupahColors.green,
              ),
            ),
            Text(
              'Kelas XI RPL 1',
              style: RupahTheme.body(
                size: 9.5,
                color: RupahColors.muted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4EA49A),
                    RupahColors.green,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Kas Terkumpul dari Sampah',
                    style: RupahTheme.body(
                      size: 10.5,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  Text(
                    'Rp 127.500',
                    style: RupahTheme.heading(
                      size: 23,
                      color: RupahColors.white,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Expanded(
                        child: _summary('Total Berat', '42,5 Kg'),
                      ),
                      Expanded(
                        child: _summary('Total Setoran', '14 kali'),
                      ),
                      Expanded(
                        child: _summary('Paling Sering', 'Plastik PET'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _historyCard(
              context,
              date: '30 Sep 2024 • 09:30 WIB',
              title: 'Botol Plastik PET & Kardus',
              category: 'Anorganik',
              weight: '4,5 Kg',
              price: 'Rp 2.000/Kg',
              reward: '+Rp 9.000',
              icon: Icons.recycling_rounded,
              detailCategory: 'Kertas',
              detailWeight: 4.5,
            ),
            _historyCard(
              context,
              date: '10 Oct 2024 • 08:30 WIB',
              title: 'Baterai & Lampu Lab',
              category: 'B3',
              weight: '1,5 Kg',
              price: 'Rp 5.000/Kg',
              reward: '+Rp 7.500',
              icon: Icons.battery_4_bar_rounded,
              detailCategory: 'Logam',
              detailWeight: 1.5,
            ),
            _historyCard(
              context,
              date: '05 Oct 2024 • 12:30 WIB',
              title: 'Gelas Mineral & Plastik',
              category: 'Anorganik',
              weight: '5,0 Kg',
              price: 'Rp 2.000/Kg',
              reward: '+Rp 10.000',
              icon: Icons.local_drink_outlined,
              detailCategory: 'Plastik',
              detailWeight: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: RupahTheme.body(
            size: 9,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: RupahTheme.body(
            size: 12,
            color: RupahColors.white,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _historyCard(
    BuildContext context, {
    required String date,
    required String title,
    required String category,
    required String weight,
    required String price,
    required String reward,
    required IconData icon,
    required String detailCategory,
    required double detailWeight,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSetoranScreen(
              category: detailCategory,
              weight: detailWeight,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: RupahColors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: RupahColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: RupahColors.softGreen,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 19,
                color: RupahColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: RupahTheme.body(
                      size: 9.5,
                      color: RupahColors.muted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: RupahTheme.body(
                      size: 12.5,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$category • $weight • $price',
                    style: RupahTheme.body(
                      size: 10,
                      color: RupahColors.muted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Kas bertambah $reward',
                    style: RupahTheme.body(
                      size: 10,
                      color: RupahColors.green,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 13,
                        color: RupahColors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Terverifikasi',
                        style: TextStyle(
                          fontSize: 10,
                          color: RupahColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: RupahColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

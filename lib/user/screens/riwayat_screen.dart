import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widget/rupah_widgets.dart';
import 'detail_setoran_screen.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FD),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
                size: 18,
                color: RupahColors.green,
              ),
            ),
            Text(
              'Kelas XI RPL 1',
              style: RupahTheme.body(
                size: 12,
                color: RupahColors.muted,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        child: Column(
          children: [
            // KARTU TOTAL KAS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF006B45),
                    Color(0xFF00856C),
                    Color(0xFF006D68),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006B45).withOpacity(0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Hiasan background
                  Positioned(
                    right: -35,
                    bottom: -45,
                    child: Icon(
                      Icons.eco_outlined,
                      size: 155,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Judul saldo
                      Text(
                        'Total Kas Terkumpul dari Sampah',
                        style: RupahTheme.body(
                          size: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // Nominal saldo
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rp 127.500',
                            style: RupahTheme.heading(
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'IDR',
                              style: TextStyle(
                                color: Color(0xFF8CF5C1),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Garis pembatas
                      Divider(
                        color: Colors.white.withOpacity(0.25),
                        thickness: 1,
                      ),

                      const SizedBox(height: 7),

                      // Statistik ringkasan
                      Row(
                        children: [
                          Expanded(
                            child: _summary(
                              'Total Berat',
                              '42,5',
                              'Kg',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _summary(
                              'Total Setoran',
                              '14',
                              'Kali',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _summary(
                              'Paling Sering',
                              'Plastik PET',
                              '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DAFTAR RIWAYAT SETORAN
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

  // WIDGET RINGKASAN STATISTIK
  Widget _summary(String title, String value, String satuan) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (satuan.isNotEmpty)
                  TextSpan(
                    text: ' $satuan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET KARTU RIWAYAT
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
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
                      size: 12,
                      color: RupahColors.muted,
                    ),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    title,
                    style: RupahTheme.body(
                      size: 14,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    '$category • $weight • $price',
                    style: RupahTheme.body(
                      size: 12,
                      color: RupahColors.muted,
                    ),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    'Kas bertambah $reward',
                    style: RupahTheme.body(
                      size: 12,
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
                          fontSize: 12,
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
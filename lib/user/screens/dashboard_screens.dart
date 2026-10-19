
import 'package:flutter/material.dart';

class DashboardScreens extends StatelessWidget {
  const DashboardScreens({super.key});

  static const Color hijau = Color(0xFF2D9565);
  static const Color background = Color(0xFFF6F8FC);
  static const Color teks = Color(0xFF172235);

  void tampilPesan(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Image.asset(
                    'assets/logo_rupah.png',
                    width: 65,
                    height: 65,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.red,
                      );
                    },
                  ),
                  const Spacer(),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, 👋',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Kelas XI RPL 1',
                        style: TextStyle(
                          color: teks,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // KARTU SALDO
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5BAEAB),
                      Color(0xFF2D9565),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: hijau.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      right: -5,
                      bottom: -15,
                      child: Icon(
                        Icons.eco,
                        size: 125,
                        color: Color(0x335FFFFFF),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '💰 Saldo Kelas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Total Tabungan Terkumpul',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Rp 50.000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x4459F5A5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'AKTIF & TERVERIFIKASI',
                          style: TextStyle(
                            color: Color(0xFFB8FFD2),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // STATISTIK
              Row(
                children: [
                  Expanded(
                    child: kartuStatistik(
                      icon: Icons.recycling,
                      judul: 'Total Sampah',
                      nilai: '25 Kg',
                      warna: const Color(0xFFD1F9DF),
                      warnaIcon: const Color(0xFF087D50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: kartuStatistik(
                      icon: Icons.inventory_2_outlined,
                      judul: 'Total Setoran',
                      nilai: '8 Setoran',
                      warna: const Color(0xFFCCF7F7),
                      warnaIcon: const Color(0xFF008A8A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // MENU UTAMA
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: teks,
                ),
              ),

              const SizedBox(height: 12),

              menuUtama(
                context,
                icon: Icons.delete_outline,
                judul: 'Setor Sampah',
                deskripsi: 'Kirim setoran baru',
                warna: const Color(0xFFD8FBE4),
                warnaIcon: const Color(0xFF168451),
                pesan: 'Halaman Setor Sampah akan dibuat berikutnya.',
              ),

              const SizedBox(height: 12),

              menuUtama(
                context,
                icon: Icons.person,
                judul: 'Profil Kelas',
                deskripsi: 'Pengaturan akun',
                warna: const Color(0xFFDCE9FF),
                warnaIcon: const Color(0xFF527DB8),
                pesan: 'Halaman Profil User akan dibuat berikutnya.',
              ),

              const SizedBox(height: 36),

              // TIPS ECO-FIN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F8F8),
                  border: Border.all(
                    color: const Color(0xFF8CF0B2),
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF087D50),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: teks,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Tips Eco-Fin: ',
                              style: TextStyle(
                                color: Color(0xFF087D50),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Pastikan botol plastik dipisahkan '
                                  'dan dikeringkan agar timbangan '
                                  'lebih efisien!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget kartuStatistik({
    required IconData icon,
    required String judul,
    required String nilai,
    required Color warna,
    required Color warnaIcon,
  }) {
    return Container(
      height: 102,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: warna,
            child: Icon(icon, color: warnaIcon, size: 23),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nilai,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: teks,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menuUtama(
    BuildContext context, {
    required IconData icon,
    required String judul,
    required String deskripsi,
    required Color warna,
    required Color warnaIcon,
    required String pesan,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () => tampilPesan(context, pesan),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE0E8E2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: warnaIcon, size: 23),
              ),
              const SizedBox(height: 12),
              Text(
                judul,
                style: const TextStyle(
                  color: teks,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deskripsi,
                style: const TextStyle(
                  color: Color(0xFF56615A),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
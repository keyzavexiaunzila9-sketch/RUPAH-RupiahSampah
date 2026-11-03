
import 'package:flutter/material.dart';
import '../widgets/admin_widgets.dart';
import 'edit_sampah_screen.dart';
import 'form_sampah_screen.dart';

class _Sampah {
  final String nama, tag, deskripsi, stok, tarif;
  final Color warna, soft;
  final IconData icon;

  const _Sampah(
    this.nama,
    this.tag,
    this.deskripsi,
    this.stok,
    this.tarif,
    this.warna,
    this.soft,
    this.icon,
  );
}

const _data = [
  _Sampah(
    'Sampah Organik',
    'Daur Ulang Alami',
    'Sisa Kantin, Dedaunan & Kompos Sekolah',
    '120.0',
    '3.000',
    AdminColors.primary,
    AdminColors.primaryLight,
    Icons.eco,
  ),
  _Sampah(
    'Sampah Anorganik',
    'Daur Ulang Pengepul',
    'Plastik PET, Kertas, Kardus & Logam',
    '285.0',
    '2.000',
    AdminColors.teal,
    AdminColors.tealLight,
    Icons.recycling,
  ),
  _Sampah(
    'Sampah B3 & Berbahaya',
    'Penanganan Khusus',
    'Baterai Bekas, Lampu TL, Limbah Kimia Lab',
    '23.5',
    '5000',
    AdminColors.danger,
    AdminColors.dangerBg,
    Icons.warning_amber_rounded,
  ),
];

class DataSampahScreen extends StatelessWidget {
  const DataSampahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER DENGAN LOGO RUPAH
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AdminColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/logo_rupah.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.recycling_rounded,
                    size: 38,
                    color: AdminColors.primary,
                  );
                },
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katalog & Data Sampah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola Master Data & Tarif • 3 Kategori',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 84,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormSampahScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Baru',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // DAFTAR DATA SAMPAH
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AdminSearch(),
              for (final s in _data) _SampahCard(s),
            ],
          ),
        ),
      ],
    );
  }
}

class _SampahCard extends StatelessWidget {
  final _Sampah s;

  const _SampahCard(this.s);

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      accent: s.warna,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: s.soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  s.icon,
                  color: s.warna,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.nama,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AdminPill(
                      s.tag,
                      bg: s.soft,
                      fg: s.warna,
                      size: 10,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.deskripsi,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AdminColors.blueSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Stok Gudang',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text.rich(
                        TextSpan(
                          text: s.stok,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: s.warna,
                          ),
                          children: const [
                            TextSpan(
                              text: ' Kg',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 36,
                  color: AdminColors.border,
                ),

                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Beli Siswa',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Rp ${s.tarif}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          children: const [
                            TextSpan(
                              text: '/Kg',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditSampahScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: s.soft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: s.warna,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Edit Tarif, Stok & Keterangan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: s.warna,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.delete_outline,
                  color: AdminColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

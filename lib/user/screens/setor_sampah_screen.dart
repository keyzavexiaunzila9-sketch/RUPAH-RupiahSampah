
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'form_setor_sampah_screen.dart';

class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});

  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen> {
  static const Color green = Color(0xFF087A4D);
  static const Color bg = Color(0xFFF5F9F7);
  static const Color ink = Color(0xFF26352F);
  static const Color muted = Color(0xFF78847E);

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> daftarSampah = [];

  bool sedangMemuat = true;
  String? pesanError;

  @override
  void initState() {
    super.initState();
    muatDataSampah();
  }

  // Mengambil data sampah dari Supabase
  Future<void> muatDataSampah() async {
    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });

    try {
      final response = await supabase
          .from('sampah')
          .select(
            'id_sampah, nama_sampah, kategori, harga_per_kg, satuan, deskripsi, status',
          )
          .eq('status', true)
          .order('nama_sampah', ascending: true);

      if (!mounted) return;

      setState(() {
        daftarSampah =
            List<Map<String, dynamic>>.from(response);
        sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        sedangMemuat = false;
        pesanError = e.toString();
      });
    }
  }

  // Format harga menjadi format Rupiah
  String formatHarga(dynamic harga) {
    final angka = (harga as num?)?.toDouble() ?? 0;

    return angka
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  // Icon berdasarkan kategori
  IconData iconKategori(String kategori) {
    final nama = kategori.toLowerCase();

    if (nama.contains('organik')) {
      return Icons.eco_rounded;
    } else if (nama.contains('kertas')) {
      return Icons.description_outlined;
    } else if (nama.contains('plastik')) {
      return Icons.recycling_rounded;
    } else if (nama.contains('logam')) {
      return Icons.hardware_rounded;
    } else if (nama.contains('b3')) {
      return Icons.warning_amber_rounded;
    }

    return Icons.delete_outline_rounded;
  }

  // Warna berdasarkan kategori
  Color warnaKategori(String kategori) {
    final nama = kategori.toLowerCase();

    if (nama.contains('organik')) {
      return green;
    } else if (nama.contains('b3')) {
      return const Color(0xFFD97706);
    }

    return const Color(0xFF168B91);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/logo_rupah.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
            const Text(
              'Setor Sampah',
              style: TextStyle(
                fontSize: 14,
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE8EFEB),
          ),
        ),
      ),

      body: RefreshIndicator(
        color: green,
        onRefresh: muatDataSampah,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 20),
          children: [
            // Label halaman
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 8),

            // Banner utama
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF50AAA5),
                    Color(0xFF29885D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: green.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -5,
                    bottom: -10,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 65,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yuk, Setor Sampahmu!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ubah sampah kelasmu menjadi pundi-pundi rupiah! '
                        'Pilah sampah dan kumpulkan untuk menambah '
                        'saldo kas kelas serta mendukung sekolah Adiwiyata.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Judul katalog
            const Text(
              'Katalog Tarif Sampah',
              style: TextStyle(
                color: ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 3),

            const Text(
              'Update tarif Bank Sampah Sekolah',
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            // Loading
            if (sedangMemuat)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: CircularProgressIndicator(
                    color: green,
                  ),
                ),
              )

            // Error
            else if (pesanError != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 35,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Gagal Memuat Data Sampah',
                      style: TextStyle(
                        color: ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pesanError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: muatDataSampah,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )

            // Data kosong
            else if (daftarSampah.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 42,
                      color: muted,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum Ada Sampah Tersedia',
                      style: TextStyle(
                        color: ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Jenis sampah yang aktif akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )

            // Katalog dari Supabase
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daftarSampah.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 170,
                ),
                itemBuilder: (context, index) {
                  final sampah = daftarSampah[index];

                  return _tarif(sampah);
                },
              ),

            const SizedBox(height: 28),

            // Tombol tambah setoran
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FormSetorSampahScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 17,
                ),
                label: const Text(
                  'Tambah Setoran Baru',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: green,
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget kartu tarif dinamis
  Widget _tarif(Map<String, dynamic> sampah) {
    final String nama = sampah['nama_sampah'] ?? '-';
    final String kategori = sampah['kategori'] ?? '-';
    final String deskripsi = sampah['deskripsi'] ?? '';
    final String satuan = sampah['satuan'] ?? 'kg';

    final harga = formatHarga(sampah['harga_per_kg']);
    final color = warnaKategori(kategori);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8EFEB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        iconKategori(kategori),
                        color: color,
                        size: 15,
                      ),
                    ),

                    const Spacer(),

                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5EF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          kategori,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Expanded(
                  child: Text(
                    deskripsi.isEmpty ? 'Tidak ada deskripsi' : deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ),

                const Divider(
                  height: 12,
                  color: Color(0xFFEDF1EE),
                ),

                Row(
                  children: [
                    const Text(
                      'Rp ',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        harga,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      ' /${satuan.toLowerCase()}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

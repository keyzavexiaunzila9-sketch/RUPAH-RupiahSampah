import 'package:flutter/material.dart';
import 'form_setor_sampah_screen.dart';

class SetorSampahScreen extends StatelessWidget {
  const SetorSampahScreen({super.key});

  static const Color green = Color(0xFF087A4D);
  static const Color bg = Color(0xFFF5F9F7);
  static const Color ink = Color(0xFF26352F);
  static const Color muted = Color(0xFF78847E);

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
                fontSize: 20,
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
      body: ListView(
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Ubah sampah kelasmu menjadi pundi-pundi rupiah! '
                      'Pilah botol, kertas, dan kardus untuk menambah '
                      'saldo kas kelas dan dukung sekolah Adiwiyata.',
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Update harian Bank Sampah Sekolah',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 12),

          // Kartu tarif dua kolom
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _tarif(
                  title: 'Organik',
                  example: 'Air mineral bening',
                  category: 'Plastik',
                  price: '3.000',
                  icon: Icons.recycling_rounded,
                  color: green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _tarif(
                  title: 'Anorganik',
                  example: 'Karton & buku bekas',
                  category: 'Kertas',
                  price: '2.000',
                  icon: Icons.description_outlined,
                  color: const Color(0xFF168B91),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Kartu B3
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.495,
              child: _tarif(
                title: 'B3',
                example: 'Kaleng soda & minuman',
                category: 'Logam',
                price: '5.000',
                icon: Icons.recycling_rounded,
                color: const Color(0xFF168B91),
              ),
            ),
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
                    builder: (_) => const FormSetorSampahScreen(),
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
    );
  }

  // Widget kartu tarif
  Widget _tarif({
    required String title,
    required String example,
    required String category,
    required String price,
    required IconData icon,
    required Color color,
  }) {
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
                        icon,
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
                          category,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  example,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                const Divider(
                  height: 12,
                  color: Color(0xFFEDF1EE),
                ),

                Row(
                  children: [
                    const Text(
                      'Nilai: ',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Rp $price',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Text(
                      ' /Kg',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
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
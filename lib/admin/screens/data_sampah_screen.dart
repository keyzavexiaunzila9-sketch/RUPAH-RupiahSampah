
import 'package:flutter/material.dart';
import '../widgets/admin_widgets.dart';
import '../../core/services/sampah_service.dart';
import 'edit_sampah_screen.dart';
import 'form_sampah_screen.dart';

class DataSampahScreen extends StatefulWidget {
  const DataSampahScreen({super.key});

  @override
  State<DataSampahScreen> createState() => _DataSampahScreenState();
}

class _DataSampahScreenState extends State<DataSampahScreen> {
  final service = SampahService();
  final searchController = TextEditingController();

  late Future<List<Map<String, dynamic>>> futureSampah;
  String kataKunci = '';

  @override
  void initState() {
    super.initState();
    futureSampah = service.getAllSampah();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void refreshData() {
    setState(() {
      futureSampah = service.getAllSampah();
    });
  }

  String formatRupiah(dynamic harga) {
    final nilai = (harga as num?)?.toInt() ?? 0;
    final angka = nilai.toString();

    return angka.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Future<void> tambahData() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FormSampahScreen(),
      ),
    );

    if (hasil == true) refreshData();
  }

  Future<void> editData(Map<String, dynamic> data) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditSampahScreen(data: data),
      ),
    );

    if (hasil == true) refreshData();
  }

  Future<void> hapusData(Map<String, dynamic> data) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Sampah'),
        content: Text(
          'Yakin ingin menghapus ${data['nama_sampah']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      await service.hapusSampah(data['id_sampah']);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus.'),
        ),
      );

      refreshData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data tidak bisa dihapus karena mungkin sudah digunakan '
            'dalam setoran. Ubah status menjadi nonaktif.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AdminColors.border),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/logo_rupah.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.recycling_rounded,
                  size: 38,
                  color: AdminColors.primary,
                ),
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
                      'Kelola Jenis Sampah & Tarif',
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
                  onPressed: tambahData,
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
                      Icon(Icons.add_circle_outline, size: 18),
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

        // DAFTAR DATA
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: futureSampah,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Gagal mengambil data sampah.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                        TextButton(
                          onPressed: refreshData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final semuaData = snapshot.data ?? [];

              // FILTER PENCARIAN
              final data = semuaData.where((item) {
                final nama = (item['nama_sampah'] ?? '')
                    .toString()
                    .toLowerCase();

                final kategori = (item['kategori'] ?? '')
                    .toString()
                    .toLowerCase();

                return nama.contains(kataKunci.toLowerCase()) ||
                    kategori.contains(kataKunci.toLowerCase());
              }).toList();

              if (semuaData.isEmpty) {
                return _pesanKosong(
                  'Belum ada data sampah.',
                  'Tambahkan jenis sampah pertama.',
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => kataKunci = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau kategori sampah...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: kataKunci.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                searchController.clear();
                                setState(() => kataKunci = '');
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (data.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(25),
                      child: Center(
                        child: Text(
                          'Data sampah tidak ditemukan.',
                        ),
                      ),
                    ),

                  for (final item in data)
                    _SampahCard(
                      data: item,
                      harga: formatRupiah(
                        item['harga_per_kg'],
                      ),
                      onEdit: () => editData(item),
                      onDelete: () => hapusData(item),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _pesanKosong(String judul, String deskripsi) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.recycling_outlined,
            size: 55,
            color: AdminColors.muted,
          ),
          const SizedBox(height: 12),
          Text(
            judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            deskripsi,
            style: const TextStyle(
              color: AdminColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CARD DATA SAMPAH
// ==========================================

class _SampahCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String harga;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SampahCard({
    required this.data,
    required this.harga,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final kategori = (data['kategori'] ?? '').toString();

    // STATUS BOOLEAN DARI SUPABASE
    final bool status = data['status'] == true;

    final warna = kategori == 'Organik'
        ? AdminColors.primary
        : kategori == 'B3'
            ? AdminColors.danger
            : AdminColors.teal;

    final soft = kategori == 'Organik'
        ? AdminColors.primaryLight
        : kategori == 'B3'
            ? AdminColors.dangerBg
            : AdminColors.tealLight;

    final icon = kategori == 'Organik'
        ? Icons.eco
        : kategori == 'B3'
            ? Icons.warning_amber_rounded
            : Icons.recycling;

    return AdminCard(
      accent: warna,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: warna),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nama_sampah'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    AdminPill(
                      kategori.isEmpty
                          ? 'Tanpa Kategori'
                          : kategori,
                      bg: soft,
                      fg: warna,
                      size: 10,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      data['deskripsi'] ?? 'Tidak ada deskripsi.',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // HARGA SAMPAH
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AdminColors.blueSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: AdminColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Text(
                      'Harga Beli dari Siswa',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      'Rp $harga / Kg',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // STATUS DAN AKSI
          Row(
            children: [
              AdminPill(
                status ? 'AKTIF' : 'NONAKTIF',
                bg: status
                    ? AdminColors.primaryLight
                    : const Color(0xFFEDEFF3),
                fg: status
                    ? AdminColors.primary
                    : AdminColors.muted,
                size: 9,
              ),

              const Spacer(),

              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AdminColors.primary,
                ),
                tooltip: 'Edit',
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AdminColors.danger,
                ),
                tooltip: 'Hapus',
              ),
            ],
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/admin_navigation.dart';
import '../widgets/admin_widgets.dart';
import 'rincian_penghasilan_screen.dart';
import '../../core/services/verifikasi_service.dart';

class RiwayatAdminScreen extends StatefulWidget {
  const RiwayatAdminScreen({super.key});

  @override
  State<RiwayatAdminScreen> createState() =>
      _RiwayatAdminScreenState();
}

class _RiwayatAdminScreenState extends State<RiwayatAdminScreen> {
  final VerifikasiService _service = VerifikasiService();
  final TextEditingController _searchController = TextEditingController();

  int _tab = 0;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> semuaSetoran = [];
  List<Map<String, dynamic>> semuaVerifikasi = [];
  List<Map<String, dynamic>> semuaUsers = [];

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // MEMUAT DATA RIWAYAT
  Future<void> loadRiwayat() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final hasil = await Future.wait<dynamic>([
        _service.getDataSetoran(),
        Supabase.instance.client
            .from('verifikasi')
            .select(
              'id_setoran, id_admin, status_verifikasi, catatan, tanggal',
            )
            .order('tanggal', ascending: false),
        Supabase.instance.client
            .from('users')
            .select('id_user, username'),
      ]);

      if (!mounted) return;

      setState(() {
        semuaSetoran =
            List<Map<String, dynamic>>.from(hasil[0] as List);

        semuaVerifikasi =
            List<Map<String, dynamic>>.from(hasil[1] as List);

        semuaUsers =
            List<Map<String, dynamic>>.from(hasil[2] as List);

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint('Gagal memuat riwayat: $e');
    }
  }

  // FORMAT RUPIAH
  String formatRupiah(double angka) {
    final nilai = angka.round().toString();

    return 'Rp ${nilai.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  // FORMAT BERAT
  String formatBerat(double angka) {
    return angka.toStringAsFixed(
      angka % 1 == 0 ? 0 : 1,
    );
  }

  // KONVERSI ANGKA
  double angka(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  // FORMAT TANGGAL
  String formatTanggal(dynamic value) {
    final tanggal = DateTime.tryParse(value?.toString() ?? '');

    if (tanggal == null) return '-';

    final sekarang = DateTime.now();

    final tanggalLokal = tanggal.toLocal();

    final jam =
        '${tanggalLokal.hour.toString().padLeft(2, '0')}:'
        '${tanggalLokal.minute.toString().padLeft(2, '0')}';

    final samaHariIni =
        tanggalLokal.year == sekarang.year &&
        tanggalLokal.month == sekarang.month &&
        tanggalLokal.day == sekarang.day;

    final kemarin = sekarang.subtract(const Duration(days: 1));

    final samaKemarin =
        tanggalLokal.year == kemarin.year &&
        tanggalLokal.month == kemarin.month &&
        tanggalLokal.day == kemarin.day;

    final namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    final tanggalText =
        '${tanggalLokal.day} ${namaBulan[tanggalLokal.month - 1]} '
        '${tanggalLokal.year}';

    if (samaHariIni) return 'Hari ini, $jam WIB';
    if (samaKemarin) return 'Kemarin, $jam WIB';

    return '$tanggalText • $jam WIB';
  }

  // MENGAMBIL DATA VERIFIKASI TERBARU
  Map<String, dynamic>? getVerifikasi(int idSetoran) {
    for (final item in semuaVerifikasi) {
      if (item['id_setoran'].toString() == idSetoran.toString()) {
        return item;
      }
    }

    return null;
  }

  // MENGAMBIL NAMA VERIFIKATOR
  String getNamaVerifikator(dynamic idAdmin) {
    if (idAdmin == null) return '-';

    for (final user in semuaUsers) {
      if (user['id_user'].toString() == idAdmin.toString()) {
        return user['username']?.toString() ?? '-';
      }
    }

    return '-';
  }

  // MENGAMBIL DATA RIWAYAT
  List<Map<String, dynamic>> get riwayatSetoran {
    final hasil = semuaSetoran.where((item) {
      final status = item['status']?.toString().toLowerCase();

      return status == 'disetujui' || status == 'ditolak';
    }).toList();

    hasil.sort((a, b) {
      final tanggalA = DateTime.tryParse(
        a['tanggal']?.toString() ?? '',
      );

      final tanggalB = DateTime.tryParse(
        b['tanggal']?.toString() ?? '',
      );

      if (tanggalA == null) return 1;
      if (tanggalB == null) return -1;

      return tanggalB.compareTo(tanggalA);
    });

    final keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) return hasil;

    return hasil.where((item) {
      final namaKelas =
          item['nama_kelas']?.toString().toLowerCase() ?? '';

      final detail = item['detail'] as List? ?? [];

      final namaSampah = detail.map((d) {
        return d['nama_sampah']?.toString().toLowerCase() ?? '';
      }).join(' ');

      return namaKelas.contains(keyword) ||
          namaSampah.contains(keyword);
    }).toList();
  }

  // MENGHITUNG TOTAL KAS SEKOLAH
  double get totalKas {
    double total = 0;

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() == 'disetujui') {
        total += angka(item['total_nilai']);
      }
    }

    return total;
  }

  // MENGHITUNG TOTAL BERAT SETORAN DISETUJUI
  double get totalBerat {
    double total = 0;

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() == 'disetujui') {
        total += angka(item['total_berat']);
      }
    }

    return total;
  }

  // MENGHITUNG TOTAL PARTISIPASI KELAS
  int get totalPartisipasi {
    final kelas = <String>{};

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() == 'disetujui') {
        final nama = item['nama_kelas']?.toString();

        if (nama != null && nama.isNotEmpty) {
          kelas.add(nama);
        }
      }
    }

    return kelas.length;
  }

  // PENGHASILAN BULAN INI
  double get penghasilanBulanIni {
    final sekarang = DateTime.now();

    double total = 0;

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() != 'disetujui') {
        continue;
      }

      final tanggal = DateTime.tryParse(
        item['tanggal']?.toString() ?? '',
      );

      if (tanggal != null &&
          tanggal.year == sekarang.year &&
          tanggal.month == sekarang.month) {
        total += angka(item['total_nilai']);
      }
    }

    return total;
  }

  // REKAP PENGHASILAN PER KELAS
  List<Map<String, dynamic>> get penghasilanKelas {
    final Map<String, Map<String, dynamic>> rekap = {};

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() != 'disetujui') {
        continue;
      }

      final namaKelas =
          item['nama_kelas']?.toString() ?? 'Kelas tidak diketahui';

      rekap.putIfAbsent(namaKelas, () {
        return {
          'nama_kelas': namaKelas,
          'total_nilai': 0.0,
          'total_berat': 0.0,
          'jumlah_setoran': 0,
        };
      });

      rekap[namaKelas]!['total_nilai'] +=
          angka(item['total_nilai']);

      rekap[namaKelas]!['total_berat'] +=
          angka(item['total_berat']);

      rekap[namaKelas]!['jumlah_setoran'] += 1;
    }

    final hasil = rekap.values.toList();

    hasil.sort((a, b) {
      return angka(b['total_nilai'])
          .compareTo(angka(a['total_nilai']));
    });

    final keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) return hasil;

    return hasil.where((item) {
      return item['nama_kelas']
          .toString()
          .toLowerCase()
          .contains(keyword);
    }).toList();
  }

  // TAB
  Widget _seg(int i, String label, {String? badge}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tab = i;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _tab == i ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _tab == i
                        ? AdminColors.primary
                        : AdminColors.text,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                AdminPill(
                  badge,
                  bg: AdminColors.tealLight,
                  fg: AdminColors.teal,
                  size: 9,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // RINGKASAN KAS
  Widget _sum(
    String label,
    String value, {
    String? unit,
    bool bright = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 3),
            Text.rich(
              TextSpan(
                text: value,
                style: TextStyle(
                  color: bright
                      ? const Color(0xFF9EF0B8)
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(fontSize: 9),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KARTU TOTAL KAS
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F7A4D),
            Color(0xFF3E9A78),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 15,
                color: Colors.white,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'TOTAL KAS SEKOLAH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AdminPill(
                '● Aktif',
                bg: Color(0x33FFFFFF),
                fg: Colors.white,
                size: 9,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Total Penghasilan Seluruh Kelas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isLoading ? 'Memuat...' : formatRupiah(totalKas),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(
            color: Colors.white24,
            height: 20,
          ),
          Row(
            children: [
              _sum(
                'Total Sampah',
                formatBerat(totalBerat),
                unit: 'Kg',
              ),
              const SizedBox(width: 8),
              _sum(
                'Partisipasi',
                '$totalPartisipasi',
                unit: 'Kelas',
              ),
              const SizedBox(width: 8),
              _sum(
                'Bulan Ini',
                penghasilanBulanIni >= 1000000
                    ? '${(penghasilanBulanIni / 1000000).toStringAsFixed(1)}jt'
                    : '${(penghasilanBulanIni / 1000).toStringAsFixed(0)}rb',
                bright: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SEARCH
  Widget _searchField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AdminColors.muted,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Cari kelas atau jenis sampah...',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: AdminColors.muted,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Icon(
                Icons.close,
                size: 17,
                color: AdminColors.muted,
              ),
            ),
        ],
      ),
    );
  }

  // BAGIAN RIWAYAT SETORAN
  Widget _riwayatContent() {
    final data = riwayatSetoran;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              color: AdminColors.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Aktivitas Setor Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${data.length} Transaksi',
              style: const TextStyle(
                fontSize: 9,
                color: AdminColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (data.isEmpty)
          _emptyState('Belum ada riwayat setoran.'),

        for (final item in data)
          _TxCard(
            item: item,
            verifikasi: getVerifikasi(
              int.tryParse(item['id_setoran'].toString()) ?? -1,
            ),
            namaVerifikator: getNamaVerifikator(
              getVerifikasi(
                int.tryParse(item['id_setoran'].toString()) ?? -1,
              )?['id_admin'],
            ),
            formatRupiah: formatRupiah,
            formatBerat: formatBerat,
            formatTanggal: formatTanggal,
          ),
      ],
    );
  }

  // BAGIAN PENGHASILAN KELAS
  Widget _penghasilanContent() {
    final data = penghasilanKelas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              color: AdminColors.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Penghasilan Per Kelas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${data.length} Kelas',
              style: const TextStyle(
                fontSize: 9,
                color: AdminColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (data.isEmpty)
          _emptyState('Belum ada penghasilan kelas.'),

        for (final item in data)
          _IncomeCard(
            item: item,
            formatRupiah: formatRupiah,
            formatBerat: formatBerat,
          ),
      ],
    );
  }

  // EMPTY STATE
  Widget _emptyState(String pesan) {
    return AdminCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 32,
              color: AdminColors.muted,
            ),
            const SizedBox(height: 8),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AdminColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARIF RESMI
  Widget _tarifCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFA8E0E0),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF9EEFF0),
            child: Icon(
              Icons.check,
              size: 16,
              color: AdminColors.teal,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TARIF RESMI BANK SAMPAH RUPAH',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.teal,
                  ),
                ),
                Text(
                  '🌿 Organik: Rp 3.000/Kg • ♻️ Anorganik: Rp 2.000/Kg • 🟠 B3: Rp 5.000/Kg',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: AdminColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AdminColors.primary,
            ),
            onPressed: () => adminTab.value = 0,
          ),
          titleSpacing: 0,
          title: const Text(
            'Riwayat & Transaksi',
            style: TextStyle(
              color: AdminColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: [
            IconButton(
              onPressed: loadRiwayat,
              icon: const Icon(
                Icons.refresh,
                color: AdminColors.primary,
              ),
            ),
          ],
        ),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AdminColors.primary,
                  ),
                )
              : errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 35,
                              color: AdminColors.danger,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Gagal memuat riwayat transaksi.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                            TextButton(
                              onPressed: loadRiwayat,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AdminColors.primary,
                      onRefresh: loadRiwayat,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDE5FA),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              children: [
                                _seg(
                                  0,
                                  'Riwayat Setor\nSampah',
                                  badge: '${riwayatSetoran.length}',
                                ),
                                _seg(
                                  1,
                                  'Penghasilan\nKelas',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _summaryCard(),
                          const SizedBox(height: 14),
                          _searchField(),
                          const SizedBox(height: 16),
                          if (_tab == 0)
                            _riwayatContent()
                          else
                            _penghasilanContent(),
                          const SizedBox(height: 14),
                          _tarifCard(),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}

// KARTU RIWAYAT TRANSAKSI
class _TxCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic>? verifikasi;
  final String namaVerifikator;

  final String Function(double) formatRupiah;
  final String Function(double) formatBerat;
  final String Function(dynamic) formatTanggal;

  const _TxCard({
    required this.item,
    required this.verifikasi,
    required this.namaVerifikator,
    required this.formatRupiah,
    required this.formatBerat,
    required this.formatTanggal,
  });

  double _angka(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final status = item['status']?.toString().toLowerCase() ?? '';

    final ditolak = status == 'ditolak';

    final idSetoran = item['id_setoran'];

    final detail = item['detail'] as List? ?? [];

    final namaKelas =
        item['nama_kelas']?.toString() ?? 'Kelas tidak diketahui';

    final namaSampah = detail.map((d) {
      return d['nama_sampah']?.toString() ?? 'Sampah';
    }).toSet().join(', ');

    final kategori = detail.map((d) {
      return d['kategori']?.toString() ?? '';
    }).toSet().where((e) => e.isNotEmpty).join(', ');

    final berat = _angka(item['total_berat']);
    final nilai = _angka(item['total_nilai']);

    final catatan = verifikasi?['catatan']?.toString().isNotEmpty == true
        ? verifikasi!['catatan'].toString()
        : item['catatan']?.toString() ?? '';

    final inisial = namaKelas.isNotEmpty
        ? namaKelas.split(' ').first.substring(
              0,
              namaKelas.split(' ').first.length > 2
                  ? 2
                  : namaKelas.split(' ').first.length,
            )
        : 'KS';

    final warnaBg = ditolak
        ? AdminColors.dangerBg
        : AdminColors.primaryLight;

    final warnaFg =
        ditolak ? AdminColors.danger : AdminColors.primary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RincianPenghasilanScreen(),
          ),
        );
      },
      child: AdminCard(
        borderColor: ditolak ? const Color(0xFFF2B8B5) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminInitial(
                  inisial,
                  bg: warnaBg,
                  fg: warnaFg,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaKelas,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (kategori.isNotEmpty)
                        AdminPill(
                          kategori,
                          bg: AdminColors.tealLight,
                          fg: AdminColors.teal,
                          size: 10,
                        ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AdminColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              formatTanggal(item['tanggal']),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                AdminPill(
                  ditolak ? 'Ditolak' : 'Terverifikasi',
                  bg: ditolak
                      ? AdminColors.dangerBg
                      : AdminColors.primaryLight,
                  fg: ditolak
                      ? AdminColors.danger
                      : AdminColors.primary,
                  icon: ditolak
                      ? Icons.cancel
                      : Icons.check_circle,
                  size: 10,
                ),
              ],
            ),

            if (ditolak && catatan.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF2B8B5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: AdminColors.danger,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Alasan Penolakan:',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AdminColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      catatan,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AdminColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 22),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.recycling_outlined,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '$namaSampah • ${formatBerat(berat)} Kg',
                              style: TextStyle(
                                fontSize: 11,
                                decoration: ditolak
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verifikator: $namaVerifikator',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AdminColors.muted,
                        ),
                      ),
                      Text(
                        'ID Setoran: $idSetoran',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AdminColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Nilai Kas',
                      style: TextStyle(fontSize: 9),
                    ),
                    Text(
                      ditolak ? 'Rp 0 (Batal)' : formatRupiah(nilai),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ditolak
                            ? AdminColors.danger
                            : AdminColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// KARTU PENGHASILAN PER KELAS
class _IncomeCard extends StatelessWidget {
  final Map<String, dynamic> item;

  final String Function(double) formatRupiah;
  final String Function(double) formatBerat;

  const _IncomeCard({
    required this.item,
    required this.formatRupiah,
    required this.formatBerat,
  });

  @override
  Widget build(BuildContext context) {
    final namaKelas = item['nama_kelas']?.toString() ?? '-';

    final totalNilai =
        double.tryParse(item['total_nilai'].toString()) ?? 0;

    final totalBerat =
        double.tryParse(item['total_berat'].toString()) ?? 0;

    final jumlahSetoran =
        int.tryParse(item['jumlah_setoran'].toString()) ?? 0;

    final inisial = namaKelas.isNotEmpty
        ? namaKelas.substring(
            0,
            namaKelas.length > 2 ? 2 : namaKelas.length,
          )
        : 'KS';

    return AdminCard(
      child: Row(
        children: [
          AdminInitial(
            inisial,
            bg: AdminColors.primaryLight,
            fg: AdminColors.primary,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaKelas,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$jumlahSetoran setoran • ${formatBerat(totalBerat)} Kg',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AdminColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total Penghasilan',
                style: TextStyle(
                  fontSize: 9,
                  color: AdminColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                formatRupiah(totalNilai),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

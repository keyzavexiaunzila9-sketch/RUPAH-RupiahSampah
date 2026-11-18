
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/admin_navigation.dart';
import '../widgets/admin_widgets.dart';
import 'rincian_penghasilan_screen.dart';
import '../../core/services/verifikasi_service.dart';
import '../../core/services/penarikan_service.dart';

class RiwayatAdminScreen extends StatefulWidget {
  const RiwayatAdminScreen({super.key});

  @override
  State<RiwayatAdminScreen> createState() =>
      _RiwayatAdminScreenState();
}

class _RiwayatAdminScreenState extends State<RiwayatAdminScreen> {
  final VerifikasiService _service = VerifikasiService();
  final TextEditingController _searchController =
      TextEditingController();

  int _tab = 0;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> semuaSetoran = [];
  List<Map<String, dynamic>> semuaVerifikasi = [];
  List<Map<String, dynamic>> semuaUsers = [];
  List<Map<String, dynamic>> semuaPenarikan = [];

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

  // ==========================================
  // KONVERSI WAKTU KE WIB
  // ==========================================

  DateTime? parseTanggalWib(dynamic value) {
    if (value == null) return null;

    try {
      final tanggal = DateTime.parse(value.toString());

      // Timestamp Supabase dikonversi ke UTC,
      // kemudian ditambahkan 7 jam untuk WIB.
      return tanggal.toUtc().add(
        const Duration(hours: 7),
      );
    } catch (e) {
      debugPrint('Gagal membaca tanggal: $e');
      return null;
    }
  }

  // ==========================================
  // MEMUAT DATA RIWAYAT
  // ==========================================

  Future<void> loadRiwayat() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

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
            .select('id_user, username, id_kelas'),
        Supabase.instance.client
            .from('penarikan_kas')
            .select('id_kelas, nominal'),
      ]);

      if (!mounted) return;

      final setoran = List<Map<String, dynamic>>.from(
        hasil[0] as List,
      );

      final verifikasi = List<Map<String, dynamic>>.from(
        hasil[1] as List,
      );

      final users = List<Map<String, dynamic>>.from(
        hasil[2] as List,
      );

      final penarikan = List<Map<String, dynamic>>.from(
        hasil[3] as List,
      );

      // Mencocokkan id_user pada setoran dengan id_kelas pada users.
      for (final item in setoran) {
        final user = users.where(
          (u) =>
              u['id_user']?.toString() ==
              item['id_user']?.toString(),
        );

        if (user.isNotEmpty) {
          item['id_kelas'] = user.first['id_kelas'];
        }
      }

      setState(() {
        semuaSetoran = setoran;
        semuaVerifikasi = verifikasi;
        semuaUsers = users;
        semuaPenarikan = penarikan;
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

  // ==========================================
  // FORMAT RUPIAH
  // ==========================================

  String formatRupiah(double angka) {
    final nilai = angka.round().toString();

    return 'Rp ${nilai.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  // ==========================================
  // FORMAT BERAT
  // ==========================================

  String formatBerat(double angka) {
    return angka.toStringAsFixed(
      angka % 1 == 0 ? 0 : 1,
    );
  }

  // ==========================================
  // KONVERSI ANGKA
  // ==========================================

  double angka(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  // ==========================================
  // FORMAT TANGGAL DAN JAM WIB
  // ==========================================

  String formatTanggal(dynamic value) {
    final tanggalLokal = parseTanggalWib(value);

    if (tanggalLokal == null) return '-';

    final sekarang = DateTime.now().toUtc().add(
      const Duration(hours: 7),
    );

    final jam =
        '${tanggalLokal.hour.toString().padLeft(2, '0')}:'
        '${tanggalLokal.minute.toString().padLeft(2, '0')}';

    final samaHariIni =
        tanggalLokal.year == sekarang.year &&
        tanggalLokal.month == sekarang.month &&
        tanggalLokal.day == sekarang.day;

    final kemarin = sekarang.subtract(
      const Duration(days: 1),
    );

    final samaKemarin =
        tanggalLokal.year == kemarin.year &&
        tanggalLokal.month == kemarin.month &&
        tanggalLokal.day == kemarin.day;

    const namaBulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final tanggalText =
        '${tanggalLokal.day} '
        '${namaBulan[tanggalLokal.month - 1]} '
        '${tanggalLokal.year}';

    if (samaHariIni) {
      return 'Hari ini, $jam WIB';
    }

    if (samaKemarin) {
      return 'Kemarin, $jam WIB';
    }

    return '$tanggalText • $jam WIB';
  }

  // ==========================================
  // MENGAMBIL DATA VERIFIKASI TERBARU
  // ==========================================

  Map<String, dynamic>? getVerifikasi(int idSetoran) {
    // Data verifikasi sudah diurutkan dari terbaru ke terlama.
    // Jadi data pertama yang cocok adalah verifikasi terbaru.
    for (final item in semuaVerifikasi) {
      if (item['id_setoran']?.toString() ==
          idSetoran.toString()) {
        return item;
      }
    }

    return null;
  }

  // ==========================================
  // MENGAMBIL WAKTU RIWAYAT SETORAN
  // ==========================================

  dynamic getTanggalRiwayat(Map<String, dynamic> item) {
    final idSetoran = int.tryParse(
      item['id_setoran']?.toString() ?? '',
    );

    if (idSetoran != null) {
      final verifikasi = getVerifikasi(idSetoran);

      // Utamakan waktu admin melakukan verifikasi.
      if (verifikasi?['tanggal'] != null) {
        return verifikasi!['tanggal'];
      }
    }

    // Jika belum ada tanggal verifikasi, gunakan tanggal setoran.
    return item['tanggal'];
  }

  // ==========================================
  // MENGAMBIL NAMA VERIFIKATOR
  // ==========================================

  String getNamaVerifikator(dynamic idAdmin) {
    if (idAdmin == null) return '-';

    for (final user in semuaUsers) {
      if (user['id_user'].toString() == idAdmin.toString()) {
        return user['username']?.toString() ?? '-';
      }
    }

    return '-';
  }

  // ==========================================
  // RIWAYAT SETORAN
  // ==========================================

  List<Map<String, dynamic>> get riwayatSetoran {
    final hasil = semuaSetoran.where((item) {
      final status = item['status']?.toString().toLowerCase();

      return status == 'disetujui' || status == 'ditolak';
    }).toList();

    // Urutkan berdasarkan waktu verifikasi admin.
    hasil.sort((a, b) {
      final tanggalA = parseTanggalWib(
        getTanggalRiwayat(a),
      );

      final tanggalB = parseTanggalWib(
        getTanggalRiwayat(b),
      );

      if (tanggalA == null && tanggalB == null) return 0;
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

  // ==========================================
  // TOTAL KAS SEKOLAH (PENGHASILAN - PENARIKAN)
  // ==========================================

  double get totalKas {
    double penghasilan = 0;
    double penarikan = 0;

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() ==
          'disetujui') {
        penghasilan += angka(item['total_nilai']);
      }
    }

    for (final item in semuaPenarikan) {
      penarikan += angka(item['nominal']);
    }

    return penghasilan - penarikan;
  }

  // ==========================================
  // TOTAL BERAT
  // ==========================================

  double get totalBerat {
    double total = 0;

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() ==
          'disetujui') {
        total += angka(item['total_berat']);
      }
    }

    return total;
  }

  // ==========================================
  // TOTAL PARTISIPASI KELAS
  // ==========================================

  int get totalPartisipasi {
    final kelas = <String>{};

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() ==
          'disetujui') {
        final nama = item['nama_kelas']?.toString();

        if (nama != null && nama.isNotEmpty) {
          kelas.add(nama);
        }
      }
    }

    return kelas.length;
  }

  // ==========================================
  // PENGHASILAN BULAN INI BERDASARKAN WIB
  // ==========================================

  double get penghasilanBulanIni {
    final sekarang = DateTime.now().toUtc().add(
      const Duration(hours: 7),
    );

    double total = 0;

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() !=
          'disetujui') {
        continue;
      }

      final tanggal = parseTanggalWib(
        getTanggalRiwayat(item),
      );

      if (tanggal == null) continue;

      if (tanggal.year == sekarang.year &&
          tanggal.month == sekarang.month) {
        total += angka(item['total_nilai']);
      }
    }

    return total;
  }

  // ==========================================
  // REKAP PENGHASILAN PER KELAS
  // ==========================================

  List<Map<String, dynamic>> get penghasilanKelas {
    final Map<String, Map<String, dynamic>> rekap = {};

    for (final item in semuaSetoran) {
      if (item['status']?.toString().toLowerCase() !=
          'disetujui') {
        continue;
      }

      final idKelas = item['id_kelas'];

      if (idKelas == null) continue;

      final namaKelas =
          item['nama_kelas']?.toString() ?? 'Kelas tidak diketahui';

      final key = idKelas.toString();

      rekap.putIfAbsent(key, () {
        return {
          'id_kelas': idKelas,
          'nama_kelas': namaKelas,
          'total_nilai': 0.0,
          'total_berat': 0.0,
          'jumlah_setoran': 0,
        };
      });

      rekap[key]!['total_nilai'] += angka(item['total_nilai']);
      rekap[key]!['total_berat'] += angka(item['total_berat']);
      rekap[key]!['jumlah_setoran'] += 1;
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

  // ==========================================
  // TAB
  // ==========================================

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

  // ==========================================
  // RINGKASAN
  // ==========================================

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

  // ==========================================
  // KARTU TOTAL KAS
  // ==========================================

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
            'Sisa Saldo Seluruh Kelas',
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
          const Divider(color: Colors.white24, height: 20),
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

  // ==========================================
  // SEARCH
  // ==========================================

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

  // ==========================================
  // RIWAYAT SETORAN
  // ==========================================

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

  // ==========================================
  // PENGHASILAN KELAS
  // ==========================================

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
            key: ValueKey(item['id_kelas']),
            item: item,
            formatRupiah: formatRupiah,
            formatBerat: formatBerat,
            formatTanggal: formatTanggal,
            onBerhasilTarik: loadRiwayat,
          ),
      ],
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

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

  // ==========================================
  // TARIF RESMI
  // ==========================================

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

  // ==========================================
  // BUILD
  // ==========================================

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
                                _seg(1, 'Penghasilan\nKelas'),
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

// ==========================================
// KARTU RIWAYAT TRANSAKSI
// ==========================================

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

    final catatan =
        verifikasi?['catatan']?.toString().isNotEmpty == true
            ? verifikasi!['catatan'].toString()
            : item['catatan']?.toString() ?? '';

    final inisial = namaKelas.isNotEmpty
        ? namaKelas.substring(
            0,
            namaKelas.length > 2 ? 2 : namaKelas.length,
          )
        : 'KS';

    final warnaBg =
        ditolak ? AdminColors.dangerBg : AdminColors.primaryLight;

    final warnaFg =
        ditolak ? AdminColors.danger : AdminColors.primary;

    // Waktu verifikasi admin lebih diutamakan.
    final tanggalRiwayat =
        verifikasi?['tanggal'] ?? item['tanggal'];

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
                              formatTanggal(tanggalRiwayat),
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

// ==========================================
// KARTU PENGHASILAN KELAS + TARIK TUNAI
// ==========================================

class _IncomeCard extends StatefulWidget {
  final Map<String, dynamic> item;

  final String Function(double) formatRupiah;
  final String Function(double) formatBerat;
  final String Function(dynamic) formatTanggal;

  final Future<void> Function() onBerhasilTarik;

  const _IncomeCard({
    super.key,
    required this.item,
    required this.formatRupiah,
    required this.formatBerat,
    required this.formatTanggal,
    required this.onBerhasilTarik,
  });

  @override
  State<_IncomeCard> createState() => _IncomeCardState();
}

class _IncomeCardState extends State<_IncomeCard> {
  final PenarikanService _penarikanService = PenarikanService();

  bool _sedangMemproses = false;

  late Future<Map<String, dynamic>> _saldoFuture;

  @override
  void initState() {
    super.initState();
    _muatSaldo();
  }

  void _muatSaldo() {
    final idKelas = int.tryParse(
      widget.item['id_kelas'].toString(),
    );

    if (idKelas == null) {
      _saldoFuture = Future.error('ID kelas tidak ditemukan.');
      return;
    }

    _saldoFuture = _penarikanService.getSaldoKelas(idKelas);
  }

  void _refreshSaldo() {
    setState(() {
      _muatSaldo();
    });
  }

  Future<void> _pilihPenarikan(double saldo) async {
    if (saldo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo kelas tidak tersedia untuk ditarik.'),
        ),
      );
      return;
    }

    final idKelas = int.tryParse(
      widget.item['id_kelas'].toString(),
    );

    if (idKelas == null) return;

    final nominalController = TextEditingController();
    int? nominalTerpilih;

    final pilihan = [10000, 20000, 30000, 40000, 50000, 100000];

    final nominal = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final custom = nominalController.text.isNotEmpty;
            final nominalCustom =
                int.tryParse(nominalController.text) ?? 0;

            final nominalAktif =
                custom ? nominalCustom : (nominalTerpilih ?? 0);

            final valid = nominalAktif > 0 &&
                nominalAktif <= saldo &&
                nominalAktif % 1000 == 0;

            return AlertDialog(
              title: const Text(
                'Tarik Tunai',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item['nama_kelas']?.toString() ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Saldo tersedia',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.formatRupiah(saldo),
                      style: const TextStyle(
                        color: AdminColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pilih nominal penarikan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pilihan.map((angka) {
                        final aktif = nominalTerpilih == angka &&
                            !custom;

                        return ChoiceChip(
                          label: Text('Rp ${angka ~/ 1000}rb'),
                          selected: aktif,
                          onSelected: (_) {
                            setDialogState(() {
                              nominalTerpilih = angka;
                              nominalController.clear();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Atau masukkan nominal sendiri',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        setDialogState(() {
                          nominalTerpilih = null;
                        });
                      },
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        hintText: 'Contoh: 75000',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    if (nominalAktif > saldo) ...[
                      const SizedBox(height: 7),
                      const Text(
                        'Nominal melebihi saldo tersedia.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (nominalAktif > 0 &&
                        nominalAktif % 1000 != 0) ...[
                      const SizedBox(height: 7),
                      const Text(
                        'Nominal harus kelipatan Rp1.000.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: valid
                      ? () {
                          Navigator.pop(dialogContext, nominalAktif);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lanjutkan'),
                ),
              ],
            );
          },
        );
      },
    );

    nominalController.dispose();

    if (nominal == null || !mounted) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Penarikan'),
          content: Text(
            'Apakah uang tunai sebesar '
            '${widget.formatRupiah(nominal.toDouble())} '
            'sudah diberikan kepada kelas '
            '${widget.item['nama_kelas']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Belum'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Konfirmasi'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true || !mounted) return;

    await _prosesPenarikan(idKelas, nominal);
  }

  Future<void> _prosesPenarikan(
    int idKelas,
    int nominal,
  ) async {
    setState(() {
      _sedangMemproses = true;
    });

    try {
      await _penarikanService.tarikTunai(
        idKelas: idKelas,
        nominal: nominal,
        keterangan: 'Penarikan tunai kas kelas',
      );

      if (!mounted) return;

      _refreshSaldo();

      await widget.onBerhasilTarik();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Penarikan ${widget.formatRupiah(nominal.toDouble())} berhasil dicatat.',
          ),
          backgroundColor: AdminColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penarikan gagal: $e'),
          backgroundColor: AdminColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sedangMemproses = false;
        });
      }
    }
  }

  Future<void> _lihatRiwayat() async {
    final idKelas = int.tryParse(
      widget.item['id_kelas'].toString(),
    );

    if (idKelas == null) return;

    try {
      final data = await _penarikanService.getRiwayatPenarikan(
        idKelas,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Riwayat Penarikan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: data.isEmpty
                  ? const Text('Belum ada penarikan tunai.')
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: data.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 18),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final nominal =
                            double.tryParse(
                              item['nominal'].toString(),
                            ) ??
                            0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.formatRupiah(nominal),
                              style: const TextStyle(
                                color: AdminColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.formatTanggal(item['tanggal']),
                              style: const TextStyle(
                                color: AdminColors.muted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              item['keterangan']?.toString() ??
                                  'Penarikan tunai',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil riwayat: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaKelas =
        widget.item['nama_kelas']?.toString() ?? '-';

    final totalNilai =
        double.tryParse(
          widget.item['total_nilai'].toString(),
        ) ??
        0;

    final totalBerat =
        double.tryParse(
          widget.item['total_berat'].toString(),
        ) ??
        0;

    final jumlahSetoran =
        int.tryParse(
          widget.item['jumlah_setoran'].toString(),
        ) ??
        0;

    final inisial = namaKelas.isNotEmpty
        ? namaKelas.substring(
            0,
            namaKelas.length > 2 ? 2 : namaKelas.length,
          )
        : 'KS';

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      '$jumlahSetoran setoran • '
                      '${widget.formatBerat(totalBerat)} Kg',
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
                    widget.formatRupiah(totalNilai),
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
          const Divider(height: 24),
          FutureBuilder<Map<String, dynamic>>(
            future: _saldoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo belum dapat dimuat.',
                      style: TextStyle(
                        color: AdminColors.danger,
                        fontSize: 11,
                      ),
                    ),
                    TextButton(
                      onPressed: _refreshSaldo,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                );
              }

              final saldo = double.tryParse(
                    snapshot.data?['saldo_tersedia']
                            ?.toString() ??
                        '0',
                  ) ??
                  0;

              final totalPenarikan = double.tryParse(
                    snapshot.data?['total_penarikan']
                            ?.toString() ??
                        '0',
                  ) ??
                  0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Sudah Ditarik',
                        style: TextStyle(
                          fontSize: 10,
                          color: AdminColors.muted,
                        ),
                      ),
                      Text(
                        widget.formatRupiah(totalPenarikan),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Saldo Tersedia',
                    style: TextStyle(
                      fontSize: 10,
                      color: AdminColors.muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.formatRupiah(saldo),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sedangMemproses || saldo <= 0
                              ? null
                              : () => _pilihPenarikan(saldo),
                          icon: _sedangMemproses
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.payments_outlined,
                                  size: 17,
                                ),
                          label: Text(
                            _sedangMemproses
                                ? 'Memproses...'
                                : 'Tarik Tunai',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AdminColors.border,
                            disabledForegroundColor:
                                AdminColors.muted,
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _lihatRiwayat,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.primary,
                          side: const BorderSide(
                            color: AdminColors.primary,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 11,
                            horizontal: 12,
                          ),
                        ),
                        child: const Icon(
                          Icons.history,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../../core/services/verifikasi_service.dart';
import 'detail_verifikasi_screen.dart';

class VerifikasiSetoranScreen extends StatefulWidget {
  const VerifikasiSetoranScreen({super.key});

  @override
  State<VerifikasiSetoranScreen> createState() =>
      _VerifikasiSetoranScreenState();
}

class _VerifikasiSetoranScreenState
    extends State<VerifikasiSetoranScreen> {
  static const Color green = Color(0xFF087A4F);
  static const Color darkGreen = Color(0xFF006B43);
  static const Color background = Color(0xFFF5F7FC);
  static const Color ink = Color(0xFF26352F);
  static const Color muted = Color(0xFF78857F);
  static const Color border = Color(0xFFE8EDF2);

  static const int _itemsPerPage = 10;

  final VerifikasiService _service = VerifikasiService();
  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> dataSetoran = [];

  bool isLoading = true;
  String? errorMessage;

  int currentPage = 1;

  String selectedDateFilter = 'Semua';
  String selectedSort = 'Terbaru';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // MEMUAT DATA DARI SUPABASE
  // ==========================================

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _service.getDataSetoran();

      if (!mounted) return;

      setState(() {
        dataSetoran = result;
        isLoading = false;
        currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ==========================================
  // KONVERSI ANGKA
  // ==========================================

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  // ==========================================
  // MEMBACA TANGGAL
  // ==========================================

  DateTime? _parseTanggal(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool _isToday(DateTime tanggal) {
    final localDate = tanggal.toLocal();
    final now = DateTime.now();

    return localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day;
  }

  bool _isThisWeek(DateTime tanggal) {
    final now = DateTime.now();
    final awalMinggu = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(days: now.weekday - 1),
    );

    final awalMingguDepan =
        awalMinggu.add(const Duration(days: 7));

    return !tanggal.isBefore(awalMinggu) &&
        tanggal.isBefore(awalMingguDepan);
  }

  bool _isThisMonth(DateTime tanggal) {
    final now = DateTime.now();

    return tanggal.year == now.year &&
        tanggal.month == now.month;
  }

  // ==========================================
  // DATA MENUNGGU + SEARCH + FILTER
  // ==========================================

  List<Map<String, dynamic>> get filteredData {
    final keyword = searchController.text.trim().toLowerCase();

    final hasil = dataSetoran.where((data) {
      final status =
          data['status']?.toString().toLowerCase() ?? '';

      if (status != 'menunggu') return false;

      final namaKelas =
          data['nama_kelas']?.toString().toLowerCase() ?? '';

      final username =
          data['username']?.toString().toLowerCase() ?? '';

      final tingkat =
          data['tingkat']?.toString().toLowerCase() ?? '';

      final jurusan =
          data['jurusan']?.toString().toLowerCase() ?? '';

      final detail = List<Map<String, dynamic>>.from(
        data['detail'] ?? [],
      );

      final namaSampah = detail
          .map(
            (item) =>
                item['nama_sampah']?.toString() ?? '',
          )
          .join(' ')
          .toLowerCase();

      final cocokSearch = keyword.isEmpty ||
          namaKelas.contains(keyword) ||
          username.contains(keyword) ||
          tingkat.contains(keyword) ||
          jurusan.contains(keyword) ||
          namaSampah.contains(keyword);

      if (!cocokSearch) return false;

      final tanggal = _parseTanggal(data['tanggal']);

      if (selectedDateFilter != 'Semua') {
        if (tanggal == null) return false;

        switch (selectedDateFilter) {
          case 'Hari ini':
            if (!_isToday(tanggal)) return false;
            break;

          case 'Minggu ini':
            if (!_isThisWeek(tanggal)) return false;
            break;

          case 'Bulan ini':
            if (!_isThisMonth(tanggal)) return false;
            break;
        }
      }

      return true;
    }).toList();

    // PENGURUTAN DATA
    hasil.sort((a, b) {
      switch (selectedSort) {
        case 'Terlama':
          final tanggalA = _parseTanggal(a['tanggal']);
          final tanggalB = _parseTanggal(b['tanggal']);

          if (tanggalA == null && tanggalB == null) return 0;
          if (tanggalA == null) return 1;
          if (tanggalB == null) return -1;

          return tanggalA.compareTo(tanggalB);

        case 'Berat tertinggi':
          return _toDouble(b['total_berat'])
              .compareTo(_toDouble(a['total_berat']));

        case 'Berat terendah':
          return _toDouble(a['total_berat'])
              .compareTo(_toDouble(b['total_berat']));

        default:
          final tanggalA = _parseTanggal(a['tanggal']);
          final tanggalB = _parseTanggal(b['tanggal']);

          if (tanggalA == null && tanggalB == null) return 0;
          if (tanggalA == null) return 1;
          if (tanggalB == null) return -1;

          return tanggalB.compareTo(tanggalA);
      }
    });

    return hasil;
  }

  // ==========================================
  // PAGINATION
  // ==========================================

  int get totalPages {
    if (filteredData.isEmpty) return 1;

    return (filteredData.length / _itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> get paginatedData {
    final data = filteredData;

    final startIndex = (currentPage - 1) * _itemsPerPage;

    if (startIndex >= data.length) return [];

    final endIndex = (startIndex + _itemsPerPage)
        .clamp(0, data.length);

    return data.sublist(startIndex, endIndex);
  }

  void _ubahHalaman(int halaman) {
    if (halaman < 1 || halaman > totalPages) return;

    setState(() {
      currentPage = halaman;
    });
  }

  void _resetHalaman() {
    setState(() {
      currentPage = 1;
    });
  }

  // ==========================================
  // STATISTIK MENUNGGU
  // ==========================================

  int get jumlahMenunggu {
    return dataSetoran.where((data) {
      return data['status']?.toString().toLowerCase() ==
          'menunggu';
    }).length;
  }

  // ==========================================
  // STATISTIK DISETUJUI HARI INI
  // ==========================================

  int get jumlahDisetujuiHariIni {
    return dataSetoran.where((data) {
      final status =
          data['status']?.toString().toLowerCase() ?? '';

      final tanggal = _parseTanggal(data['tanggal']);

      return status == 'disetujui' &&
          tanggal != null &&
          _isToday(tanggal);
    }).length;
  }

  // ==========================================
  // TOTAL BERAT DISETUJUI HARI INI
  // ==========================================

  double get beratHariIni {
    return dataSetoran.where((data) {
      final status =
          data['status']?.toString().toLowerCase() ?? '';

      final tanggal = _parseTanggal(data['tanggal']);

      return status == 'disetujui' &&
          tanggal != null &&
          _isToday(tanggal);
    }).fold<double>(
      0,
      (total, data) =>
          total + _toDouble(data['total_berat']),
    );
  }

  // ==========================================
  // FORMAT ANGKA
  // ==========================================

  String _formatAngka(num value) {
    final angka = value.toStringAsFixed(0);

    return angka.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  // ==========================================
  // FORMAT TANGGAL
  // ==========================================

  String _formatTanggal(dynamic value) {
    final tanggal = _parseTanggal(value);

    if (tanggal == null) return '-';

    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year;
    final jam = tanggal.hour.toString().padLeft(2, '0');
    final menit = tanggal.minute.toString().padLeft(2, '0');

    return '$hari/$bulan/$tahun • $jam:$menit';
  }

  // ==========================================
  // PESAN
  // ==========================================

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 12),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red : darkGreen,
      ),
    );
  }

  // ==========================================
  // MEMBUKA DETAIL VERIFIKASI
  // ==========================================

  Future<void> _bukaDetailVerifikasi(
    Map<String, dynamic> data,
  ) async {
    final idSetoran = int.tryParse(
      data['id_setoran'].toString(),
    );

    if (idSetoran == null) {
      showMessage(
        'ID setoran tidak valid.',
        error: true,
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailVerifikasiScreen(
          idSetoran: idSetoran,
        ),
      ),
    );

    if (!mounted) return;

    await loadData();
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final dataHalaman = paginatedData;

    final totalData = filteredData.length;

    final nomorAwal = totalData == 0
        ? 0
        : ((currentPage - 1) * _itemsPerPage) + 1;

    final nomorAkhir =
        (currentPage * _itemsPerPage).clamp(0, totalData);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
                color: green,
                onRefresh: loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    12,
                    10,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statistics(),
                      const SizedBox(height: 12),
                      _searchBar(),
                      const SizedBox(height: 9),
                      _filterBar(),
                      const SizedBox(height: 13),

                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(35),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: green,
                            ),
                          ),
                        )
                      else if (errorMessage != null)
                        _errorView()
                      else if (totalData == 0)
                        _emptyView()
                      else ...[
                        _resultHeader(
                          nomorAwal,
                          nomorAkhir,
                          totalData,
                        ),
                        const SizedBox(height: 9),

                        // MAKSIMAL 10 KARTU
                        ...dataHalaman.map(
                          (data) => _verificationCard(data),
                        ),

                        const SizedBox(height: 5),

                        // NAVIGASI HALAMAN
                        _pagination(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: border),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/logo_rupah.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.recycling_rounded,
                color: green,
                size: 30,
              );
            },
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Verifikasi Setoran',
                  style: TextStyle(
                    fontSize: 14,
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'SMKN 8 MALANG • Petugas Admin',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : loadData,
            tooltip: 'Muat ulang',
            icon: const Icon(
              Icons.refresh_rounded,
              size: 21,
              color: green,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STATISTIK
  // ==========================================

  Widget _statistics() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFE99A22),
            title: 'Menunggu',
            value: isLoading ? '-' : '$jumlahMenunggu',
            subtitle: 'Antrean',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _statCard(
            icon: Icons.verified_rounded,
            iconColor: const Color(0xFF159B69),
            title: 'Hari ini',
            value: isLoading
                ? '-'
                : '$jumlahDisetujuiHariIni',
            subtitle: 'Disetujui',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _statCard(
            icon: Icons.scale_rounded,
            iconColor: const Color(0xFF159BA6),
            title: 'Kg',
            value: isLoading
                ? '-'
                : beratHariIni.toStringAsFixed(1),
            subtitle: 'Bobot Masuk',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SEARCH BAR
  // ==========================================

  Widget _searchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => _resetHalaman(),
              style: const TextStyle(
                fontSize: 12,
                color: ink,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari nama akun, kelas, atau sampah...',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: muted,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();
                _resetHalaman();
              },
              icon: const Icon(
                Icons.close_rounded,
                size: 17,
                color: muted,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // FILTER TANGGAL DAN SORTING
  // ==========================================

  Widget _filterBar() {
    return Row(
      children: [
        Expanded(
          child: _dropdownFilter(
            label: 'Tanggal',
            value: selectedDateFilter,
            items: const [
              'Semua',
              'Hari ini',
              'Minggu ini',
              'Bulan ini',
            ],
            icon: Icons.calendar_month_outlined,
            onChanged: (value) {
              setState(() {
                selectedDateFilter = value;
                currentPage = 1;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _dropdownFilter(
            label: 'Urutkan',
            value: selectedSort,
            items: const [
              'Terbaru',
              'Terlama',
              'Berat tertinggi',
              'Berat terendah',
            ],
            icon: Icons.sort_rounded,
            onChanged: (value) {
              setState(() {
                selectedSort = value;
                currentPage = 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _dropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: green,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: muted,
                ),
                style: const TextStyle(
                  fontSize: 10,
                  color: ink,
                  fontWeight: FontWeight.w600,
                ),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HEADER JUMLAH HASIL
  // ==========================================

  Widget _resultHeader(
    int awal,
    int akhir,
    int total,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.list_alt_rounded,
          size: 17,
          color: green,
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'Daftar Menunggu Verifikasi',
            style: TextStyle(
              fontSize: 12,
              color: ink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '$awal-$akhir dari $total data',
          style: const TextStyle(
            fontSize: 10,
            color: muted,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PAGINATION
  // ==========================================

  Widget _pagination() {
    final pages = totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Halaman $currentPage dari $pages',
              style: const TextStyle(
                fontSize: 10,
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _pageButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 1,
            onTap: () => _ubahHalaman(currentPage - 1),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$currentPage',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _pageButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < pages,
            onTap: () => _ubahHalaman(currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFE7F3ED)
              : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? const Color(0xFFC8E3D3)
                : border,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? green : const Color(0xFFB8C0BC),
        ),
      ),
    );
  }

  // ==========================================
  // ERROR
  // ==========================================

  Widget _errorView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 35,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 9),
          const Text(
            'Gagal Memuat Data',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            errorMessage ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: muted,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: loadData,
            icon: const Icon(Icons.refresh, size: 15),
            label: const Text(
              'Coba Lagi',
              style: TextStyle(fontSize: 11),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DATA KOSONG
  // ==========================================

  Widget _emptyView() {
    final sedangMencari =
        searchController.text.trim().isNotEmpty ||
        selectedDateFilter != 'Semua';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Color(0xFFB6C4BC),
          ),
          const SizedBox(height: 10),
          Text(
            sedangMencari
                ? 'Data Tidak Ditemukan'
                : 'Belum Ada Setoran Menunggu',
            style: const TextStyle(
              fontSize: 13,
              color: ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            sedangMencari
                ? 'Coba ubah kata pencarian atau filter.'
                : 'Setoran dari akun kelas akan muncul di sini '
                    'setelah berhasil dikirim.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
          if (sedangMencari) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                searchController.clear();

                setState(() {
                  selectedDateFilter = 'Semua';
                  selectedSort = 'Terbaru';
                  currentPage = 1;
                });
              },
              icon: const Icon(Icons.restart_alt, size: 16),
              label: const Text('Reset pencarian dan filter'),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // KARTU VERIFIKASI
  // ==========================================

  Widget _verificationCard(Map<String, dynamic> data) {
    final detail = List<Map<String, dynamic>>.from(
      data['detail'] ?? [],
    );

    final namaKelas =
        data['nama_kelas']?.toString() ?? '-';

    final totalBerat = _toDouble(data['total_berat']);
    final totalNilai = _toDouble(data['total_nilai']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4E9DD),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2D0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFFD58B16),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Menunggu Verifikasi',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFB77913),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _formatTanggal(data['tanggal']),
                style: const TextStyle(
                  fontSize: 10,
                  color: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // IDENTITAS KELAS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FD),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: darkGreen,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaKelas,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${data['tingkat'] ?? ''} '
                        '${data['jurusan'] ?? ''}'.trim(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // DETAIL SAMPAH
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Sampah',
                  style: TextStyle(
                    fontSize: 10,
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                if (detail.isEmpty)
                  const Text(
                    'Belum ada detail sampah.',
                    style: TextStyle(
                      fontSize: 11,
                      color: muted,
                    ),
                  )
                else
                  ...detail.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.recycling_rounded,
                            size: 13,
                            color: green,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item['nama_sampah']?.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 11,
                                color: ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${_toDouble(item['berat_kg']).toStringAsFixed(1)} Kg',
                            style: const TextStyle(
                              fontSize: 11,
                              color: green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const Divider(height: 12),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Berat',
                        style: TextStyle(
                          fontSize: 10,
                          color: muted,
                        ),
                      ),
                    ),
                    Text(
                      '${totalBerat.toStringAsFixed(1)} Kg',
                      style: const TextStyle(
                        fontSize: 11,
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Estimasi Nilai',
                        style: TextStyle(
                          fontSize: 10,
                          color: muted,
                        ),
                      ),
                    ),
                    Text(
                      'Rp ${_formatAngka(totalNilai)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          // TOMBOL DETAIL VERIFIKASI
          SizedBox(
            width: double.infinity,
            height: 37,
            child: ElevatedButton.icon(
              onPressed: () => _bukaDetailVerifikasi(data),
              icon: const Icon(
                Icons.verified_user_outlined,
                size: 14,
              ),
              label: const Text(
                'Verifikasi Sekarang',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

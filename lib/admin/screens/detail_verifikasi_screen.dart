
import 'package:flutter/material.dart';

import '../../core/services/verifikasi_service.dart';
import 'tolak_setoran_screen.dart';

class DetailVerifikasiScreen extends StatefulWidget {
  final int idSetoran;

  const DetailVerifikasiScreen({
    super.key,
    required this.idSetoran,
  });

  @override
  State<DetailVerifikasiScreen> createState() =>
      _DetailVerifikasiScreenState();
}

class _DetailVerifikasiScreenState
    extends State<DetailVerifikasiScreen> {
  static const Color green = Color(0xFF087A4F);
  static const Color darkGreen = Color(0xFF006B43);
  static const Color background = Color(0xFFF5F7FC);
  static const Color ink = Color(0xFF26352F);
  static const Color muted = Color(0xFF78857F);
  static const Color border = Color(0xFFE8EDF2);
  static const Color orange = Color(0xFFE59A26);
  static const Color red = Color(0xFFD93636);

  final VerifikasiService _service = VerifikasiService();
  final TextEditingController catatanController =
      TextEditingController();

  Map<String, dynamic>? dataSetoran;

  bool isLoading = true;
  bool isProcessing = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }

  // MEMUAT DETAIL SETORAN DARI SUPABASE
  Future<void> loadDetail() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final semuaData = await _service.getDataSetoran();

      final hasil = semuaData.where((item) {
        return item['id_setoran'].toString() ==
            widget.idSetoran.toString();
      }).toList();

      if (hasil.isEmpty) {
        throw Exception('Data setoran tidak ditemukan.');
      }

      if (!mounted) return;

      setState(() {
        dataSetoran = hasil.first;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatAngka(num value) {
    final angka = value.toStringAsFixed(0);

    return angka.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  String _formatTanggal(dynamic value) {
    if (value == null) return '-';

    final tanggal = DateTime.tryParse(value.toString());

    if (tanggal == null) return '-';

    final local = tanggal.toLocal();

    final hari = local.day.toString().padLeft(2, '0');
    final bulan = local.month.toString().padLeft(2, '0');
    final tahun = local.year;
    final jam = local.hour.toString().padLeft(2, '0');
    final menit = local.minute.toString().padLeft(2, '0');

    return '$hari/$bulan/$tahun • $jam:$menit';
  }

  List<Map<String, dynamic>> get detailSampah {
    if (dataSetoran == null) return [];

    return List<Map<String, dynamic>>.from(
      dataSetoran!['detail'] ?? [],
    );
  }

  String get namaSampah {
    if (detailSampah.isEmpty) return '-';

    return detailSampah
        .map((item) => item['nama_sampah']?.toString() ?? '-')
        .join(', ');
  }

  // PESAN
  void showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 12),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? red : darkGreen,
      ),
    );
  }

  // KONFIRMASI PERSETUJUAN
  Future<bool> _konfirmasiSetuju() async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Setujui Setoran?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menyetujui setoran ini?',
            style: TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: muted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Ya, Setujui',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );

    return hasil == true;
  }

  // MENYETUJUI SETORAN
  Future<void> setujuiSetoran() async {
    if (dataSetoran == null || isProcessing) return;

    final status =
        dataSetoran!['status']?.toString().toLowerCase();

    if (status != 'menunggu') {
      showMessage(
        'Setoran ini sudah tidak menunggu verifikasi.',
        error: true,
      );
      await loadDetail();
      return;
    }

    final yakin = await _konfirmasiSetuju();

    if (!yakin || !mounted) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final catatan = catatanController.text.trim();

      await _service.verifikasiSetoran(
        idSetoran: widget.idSetoran,
        status: 'disetujui',
        catatan: catatan.isEmpty ? null : catatan,
      );

      if (!mounted) return;

      showMessage('Setoran berhasil disetujui.');

      // KEMBALI KE DAFTAR DAN MEMICU REFRESH
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      showMessage(
        'Gagal menyetujui setoran: $e',
        error: true,
      );
    }
  }

  // MEMBUKA HALAMAN PENOLAKAN
  Future<void> tolakSetoran() async {
    if (dataSetoran == null || isProcessing) return;

    final status =
        dataSetoran!['status']?.toString().toLowerCase();

    if (status != 'menunggu') {
      showMessage(
        'Setoran ini sudah tidak menunggu verifikasi.',
        error: true,
      );
      await loadDetail();
      return;
    }

    final data = dataSetoran!;

    setState(() {
      isProcessing = true;
    });

    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TolakSetoranScreen(
          idSetoran: widget.idSetoran,
          nama: data['username']?.toString() ?? '-',
          kelas: data['nama_kelas']?.toString() ?? '-',
          jenisSampah: namaSampah,
          berat:
              '${_toDouble(data['total_berat']).toStringAsFixed(1)} Kg',
          nilaiKas:
              'Rp ${_formatAngka(_toDouble(data['total_nilai']))}',
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      isProcessing = false;
    });

    if (hasil == true) {
      // FORM PENOLAKAN BERHASIL MENYIMPAN DATA
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: green,
            size: 20,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Verifikasi',
              style: TextStyle(
                color: green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PEMERIKSAAN DATA SETORAN',
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            )
          : errorMessage != null
              ? _errorView()
              : dataSetoran == null
                  ? _emptyView()
                  : _content(),
    );
  }

  // KONTEN DETAIL
  Widget _content() {
    final data = dataSetoran!;

    final totalBerat = _toDouble(data['total_berat']);
    final totalNilai = _toDouble(data['total_nilai']);

    final status =
        data['status']?.toString().toLowerCase() ?? '-';

    final fotoUrl = data['foto_url']?.toString();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusCard(status),
                const SizedBox(height: 12),
                _identitasCard(data),
                const SizedBox(height: 12),
                _detailSampahCard(),
                const SizedBox(height: 12),
                _ringkasanCard(totalBerat, totalNilai),
                const SizedBox(height: 12),
                _fotoSetoranCard(fotoUrl),
                const SizedBox(height: 12),
                _catatanCard(),
              ],
            ),
          ),
        ),

        // TOMBOL KEPUTUSAN
        if (status == 'menunggu')
          _bottomButtons()
        else
          _statusSelesai(status),
      ],
    );
  }

  // STATUS SETORAN
  Widget _statusCard(String status) {
    final bool menunggu = status == 'menunggu';

    final Color warna =
        menunggu ? orange : green;

    final String label =
        menunggu ? 'Menunggu Verifikasi' : status.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: menunggu
            ? const Color(0xFFFFF8E7)
            : const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: menunggu
              ? const Color(0xFFFFE2A0)
              : const Color(0xFFCDE7D8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            menunggu
                ? Icons.access_time_rounded
                : Icons.verified_rounded,
            color: warna,
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: warna,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  menunggu
                      ? 'Setoran perlu diperiksa oleh admin.'
                      : 'Status setoran sudah diperbarui.',
                  style: TextStyle(
                    fontSize: 11,
                    color: warna,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // IDENTITAS PENYETOR
  Widget _identitasCard(Map<String, dynamic> data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.person_outline_rounded,
            'Identitas Penyetor',
          ),
          const SizedBox(height: 12),
          Text(
            data['username']?.toString() ?? '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.confirmation_number_outlined,
            'ID Setoran',
            '#${widget.idSetoran}',
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.school_outlined,
            'Kelas',
            data['nama_kelas']?.toString() ?? '-',
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.calendar_month_outlined,
            'Tanggal Setoran',
            _formatTanggal(data['tanggal']),
          ),
        ],
      ),
    );
  }

  // DETAIL SAMPAH
  Widget _detailSampahCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.recycling_rounded,
            'Detail Sampah',
          ),
          const SizedBox(height: 12),

          if (detailSampah.isEmpty)
            const Text(
              'Belum ada detail sampah.',
              style: TextStyle(
                fontSize: 12,
                color: muted,
              ),
            )
          else
            ...detailSampah.map((item) {
              final berat = _toDouble(item['berat_kg']);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F3EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.recycling_rounded,
                        color: green,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama_sampah']?.toString() ?? '-',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['kategori']?.toString() ?? '-',
                            style: const TextStyle(
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${berat.toStringAsFixed(1)} Kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // RINGKASAN SETORAN
  Widget _ringkasanCard(
    double totalBerat,
    double totalNilai,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.receipt_long_rounded,
            'Ringkasan Setoran',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Total Berat',
                  '${totalBerat.toStringAsFixed(1)} Kg',
                  Icons.scale_outlined,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _summaryItem(
                  'Estimasi Nilai',
                  'Rp ${_formatAngka(totalNilai)}',
                  Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green, size: 19),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // FOTO SETORAN DARI SUPABASE STORAGE
  Widget _fotoSetoranCard(String? fotoUrl) {
    final url = fotoUrl?.trim() ?? '';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.photo_outlined,
            'Foto Bukti Setoran',
          ),
          const SizedBox(height: 10),
          if (url.isEmpty)
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 30,
                    color: muted,
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Foto setoran tidak tersedia.',
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return const SizedBox(
                    height: 140,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: green,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 140,
                    color: const Color(0xFFF7FAFC),
                    child: const Center(
                      child: Text(
                        'Foto gagal dimuat.',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // CATATAN ADMIN
  Widget _catatanCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.edit_note_rounded,
            'Catatan Pemeriksaan Admin',
          ),
          const SizedBox(height: 8),
          const Text(
            'Catatan ini akan disimpan bersama hasil verifikasi.',
            style: TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: catatanController,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 12,
              color: ink,
            ),
            decoration: InputDecoration(
              hintText: 'Tulis hasil pemeriksaan...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFC),
              contentPadding: const EdgeInsets.all(11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TOMBOL KEPUTUSAN
  Widget _bottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isProcessing ? null : tolakSetoran,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Tolak Setoran',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed:
                    isProcessing ? null : setujuiSetoran,
                icon: isProcessing
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.verified_rounded,
                        size: 16,
                      ),
                label: Text(
                  isProcessing ? 'Memproses...' : 'Setujui',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STATUS SETELAH VERIFIKASI
  Widget _statusSelesai(String status) {
    final disetujui = status == 'disetujui';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: Colors.white,
      child: Text(
        disetujui
            ? 'Setoran ini sudah disetujui.'
            : 'Setoran ini sudah ditolak.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: disetujui ? green : red,
        ),
      ),
    );
  }

  // KOMPONEN CARD
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(icon, size: 17, color: green),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: green,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }

  // ERROR
  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: red,
            ),
            const SizedBox(height: 10),
            const Text(
              'Gagal Memuat Detail Setoran',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: muted,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: loadDetail,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Text(
        'Data setoran tidak ditemukan.',
        style: TextStyle(
          fontSize: 12,
          color: muted,
        ),
      ),
    );
  }
}

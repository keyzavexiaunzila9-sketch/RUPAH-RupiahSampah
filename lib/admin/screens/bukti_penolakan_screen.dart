
import 'package:flutter/material.dart';

import '../../core/services/verifikasi_service.dart';

class BuktiPenolakanScreen extends StatefulWidget {
  final int idSetoran;

  const BuktiPenolakanScreen({
    super.key,
    required this.idSetoran,
  });

  @override
  State<BuktiPenolakanScreen> createState() =>
      _BuktiPenolakanScreenState();
}

class _BuktiPenolakanScreenState
    extends State<BuktiPenolakanScreen> {
  final VerifikasiService _service = VerifikasiService();

  static const Color red = Color(0xFFC51D25);
  static const Color green = Color(0xFF087A4F);
  static const Color background = Color(0xFFF5F7FA);
  static const Color ink = Color(0xFF263238);
  static const Color muted = Color(0xFF78857F);
  static const Color border = Color(0xFFE8EDF2);

  bool sedangMemuat = true;
  String? pesanError;

  Map<String, dynamic> data = {};

  List<Map<String, dynamic>> detailSetoran = [];
  List<String> tindakLanjut = [];

  @override
  void initState() {
    super.initState();
    ambilDataPenolakan();
  }

  // ==========================================
  // MENGAMBIL DATA DARI SUPABASE
  // ==========================================
  Future<void> ambilDataPenolakan() async {
    if (mounted) {
      setState(() {
        sedangMemuat = true;
        pesanError = null;
      });
    }

    try {
      final response =
          await _service.getBuktiPenolakan(widget.idSetoran);

      final detail = response['detail'];

      final List<Map<String, dynamic>> detailList =
          detail is List
              ? detail
                  .map(
                    (item) =>
                        Map<String, dynamic>.from(item as Map),
                  )
                  .toList()
              : [];

      final tindakanData = response['tindak_lanjut'];

      final List<String> tindakan =
          tindakanData is List
              ? tindakanData
                  .map((item) => item.toString())
                  .toList()
              : [];

      if (!mounted) return;

      setState(() {
        data = response;
        detailSetoran = detailList;
        tindakLanjut = tindakan;
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

  // ==========================================
  // FORMAT TANGGAL
  // ==========================================
  String formatTanggal(dynamic tanggal) {
    if (tanggal == null) return '-';

    try {
      final date =
          DateTime.parse(tanggal.toString()).toLocal();

      const bulan = [
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

      final jam = date.hour.toString().padLeft(2, '0');
      final menit = date.minute.toString().padLeft(2, '0');

      return '${date.day} ${bulan[date.month - 1]} '
          '${date.year}, $jam:$menit WIB';
    } catch (_) {
      return tanggal.toString();
    }
  }

  // ==========================================
  // FORMAT RUPIAH
  // ==========================================
  String formatRupiah(dynamic nilai) {
    final angka =
        num.tryParse(nilai?.toString() ?? '') ?? 0;

    final hasil = angka.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (int i = 0; i < hasil.length; i++) {
      buffer.write(hasil[i]);

      final sisa = hasil.length - i - 1;

      if (sisa > 0 && sisa % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  // ==========================================
  // FORMAT BERAT
  // ==========================================
  String formatBerat(dynamic berat) {
    final angka =
        num.tryParse(berat?.toString() ?? '') ?? 0;

    return '${angka.toString()} Kg';
  }

  // ==========================================
  // GETTER DATA
  // ==========================================
  String get namaPenyetor =>
      data['username']?.toString() ?? '-';

  String get namaKelas =>
      data['nama_kelas']?.toString() ?? '-';

  String get kategoriPenolakan =>
      data['kategori_penolakan']?.toString() ?? '-';

  String get alasanPenolakan =>
      data['catatan_penolakan']?.toString() ?? '-';

  String get namaAdmin =>
      data['nama_admin']?.toString() ?? '-';

  String get daftarSampah {
    if (detailSetoran.isEmpty) return '-';

    return detailSetoran
        .map(
          (item) => item['nama_sampah']?.toString() ?? '-',
        )
        .toSet()
        .join(', ');
  }

  String get daftarKategoriSampah {
    if (detailSetoran.isEmpty) return '-';

    return detailSetoran
        .map(
          (item) => item['kategori']?.toString() ?? '-',
        )
        .toSet()
        .join(', ');
  }

  num get totalBerat {
    return num.tryParse(
          data['total_berat']?.toString() ?? '',
        ) ??
        0;
  }

  num get totalNilai {
    return num.tryParse(
          data['total_nilai']?.toString() ?? '',
        ) ??
        0;
  }

  // ==========================================
  // TAMPILAN UTAMA
  // ==========================================
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
            color: ink,
            size: 21,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bukti Penolakan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            Text(
              '#${widget.idSetoran}',
              style: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: border,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // ==========================================
  // BODY
  // ==========================================
  Widget _buildBody() {
    if (sedangMemuat) {
      return const Center(
        child: CircularProgressIndicator(
          color: green,
        ),
      );
    }

    if (pesanError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: red,
                size: 40,
              ),
              const SizedBox(height: 10),
              const Text(
                'Gagal Memuat Bukti Penolakan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                pesanError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: ambilDataPenolakan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: green,
      onRefresh: ambilDataPenolakan,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          14,
          12,
          14,
          20,
        ),
        child: Column(
          children: [
            _statusCard(),
            const SizedBox(height: 12),
            _summaryCard(),
            const SizedBox(height: 12),
            _detailSampahCard(),
            const SizedBox(height: 12),
            _followUpCard(),
            const SizedBox(height: 12),
            _adminCard(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // KARTU STATUS PENOLAKAN
  // ==========================================
  Widget _statusCard() {
    return _card(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDADA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: red,
              size: 27,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Setoran Ditolak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: red,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$namaPenyetor • '
            '${formatTanggal(data['tanggal_verifikasi'])}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
          const SizedBox(height: 12),
          _infoBox(
            title: 'Kategori Penolakan',
            content: kategoriPenolakan,
          ),
          const SizedBox(height: 8),
          _infoBox(
            title: 'Alasan Penolakan',
            content: alasanPenolakan,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RINGKASAN SETORAN
  // ==========================================
  Widget _summaryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RINGKASAN SETORAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: muted,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow(
            'ID Setoran',
            '#${widget.idSetoran}',
          ),
          _detailRow(
            'Penyetor',
            namaPenyetor,
          ),
          _detailRow(
            'Kelas',
            namaKelas,
          ),
          _detailRow(
            'Tanggal Setoran',
            formatTanggal(data['tanggal']),
          ),
          _detailRow(
            'Berat Setoran',
            formatBerat(totalBerat),
          ),
          _detailRow(
            'Nilai Setoran',
            formatRupiah(totalNilai),
            valueColor: muted,
            lineThrough: true,
          ),
          _detailRow(
            'Kas Diterima',
            'Rp 0',
            valueColor: red,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DETAIL JENIS SAMPAH
  // ==========================================
  Widget _detailSampahCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETAIL JENIS SAMPAH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: muted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            daftarSampah,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Kategori: $daftarKategoriSampah',
            style: const TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            height: 1,
            color: border,
          ),
          const SizedBox(height: 10),
          if (detailSetoran.isEmpty)
            const Text(
              'Tidak ada detail sampah yang ditemukan.',
              style: TextStyle(
                fontSize: 12,
                color: muted,
              ),
            )
          else
            ...detailSetoran.map(
              (item) => _detailRow(
                item['nama_sampah']?.toString() ?? '-',
                formatBerat(item['berat_kg']),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TINDAK LANJUT
  // ==========================================
  Widget _followUpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFF6),
        border: Border.all(
          color: const Color(0xFFB8EBD0),
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: green,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Tindak Lanjut',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (tindakLanjut.isEmpty)
            const Text(
              'Tidak ada tindak lanjut yang dipilih.',
              style: TextStyle(
                fontSize: 12,
                color: muted,
              ),
            )
          else
            ...tindakLanjut.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 15,
                      color: green,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF47715D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // ADMIN PEMERIKSA
  // ==========================================
  Widget _adminCard() {
    return _card(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFD2E9DF),
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: green,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Petugas Pemeriksa',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  namaAdmin,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: green,
            size: 19,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // KOTAK INFORMASI
  // ==========================================
  Widget _infoBox({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        border: Border.all(
          color: const Color(0xFFFFD0D0),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD UMUM
  // ==========================================
  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==========================================
  // BARIS DETAIL
  // ==========================================
  Widget _detailRow(
    String title,
    String value, {
    Color valueColor = ink,
    bool lineThrough = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor,
                decoration: lineThrough
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

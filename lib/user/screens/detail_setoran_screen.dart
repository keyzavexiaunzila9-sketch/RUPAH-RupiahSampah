
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';

class DetailSetoranScreen extends StatefulWidget {
  final int idSetoran;

  const DetailSetoranScreen({
    super.key,
    required this.idSetoran,
  });

  @override
  State<DetailSetoranScreen> createState() =>
      _DetailSetoranScreenState();
}

class _DetailSetoranScreenState extends State<DetailSetoranScreen> {
  final supabase = Supabase.instance.client;

  bool sedangMemuat = true;
  String? pesanError;

  Map<String, dynamic>? dataSetoran;
  List<Map<String, dynamic>> daftarDetail = [];

  String namaKelas = 'Kelas belum terdaftar';
  String? fotoUrl;

  static const bg = Color(0xFFF6F8FD);
  static const green = Color(0xFF16805D);
  static const darkGreen = Color(0xFF116B4E);
  static const ink = Color(0xFF253342);
  static const muted = Color(0xFF7A8794);
  static const border = Color(0xFFE8EDF4);

  @override
  void initState() {
    super.initState();
    muatDetailSetoran();
  }

  // ==========================================
  // MEMUAT DATA SETORAN
  // ==========================================

  Future<void> muatDetailSetoran() async {
    if (!mounted) return;

    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });

    try {
      // 1. Mengambil data utama setoran.
      final responseSetoran = await supabase
          .from('setoran')
          .select(
            'id_setoran, id_user, tanggal, status, '
            'total_berat, total_nilai, catatan, foto_url',
          )
          .eq('id_setoran', widget.idSetoran)
          .single();

      final setoran =
          Map<String, dynamic>.from(responseSetoran);

      // 2. Mengambil detail setoran.
      final responseDetail = await supabase
          .from('detail_setoran')
          .select('id_detail, id_setoran, id_sampah, berat_kg')
          .eq('id_setoran', widget.idSetoran);

      final hasilDetail =
          List<Map<String, dynamic>>.from(responseDetail);

      // 3. Mengambil informasi masing-masing sampah.
      for (final item in hasilDetail) {
        final responseSampah = await supabase
            .from('sampah')
            .select(
              'nama_sampah, kategori, harga_per_kg, satuan',
            )
            .eq('id_sampah', item['id_sampah'])
            .maybeSingle();

        item['sampah'] = responseSampah == null
            ? null
            : Map<String, dynamic>.from(responseSampah);
      }

      // 4. Mengambil informasi kelas penyetor.
      final responseUser = await supabase
          .from('users')
          .select('id_kelas')
          .eq('id_user', setoran['id_user'])
          .maybeSingle();

      String kelas = 'Kelas belum terdaftar';

      if (responseUser != null &&
          responseUser['id_kelas'] != null) {
        final responseKelas = await supabase
            .from('kelas')
            .select('nama_kelas')
            .eq('id_kelas', responseUser['id_kelas'])
            .maybeSingle();

        kelas = responseKelas?['nama_kelas'] ?? kelas;
      }

      // 5. Mengambil signed URL foto.
      String? signedFoto;

      final pathFoto = setoran['foto_url']?.toString();

      if (pathFoto != null && pathFoto.isNotEmpty) {
        try {
          signedFoto = await supabase.storage
              .from('bukti-setoran')
              .createSignedUrl(pathFoto, 3600);
        } catch (_) {
          // Foto gagal dimuat, tetapi detail transaksi tetap ditampilkan.
          signedFoto = null;
        }
      }

      if (!mounted) return;

      setState(() {
        dataSetoran = setoran;
        daftarDetail = hasilDetail;
        namaKelas = kelas;
        fotoUrl = signedFoto;
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
  // FORMAT DATA
  // ==========================================

  String rupiah(dynamic value) {
    final angka = value is num ? value.round() : 0;

    return angka.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  String formatTanggal(dynamic value) {
    if (value == null) return '-';

    try {
      final tanggal =
          DateTime.parse(value.toString()).toLocal();

      const bulan = [
        'Jan', 'Feb', 'Mar', 'Apr',
        'Mei', 'Jun', 'Jul', 'Agu',
        'Sep', 'Okt', 'Nov', 'Des',
      ];

      return '${tanggal.day} '
          '${bulan[tanggal.month - 1]} '
          '${tanggal.year}, '
          '${tanggal.hour.toString().padLeft(2, '0')}:'
          '${tanggal.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return '-';
    }
  }

  // ==========================================
  // STATUS DARI DATABASE
  // ==========================================

  String get statusDatabase {
    return dataSetoran?['status']
            ?.toString()
            .toLowerCase() ??
        'menunggu';
  }

  bool get diterima {
    return statusDatabase == 'disetujui' ||
        statusDatabase == 'diterima';
  }

  bool get ditolak => statusDatabase == 'ditolak';

  String get labelStatus {
    if (diterima) return 'Disetujui & Tervalidasi';
    if (ditolak) return 'Setoran Ditolak';
    return 'Menunggu Verifikasi';
  }

  String get deskripsiStatus {
    if (diterima) {
      return 'Setoran telah disetujui oleh admin.';
    }

    if (ditolak) {
      return 'Setoran tidak disetujui oleh admin.';
    }

    return 'Setoran sedang diperiksa oleh admin.';
  }

  Color get warnaStatus {
    if (diterima) return darkGreen;
    if (ditolak) return const Color(0xFFC84444);
    return const Color(0xFFB98220);
  }

  Color get backgroundStatus {
    if (diterima) return const Color(0xFFD5F6E4);
    if (ditolak) return const Color(0xFFFFE7E7);
    return const Color(0xFFFFF1D6);
  }

  // ==========================================
  // TAMPILAN UTAMA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    if (sedangMemuat) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(
            color: green,
          ),
        ),
      );
    }

    if (pesanError != null || dataSetoran == null) {
      return _tampilanError();
    }

    final tanggal = dataSetoran!['tanggal'];

    final totalBerat =
        (dataSetoran!['total_berat'] as num?)?.toDouble() ?? 0;

    final totalNilai =
        (dataSetoran!['total_nilai'] as num?)?.toDouble() ?? 0;

    final catatan =
        dataSetoran!['catatan']?.toString() ?? '';

    final nomor = '#RPH-${widget.idSetoran}';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: ink,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'BUKTI TRANSAKSI',
                        style: TextStyle(
                          color: green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Detail Setoran',
                        style: RupahTheme.heading(
                          size: 14,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: border),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // STATUS SETORAN
                  _card(
                    color: backgroundStatus,
                    child: Row(
                      children: [
                        Icon(
                          diterima
                              ? Icons.verified_rounded
                              : ditolak
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_top_rounded,
                          color: warnaStatus,
                          size: 29,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                labelStatus,
                                style: TextStyle(
                                  color: warnaStatus,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                deskripsiStatus,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _chip(
                          diterima
                              ? 'Selesai'
                              : ditolak
                                  ? 'Ditolak'
                                  : 'Proses',
                          warnaStatus,
                          Colors.white,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // REWARD
                  _card(
                    color: green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '♻  Kompensasi Sampah Terpilah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          diterima
                              ? 'Total Reward Diterima'
                              : ditolak
                                  ? 'Reward Tidak Diterima'
                                  : 'Estimasi Reward',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rp ${rupiah(ditolak ? 0 : totalNilai)}',
                          style: RupahTheme.heading(
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const Divider(color: Colors.white38),
                        Text(
                          'Total berat: ${totalBerat.toStringAsFixed(1)} Kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kas Kelas $namaKelas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // INFORMASI TRANSAKSI
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Penimbangan',
                          style: RupahTheme.heading(
                            size: 14,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _info('ID Transaksi / Ref', nomor),
                        _info('Waktu Setor', formatTanggal(tanggal)),
                        _info('Kelas Penyetor', namaKelas),

                        const Divider(height: 18),

                        if (daftarDetail.isEmpty)
                          const Text(
                            'Belum ada detail sampah untuk setoran ini.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),

                        ...daftarDetail.map((item) {
                          final sampah =
                              item['sampah'] as Map<String, dynamic>?;

                          final nama =
                              sampah?['nama_sampah']?.toString() ?? '-';

                          final kategori =
                              sampah?['kategori']?.toString() ?? '-';

                          final berat =
                              (item['berat_kg'] as num?)?.toDouble() ?? 0;

                          final harga =
                              (sampah?['harga_per_kg'] as num?)
                                      ?.toDouble() ??
                                  0;

                          final satuan =
                              sampah?['satuan']?.toString() ?? 'kg';

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _info('Nama Sampah', nama),
                              _info('Kategori', kategori),
                              _info(
                                'Berat Timbangan',
                                '${berat.toStringAsFixed(1)} Kg',
                                valueColor: green,
                              ),
                              _info(
                                'Tarif per $satuan',
                                'Rp ${rupiah(harga)}',
                              ),
                              const Divider(height: 18),
                            ],
                          );
                        }),

                        if (catatan.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'CATATAN PENYETOR',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            catatan,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // FOTO BUKTI
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: green,
                              size: 19,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Bukti Fisik Timbangan',
                                style: RupahTheme.heading(
                                  size: 14,
                                  color: ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 160,
                            child: fotoUrl == null
                                ? const ColoredBox(
                                    color: Color(0xFFE3E6EB),
                                    child: Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 42,
                                        color: muted,
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    fotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const ColoredBox(
                                        color: Color(0xFFE3E6EB),
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 42,
                                            color: muted,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      '♻ RUPAH\n'
                      'School Waste to Rupiah Ecosystem',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: green,
                        fontSize: 12,
                        height: 1.7,
                      ),
                    ),
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
  // TAMPILAN ERROR
  // ==========================================

  Widget _tampilanError() {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Detail Setoran'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal Memuat Detail Setoran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pesanError ?? 'Data setoran tidak ditemukan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: muatDetailSetoran,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // KOMPONEN TAMPILAN
  // ==========================================

  Widget _card({
    required Widget child,
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _info(
    String label,
    String value, {
    Color valueColor = ink,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bgColor, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

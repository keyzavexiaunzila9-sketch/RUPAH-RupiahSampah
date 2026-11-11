
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/rupah_widgets.dart';
import 'detail_setoran_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final supabase = Supabase.instance.client;

  bool sedangMemuat = true;
  String? pesanError;

  List<Map<String, dynamic>> daftarRiwayat = [];

  String namaKelas = '-';

  double totalKas = 0;
  double totalBerat = 0;
  int totalSetoran = 0;
  String sampahTerbanyak = '-';

  static const bg = Color(0xFFF6F8FD);
  static const green = Color(0xFF16805D);
  static const ink = Color(0xFF253342);
  static const muted = Color(0xFF7A8794);

  @override
  void initState() {
    super.initState();
    muatRiwayat();
  }

  // ==========================================
  // MEMUAT RIWAYAT DARI SUPABASE
  // ==========================================

  Future<void> muatRiwayat() async {
    if (!mounted) return;

    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });

    try {
      final uid = supabase.auth.currentUser?.id;

      if (uid == null) {
        throw Exception('Pengguna belum login.');
      }

      // 1. Mengambil informasi kelas pengguna.
      final user = await supabase
          .from('users')
          .select('id_kelas')
          .eq('id_user', uid)
          .maybeSingle();

      String kelas = 'Kelas belum terdaftar';

      if (user != null && user['id_kelas'] != null) {
        final dataKelas = await supabase
            .from('kelas')
            .select('nama_kelas')
            .eq('id_kelas', user['id_kelas'])
            .maybeSingle();

        kelas = dataKelas?['nama_kelas'] ?? kelas;
      }

      // 2. Mengambil seluruh transaksi pengguna.
      final responseSetoran = await supabase
          .from('setoran')
          .select(
            'id_setoran, tanggal, status, total_berat, '
            'total_nilai, catatan, foto_url',
          )
          .eq('id_user', uid)
          .order('tanggal', ascending: false);

      final hasilRiwayat =
          List<Map<String, dynamic>>.from(responseSetoran);

      double kas = 0;
      double beratDisetujui = 0;
      int jumlahSetoran = hasilRiwayat.length;

      // Menghitung jenis sampah yang paling sering disetorkan.
      final Map<String, int> jumlahSampah = {};

      // 3. Mengambil detail setiap transaksi.
      for (final setoran in hasilRiwayat) {
        final idSetoran =
            (setoran['id_setoran'] as num).toInt();

        final status =
            setoran['status']?.toString().toLowerCase() ??
                'menunggu';

        final berat =
            (setoran['total_berat'] as num?)?.toDouble() ?? 0;

        final nilai =
            (setoran['total_nilai'] as num?)?.toDouble() ?? 0;

        // Kas dan berat hanya dihitung jika disetujui.
        if (status == 'disetujui' || status == 'diterima') {
          kas += nilai;
          beratDisetujui += berat;
        }

        // 4. Mengambil detail jenis sampah.
        final responseDetail = await supabase
            .from('detail_setoran')
            .select('id_sampah, berat_kg')
            .eq('id_setoran', idSetoran);

        final detail =
            List<Map<String, dynamic>>.from(responseDetail);

        final List<Map<String, dynamic>> daftarSampah = [];

        for (final item in detail) {
          final dataSampah = await supabase
              .from('sampah')
              .select('nama_sampah, kategori, harga_per_kg')
              .eq('id_sampah', item['id_sampah'])
              .maybeSingle();

          final beratDetail =
              (item['berat_kg'] as num?)?.toDouble() ?? 0;

          final sampah = dataSampah == null
              ? null
              : Map<String, dynamic>.from(dataSampah);

          daftarSampah.add({
            'nama_sampah':
                sampah?['nama_sampah'] ?? 'Sampah tidak ditemukan',
            'kategori': sampah?['kategori'] ?? '-',
            'berat_kg': beratDetail,
          });

          // Jenis sampah terbanyak dihitung dari setoran disetujui.
          if (sampah != null &&
              (status == 'disetujui' || status == 'diterima')) {
            final nama = sampah['nama_sampah'].toString();

            jumlahSampah[nama] =
                (jumlahSampah[nama] ?? 0) + 1;
          }
        }

        setoran['detail'] = daftarSampah;
      }

      // 5. Menentukan jenis sampah paling sering.
      String palingSering = '-';

      if (jumlahSampah.isNotEmpty) {
        final urutan = jumlahSampah.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        palingSering = urutan.first.key;
      }

      if (!mounted) return;

      setState(() {
        namaKelas = kelas;
        daftarRiwayat = hasilRiwayat;
        totalKas = kas;
        totalBerat = beratDisetujui;
        totalSetoran = jumlahSetoran;
        sampahTerbanyak = palingSering;
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

      return '${tanggal.day} ${bulan[tanggal.month - 1]} '
          '${tanggal.year} • '
          '${tanggal.hour.toString().padLeft(2, '0')}:'
          '${tanggal.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return '-';
    }
  }

  String formatBerat(dynamic value) {
    final angka = value is num ? value.toDouble() : 0.0;
    return '${angka.toStringAsFixed(1).replaceAll('.', ',')} Kg';
  }

  // ==========================================
  // STATUS TRANSAKSI
  // ==========================================

  String labelStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
      case 'diterima':
        return 'Terverifikasi';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu Verifikasi';
    }
  }

  Color warnaStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
      case 'diterima':
        return green;
      case 'ditolak':
        return const Color(0xFFC84444);
      default:
        return const Color(0xFFB98220);
    }
  }

  IconData ikonStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
      case 'diterima':
        return Icons.check_circle_outline;
      case 'ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  // ==========================================
  // TAMPILAN UTAMA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 62,
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: RupahLogo(size: 44),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Setor Kelas',
              style: RupahTheme.heading(
                size: 18,
                color: RupahColors.green,
              ),
            ),
            Text(
              namaKelas,
              style: RupahTheme.body(
                size: 12,
                color: RupahColors.muted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: muatRiwayat,
            icon: const Icon(
              Icons.refresh_rounded,
              color: green,
            ),
          ),
        ],
      ),

      body: sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            )
          : pesanError != null
              ? _tampilanError()
              : RefreshIndicator(
                  color: green,
                  onRefresh: muatRiwayat,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16, 16, 16, 22,
                    ),
                    children: [
                      _kartuRingkasan(),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Daftar Riwayat Setoran',
                              style: RupahTheme.heading(
                                size: 16,
                                color: ink,
                              ),
                            ),
                          ),
                          Text(
                            '$totalSetoran transaksi',
                            style: RupahTheme.body(
                              size: 12,
                              color: muted,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (daftarRiwayat.isEmpty)
                        _tampilanKosong()
                      else
                        ...daftarRiwayat.map(
                          (data) => _historyCard(
                            context,
                            data,
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  // ==========================================
  // KARTU RINGKASAN TOTAL KAS
  // ==========================================

  Widget _kartuRingkasan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006B45),
            Color(0xFF00856C),
            Color(0xFF006D68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006B45).withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            bottom: -45,
            child: Icon(
              Icons.eco_outlined,
              size: 155,
              color: Colors.white.withOpacity(0.10),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Text(
                'Total Kas Terkumpul dari Sampah',
                style: RupahTheme.body(
                  size: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),

              const SizedBox(height: 7),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      'Rp ${rupiah(totalKas)}',
                      style: RupahTheme.heading(
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'IDR',
                      style: TextStyle(
                        color: Color(0xFF8CF5C1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Divider(
                color: Colors.white.withOpacity(0.25),
                thickness: 1,
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  Expanded(
                    child: _summary(
                      'Total Berat',
                      totalBerat.toStringAsFixed(1)
                          .replaceAll('.', ','),
                      'Kg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summary(
                      'Total Setoran',
                      totalSetoran.toString(),
                      'Kali',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summary(
                      'Paling Sering',
                      sampahTerbanyak,
                      '',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                '* Kas dan berat dihitung dari setoran yang disetujui.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summary(
    String title,
    String value,
    String satuan,
  ) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (satuan.isNotEmpty)
                  TextSpan(
                    text: ' $satuan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
  // KARTU RIWAYAT SETORAN
  // ==========================================

  Widget _historyCard(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final idSetoran =
        (data['id_setoran'] as num).toInt();

    final status = data['status']?.toString() ?? 'menunggu';

    final detail =
        data['detail'] as List<Map<String, dynamic>>? ?? [];

    final namaSampah = detail
        .map((item) => item['nama_sampah'].toString())
        .toSet()
        .join(' & ');

    final kategori = detail
        .map((item) => item['kategori'].toString())
        .toSet()
        .join(', ');

    final berat =
        (data['total_berat'] as num?)?.toDouble() ?? 0;

    final nilai =
        (data['total_nilai'] as num?)?.toDouble() ?? 0;

    final diterima =
        status.toLowerCase() == 'disetujui' ||
        status.toLowerCase() == 'diterima';

    final ditolak = status.toLowerCase() == 'ditolak';

    final String reward = diterima
        ? '+Rp ${rupiah(nilai)}'
        : ditolak
            ? 'Tidak diterima'
            : 'Menunggu verifikasi';

    final IconData icon = kategori.toLowerCase().contains('organik')
        ? Icons.eco_outlined
        : kategori.toLowerCase().contains('b3')
            ? Icons.warning_amber_rounded
            : Icons.recycling_rounded;

    final warna = warnaStatus(status);

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSetoranScreen(
              idSetoran: idSetoran,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: RupahColors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: RupahColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: RupahColors.softGreen,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 19,
                color: RupahColors.green,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatTanggal(data['tanggal']),
                    style: RupahTheme.body(
                      size: 12,
                      color: RupahColors.muted,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    namaSampah.isEmpty
                        ? 'Detail sampah belum tersedia'
                        : namaSampah,
                    style: RupahTheme.body(
                      size: 14,
                      weight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${kategori.isEmpty ? '-' : kategori} • '
                    '${formatBerat(berat)}',
                    style: RupahTheme.body(
                      size: 12,
                      color: RupahColors.muted,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    diterima
                        ? 'Kas bertambah $reward'
                        : reward,
                    style: RupahTheme.body(
                      size: 12,
                      color: warna,
                      weight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ikonStatus(status),
                        size: 13,
                        color: warna,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          labelStatus(status),
                          style: TextStyle(
                            fontSize: 12,
                            color: warna,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: RupahColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAMPILAN KOSONG
  // ==========================================

  Widget _tampilanKosong() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RupahColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: muted,
          ),
          SizedBox(height: 12),
          Text(
            'Belum Ada Riwayat Setoran',
            style: TextStyle(
              color: ink,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Riwayat setoran kamu akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAMPILAN ERROR
  // ==========================================

  Widget _tampilanError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal Memuat Riwayat',
              style: TextStyle(
                color: ink,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pesanError ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: muatRiwayat,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

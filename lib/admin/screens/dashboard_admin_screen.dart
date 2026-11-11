
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/login_screen.dart';
import '../../core/services/verifikasi_service.dart';

class DashboardAdminScreen extends StatefulWidget {
  final VoidCallback? onOpenVerification;

  const DashboardAdminScreen({
    super.key,
    this.onOpenVerification,
  });

  @override
  State<DashboardAdminScreen> createState() =>
      _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  static const Color green = Color(0xFF007545);
  static const Color darkGreen = Color(0xFF006B43);
  static const Color background = Color(0xFFF5F7FC);
  static const Color ink = Color(0xFF202B38);
  static const Color muted = Color(0xFF68766F);
  static const Color border = Color(0xFFE9EDF2);

  final VerifikasiService _verifikasiService = VerifikasiService();

  List<Map<String, dynamic>> dataSetoran = [];

  int jumlahAntrean = 0;
  int jumlahKelasAktif = 0;

  double totalSampahHariIni = 0;
  double totalNilaiDisetujui = 0;

  bool isLoading = true;
  bool isLoggingOut = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // MEMUAT DATA DASHBOARD
  Future<void> loadDashboard() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final hasil = await Future.wait<dynamic>([
        _verifikasiService.getDataSetoran(),
        Supabase.instance.client
            .from('kelas')
            .select('id_kelas')
            .eq('status', 'aktif'),
      ]);

      final semuaSetoran =
          List<Map<String, dynamic>>.from(hasil[0] as List);

      final semuaKelas =
          List<Map<String, dynamic>>.from(hasil[1] as List);

      final sekarang = DateTime.now();

      // SETORAN HARI INI
      final setoranHariIni = semuaSetoran.where((item) {
        final tanggal = DateTime.tryParse(
          item['tanggal']?.toString() ?? '',
        );

        return tanggal != null &&
            tanggal.year == sekarang.year &&
            tanggal.month == sekarang.month &&
            tanggal.day == sekarang.day;
      }).toList();

      // ANTREAN VERIFIKASI
      final antrean = semuaSetoran.where((item) {
        return item['status']?.toString().toLowerCase() ==
            'menunggu';
      }).toList();

      // SETORAN DISETUJUI
      final setoranDisetujui = semuaSetoran.where((item) {
        return item['status']?.toString().toLowerCase() ==
            'disetujui';
      }).toList();

      // TOTAL BERAT HARI INI
      double beratHariIni = 0;

      for (final item in setoranHariIni) {
        beratHariIni +=
            double.tryParse(
              item['total_berat']?.toString() ?? '0',
            ) ??
            0;
      }

      // TOTAL NILAI SETORAN DISETUJUI
      double nilaiDisetujui = 0;

      for (final item in setoranDisetujui) {
        nilaiDisetujui +=
            double.tryParse(
              item['total_nilai']?.toString() ?? '0',
            ) ??
            0;
      }

      // URUTKAN ANTREAN TERBARU
      antrean.sort((a, b) {
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

      if (!mounted) return;

      setState(() {
        dataSetoran = antrean;
        jumlahAntrean = antrean.length;
        jumlahKelasAktif = semuaKelas.length;
        totalSampahHariIni = beratHariIni;
        totalNilaiDisetujui = nilaiDisetujui;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint('Gagal memuat dashboard: $e');
    }
  }

  // FORMAT RUPIAH
  String formatRupiah(double angka) {
    final nilai = angka.round().toString();

    final hasil = nilai.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp $hasil';
  }

  // FORMAT BERAT
  String formatBerat(double angka) {
    return angka.toStringAsFixed(
      angka % 1 == 0 ? 0 : 1,
    );
  }

  // LOGOUT
  Future<void> _logout() async {
    if (isLoggingOut) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun admin?',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF68766F),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: SafeArea(
        child: RefreshIndicator(
          color: green,
          onRefresh: loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 19),
                _statistics(),
                const SizedBox(height: 22),
                _queueTitle(),
                const SizedBox(height: 11),
                _verificationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Row(
      children: [
        Image.asset(
          'assets/logo_rupah.png',
          width: 42,
          height: 46,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              width: 42,
              height: 46,
              child: Icon(
                Icons.recycling_rounded,
                color: green,
                size: 36,
              ),
            );
          },
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bank Sampah',
                style: TextStyle(
                  fontSize: 14,
                  color: darkGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'SMKN 8 MALANG',
                style: TextStyle(
                  fontSize: 14,
                  color: darkGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Ibu.Sugiyanti • Penanggung Jawab',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        IconButton(
          onPressed: isLoggingOut ? null : _logout,
          tooltip: 'Logout',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFFEEEE),
            foregroundColor: Colors.red,
            padding: const EdgeInsets.all(10),
          ),
          icon: const Icon(
            Icons.logout_rounded,
            size: 20,
          ),
        ),
      ],
    );
  }

  // STATISTIK
  Widget _statistics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Antrean Verifikasi',
                value: isLoading ? '-' : '$jumlahAntrean',
                subtitle: 'Menunggu',
                icon: Icons.hourglass_top_rounded,
                accent: const Color(0xFFC45C00),
                subtitleColor: muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Sampah Hari Ini',
                value: isLoading
                    ? '-'
                    : formatBerat(totalSampahHariIni),
                unit: 'Kg',
                subtitle: 'Total setoran hari ini',
                icon: Icons.eco_outlined,
                accent: green,
                subtitleColor: green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Nilai Setoran',
                value: isLoading
                    ? '-'
                    : formatRupiah(totalNilaiDisetujui),
                subtitle: 'Setoran disetujui',
                icon: Icons.account_balance_wallet_outlined,
                accent: const Color(0xFF087F83),
                subtitleColor: muted,
                valueSize: 15,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Kelas Aktif',
                value: isLoading ? '-' : '$jumlahKelasAktif',
                unit: 'Kelas',
                subtitle: 'Terdaftar di RUPAH',
                icon: Icons.school_outlined,
                accent: const Color(0xFF43A7A5),
                subtitleColor: muted,
                valueSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // KARTU STATISTIK
  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color subtitleColor,
    String? unit,
    double valueSize = 21,
  }) {
    return Container(
      height: 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF0F2F5),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            color: accent,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 11, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.2,
                            color: Color(0xFF48534C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        icon,
                        size: 16,
                        color: accent,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: valueSize,
                            height: 1.1,
                            color: ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (unit != null) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            unit,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: muted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.3,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
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

  // JUDUL ANTREAN
  Widget _queueTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Antrean Butuh Verifikasi',
            style: TextStyle(
              fontSize: 15,
              color: ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        InkWell(
          onTap: widget.onOpenVerification,
          child: Text(
            'Lihat Semua ($jumlahAntrean) →',
            style: const TextStyle(
              fontSize: 10,
              color: green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // KARTU VERIFIKASI
  Widget _verificationCard() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: CircularProgressIndicator(
            color: green,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return _emptyCard(
        icon: Icons.error_outline,
        message: 'Gagal memuat data antrean.',
        buttonText: 'Coba Lagi',
        onPressed: loadDashboard,
      );
    }

    if (dataSetoran.isEmpty) {
      return _emptyCard(
        icon: Icons.inbox_outlined,
        message: 'Belum ada setoran yang menunggu verifikasi.',
      );
    }

    final item = dataSetoran.first;

    final namaKelas =
        item['nama_kelas']?.toString() ?? 'Kelas tidak diketahui';

    final detail = item['detail'] as List? ?? [];

    final tanggal = DateTime.tryParse(
      item['tanggal']?.toString() ?? '',
    );

    final berat = double.tryParse(
          item['total_berat']?.toString() ?? '0',
        ) ??
        0;

    final nilai = double.tryParse(
          item['total_nilai']?.toString() ?? '0',
        ) ??
        0;

    final namaSampah = detail.map((d) {
      return d['nama_sampah']?.toString() ?? 'Sampah';
    }).toSet().join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKelas,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      namaSampah.isEmpty
                          ? 'Detail sampah belum tersedia'
                          : namaSampah,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.35,
                        color: Color(0xFF48534C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatBerat(berat)} Kg',
                      style: const TextStyle(
                        fontSize: 10,
                        color: green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Column(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 13,
                    color: muted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tanggal == null
                        ? '-'
                        : '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFEDF0F4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Potensi Nilai Kas',
                      style: TextStyle(
                        fontSize: 9,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatRupiah(nilai),
                      style: const TextStyle(
                        fontSize: 12,
                        color: green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: widget.onOpenVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verifikasi Sekarang',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAMPILAN KOSONG / ERROR
  Widget _emptyCard({
    required IconData icon,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: muted,
            size: 32,
          ),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
          if (buttonText != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }
}

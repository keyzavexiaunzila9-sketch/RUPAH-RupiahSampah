
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/rupah_widgets.dart';
import '../../auth/login_screen.dart';

class ProfilUserScreen extends StatefulWidget {
  const ProfilUserScreen({super.key});

  @override
  State<ProfilUserScreen> createState() => _ProfilUserScreenState();
}

class _ProfilUserScreenState extends State<ProfilUserScreen> {
  final supabase = Supabase.instance.client;

  bool sedangMemuat = true;
  bool sedangKeluar = false;
  String? pesanError;

  String namaKelas = '-';
  String tingkat = '-';
  String jurusan = '-';
  String namaWaliKelas = '-';
  String statusKelas = 'Aktif';

  double totalSaldo = 0;
  double totalBerat = 0;

  @override
  void initState() {
    super.initState();
    muatProfil();
  }

  // ==========================================
  // MEMUAT PROFIL DAN STATISTIK KELAS
  // ==========================================

  Future<void> muatProfil() async {
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

      // 1. Mengambil data pengguna.
      final user = await supabase
          .from('users')
          .select('id_kelas')
          .eq('id_user', uid)
          .maybeSingle();

      if (user == null) {
        throw Exception('Data pengguna tidak ditemukan.');
      }

      final idKelas = user['id_kelas'];

      if (idKelas == null) {
        throw Exception('Pengguna belum terdaftar di kelas.');
      }

      // 2. Mengambil informasi kelas.
      final kelas = await supabase
          .from('kelas')
          .select(
            'nama_kelas, tingkat, jurusan, '
            'nama_wali_kelas, status',
          )
          .eq('id_kelas', idKelas)
          .maybeSingle();

      if (kelas == null) {
        throw Exception('Data kelas tidak ditemukan.');
      }

      // 3. Mengambil transaksi pengguna.
      final responseSetoran = await supabase
          .from('setoran')
          .select('status, total_berat, total_nilai')
          .eq('id_user', uid);

      final daftarSetoran =
          List<Map<String, dynamic>>.from(responseSetoran);

      double saldo = 0;
      double berat = 0;

      // 4. Menghitung setoran yang sudah disetujui.
      for (final setoran in daftarSetoran) {
        final status =
            setoran['status']?.toString().toLowerCase();

        if (status == 'disetujui' || status == 'diterima') {
          saldo +=
              (setoran['total_nilai'] as num?)?.toDouble() ?? 0;

          berat +=
              (setoran['total_berat'] as num?)?.toDouble() ?? 0;
        }
      }

      if (!mounted) return;

      setState(() {
        namaKelas = kelas['nama_kelas']?.toString() ?? '-';
        tingkat = kelas['tingkat']?.toString() ?? '-';
        jurusan = kelas['jurusan']?.toString() ?? '-';
        namaWaliKelas =
            kelas['nama_wali_kelas']?.toString() ?? '-';
        statusKelas =
            kelas['status']?.toString() ?? 'Aktif';

        totalSaldo = saldo;
        totalBerat = berat;

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
  // FORMAT RUPIAH
  // ==========================================

  String rupiah(double angka) {
    return angka.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  // ==========================================
  // KELUAR AKUN
  // ==========================================

  Future<void> keluarAkun() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar Akun'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun kelas?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC84444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true || !mounted) return;

    setState(() {
      sedangKeluar = true;
    });

    try {
      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        sedangKeluar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal keluar akun: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================
  // TAMPILAN UTAMA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FD),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 62,
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: RupahLogo(size: 44),
        ),
        title: Text(
          'Profil Kelas',
          style: RupahTheme.heading(
            size: 14,
            color: RupahColors.green,
          ),
        ),
        actions: [
          IconButton(
            onPressed: sedangMemuat ? null : muatProfil,
            icon: const Icon(
              Icons.refresh_rounded,
              color: RupahColors.green,
            ),
          ),
        ],
      ),

      body: sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(
                color: RupahColors.green,
              ),
            )
          : pesanError != null
              ? _tampilanError()
              : RefreshIndicator(
                  color: RupahColors.green,
                  onRefresh: muatProfil,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16, 4, 16, 26,
                    ),
                    child: Column(
                      children: [
                        // INFORMASI KELAS
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: RupahColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: RupahColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                padding: const EdgeInsets.all(9),
                                decoration: const BoxDecoration(
                                  color: RupahColors.softGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const RupahLogo(size: 38),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      namaKelas,
                                      style: RupahTheme.heading(
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    StatusPill(
                                      text: statusKelas.toLowerCase() ==
                                              'aktif'
                                          ? 'Aktif'
                                          : 'Nonaktif',
                                      color: statusKelas.toLowerCase() ==
                                              'aktif'
                                          ? RupahColors.green
                                          : Colors.red,
                                      background:
                                          statusKelas.toLowerCase() ==
                                                  'aktif'
                                              ? RupahColors.softGreen
                                              : const Color(0xFFFFE7E7),
                                      icon: statusKelas.toLowerCase() ==
                                              'aktif'
                                          ? Icons.verified_rounded
                                          : Icons.cancel_outlined,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Tingkat: $tingkat • $jurusan',
                                      style: RupahTheme.body(
                                        size: 12,
                                        color: RupahColors.muted,
                                      ),
                                    ),
                                    Text(
                                      'Wali Kelas: $namaWaliKelas',
                                      style: RupahTheme.body(
                                        size: 12,
                                        color: RupahColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // STATISTIK KELAS
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: RupahColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: RupahColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _metric(
                                  'Total Saldo Kelas',
                                  'Rp ${rupiah(totalSaldo)}',
                                  Icons.account_balance_wallet_outlined,
                                  RupahColors.green,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _metric(
                                  'Sampah Terpilah',
                                  '${totalBerat.toStringAsFixed(1)} Kg',
                                  Icons.recycling_rounded,
                                  RupahColors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 13),

                        // INFORMASI SEKOLAH
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: RupahColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: RupahColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_outlined,
                                    color: RupahColors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Informasi Sekolah',
                                      style: RupahTheme.heading(
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  const StatusPill(
                                    text: 'Terverifikasi',
                                    color: RupahColors.green,
                                    background:
                                        RupahColors.softGreen,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const InfoRow(
                                icon: Icons.school_outlined,
                                label: 'Institusi',
                                value: 'SMKN 8 MALANG',
                              ),
                              const InfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Drop Point',
                                value: 'RUANG ADIWIYATA',
                              ),
                              const InfoRow(
                                icon: Icons.access_time_rounded,
                                label: 'Jadwal',
                                value:
                                    'Setiap Jumat, 09:00 - 10:30 WIB',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // TOMBOL KELUAR
                        RupahPrimaryButton(
                          label: sedangKeluar
                              ? 'Sedang Keluar...'
                              : 'Keluar Akun Kelas',
                          icon: Icons.logout_rounded,
                          outlined: true,
                          onPressed:
                              sedangKeluar ? null : keluarAkun,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ==========================================
  // KARTU STATISTIK
  // ==========================================

  Widget _metric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 7),
          Text(
            label,
            style: RupahTheme.body(
              size: 12,
              color: RupahColors.muted,
            ),
          ),
          Text(
            value,
            style: RupahTheme.heading(
              size: 14,
              color: color,
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
              color: Colors.redAccent,
              size: 45,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal Memuat Profil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pesanError ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RupahColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: muatProfil,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

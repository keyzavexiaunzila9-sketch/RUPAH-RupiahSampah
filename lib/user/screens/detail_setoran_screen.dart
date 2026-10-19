import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DetailSetoranScreen extends StatelessWidget {
  final String category;
  final double weight;
  final String note;
  final Uint8List? photoBytes;
  final DateTime? date;
  final String status;
  final String? nomorSetoran;

  const DetailSetoranScreen({
    super.key,
    this.category = 'Plastik',
    this.weight = 5,
    this.note = 'Telah dicuci bersih dan dipadatkan sesuai panduan RUPAH.',
    this.photoBytes,
    this.date,
    this.status = 'Diterima',
    this.nomorSetoran,
  });

  static const bg = Color(0xFFF6F8FD);
  static const green = Color(0xFF16805D);
  static const darkGreen = Color(0xFF116B4E);
  static const ink = Color(0xFF253342);
  static const muted = Color(0xFF7A8794);
  static const border = Color(0xFFE8EDF4);

  @override
  Widget build(BuildContext context) {
    final tanggal = date ?? DateTime.now();

    final rate = category == 'Plastik'
        ? 3000
        : category == 'Kertas'
            ? 2000
            : 5000;

    final total = rate * weight;
    final diterima = status == 'Diterima';
    final ditolak = status == 'Ditolak';

    final warna = diterima
        ? darkGreen
        : ditolak
            ? const Color(0xFFC84444)
            : const Color(0xFFB98220);

    final nomor = nomorSetoran ??
        '#RPH-${tanggal.year}-${tanggal.millisecondsSinceEpoch.toString().substring(7)}';

    final tanggalText =
        '${tanggal.day} ${_bulan(tanggal.month)} ${tanggal.year}, '
        '${tanggal.hour.toString().padLeft(2, '0')}:'
        '${tanggal.minute.toString().padLeft(2, '0')} WIB';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Detail Setoran',
                        style: RupahTheme.heading(
                          size: 17,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: border),

            // Isi halaman
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // Status setoran
                  _card(
                    color: diterima
                        ? const Color(0xFFD5F6E4)
                        : ditolak
                            ? const Color(0xFFFFE7E7)
                            : const Color(0xFFFFF1D6),
                    child: Row(
                      children: [
                        Icon(
                          diterima
                              ? Icons.verified_rounded
                              : ditolak
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_top_rounded,
                          color: warna,
                          size: 29,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diterima
                                    ? 'Disetujui & Tervalidasi'
                                    : ditolak
                                        ? 'Setoran Ditolak'
                                        : 'Menunggu Verifikasi',
                                style: TextStyle(
                                  color: warna,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                diterima
                                    ? 'Saldo dialokasikan ke dompet kas kelas'
                                    : ditolak
                                        ? 'Setoran tidak disetujui admin'
                                        : 'Setoran sedang diperiksa admin',
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 11,
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
                          warna,
                          Colors.white,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reward
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
                              : 'Estimasi Reward',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rp ${_rupiah(ditolak ? 0 : total)}',
                          style: RupahTheme.heading(
                            size: 27,
                            color: Colors.white,
                          ),
                        ),
                        const Divider(color: Colors.white38),
                        Text(
                          'Tarif: Rp ${_rupiah(rate)} /Kg × '
                          '${weight.toStringAsFixed(1)} Kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '♟ Kas Kelas XI RPL 1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Informasi penimbangan
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Penimbangan',
                          style: RupahTheme.heading(
                            size: 16,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _info('ID Transaksi / Ref', nomor),
                        _info('Waktu Setor', tanggalText),
                        _info('Kelas Penyetor', 'Kelas XI RPL 1'),
                        _info('Jenis Sampah', category),

                        const Divider(height: 18),

                        _info(
                          'Berat Timbangan Akhir',
                          '${weight.toStringAsFixed(1)} Kg',
                          valueColor: green,
                        ),

                        if (note.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'CATATAN PENYETOR',
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            note,
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

                  // Bukti foto
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
                                  size: 15,
                                  color: ink,
                                ),
                              ),
                            ),
                            _chip(
                              'Foto Terverifikasi',
                              const Color(0xFFD5F6E4),
                              darkGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 160,
                            child: photoBytes == null
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
                                : Image.memory(
                                    photoBytes!,
                                    fit: BoxFit.cover,
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
                        fontSize: 10,
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _bulan(int month) => [
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
      ][month - 1];

  String _rupiah(num value) => value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
}

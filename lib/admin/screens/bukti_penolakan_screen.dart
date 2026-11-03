import 'dart:typed_data';
import 'package:flutter/material.dart';

class BuktiPenolakanScreen extends StatelessWidget {
  final String nomorSetoran;
  final String namaPenyetor;
  final String kelas;
  final String tanggal;
  final String alasan;
  final String kategori;
  final String beratAwal;
  final String beratRiil;
  final String kasDiterima;
  final String kasPotensial;
  final String petugas;
  final Uint8List? photoBytes;

  const BuktiPenolakanScreen({
    super.key,
    this.nomorSetoran = '#RPH-20241024-05',
    this.namaPenyetor = 'Pos Timbang B-2',
    this.kelas = 'XI TKJ B',
    this.tanggal = '24 Okt 2024, 08:45 WIB',
    this.alasan =
        'Ditemukan pemberat batu paving di dalam karung, selisih berat -3.3 Kg dari klaim.',
    this.kategori = 'Kardus & Anorganik',
    this.beratAwal = '8.5 Kg',
    this.beratRiil = '5.2 Kg',
    this.kasDiterima = 'Rp 0',
    this.kasPotensial = 'Rp 17.000',
    this.petugas = 'Bu Sugiyanti',
    this.photoBytes,
  });

  static const Color red = Color(0xFFC51D25);
  static const Color darkRed = Color(0xFFB91C25);
  static const Color green = Color(0xFF087A4F);
  static const Color background = Color(0xFFF5F7FA);
  static const Color ink = Color(0xFF263238);
  static const Color muted = Color(0xFF78857F);
  static const Color border = Color(0xFFE8EDF2);

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
              nomorSetoran,
              style: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Column(
          children: [
            // STATUS PENOLAKAN
            _card(
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
                    '$namaPenyetor • $tanggal',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      border: Border.all(
                        color: const Color(0xFFFFD0D0),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: red,
                          size: 16,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: ink,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Alasan Penolakan: ',
                                  style: TextStyle(
                                    color: red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: alasan),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // RINGKASAN SETORAN
            _card(
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

                  const SizedBox(height: 9),

                  _detailRow('Penyetor', kelas),

                  _detailRow('Kategori Sampah', kategori),

                  _detailRow(
                    'Berat (Klaim | Riil)',
                    '$beratAwal | $beratRiil (-3.3 Kg)',
                    valueColor: red,
                  ),

                  _detailRow(
                    'Kas Diterima',
                    kasDiterima,
                    valueColor: red,
                  ),

                  _detailRow(
                    'Potensi Kas',
                    kasPotensial,
                    valueColor: muted,
                    lineThrough: true,
                  ),

                  _detailRow(
                    'Petugas Pemeriksa',
                    petugas,
                    valueColor: green,
                    icon: Icons.verified_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // FOTO BUKTI TEMUAN PETUGAS
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FOTO BUKTI TEMUAN PETUGAS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Container(
                    width: double.infinity,
                    height: 168,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EEFF),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: const Color(0xFFFFB9B9),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: photoBytes != null
                        ? Image.memory(
                            photoBytes!,
                            width: double.infinity,
                            height: 168,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // SOLUSI SETOR ULANG
            Container(
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
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Solusi Setor Ulang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Keluarkan benda asing/pemberat dan keringkan sampah sebelum melakukan setor ulang ke Pos Timbang.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF47715D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // TOMBOL KEMBALI
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: border),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 43,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.history_rounded,
                size: 15,
              ),
              label: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                side: const BorderSide(color: border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
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

  Widget _detailRow(
    String title,
    String value, {
    Color valueColor = ink,
    IconData? icon,
    bool lineThrough = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: valueColor,
            ),
            const SizedBox(width: 4),
          ],
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

import 'dart:typed_data';
import 'package:flutter/material.dart';

class DetailVerifikasiSetoranScreen extends StatelessWidget {
  final String nama;
  final String kelas;
  final String waktu;
  final String kategori;
  final String berat;
  final String totalKas;
  final String hargaPerKg;
  final String lokasi;
  final String catatanAdmin;
  final Uint8List? photoBytes;

  const DetailVerifikasiSetoranScreen({
    super.key,
    this.nama = 'Dimas Pratama',
    this.kelas = 'XI RPL 1',
    this.waktu = '11 Sept 2026, 14:40 WIB',
    this.kategori = 'Botol PET Bening',
    this.berat = '5.0 Kg',
    this.totalKas = 'Rp 15.000',
    this.hargaPerKg = 'Rp 3.000 / Kg',
    this.lokasi = 'Ruang Adiwiyata SMKN 8 MALANG',
    this.catatanAdmin =
        'Sampah disortir dengan sangat rapi oleh perwakilan kelas XI RPL 1. Bobot sesuai kalibrasi digital. Rekomendasi percontohan kelas Adiwiyata terbaik.',
    this.photoBytes,
  });

  static const green = Color(0xFF087A50);
  static const darkGreen = Color(0xFF006B43);
  static const background = Color(0xFFF5F8F6);
  static const ink = Color(0xFF26352F);
  static const muted = Color(0xFF84908B);
  static const border = Color(0xFFE6ECE9);

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
        title: const Text(
          'Detail Verifikasi Setoran',
          style: TextStyle(
            fontSize: 14,
            color: darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusCard(),

            const SizedBox(height: 10),

            _identityCard(),

            const SizedBox(height: 10),

            _cashCard(),

            const SizedBox(height: 10),

            _inspectionCard(),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.keyboard_return_rounded,
                  size: 14,
                ),
                label: const Text(
                  'Kembali ke Antrean Verifikasi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: green,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STATUS SETORAN
  Widget _statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF258D73),
            Color(0xFF4EA9A5),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 5,
            top: 0,
            child: Icon(
              Icons.bolt_rounded,
              size: 65,
              color: Color(0x337FFFFFF),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Disetujui & Saldo Diterbitkan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Waktu Verifikasi Tim Operasional',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                waktu,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // IDENTITAS PENYETOR
  Widget _identityCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.groups_rounded,
            'Identitas Penyetor & Kelas',
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: _infoBox(
                  'Kelas Pemilik Rekening',
                  kelas,
                  'Kelas Penghasil',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _infoBox(
                  'Penyetor',
                  nama,
                  'Ketua Tim Eco Adiwiyata',
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F7),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: green,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi Drop Point Timbangan',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                      Text(
                        lokasi,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(
    String title,
    String value,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  // HASIL KONVERSI KAS
  Widget _cashCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.payments_outlined,
            'Hasil Konversi Kas & Poin',
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD4E9DF),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saldo Kas Masuk',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalKas,
                        style: const TextStyle(
                          fontSize: 14,
                          color: darkGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Disetor ke: Kas Bersama $kelas',
                        style: const TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: darkGreen,
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          _cashRow('Volume Bersih Terverifikasi', berat),
          const SizedBox(height: 7),
          _cashRow('Tarif Berlaku (Grade A Standard)', hargaPerKg),
        ],
      ),
    );
  }

  Widget _cashRow(String title, String value) {
    return Row(
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: ink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // INSPEKSI MUTU DAN BUKTI FOTO
  Widget _inspectionCard() {
    final checks = [
      'Tingkat Kebersihan: 100% (Kering & bebas tanah)',
      'Pelepasan Label & tutup botol dipilah terpisah',
      'Bebas residu zat organik / minyak cair',
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.fact_check_outlined,
            'Inspeksi Mutu & Bukti Foto',
          ),

          const SizedBox(height: 10),

          ...checks.map(
            (item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 13,
                    color: green,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 5),

          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(9),
              ),
              child: photoBytes != null
                  ? Image.memory(
                      photoBytes!,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 25,
                            color: muted,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Belum ada foto bukti setoran',
                            style: TextStyle(
                              fontSize: 12,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E5),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: const Color(0xFFFFE2A0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 13,
                      color: Color(0xFFC27A18),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Catatan Resmi Petugas Lapangan:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB66C12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"$catatanAdmin"',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF96723D),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // KOMPONEN KARTU
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
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

  Widget _sectionTitle(IconData icon, String title) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F4ED),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 13,
                color: green,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(
          height: 1,
          color: border,
        ),
      ],
    );
  }
}

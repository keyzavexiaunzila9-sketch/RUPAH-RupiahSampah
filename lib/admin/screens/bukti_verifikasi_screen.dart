import 'package:flutter/material.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_widgets.dart';

class BuktiVerifikasiScreen extends StatelessWidget {
  const BuktiVerifikasiScreen({super.key});

  Widget _check(String t) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AdminColors.blueSoft, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.check_circle, size: 18, color: AdminColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 12))),
        ]),
      );

  Widget _infoBox(String a, String b, String c, {Color? cColor}) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AdminColors.blueSoft, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a, style: const TextStyle(fontSize: 10)),
            Text(b, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            Text(c,
                style: TextStyle(
                    fontSize: 9,
                    color: cColor ?? AdminColors.muted,
                    fontWeight: cColor != null ? FontWeight.w600 : FontWeight.w400)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdminColors.bg,
        appBar: adminBackBar(context, 'Detail Verifikasi Setoran'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          // Banner status
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient:
                  const LinearGradient(colors: [Color(0xFF2E8B57), Color(0xFF5BA8A8)]),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AdminPill('Disetujui & Saldo Diterbitkan',
                  bg: AdminColors.primaryLight,
                  fg: AdminColors.primary,
                  icon: Icons.check_circle,
                  size: 12),
              SizedBox(height: 12),
              Text('Waktu Verifikasi Tim Operasional',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
              SizedBox(height: 2),
              Text('11 Sept 2026, 14:40 WIB',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
          ),

          // Identitas
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AdminSection(Icons.school, 'Identitas Penyetor & Kelas'),
              Row(children: [
                _infoBox('Kelas Pemilik Rekening', 'XI RPL 1', 'Rekayasa Perangkat Lunak'),
                const SizedBox(width: 10),
                _infoBox('Penyetor', 'Dimas Pratama', 'Ketua Tim Eco Adiwiyata',
                    cColor: AdminColors.primary),
              ]),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AdminColors.bg, borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AdminColors.primary),
                  SizedBox(width: 6),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Lokasi Drop Point Timbangan', style: TextStyle(fontSize: 10)),
                      Text('Ruang Adiwiyata SMKN 8 MALANG',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),

          // Konversi kas
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AdminSection(Icons.payments_outlined, 'Hasil Konversi Kas &\nPoin'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AdminColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFE0CB))),
                child: Row(children: [
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Total Saldo Kas Masuk', style: TextStyle(fontSize: 10)),
                      Text('Rp 15.000',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.primary)),
                      Text.rich(TextSpan(
                          text: 'Disetor ke: ',
                          style: TextStyle(fontSize: 10),
                          children: [
                            TextSpan(
                                text: 'Kas Bersama XI RPL 1',
                                style: TextStyle(fontWeight: FontWeight.w700))
                          ])),
                    ]),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                        color: AdminColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Volume Bersih Terverifikasi', style: TextStyle(fontSize: 11)),
                Text('5.0 Kg',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
              const Divider(height: 18),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Tarif Berlaku (Grade A Standard)', style: TextStyle(fontSize: 11)),
                Text('Rp 3.000 / Kg',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ]),
          ),

          // Inspeksi mutu
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AdminSection(Icons.fact_check_outlined, 'Inspeksi Mutu & Bukti Foto'),
              _check('Tingkat Kebersihan: 100% (Kering & bebas tanah)'),
              _check('Pelepasan label & tutup botol dipilah terpisah'),
              _check('Bebas residu zat organik / minyak cair'),
              const SizedBox(height: 4),
              Container(
                height: 170,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminColors.border)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AdminColors.amberBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF5D88A))),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.rate_review_outlined, size: 16, color: AdminColors.orange),
                    SizedBox(width: 6),
                    Text('Catatan Resmi Petugas Lapangan:',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AdminColors.orange)),
                  ]),
                  SizedBox(height: 6),
                  Text(
                      '"Sampah disortir dengan sangat rapi oleh perwakilan kelas XI RPL 1. Bobot sesuai kalibrasi digital. Rekomendasi percontohan kelas Adiwiyata terbaik."',
                      style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AdminColors.orange)),
                ]),
              ),
            ]),
          ),
        ]),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SafeArea(
            top: false,
            child: TextButton.icon(
              onPressed: () {
                adminTab.value = 1;
                Navigator.of(context)
                  ..pop() // tutup Bukti
                  ..pop(); // tutup Detail -> kembali ke AdminApp
              },
              icon: const Icon(Icons.checklist, color: AdminColors.primary, size: 18),
              label: const Text('Kembali ke Antrean Verifikasi',
                  style: TextStyle(
                      color: AdminColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ),
        ),
      );
}
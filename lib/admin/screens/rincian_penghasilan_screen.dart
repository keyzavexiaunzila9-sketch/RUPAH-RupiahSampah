import 'package:flutter/material.dart';
import '../widgets/admin_widgets.dart';

class RincianPenghasilanScreen extends StatefulWidget {
  const RincianPenghasilanScreen({super.key});
  @override
  State<RincianPenghasilanScreen> createState() => _RincianPenghasilanScreenState();
}

class _RincianPenghasilanScreenState extends State<RincianPenghasilanScreen> {
  // nama, deskripsi, tarif per kg, warna, warna soft
  static const _kat = [
    ('Sampah Organik', 'Daun kering, sisa buah kantin, sisa sayuran, ranting kecil', 3000,
        AdminColors.primary, AdminColors.primaryLight),
    ('Sampah\nAnorganik', 'Botol PET bening, kardus, gelas plastik, kertas berkas', 2000,
        AdminColors.teal, Color(0xFFD6EEFF)),
    ('Sampah B3\nSekolah', 'Baterai bekas praktek, neon lab mati, e-waste mini, cartridge',
        5000, AdminColors.orange, AdminColors.amberBg),
  ];
  final List<double> _bobot = [6.0, 12.0, 2.0];

  double get _totalBobot => _bobot.fold(0.0, (a, b) => a + b);
  int get _totalKas {
    var sum = 0;
    for (var i = 0; i < _kat.length; i++) {
      sum += (_bobot[i] * _kat[i].$3).round();
    }
    return sum;
  }

  String _rp(num v) =>
      'Rp ${v.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

  void _ubah(int i, double d) =>
      setState(() => _bobot[i] = (_bobot[i] + d).clamp(0.0, 999.0).toDouble());

  Widget _step(IconData icon, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Icon(icon, size: 18, color: AdminColors.muted));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdminColors.bg,
        appBar: adminBackBar(context, 'Rincian Setoran Sampah'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ENTITAS PENYETOR KAS',
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700, color: AdminColors.muted)),
              const SizedBox(height: 6),
              const Text('XII RPL D',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.primary)),
              const Divider(height: 20),
              const Row(children: [
                Icon(Icons.schedule, size: 16, color: AdminColors.primary),
                SizedBox(width: 8),
                Text('Kamis, 24 Okt 2024 • 09:15 WIB', style: TextStyle(fontSize: 11)),
              ]),
              const SizedBox(height: 8),
              const Row(children: [
                Icon(Icons.verified_user_outlined, size: 16, color: AdminColors.primary),
                SizedBox(width: 8),
                Text('Verifikator:Bu Yanti (PJ Adiwiyata)', style: TextStyle(fontSize: 11)),
              ]),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Sesuai penimbangan timbangan digital\nsekolah',
                style: TextStyle(fontSize: 11)),
          ),
          for (var i = 0; i < _kat.length; i++)
            AdminCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: Text(_kat[i].$1,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700, height: 1.2))),
                  AdminPill('${_rp(_kat[i].$3)} / Kg',
                      bg: _kat[i].$5, fg: _kat[i].$4, size: 9),
                ]),
                const SizedBox(height: 4),
                Text(_kat[i].$2, style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AdminColors.blueSoft,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    Row(children: [
                      const Text('Bobot:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AdminColors.border)),
                        child: Row(children: [
                          _step(Icons.remove, () => _ubah(i, -0.5)),
                          const SizedBox(width: 14),
                          Text(_bobot[i].toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          const Text('Kg', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 14),
                          _step(Icons.add, () => _ubah(i, 0.5)),
                        ]),
                      ),
                    ]),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text('Subtotal Kas',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                        Text(_rp(_bobot[i] * _kat[i].$3),
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: _kat[i].$4)),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          AdminCard(
            borderColor: const Color(0xFFBFE0CB),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.payments_outlined, color: AdminColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text('Akumulasi Kas\nMasuk',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, height: 1.2))),
                Text.rich(TextSpan(
                    text: 'Total Bobot: ',
                    style: const TextStyle(fontSize: 10),
                    children: [
                      TextSpan(
                          text: '${_totalBobot.toStringAsFixed(1)}\nKg',
                          style: const TextStyle(fontWeight: FontWeight.w700))
                    ])),
              ]),
              const Divider(height: 24),
              Center(
                child: Column(children: [
                  const Text('ESTIMASI PENAMBAHAN KAS KELAS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_rp(_totalKas),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.primary)),
                ]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AdminColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFE0CB))),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.check_circle_outline, color: AdminColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Kondisi: 100% Terpilah Bersih (Memenuhi Standar Adiwiyata)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.primary)),
                      SizedBox(height: 2),
                      Text(
                          'Material kering, wadah bebas residu minyak/cairan kotor, siap didaur ulang.',
                          style: TextStyle(fontSize: 10, color: AdminColors.primary)),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
          const AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.notes, size: 16),
                SizedBox(width: 6),
                Expanded(
                    child: Text('Catatan Petugas / Siswa',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                Text('Opsional', style: TextStyle(fontSize: 10, color: AdminColors.muted)),
              ]),
              SizedBox(height: 10),
              AdminField(
                  maxLines: 4,
                  initial:
                      'Sampah anorganik botol plastik sudah dalam kondisi bersih & terpilihkan. Daun kering siap masuk komposter.'),
            ]),
          ),
        ]),
      );
}
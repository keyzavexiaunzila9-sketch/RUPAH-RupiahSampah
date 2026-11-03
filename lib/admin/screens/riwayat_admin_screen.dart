import 'package:flutter/material.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_widgets.dart';
import 'rincian_penghasilan_screen.dart';

class _Tx {
  final String kelas, inisial, tag, waktu, deskripsi, verifikator, nilai, alasan;
  final Color inisialBg, tagBg, tagFg;
  final bool ditolak;
  const _Tx(this.kelas, this.inisial, this.inisialBg, this.tag, this.tagBg, this.tagFg,
      this.waktu, this.deskripsi, this.verifikator, this.nilai,
      {this.ditolak = false, this.alasan = ''});
}

const _data = [
  _Tx('XI RPL 1', 'XI', Color(0xFFE3E8FF), 'Anorganik • PET', AdminColors.tealLight,
      AdminColors.teal, 'Hari ini, 24 Okt 2024 • 09:30 WIB', '4.5 Kg Botol Plastik Bersih',
      'Pak Haryono (Piket)', '+Rp 9.000'),
  _Tx('XII RPL D', 'XII', AdminColors.dangerBg, 'Anorganik • Plastik Campur',
      AdminColors.tealLight, AdminColors.teal, 'Hari ini, 24 Okt 2024 • 08:45 WIB',
      '3.0 Kg Plastik Kotor', 'Bu Yanti (PJ Adiwiyata)', 'Rp 0 (Batal)',
      ditolak: true,
      alasan:
          'Sampah botol plastik masih sangat kotor, basah, dan bercampur sisa makanan berlemak. Harap cuci & keringkan sebelum disetor kembali.'),
  _Tx('XII TKJ 1', 'XII', AdminColors.primaryLight, 'Organik • Daun & Sisa',
      AdminColors.primaryLight, AdminColors.primary, 'Hari ini, 24 Okt 2024 • 08:15 WIB',
      '12.0 Kg Sampah Organik Daun', 'Ibu Rahma', '+Rp 36.000'),
  _Tx('X METRO 2', 'X', AdminColors.blueSoft, 'Anorganik • Plastik & Kardus',
      Color(0xFF9EEFF0), AdminColors.teal, 'Kemarin, 23 Okt 2024 • 14:10 WIB',
      '15.0 Kg Kardus & Botol Plastik', 'Pak Joko', '+Rp 30.000'),
  _Tx('XI ELIN 2', 'XI', AdminColors.dangerBg, 'B3 • E-Waste', AdminColors.dangerBg,
      AdminColors.danger, '22 Okt 2024 • 10:45 WIB', '2.0 Kg E-Waste & Baterai',
      'Pak Haryono', '+Rp 10.000'),
];

class RiwayatAdminScreen extends StatefulWidget {
  const RiwayatAdminScreen({super.key});
  @override
  State<RiwayatAdminScreen> createState() => _RiwayatAdminScreenState();
}

class _RiwayatAdminScreenState extends State<RiwayatAdminScreen> {
  int _tab = 0;

  Widget _seg(int i, String label, {String? badge}) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: _tab == i ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(24)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _tab == i ? AdminColors.primary : AdminColors.text)),
              if (badge != null) ...[
                const SizedBox(width: 6),
                AdminPill(badge,
                    bg: AdminColors.tealLight, fg: AdminColors.teal, size: 9),
              ],
            ]),
          ),
        ),
      );

  Widget _sum(String label, String value, {String? unit, bool bright = false}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)),
            Text.rich(TextSpan(
                text: value,
                style: TextStyle(
                    color: bright ? const Color(0xFF9EF0B8) : Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
                children: [
                  if (unit != null)
                    TextSpan(text: ' $unit', style: const TextStyle(fontSize: 9))
                ])),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(children: [
        AppBar(
          backgroundColor: AdminColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AdminColors.primary),
              onPressed: () => adminTab.value = 0),
          titleSpacing: 0,
          title: const Text('Riwayat & Transaksi',
              style: TextStyle(
                  color: AdminColors.primary, fontWeight: FontWeight.w700, fontSize: 17)),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color(0xFFDDE5FA), borderRadius: BorderRadius.circular(28)),
              child: Row(children: [
                _seg(0, 'Riwayat Setor\nSampah', badge: '142'),
                _seg(1, 'Penghasilan\nKelas'),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                    colors: [Color(0xFF1F7A4D), Color(0xFF3E9A78)]),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text('TOTAL KAS SEKOLAH',
                      style: TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  Spacer(),
                  AdminPill('● Aktif TA 24/25',
                      bg: Color(0x33FFFFFF), fg: Colors.white, size: 9),
                ]),
                const SizedBox(height: 10),
                const Text('Total Penghasilan Seluruh Kelas',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
                const Text('Rp 4.750.000',
                    style: TextStyle(
                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                const Divider(color: Colors.white24, height: 20),
                Row(children: [
                  _sum('Total Sampah', '1.284,5', unit: 'Kg'),
                  const SizedBox(width: 8),
                  _sum('Partisipasi', '32', unit: 'Kelas'),
                  const SizedBox(width: 8),
                  _sum('Bulan Ini', '+920rb', bright: true),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            const AdminSearch(),
            Row(children: [
              Container(width: 4, height: 18, color: AdminColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                  child: Text('Aktivitas Setor Terbaru',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              const Text('5 Transaksi Ditampilkan',
                  style: TextStyle(fontSize: 9, color: AdminColors.muted)),
            ]),
            const SizedBox(height: 12),
            for (final t in _data) _TxCard(t),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA8E0E0))),
              child: const Row(children: [
                CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF9EEFF0),
                    child: Icon(Icons.check, size: 16, color: AdminColors.teal)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('TARIF RESMI BANK SAMPAH RUPAH',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.teal)),
                    Text(
                        '🌿 Organik: Rp 3.000/Kg • ♻️ Anorganik: Rp 2.000/Kg • 🟠 B3: Rp 5.000/Kg',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ]);
}

class _TxCard extends StatelessWidget {
  final _Tx t;
  const _TxCard(this.t);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RincianPenghasilanScreen())),
        child: AdminCard(
          borderColor: t.ditolak ? const Color(0xFFF2B8B5) : null,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AdminInitial(t.inisial,
                  bg: t.inisialBg,
                  fg: t.ditolak ? AdminColors.danger : AdminColors.primary,
                  size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.kelas,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  AdminPill(t.tag, bg: t.tagBg, fg: t.tagFg, size: 10),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.access_time, size: 12, color: AdminColors.muted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(t.waktu, style: const TextStyle(fontSize: 10))),
                  ]),
                ]),
              ),
              t.ditolak
                  ? const AdminPill('Ditolak',
                      bg: AdminColors.dangerBg,
                      fg: AdminColors.danger,
                      icon: Icons.cancel,
                      size: 10)
                  : const AdminPill('Terverifikasi',
                      bg: AdminColors.primaryLight,
                      fg: AdminColors.primary,
                      icon: Icons.check_circle,
                      size: 10),
            ]),
            if (t.ditolak) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AdminColors.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF2B8B5))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.error_outline, size: 14, color: AdminColors.danger),
                    SizedBox(width: 6),
                    Text('Alasan Penolakan:',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AdminColors.danger)),
                  ]),
                  const SizedBox(height: 4),
                  Text(t.alasan,
                      style: const TextStyle(fontSize: 10, color: AdminColors.danger)),
                ]),
              ),
            ],
            const Divider(height: 22),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.hourglass_top, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(t.deskripsi,
                            style: TextStyle(
                                fontSize: 12,
                                decoration:
                                    t.ditolak ? TextDecoration.lineThrough : null))),
                  ]),
                  Text('Verifikator: ${t.verifikator}',
                      style: const TextStyle(fontSize: 10, color: AdminColors.muted)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Nilai Kas', style: TextStyle(fontSize: 9)),
                Text(t.nilai,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: t.ditolak ? AdminColors.danger : AdminColors.primary)),
              ]),
            ]),
          ]),
        ),
      );
}
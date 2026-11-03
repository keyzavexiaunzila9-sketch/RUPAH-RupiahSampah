import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'tolak_setoran_screen.dart';

class DetailVerifikasiScreen extends StatefulWidget {
  final String nama;
  final String kelas;
  final String tanggal;
  final String kategori;
  final String namaSampah;
  final double berat;
  final double beratTimbang;
  final String estimasi;
  final String nomorSetoran;
  final Uint8List? fotoSetoran;
  final Uint8List? fotoTimbangan;

  const DetailVerifikasiScreen({
    super.key,
    this.nama = 'Dimas Pratama',
    this.kelas = 'XI RPL 1',
    this.tanggal = '28 Oktober 2026',
    this.kategori = 'Anorganik Campuran Plastik & Kardus',
    this.namaSampah = 'Botol PET Bening (Grade A)',
    this.berat = 8.5,
    this.beratTimbang = 5.2,
    this.estimasi = 'Rp 17.000',
    this.nomorSetoran = 'RPH-2026-001',
    this.fotoSetoran,
    this.fotoTimbangan,
  });

  @override
  State<DetailVerifikasiScreen> createState() =>
      _DetailVerifikasiScreenState();
}

class _DetailVerifikasiScreenState
    extends State<DetailVerifikasiScreen> {
  static const green = Color(0xFF087A4F);
  static const darkGreen = Color(0xFF006B43);
  static const background = Color(0xFFF5F7FC);
  static const ink = Color(0xFF26352F);
  static const muted = Color(0xFF78857F);
  static const border = Color(0xFFE8EDF2);
  static const orange = Color(0xFFE59A26);
  static const red = Color(0xFFD93636);

  final List<bool> auditChecks = [
    true,
    false,
    true,
    false,
    false,
  ];

  final TextEditingController catatanController =
      TextEditingController(
    text: 'Ditemukan beberapa bagian plastik yang perlu diperiksa '
        'lebih lanjut. Pastikan berat sesuai dengan kondisi sampah.',
  );

  int selectedDecision = 1;

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> konfirmasiKeputusan(bool diterima) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          diterima ? 'Setujui Setoran?' : 'Tolak Setoran?',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          diterima
              ? 'Setoran akan disetujui dan saldo kelas akan dicairkan.'
              : 'Setoran ini akan ditolak berdasarkan hasil pemeriksaan.',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontSize: 12),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: diterima ? green : red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              diterima ? 'Setujui' : 'Tolak',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );

    if (hasil == true && mounted) {
      showMessage(
        diterima
            ? 'Setoran berhasil disetujui.'
            : 'Setoran berhasil ditolak.',
      );
    }
  }

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit & Verifikasi Setoran',
              style: TextStyle(
                color: green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PEMERIKSAAN DATA SETORAN',
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _warningCard(),

            const SizedBox(height: 12),

            _identitasCard(),

            const SizedBox(height: 12),

            _auditCard(),

            const SizedBox(height: 12),

            _decisionCard(),

            const SizedBox(height: 12),

            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  // PERINGATAN
  Widget _warningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFFE2A0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: orange,
            size: 21,
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sedang Diperiksa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9A6412),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Periksa kesesuaian data setoran, foto bukti, '
                  'dan hasil penimbangan sebelum memberikan keputusan.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF80652F),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDC3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PRIORITAS',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9A6412),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // IDENTITAS DAN BUKTI SETORAN
  Widget _identitasCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: green,
                size: 15,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'IDENTITAS PENYETOR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),
              ),
              _pill('Data Sesuai', green),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            widget.nama,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            'ID Setoran: ${widget.nomorSetoran}',
            style: const TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.groups_rounded,
                    'KELAS PENYETOR',
                    widget.kelas,
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.calendar_month_rounded,
                    'WAKTU SETORAN',
                    widget.tanggal,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _infoItem(
            Icons.recycling_rounded,
            'KATEGORI',
            widget.kategori,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _weightBox(
                  title: 'BERAT AWAL',
                  weight: widget.berat,
                  subtitle: 'Estimasi ${widget.estimasi}',
                  isError: false,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _weightBox(
                  title: 'TIMBANGAN ADMIN',
                  weight: widget.beratTimbang,
                  subtitle: 'Selisih ${(widget.berat - widget.beratTimbang).abs().toStringAsFixed(1)} Kg',
                  isError: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _sectionTitle(
            Icons.photo_library_outlined,
            'PERBANDINGAN FOTO SETORAN',
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _photoBox(
                  title: 'Foto Penyetor',
                  bytes: widget.fotoSetoran,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _photoBox(
                  title: 'Foto Timbangan Admin',
                  bytes: widget.fotoTimbangan,
                  isAdmin: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // INFORMASI
  Widget _infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: green),
        const SizedBox(width: 6),
        Expanded(
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
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // KOTAK BERAT
  Widget _weightBox({
    required String title,
    required double weight,
    required String subtitle,
    required bool isError,
  }) {
    final color = isError ? red : green;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFFF3F2)
            : const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isError
              ? const Color(0xFFFFC8C5)
              : const Color(0xFFDCE6F5),
        ),
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
          const SizedBox(height: 5),
          Text(
            '${weight.toStringAsFixed(1)} Kg',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // FOTO BUKTI
  Widget _photoBox({
    required String title,
    Uint8List? bytes,
    bool isAdmin = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 105,
            width: double.infinity,
            color: const Color(0xFFE6EEFF),
            child: bytes != null
                ? Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isAdmin
                            ? Icons.add_a_photo_outlined
                            : Icons.image_outlined,
                        size: 25,
                        color: muted,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isAdmin
                            ? 'Foto belum tersedia'
                            : 'Bukti penyetor',
                        style: const TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: muted,
          ),
        ),
      ],
    );
  }

  // AUDIT
  Widget _auditCard() {
    final auditTitles = [
      'Berat Timbangan Tidak Sesuai',
      'Foto Bukti Tidak Sesuai / Duplikasi',
      'Sampah Bersih, Aman, dan Terpilah',
      'Data Setoran Tidak Cocok',
      'Indikasi Pelanggaran Berulang',
    ];

    final auditDescriptions = [
      'Periksa perbedaan berat antara penyetor dan hasil timbang admin.',
      'Pastikan foto merupakan bukti asli dan bukan hasil duplikasi.',
      'Pastikan sampah tidak tercampur bahan berbahaya.',
      'Cocokkan kategori, tanggal, dan data setoran.',
      'Periksa kemungkinan kecurangan atau manipulasi data.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD879),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Investigasi & Audit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
              ),
              _pill('Perlu Pemeriksaan', orange),
            ],
          ),

          const Divider(height: 18),

          const Text(
            'Kategori Indikasi Masalah:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),

          const SizedBox(height: 8),

          ...List.generate(auditTitles.length, (index) {
            return _auditItem(
              index: index,
              title: auditTitles[index],
              description: auditDescriptions[index],
            );
          }),

          const SizedBox(height: 12),

          const Text(
            'Foto Bukti Pendukung Tambahan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),

          const SizedBox(height: 7),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD6E2DD),
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 26,
                  color: Color(0xFF6BC9C1),
                ),
                SizedBox(height: 5),
                Text(
                  'Belum ada foto tambahan',
                  style: TextStyle(
                    fontSize: 12,
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Bukti tambahan dapat digunakan untuk '
                  'memperkuat hasil pemeriksaan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Catatan Pemeriksaan Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
              ),
              const Text(
                'Wajib diperiksa',
                style: TextStyle(
                  fontSize: 12,
                  color: green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          TextField(
            controller: catatanController,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 12,
              color: ink,
            ),
            decoration: InputDecoration(
              hintText: 'Tulis hasil pemeriksaan...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFC),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: border),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFFDDF3E7),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 17,
                    color: green,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auditor Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      Text(
                        'Petugas Verifikasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Terverifikasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditItem({
    required int index,
    required String title,
    required String description,
  }) {
    final checked = auditChecks[index];

    return InkWell(
      onTap: () {
        setState(() {
          auditChecks[index] = !auditChecks[index];
        });
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: checked
              ? const Color(0xFFF0F8F4)
              : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: checked
                ? const Color(0xFFB9DCCB)
                : border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 17,
              color: checked ? green : muted,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: muted,
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

  // KEPUTUSAN AKHIR
  Widget _decisionCard() {
    final decisions = [
      {
        'title': 'Terlalu Lebih / Salah Timbang',
        'subtitle': 'Periksa kembali hasil penimbangan sebelum menyetujui.',
        'status': 'PERIKSA ULANG',
        'color': orange,
      },
      {
        'title': 'Tolak Setoran / Pelanggaran',
        'subtitle': 'Setoran ditolak karena tidak sesuai dengan ketentuan.',
        'status': 'TOLAK',
        'color': red,
      },
      {
        'title': 'Verifikasi Diterima / Bukan Kecurangan',
        'subtitle': 'Setoran disetujui dan saldo kelas dapat dicairkan.',
        'status': 'DISETUJUI',
        'color': green,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Putusan Hasil Akhir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih keputusan berdasarkan hasil pemeriksaan.',
            style: TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
          const SizedBox(height: 10),

          ...List.generate(decisions.length, (index) {
            final item = decisions[index];
            final selected = selectedDecision == index;
            final color = item['color'] as Color;

            return InkWell(
              onTap: () {
                setState(() {
                  selectedDecision = index;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.07)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color : border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected ? color : muted,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    _pill(
                      item['status'] as String,
                      color,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // TOMBOL BAWAH
  Widget _bottomButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () => konfirmasiKeputusan(false),
              icon: const Icon(
                Icons.cancel_outlined,
                size: 15,
              ),
              label: const Text(
                'Tolak Setoran',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () {
                if (selectedDecision == 1) {
                  konfirmasiKeputusan(false);
                } else if (selectedDecision == 2) {
                  konfirmasiKeputusan(true);
                } else {
                  showMessage(
                    'Periksa kembali hasil penimbangan terlebih dahulu.',
                  );
                }
              },
              icon: const Icon(
                Icons.verified_rounded,
                size: 15,
              ),
              label: const Text(
                'Setujui & Cairkan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 15, color: green),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
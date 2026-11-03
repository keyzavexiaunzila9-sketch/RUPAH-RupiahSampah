import 'package:flutter/material.dart';

class TolakSetoranScreen extends StatefulWidget {
  final String nama;
  final String kelas;
  final String jenisSampah;
  final String berat;
  final String nilaiKas;

  const TolakSetoranScreen({
    super.key,
    this.nama = 'Dimas Pratama',
    this.kelas = 'XI RPL 1',
    this.jenisSampah = 'Botol PET Bening',
    this.berat = '5,0 Kg',
    this.nilaiKas = 'Rp 15.000',
  });

  @override
  State<TolakSetoranScreen> createState() =>
      _TolakSetoranScreenState();
}

class _TolakSetoranScreenState extends State<TolakSetoranScreen> {
  static const red = Color(0xFFBE171B);
  static const darkRed = Color(0xFFA91419);
  static const green = Color(0xFF087A50);
  static const background = Color(0xFFF5F7FC);
  static const ink = Color(0xFF26352F);
  static const muted = Color(0xFF84908B);
  static const border = Color(0xFFE9EDF2);

  final TextEditingController uraianController =
      TextEditingController();

  int? selectedReason;
  bool selectedAction1 = true;
  bool selectedAction2 = false;

  final List<Map<String, dynamic>> reasons = [
    {
      'icon': Icons.cancel_outlined,
      'title': 'Kondisi Sampah Tidak Layak',
      'description':
          'Sampah terlalu kotor, basah, atau bercampur dengan material yang tidak sesuai.',
    },
    {
      'icon': Icons.scale_outlined,
      'title': 'Perbedaan Berat Signifikan',
      'description':
          'Berat sampah yang ditimbang tidak sesuai dengan data yang dilaporkan.',
    },
    {
      'icon': Icons.eco_outlined,
      'title': 'Pemilahan Tidak Sesuai',
      'description':
          'Sampah tercampur dengan jenis lain dan tidak sesuai kategori yang dipilih.',
    },
    {
      'icon': Icons.image_outlined,
      'title': 'Foto Bukti Tidak Valid',
      'description':
          'Foto bukti tidak jelas, tidak sesuai, atau tidak menampilkan kondisi sampah.',
    },
    {
      'icon': Icons.warning_amber_rounded,
      'title': 'Indikasi Manipulasi / Kecurangan',
      'description':
          'Ditemukan indikasi data yang tidak sesuai atau manipulasi selama proses penyetoran.',
    },
    {
      'icon': Icons.school_outlined,
      'title': 'Lainnya / Kebijakan Sekolah',
      'description':
          'Setoran tidak memenuhi ketentuan atau kebijakan lingkungan sekolah.',
    },
  ];

  @override
  void dispose() {
    uraianController.dispose();
    super.dispose();
  }

  void kirimPenolakan() {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih alasan penolakan terlebih dahulu.'),
        ),
      );
      return;
    }

    if (uraianController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uraian alasan wajib diisi.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          title: const Text(
            'Konfirmasi Penolakan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menolak setoran ${widget.nama}?',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Penolakan setoran berhasil diproses.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Ya, Tolak',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF0FF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: ink,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FORM PENOLAKAN',
              style: TextStyle(
                fontSize: 12,
                color: red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tolak Setoran',
              style: TextStyle(
                fontSize: 14,
                color: ink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.verified_user_outlined,
              color: green,
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _identityCard(),

            const SizedBox(height: 12),

            _warningCard(),

            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kategori Alasan Penolakan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                ),
                Text(
                  '* Pilih 1 kategori',
                  style: TextStyle(
                    fontSize: 12,
                    color: red.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...List.generate(
              reasons.length,
              (index) => _reasonCard(index),
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: Text(
                    'Uraian Alasan & Edukasi untuk Siswa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                ),
                Text(
                  '* WAJIB',
                  style: TextStyle(
                    fontSize: 12,
                    color: red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            _uraianCard(),

            const SizedBox(height: 12),

            _followUpCard(),

            const SizedBox(height: 12),

            _adminCard(),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 43,
              child: ElevatedButton.icon(
                onPressed: kirimPenolakan,
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 15,
                ),
                label: const Text(
                  'Tolak & Kirim Notifikasi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 9),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal / Kembali ke Verifikasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IDENTITAS PENYETOR
  Widget _identityCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENOLAKAN SETORAN',
                  style: TextStyle(
                    fontSize: 12,
                    color: red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.recycling_rounded,
                color: green,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            widget.nama,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),

          const SizedBox(height: 3),

          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 12,
                color: green,
              ),
              const SizedBox(width: 4),
              Text(
                widget.kelas,
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                '•',
                style: TextStyle(color: muted),
              ),
              const SizedBox(width: 7),
              const Text(
                'Bank Sampah Sekolah',
                style: TextStyle(
                  fontSize: 12,
                  color: green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _identityInfo(
                  'Kategori Sampah',
                  widget.jenisSampah,
                  widget.berat,
                  const Color(0xFFEAF1FF),
                  const Color(0xFF3769B0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _identityInfo(
                  'Nilai Kas Terestimasi',
                  widget.nilaiKas,
                  'Potensi saldo kelas',
                  const Color(0xFFFFEEEE),
                  red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _identityInfo(
    String title,
    String value,
    String subtitle,
    Color color,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
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
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
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

  // PERINGATAN
  Widget _warningCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E9),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFFD995),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD88A19),
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prinsip Verifikasi Objektif Lapangan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9B6414),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Penolakan dilakukan berdasarkan pemeriksaan '
                  'fisik dan bukti setoran. Admin wajib memberikan '
                  'alasan yang jelas agar siswa memahami kesalahan '
                  'dan dapat memperbaikinya pada penyetoran berikutnya.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF806B4B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PILIHAN ALASAN
  Widget _reasonCard(int index) {
    final item = reasons[index];
    final selected = selectedReason == index;

    return InkWell(
      onTap: () {
        setState(() => selectedReason = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF0F0)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? red : border,
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? red : const Color(0xFFB8C7C0),
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 14,
                        color: selected ? red : muted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selected ? red : ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
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

  // URAIAN ALASAN
  Widget _uraianCard() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: uraianController,
            maxLines: 5,
            minLines: 4,
            maxLength: 500,
            style: const TextStyle(
              fontSize: 12,
              color: ink,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText:
                  'Jelaskan alasan penolakan secara detail, '
                  'misalnya kondisi sampah, berat, atau bukti '
                  'yang tidak sesuai. Berikan arahan agar siswa '
                  'dapat memperbaikinya.',
              hintStyle: TextStyle(
                fontSize: 12,
                color: muted,
                height: 1.4,
              ),
              border: InputBorder.none,
              counterStyle: TextStyle(fontSize: 12),
            ),
          ),
          const Divider(height: 12),
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: green,
                size: 14,
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Tips: Gunakan bahasa yang sopan dan edukatif.',
                  style: TextStyle(
                    fontSize: 12,
                    color: green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // OPSI TINDAK LANJUT
  Widget _followUpCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: green,
                size: 17,
              ),
              SizedBox(width: 7),
              Text(
                'Opsi Tindakan Lanjutan Bagi Siswa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _actionOption(
            value: selectedAction1,
            onChanged: (value) {
              setState(() => selectedAction1 = value ?? false);
            },
            title: 'Lakukan pemilahan ulang setelah diperbaiki',
            description:
                'Siswa dapat memperbaiki kondisi sampah dan '
                'mengirimkan ulang setoran.',
          ),

          const Divider(height: 12),

          _actionOption(
            value: selectedAction2,
            onChanged: (value) {
              setState(() => selectedAction2 = value ?? false);
            },
            title: 'Beri catatan teguran edukatif ke wali kelas',
            description:
                'Kirimkan informasi kepada wali kelas sebagai '
                'bahan pembinaan apabila diperlukan.',
          ),
        ],
      ),
    );
  }

  Widget _actionOption({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: green,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // INFORMASI ADMIN
  Widget _adminCard() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFD2E9DF),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFFD2E9DF),
            child: Text(
              'AD',
              style: TextStyle(
                fontSize: 12,
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bu Sugiyanti',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                Text(
                  'Admin • Penanggung Jawab',
                  style: TextStyle(
                    fontSize: 12,
                    color: green,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Admin Verifikasi',
            style: TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}
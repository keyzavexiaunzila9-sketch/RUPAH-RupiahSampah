import 'package:flutter/material.dart';

class FormSampahScreen extends StatefulWidget {
  const FormSampahScreen({super.key});

  @override
  State<FormSampahScreen> createState() =>
      _FormSampahScreenState();
}

class _FormSampahScreenState extends State<FormSampahScreen> {
  static const green = Color(0xFF087A4F);
  static const darkGreen = Color(0xFF006B43);
  static const background = Color(0xFFF5F7FC);
  static const ink = Color(0xFF26352F);
  static const muted = Color(0xFF78857F);
  static const border = Color(0xFFE8EDF2);

  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();

  String kategori = 'Anorganik';

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  void simpanData() {
    if (!formKey.currentState!.validate()) return;

    final dataSampah = {
      'nama': namaController.text.trim(),
      'kategori': kategori,
      'harga': int.parse(hargaController.text),
      'deskripsi': deskripsiController.text.trim(),
    };

    Navigator.pop(context, dataSampah);
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
            color: ink,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Data Sampah',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            Text(
              'BANK SAMPAH DIGITAL',
              style: TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            // INFORMASI
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F6ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFC5E9D5),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.recycling_rounded,
                    color: green,
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Jenis Sampah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Masukkan informasi jenis sampah dan '
                          'harga agar dapat digunakan dalam transaksi.',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // NAMA SAMPAH
            _label('Nama Sampah'),
            TextFormField(
              controller: namaController,
              style: const TextStyle(fontSize: 12, color: ink),
              decoration: _decoration(
                'Contoh: Botol Plastik PET',
                Icons.delete_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama sampah wajib diisi.';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            // KATEGORI
            _label('Kategori Sampah'),
            DropdownButtonFormField<String>(
              value: kategori,
              style: const TextStyle(
                fontSize: 12,
                color: ink,
              ),
              decoration: _decoration(
                'Pilih kategori',
                Icons.category_outlined,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Organik',
                  child: Text('Organik'),
                ),
                DropdownMenuItem(
                  value: 'Anorganik',
                  child: Text('Anorganik'),
                ),
                DropdownMenuItem(
                  value: 'B3',
                  child: Text('B3 (Bahan Berbahaya dan Beracun)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => kategori = value);
                }
              },
            ),

            const SizedBox(height: 15),

            // HARGA
            _label('Harga Sampah per Kg'),
            TextFormField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12, color: ink),
              decoration: _decoration(
                'Contoh: 3000',
                Icons.payments_outlined,
                prefix: 'Rp ',
              ),
              validator: (value) {
                final harga = int.tryParse(value ?? '');
                if (harga == null || harga <= 0) {
                  return 'Masukkan harga yang valid.';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            // DESKRIPSI
            _label('Deskripsi Sampah'),
            TextFormField(
              controller: deskripsiController,
              maxLines: 4,
              style: const TextStyle(fontSize: 12, color: ink),
              decoration: _decoration(
                'Masukkan keterangan atau kondisi sampah...',
                Icons.description_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi sampah wajib diisi.';
                }
                return null;
              },
            ),

            const SizedBox(height: 22),

            // TOMBOL SIMPAN
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: simpanData,
                icon: const Icon(
                  Icons.save_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Simpan Data Sampah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: ink,
        ),
      ),
    );
  }

  InputDecoration _decoration(
    String hint,
    IconData icon, {
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixIcon: Icon(
        icon,
        size: 18,
        color: muted,
      ),
      hintStyle: const TextStyle(
        fontSize: 12,
        color: muted,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: green, width: 1.3),
      ),
    );
  }
}
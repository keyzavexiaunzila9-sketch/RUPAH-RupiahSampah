import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/rupah_widgets.dart';
import 'status_setor_screen.dart';

class FormSetorSampahScreen extends StatefulWidget {
  const FormSetorSampahScreen({super.key});

  @override
  State<FormSetorSampahScreen> createState() =>
      _FormSetorSampahScreenState();
}

class _FormSetorSampahScreenState
    extends State<FormSetorSampahScreen> {
  final formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final nameController = TextEditingController(
    text: 'Botol Plastik PET Bening Bersih',
  );
  final picker = ImagePicker();

  String selectedCategory = 'Anorganik';
  DateTime selectedDate = DateTime(2026, 9, 11);
  double weight = 5;
  Uint8List? photoBytes;
  bool isPickingPhoto = false;

  static const green = Color(0xFF218D79);
  static const darkGreen = Color(0xFF258A59);
  static const background = Color(0xFFF5F8F7);
  static const ink = Color(0xFF26352F);
  static const muted = Color(0xFF84908B);
  static const border = Color(0xFFE6ECE9);

  int get pricePerKg {
    switch (selectedCategory) {
      case 'Organik':
        return 3000;
      case 'Anorganik':
        return 2000;
      case 'B3':
        return 5000;
      default:
        return 2000;
    }
  }

  String get formattedDate {
    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${selectedDate.day} ${months[selectedDate.month - 1]} '
        '${selectedDate.year}';
  }

  @override
  void dispose() {
    noteController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> ambilFotoLangsung() async {
    if (isPickingPhoto) return;

    setState(() => isPickingPhoto = true);

    try {
      final foto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );

      if (foto == null || !mounted) return;

      final bytes = await foto.readAsBytes();

      if (!mounted) return;

      if (bytes.length > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran foto maksimal 5 MB.'),
          ),
        );
        return;
      }

      setState(() => photoBytes = bytes);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kamera tidak tersedia. Periksa izin kamera perangkat.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isPickingPhoto = false);
      }
    }
  }

  Future<void> pilihTanggal() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      setState(() => selectedDate = date);
    }
  }

  void kirimSetoran() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ambil foto bukti setoran terlebih dahulu.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StatusSetorScreen(
          category: selectedCategory,
          weight: weight,
          note: noteController.text.trim(),
          photoBytes: photoBytes,
        ),
      ),
    );
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
            size: 20,
            color: ink,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Setor Sampah',
              style: RupahTheme.heading(
                size: 15,
                color: darkGreen,
              ),
            ),
            const Text(
              'BANK SAMPAH DIGITAL',
              style: TextStyle(
                fontSize: 8,
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
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
          children: [
            // Informasi
            _card(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: Color(0xFFDDF5E8),
                    child: Icon(
                      Icons.eco_rounded,
                      color: darkGreen,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubah Sampah Jadi Berkah Kelas!',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Pastikan sampah dipilah dengan benar dan '
                          'difoto jelas untuk mempermudah verifikasi petugas.',
                          style: TextStyle(
                            fontSize: 8,
                            height: 1.4,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Kelas penyetor
            _label('Kelas Penyetor'),
            _card(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              child: const Row(
                children: [
                  Icon(Icons.groups_rounded, color: darkGreen, size: 17),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kelas XI RPL 1',
                      style: TextStyle(fontSize: 10, color: ink),
                    ),
                  ),
                  Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: darkGreen,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Nama sampah
            _label('Nama Sampah'),
            TextFormField(
              controller: nameController,
              style: const TextStyle(fontSize: 10),
              decoration: _inputDecoration(
                hint: 'Masukkan nama sampah',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama sampah harus diisi.';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Kategori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Kategori Sampah'),
                const Text(
                  'Pilih salah satu',
                  style: TextStyle(fontSize: 7, color: muted),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _categoryCard(
                    'Organik',
                    Icons.eco_outlined,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _categoryCard(
                    'Anorganik',
                    Icons.recycling_rounded,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _categoryCard(
                    'B3',
                    Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Berat
            _label('Berat Sampah'),
            _card(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _weightButton(
                        icon: Icons.remove,
                        onTap: weight <= 1
                            ? null
                            : () => setState(() => weight -= 0.5),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weight.toStringAsFixed(
                                weight % 1 == 0 ? 0 : 1,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: darkGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'Kg',
                              style: TextStyle(fontSize: 8, color: ink),
                            ),
                          ],
                        ),
                      ),
                      _weightButton(
                        icon: Icons.add,
                        onTap: () => setState(() => weight += 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.price_check_rounded,
                          color: green,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        const Expanded(
                          child: Text(
                            'Estimasi Reward:',
                            style: TextStyle(
                              fontSize: 8,
                              color: ink,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+Rp ${(pricePerKg * weight).round()}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: darkGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '(Rp $pricePerKg/Kg)',
                              style: const TextStyle(
                                fontSize: 7,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Foto bukti
            _label('Upload Foto Bukti Sampah'),
            InkWell(
              onTap: isPickingPhoto ? null : ambilFotoLangsung,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 145,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFB7DCCD),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FA),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFFA7D3BF),
                    ),
                  ),
                  child: isPickingPhoto
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : photoBytes != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.memory(
                                    photoBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 6,
                                  bottom: 6,
                                  child: FilledButton.icon(
                                    onPressed: ambilFotoLangsung,
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 12,
                                    ),
                                    label: const Text(
                                      'Ganti Foto',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: ink,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 25,
                                  color: muted,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'FOTO TERVERIFIKASI',
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: darkGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Ambil foto sampah dan timbangan',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: ink,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Pastikan label terlihat dan kondisi sampah '
                                  'bersih dari sisa cairan.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tanggal
            _label('Tanggal Setor'),
            InkWell(
              onTap: pilihTanggal,
              borderRadius: BorderRadius.circular(9),
              child: _card(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 9,
                          color: ink,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: muted,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Catatan
            _label('Catatan Tambahan'),
            TextFormField(
              controller: noteController,
              maxLines: 2,
              style: const TextStyle(fontSize: 9),
              decoration: _inputDecoration(
                hint: 'Tulis kondisi barang dan informasi tambahan.',
              ),
            ),

            const SizedBox(height: 16),

            // Kirim
            SizedBox(
              height: 43,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4EA9A5), Color(0xFF288B5C)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ElevatedButton.icon(
                  onPressed: kirimSetoran,
                  icon: const Icon(Icons.send_rounded, size: 13),
                  label: const Text(
                    'Kirim Setoran',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
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
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: ink,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _categoryCard(String category, IconData icon) {
    final selected = selectedCategory == category;

    return InkWell(
      onTap: () => setState(() => selectedCategory = category),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF8F0) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? darkGreen : border,
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? darkGreen : muted,
            ),
            const SizedBox(height: 3),
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: selected ? darkGreen : ink,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weightButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.grey : darkGreen,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 9,
        color: muted,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: green),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> daftarSampah = [];
  Map<String, dynamic>? selectedSampah;

  String namaKelas = 'Memuat kelas...';
  String? errorMemuat;

  DateTime selectedDate = DateTime.now();
  double weight = 5;
  Uint8List? photoBytes;

  bool isPickingPhoto = false;
  bool isLoadingData = true;
  bool isSaving = false;

  static const green = Color(0xFF218D79);
  static const darkGreen = Color(0xFF258A59);
  static const background = Color(0xFFF5F8F7);
  static const ink = Color(0xFF26352F);
  static const muted = Color(0xFF84908B);
  static const border = Color(0xFFE6ECE9);

  int get pricePerKg {
    final harga = selectedSampah?['harga_per_kg'];
    return harga is num ? harga.round() : 0;
  }

  int get estimasiNilai => (pricePerKg * weight).round();

  String get formattedDate {
    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${selectedDate.day} '
        '${months[selectedDate.month - 1]} '
        '${selectedDate.year}';
  }

  @override
  void initState() {
    super.initState();
    muatDataAwal();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  // ==========================================
  // MEMUAT DATA SAMPAH DAN KELAS
  // ==========================================

  Future<void> muatDataAwal() async {
    setState(() {
      isLoadingData = true;
      errorMemuat = null;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Akun belum login. Silakan login kembali.');
      }

      // Mengambil sampah yang statusnya aktif.
      final responseSampah = await supabase
          .from('sampah')
          .select(
            'id_sampah, nama_sampah, kategori, harga_per_kg, satuan',
          )
          .eq('status', true)
          .order('nama_sampah');

      final sampah =
          List<Map<String, dynamic>>.from(responseSampah);

      // Mengambil kelas milik user yang sedang login.
      final responseUser = await supabase
          .from('users')
          .select('id_kelas')
          .eq('id_user', user.id)
          .maybeSingle();

      String kelas = 'Kelas belum terdaftar';

      if (responseUser != null &&
          responseUser['id_kelas'] != null) {
        final responseKelas = await supabase
            .from('kelas')
            .select('nama_kelas')
            .eq('id_kelas', responseUser['id_kelas'])
            .maybeSingle();

        kelas = responseKelas?['nama_kelas'] ?? kelas;
      }

      if (!mounted) return;

      setState(() {
        daftarSampah = sampah;
        selectedSampah = sampah.isNotEmpty ? sampah.first : null;
        namaKelas = kelas;
        isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingData = false;
        errorMemuat = e.toString();
      });
    }
  }

  // ==========================================
  // MENGAMBIL FOTO
  // ==========================================

  Future<void> ambilFotoLangsung() async {
    if (isPickingPhoto || isSaving) return;

    setState(() => isPickingPhoto = true);

    try {
      final foto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );

      if (foto == null || !mounted) return;

      final bytes = await foto.readAsBytes();

      if (bytes.length > 5 * 1024 * 1024) {
        tampilkanPesan('Ukuran foto maksimal 5 MB.');
        return;
      }

      setState(() {
        photoBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      tampilkanPesan(
        'Kamera tidak tersedia. Periksa izin kamera perangkat.',
      );
    } finally {
      if (mounted) {
        setState(() => isPickingPhoto = false);
      }
    }
  }

  // ==========================================
  // MEMILIH TANGGAL
  // ==========================================

  Future<void> pilihTanggal() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // ==========================================
  // MENYIMPAN SETORAN
  // ==========================================

  Future<void> kirimSetoran() async {
    if (isSaving) return;

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (selectedSampah == null) {
      tampilkanPesan('Pilih jenis sampah terlebih dahulu.');
      return;
    }

    if (photoBytes == null) {
      tampilkanPesan('Ambil foto bukti setoran terlebih dahulu.');
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      tampilkanPesan('Sesi login tidak ditemukan. Silakan login ulang.');
      return;
    }

    if (pricePerKg <= 0) {
      tampilkanPesan('Harga sampah belum tersedia.');
      return;
    }

    setState(() => isSaving = true);

    final uid = user.id;
    final waktu = DateTime.now().microsecondsSinceEpoch;
    final fotoPath = '$uid/setoran_$waktu.jpg';

    int? idSetoran;
    bool fotoTerunggah = false;

    try {
      // 1. Upload foto ke Storage.
      await supabase.storage
          .from('bukti-setoran')
          .uploadBinary(
            fotoPath,
            photoBytes!,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      fotoTerunggah = true;

      // 2. Simpan data utama ke tabel setoran.
      final hasilSetoran = await supabase
          .from('setoran')
          .insert({
            'id_user': uid,
            'tanggal': DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
            ).toUtc().toIso8601String(),
            'status': 'menunggu',
            'total_berat': weight,
            'total_nilai': estimasiNilai,
            'catatan': noteController.text.trim().isEmpty
                ? null
                : noteController.text.trim(),
            'foto_url': fotoPath,
          })
          .select('id_setoran')
          .single();

      idSetoran = (hasilSetoran['id_setoran'] as num).toInt();

      // 3. Simpan detail dan hubungkan dengan setoran.
      await supabase.from('detail_setoran').insert({
        'id_setoran': idSetoran,
        'id_sampah': selectedSampah!['id_sampah'],
        'berat_kg': weight,
      });

      if (!mounted) return;

      // 4. Pindah ke halaman status dengan membawa ID setoran.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StatusSetorScreen(
            idSetoran: idSetoran!,
            category: selectedSampah!['kategori'].toString(),
            weight: weight,
            note: noteController.text.trim(),
            photoBytes: photoBytes,
          ),
        ),
      );
    } catch (e) {
      // Membersihkan data jika penyimpanan detail gagal.
      try {
        if (idSetoran != null) {
          await supabase
              .from('setoran')
              .delete()
              .eq('id_setoran', idSetoran);
        }

        if (fotoTerunggah) {
          await supabase.storage
              .from('bukti-setoran')
              .remove([fotoPath]);
        }
      } catch (_) {
        // Jika pembersihan ditolak RLS, error utama tetap ditampilkan.
      }

      if (!mounted) return;

      tampilkanPesan('Gagal menyimpan setoran: $e');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // ==========================================
  // TAMPILAN UTAMA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
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
                size: 14,
                color: darkGreen,
              ),
            ),
            const Text(
              'BANK SAMPAH DIGITAL',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : errorMemuat != null
              ? _tampilanError()
              : daftarSampah.isEmpty
                  ? _tampilanKosong()
                  : _tampilanForm(),
    );
  }

  Widget _tampilanError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 10),
            const Text(
              'Gagal memuat data.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMemuat!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: muted),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: muatDataAwal,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tampilanKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 45,
              color: muted,
            ),
            const SizedBox(height: 10),
            const Text(
              'Belum ada sampah aktif.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: muatDataAwal,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tampilanForm() {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
        children: [
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pastikan sampah dipilah dengan benar dan '
                        'difoto jelas untuk mempermudah verifikasi petugas.',
                        style: TextStyle(
                          fontSize: 12,
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

          _label('Kelas Penyetor'),
          _card(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  color: darkGreen,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    namaKelas,
                    style: const TextStyle(fontSize: 12, color: ink),
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  size: 15,
                  color: darkGreen,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _label('Nama Sampah'),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedSampah,
            isExpanded: true,
            decoration: _inputDecoration(
              hint: 'Pilih jenis sampah',
            ),
            items: daftarSampah.map((sampah) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: sampah,
                child: Text(
                  sampah['nama_sampah'].toString(),
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: isSaving
                ? null
                : (value) {
                    setState(() => selectedSampah = value);
                  },
            validator: (value) {
              if (value == null) {
                return 'Pilih jenis sampah.';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('Kategori Sampah'),
              const Text(
                'Mengikuti data sampah',
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
          _card(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 11,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.recycling_rounded,
                  color: darkGreen,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    selectedSampah?['kategori']?.toString() ?? '-',
                    style: const TextStyle(fontSize: 12, color: ink),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

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
                      onTap: weight <= 0.5 || isSaving
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
                              fontSize: 14,
                              color: darkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'Kg',
                            style: TextStyle(fontSize: 12, color: ink),
                          ),
                        ],
                      ),
                    ),
                    _weightButton(
                      icon: Icons.add,
                      onTap: isSaving
                          ? null
                          : () => setState(() => weight += 0.5),
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
                          style: TextStyle(fontSize: 12, color: ink),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+Rp ${estimasiNilai.toString()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: darkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '(Rp $pricePerKg/Kg)',
                            style: const TextStyle(
                              fontSize: 12,
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

          _label('Upload Foto Bukti Sampah'),
          InkWell(
            onTap: isPickingPhoto || isSaving
                ? null
                : ambilFotoLangsung,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 145,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFB7DCCD),
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
                                  onPressed: isSaving
                                      ? null
                                      : ambilFotoLangsung,
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 12,
                                  ),
                                  label: const Text(
                                    'Ganti Foto',
                                    style: TextStyle(fontSize: 12),
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
                                'FOTO BUKTI SETORAN',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: darkGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Ambil foto sampah dan timbangan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ink,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Pastikan label terlihat dan kondisi '
                                'sampah bersih.',
                                textAlign: TextAlign.center,
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

          const SizedBox(height: 12),

          _label('Tanggal Setor'),
          InkWell(
            onTap: isSaving ? null : pilihTanggal,
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
                      style: const TextStyle(fontSize: 12, color: ink),
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

          _label('Catatan Tambahan'),
          TextFormField(
            controller: noteController,
            maxLines: 2,
            enabled: !isSaving,
            style: const TextStyle(fontSize: 12),
            decoration: _inputDecoration(
              hint: 'Tulis kondisi barang dan informasi tambahan.',
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 43,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4EA9A5),
                    Color(0xFF288B5C),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : kirimSetoran,
                icon: isSaving
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 13),
                label: Text(
                  isSaving ? 'Menyimpan...' : 'Kirim Setoran',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
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
    );
  }

  // ==========================================
  // KOMPONEN TAMPILAN
  // ==========================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: ink,
          fontSize: 14,
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
      hintStyle: const TextStyle(fontSize: 12, color: muted),
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

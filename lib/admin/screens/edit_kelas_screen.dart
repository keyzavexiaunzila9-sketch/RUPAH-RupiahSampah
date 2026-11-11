
import 'package:flutter/material.dart';
import '../../core/services/kelas_service.dart';
import '../widgets/admin_widgets.dart';

class EditKelasScreen extends StatefulWidget {
  final int idKelas;
  final String namaKelas;
  final String jurusan;
  final String namaWaliKelas;

  const EditKelasScreen({
    super.key,
    required this.idKelas,
    required this.namaKelas,
    required this.jurusan,
    required this.namaWaliKelas,
  });

  @override
  State<EditKelasScreen> createState() => _EditKelasScreenState();
}

class _EditKelasScreenState extends State<EditKelasScreen> {
  final KelasService service = KelasService();

  final namaController = TextEditingController();
  final jurusanController = TextEditingController();
  final namaWaliKelasController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    namaController.text = widget.namaKelas;
    jurusanController.text = widget.jurusan;
    namaWaliKelasController.text = widget.namaWaliKelas;
  }

  @override
  void dispose() {
    namaController.dispose();
    jurusanController.dispose();
    namaWaliKelasController.dispose();
    super.dispose();
  }

  Future<void> simpanData() async {
    if (namaController.text.trim().isEmpty ||
        jurusanController.text.trim().isEmpty ||
        namaWaliKelasController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data wajib diisi.'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await service.updateKelas(
        idKelas: widget.idKelas,
        namaKelas: namaController.text.trim(),
        jurusan: jurusanController.text.trim(),
        namaWaliKelas: namaWaliKelasController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kelas berhasil diperbarui.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget field(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: adminBackBar(context, 'Edit Data Kelas'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Kelas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                field('Nama Kelas', namaController),
                field('Jurusan', jurusanController),
                field('Nama Wali Kelas', namaWaliKelasController),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminActionBar(
        saveLabel: 'Simpan Data Kelas',
        icon: Icons.check_circle_outline,
        onSave:simpanData,
      ),
    );
  }
}

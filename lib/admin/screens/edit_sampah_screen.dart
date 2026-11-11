
import 'package:flutter/material.dart';
import '../widgets/admin_widgets.dart';
import '../../core/services/sampah_service.dart';

class EditSampahScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditSampahScreen({
    super.key,
    required this.data,
  });

  @override
  State<EditSampahScreen> createState() => _EditSampahScreenState();
}

class _EditSampahScreenState extends State<EditSampahScreen> {
  final service = SampahService();

  late TextEditingController namaController;
  late TextEditingController kategoriController;
  late TextEditingController hargaController;
  late TextEditingController deskripsiController;

  bool status = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    namaController = TextEditingController(
      text: widget.data['nama_sampah']?.toString() ?? '',
    );

    kategoriController = TextEditingController(
      text: widget.data['kategori']?.toString() ?? '',
    );

    hargaController = TextEditingController(
      text: widget.data['harga_per_kg']?.toString() ?? '',
    );

    deskripsiController = TextEditingController(
      text: widget.data['deskripsi']?.toString() ?? '',
    );

    status = widget.data['status'] == true;
  }

  @override
  void dispose() {
    namaController.dispose();
    kategoriController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> simpanPerubahan() async {
    if (namaController.text.trim().isEmpty ||
        hargaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan tarif wajib diisi'),
        ),
      );
      return;
    }

    final harga = double.tryParse(
      hargaController.text.trim(),
    );

    if (harga == null || harga < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarif harus berupa angka yang valid'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await service.editSampah(
        id: widget.data['id_sampah'],
        nama: namaController.text.trim(),
        kategori: kategoriController.text.trim(),
        harga: harga,
        deskripsi: deskripsiController.text.trim(),
        status: status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sampah berhasil diperbarui'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah data: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: adminBackBar(context, 'Edit Data Sampah'),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // INFORMASI SAMPAH
          AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSection(
                  Icons.recycling,
                  'Informasi Sampah',
                ),

                const Text('Nama Sampah'),
                const SizedBox(height: 8),

                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan nama sampah',
                  ),
                ),

                const SizedBox(height: 16),

                const Text('Kategori'),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: [
                    'Organik',
                    'Anorganik',
                    'B3',
                  ].contains(kategoriController.text)
                      ? kategoriController.text
                      : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ['Organik', 'Anorganik', 'B3']
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      kategoriController.text = value;
                    }
                  },
                ),
              ],
            ),
          ),

          // TARIF SAMPAH
          AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSection(
                  Icons.payments_outlined,
                  'Tarif Sampah',
                ),

                const Text('Tarif per Kilogram (Kg)'),
                const SizedBox(height: 8),

                TextField(
                  controller: hargaController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                    suffixText: '/Kg',
                  ),
                ),
              ],
            ),
          ),

          // DESKRIPSI DAN STATUS
          AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSection(
                  Icons.notes,
                  'Keterangan & Status',
                ),

                const Text('Deskripsi Sampah'),
                const SizedBox(height: 8),

                TextField(
                  controller: deskripsiController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan deskripsi sampah',
                  ),
                ),

                const SizedBox(height: 16),

                const Text('Status Sampah'),
                const SizedBox(height: 8),

                DropdownButtonFormField<bool>(
                  value: status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<bool>(
                      value: true,
                      child: Text('AKTIF'),
                    ),
                    DropdownMenuItem<bool>(
                      value: false,
                      child: Text('NONAKTIF'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        status = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: AdminActionBar(
        saveLabel: isLoading
            ? 'Menyimpan...'
            : 'Simpan Perubahan',
        onSave: simpanPerubahan,
      ),
    );
  }
}

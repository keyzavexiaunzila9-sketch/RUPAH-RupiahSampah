
import 'package:flutter/material.dart';
import '../../core/services/kelas_service.dart';
import '../widgets/admin_widgets.dart';
import 'edit_kelas_screen.dart';
import 'form_kelas_screen.dart';

class DataKelasScreen extends StatefulWidget {
  const DataKelasScreen({super.key});

  @override
  State<DataKelasScreen> createState() => _DataKelasScreenState();
}

class _DataKelasScreenState extends State<DataKelasScreen> {
  final KelasService service = KelasService();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> dataKelas = [];
  bool loading = true;

  String kataKunci = '';
  String filterJurusan = 'Semua';
  String filterStatus = 'Semua';
  String urutanTanggal = 'Terbaru';

  int currentPage = 1;
  static const int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  DateTime tanggalData(dynamic value) {
    if (value == null) return DateTime(1970);
    return DateTime.tryParse(value.toString()) ?? DateTime(1970);
  }

  List<String> get daftarJurusan {
    final jurusan = dataKelas
        .map((kelas) => kelas['jurusan']?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    jurusan.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['Semua', ...jurusan];
  }

  List<Map<String, dynamic>> get kelasTersaring {
    final hasil = dataKelas.where((kelas) {
      final nama = kelas['nama_kelas']?.toString().toLowerCase() ?? '';
      final jurusan = kelas['jurusan']?.toString().toLowerCase() ?? '';
      final wali = kelas['nama_wali_kelas']?.toString().toLowerCase() ?? '';
      final username = kelas['username']?.toString().toLowerCase() ?? '';
      final status = kelas['status']?.toString().toLowerCase() ?? '';

      final cocokCari = nama.contains(kataKunci) ||
          jurusan.contains(kataKunci) ||
          wali.contains(kataKunci) ||
          username.contains(kataKunci);

      final cocokJurusan = filterJurusan == 'Semua' ||
          jurusan == filterJurusan.toLowerCase();

      final cocokStatus = filterStatus == 'Semua' ||
          status == filterStatus.toLowerCase();

      return cocokCari && cocokJurusan && cocokStatus;
    }).toList();

    hasil.sort((a, b) {
      final tanggalA = tanggalData(a['created_at']);
      final tanggalB = tanggalData(b['created_at']);

      return urutanTanggal == 'Terbaru'
          ? tanggalB.compareTo(tanggalA)
          : tanggalA.compareTo(tanggalB);
    });

    return hasil;
  }

  Future<void> ambilData() async {
    if (mounted) {
      setState(() => loading = true);
    }

    try {
      final data = await service.getKelas();

      if (!mounted) return;

      setState(() {
        dataKelas = data;
        loading = false;
        currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data kelas: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> hapusKelas(int idKelas) async {
    try {
      await service.hapusKelas(idKelas);
      await ambilData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kelas berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus kelas: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> tambahKelas() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormKelasScreen()),
    );

    if (mounted) await ambilData();
  }

  Future<void> editKelas(Map<String, dynamic> kelas) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditKelasScreen(
          idKelas: (kelas['id_kelas'] as num).toInt(),
          namaKelas: kelas['nama_kelas']?.toString() ?? '',
          jurusan: kelas['jurusan']?.toString() ?? '',
          namaWaliKelas: kelas['nama_wali_kelas']?.toString() ?? '',
        ),
      ),
    );

    if (mounted) await ambilData();
  }

  Widget dropdownFilter({
    required String label,
    required String value,
    required List<String> pilihan,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AdminColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AdminColors.border),
              ),
            ),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
            items: pilihan.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget pagination(int totalData, int totalPages) {
    final start = totalData == 0
        ? 0
        : ((currentPage - 1) * itemsPerPage) + 1;

    final end = (currentPage * itemsPerPage)
        .clamp(0, totalData)
        .toInt();

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        children: [
          Text(
            '$start–$end dari $totalData data',
            style: const TextStyle(
              fontSize: 11,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.primary,
                  minimumSize: const Size(40, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Icon(Icons.chevron_left),
              ),
              const SizedBox(width: 14),
              Text(
                'Halaman $currentPage dari $totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 14),
              OutlinedButton(
                onPressed: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.primary,
                  minimumSize: const Size(40, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = kelasTersaring;
    final totalData = data.length;

    final totalPages = totalData == 0
        ? 1
        : (totalData / itemsPerPage).ceil();

    if (currentPage > totalPages) {
      currentPage = totalPages;
    }

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage)
        .clamp(0, totalData)
        .toInt();

    final dataHalaman = data.sublist(
      startIndex.clamp(0, totalData).toInt(),
      endIndex,
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AdminColors.border)),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/logo_rupah.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.recycling_rounded,
                    size: 38,
                    color: AdminColors.primary,
                  );
                },
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kelola Data Kelas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Data Kelas',
                      style: TextStyle(
                        fontSize: 10,
                        color: AdminColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 105,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: tambahKelas,
                  icon: const Icon(Icons.add_circle_outline, size: 17),
                  label: const Text(
                    'Tambah Kelas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: ambilData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            kataKunci = value.toLowerCase().trim();
                            currentPage = 1;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari kelas, jurusan, wali, username...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AdminColors.muted,
                          ),
                          suffixIcon: kataKunci.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      kataKunci = '';
                                      currentPage = 1;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AdminColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AdminColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          dropdownFilter(
                            label: 'Jurusan',
                            value: filterJurusan,
                            pilihan: daftarJurusan,
                            onChanged: (value) {
                              setState(() {
                                filterJurusan = value ?? 'Semua';
                                currentPage = 1;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          dropdownFilter(
                            label: 'Status',
                            value: filterStatus,
                            pilihan: const ['Semua', 'Aktif', 'Nonaktif'],
                            onChanged: (value) {
                              setState(() {
                                filterStatus = value ?? 'Semua';
                                currentPage = 1;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      dropdownFilter(
                        label: 'Urutan Tanggal',
                        value: urutanTanggal,
                        pilihan: const ['Terbaru', 'Terlama'],
                        onChanged: (value) {
                          setState(() {
                            urutanTanggal = value ?? 'Terbaru';
                            currentPage = 1;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      if (dataKelas.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(child: Text('Belum ada data kelas.')),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$totalData Data Kelas',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AdminColors.muted,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  kataKunci = '';
                                  filterJurusan = 'Semua';
                                  filterStatus = 'Semua';
                                  urutanTanggal = 'Terbaru';
                                  currentPage = 1;
                                });
                              },
                              icon: const Icon(Icons.refresh, size: 15),
                              label: const Text(
                                'Reset',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (data.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(child: Text('Kelas tidak ditemukan.')),
                          )
                        else ...[
                          for (final kelas in dataHalaman)
                            _KelasCard(
                              kelas: kelas,
                              onEdit: () => editKelas(kelas),
                              onDelete: hapusKelas,
                            ),
                          pagination(totalData, totalPages),
                        ],
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// KARTU DATA KELAS
class _KelasCard extends StatelessWidget {
  final Map<String, dynamic> kelas;
  final VoidCallback onEdit;
  final Future<void> Function(int idKelas) onDelete;

  const _KelasCard({
    required this.kelas,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final int idKelas = (kelas['id_kelas'] as num).toInt();
    final String namaKelas = kelas['nama_kelas']?.toString() ?? '-';
    final String status = kelas['status']?.toString() ?? 'aktif';
    final String username = kelas['username']?.toString() ?? '-';

    final bool aktif = status.toLowerCase() == 'aktif';

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: AdminColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  namaKelas,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AdminPill(
                aktif ? 'Aktif' : 'Nonaktif',
                bg: aktif ? AdminColors.primaryLight : AdminColors.dangerBg,
                fg: aktif ? AdminColors.primary : AdminColors.danger,
                icon: aktif
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                size: 10,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoKelas(
            icon: Icons.computer_outlined,
            label: 'Jurusan',
            value: kelas['jurusan']?.toString() ?? '-',
            background: AdminColors.bg,
          ),
          const SizedBox(height: 10),
          _InfoKelas(
            icon: Icons.person_outline,
            label: 'Wali Kelas',
            value: kelas['nama_wali_kelas']?.toString() ?? '-',
            background: AdminColors.bg,
          ),
          const SizedBox(height: 10),
          _InfoKelas(
            icon: Icons.account_circle_outlined,
            label: 'Username',
            value: username,
            background: AdminColors.blueSoft,
          ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    'Edit Data',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.primary,
                    side: const BorderSide(color: AdminColors.primary),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () async {
                  final konfirmasi = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Hapus Kelas'),
                      content: Text('Hapus kelas $namaKelas?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (konfirmasi == true) {
                    await onDelete(idKelas);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AdminColors.dangerBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AdminColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// WIDGET INFORMASI KELAS
class _InfoKelas extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color background;

  const _InfoKelas({
    required this.icon,
    required this.label,
    required this.value,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AdminColors.muted),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontSize: 11)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AdminColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

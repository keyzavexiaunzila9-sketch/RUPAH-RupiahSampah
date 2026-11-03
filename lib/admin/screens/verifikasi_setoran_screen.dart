
import 'package:flutter/material.dart';

class VerifikasiSetoranScreen extends StatefulWidget {
  const VerifikasiSetoranScreen({super.key});

  @override
  State<VerifikasiSetoranScreen> createState() =>
      _VerifikasiSetoranScreenState();
}

class _VerifikasiSetoranScreenState
    extends State<VerifikasiSetoranScreen> {
  static const Color green = Color(0xFF087A4F);
  static const Color darkGreen = Color(0xFF006B43);
  static const Color background = Color(0xFFF5F7FC);
  static const Color ink = Color(0xFF26352F);
  static const Color muted = Color(0xFF78857F);
  static const Color border = Color(0xFFE8EDF2);

  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> dataSetoran = [
    {
      'initials': 'DP',
      'name': 'Dimas Pratama',
      'class': 'XI RPL 1',
      'time': '10 mnt lalu •\n14:35',
      'category': 'Botol PET Bening\n(Grade A)',
      'weight': '5.0 Kg',
      'reward': 'Rp 15.000',
      'status': 'Menunggu Verifikasi',
    },
    {
      'initials': 'SA',
      'name': 'Siti Aisyah',
      'class': 'X TKJ',
      'time': '25 mnt lalu •\n14:20',
      'category': 'Kardus & Kertas Duple',
      'weight': '12.4 Kg',
      'reward': 'Rp 24.800',
      'status': 'Menunggu Verifikasi',
    },
  ];

  List<Map<String, dynamic>> get filteredData {
    final keyword = searchController.text.toLowerCase();

    return dataSetoran.where((data) {
      return data['name'].toString().toLowerCase().contains(keyword) ||
          data['class'].toString().toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statistics(),

                    const SizedBox(height: 12),

                    _searchBar(),

                    const SizedBox(height: 13),

                    ...filteredData.map(
                      (data) => _verificationCard(data),
                    ),

                    if (filteredData.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'Data setoran tidak ditemukan.',
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
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: border),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/logo_rupah.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.recycling_rounded,
                color: green,
                size: 30,
              );
            },
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Verifikasi Setoran',
                  style: TextStyle(
                    fontSize: 14,
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'SMA Harapan Bangsa • Petugas Piket',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 25),
        ],
      ),
    );
  }

  // STATISTIK
  Widget _statistics() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFE99A22),
            title: 'Menunggu',
            value: '8',
            subtitle: '',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _statCard(
            icon: Icons.verified_rounded,
            iconColor: const Color(0xFF159B69),
            title: 'Hari ini',
            value: '24',
            subtitle: 'Disetujui',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _statCard(
            icon: Icons.scale_rounded,
            iconColor: const Color(0xFF159BA6),
            title: 'Kg',
            value: '142.5',
            subtitle: 'Bobot Masuk',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: iconColor,
              ),
              const Spacer(),
              if (title == 'Menunggu')
                const Icon(
                  Icons.circle,
                  size: 6,
                  color: Color(0xFFFFA000),
                ),
              if (title != 'Menunggu')
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
            )
          else
            const Text(
              'Menunggu',
              style: TextStyle(
                fontSize: 12,
                color: ink,
              ),
            ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _searchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontSize: 12,
                color: ink,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari nama penyetor atau kelas...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: _showFilter,
            icon: const Icon(
              Icons.tune_rounded,
              size: 17,
              color: muted,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
        ],
      ),
    );
  }

  // FILTER
  void _showFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Setoran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Status: Menunggu Verifikasi',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showMessage('Filter diterapkan.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Terapkan Filter',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // KARTU VERIFIKASI
  Widget _verificationCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4E9DD),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2D0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFFD58B16),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Menunggu\nVerifikasi',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.1,
                        color: Color(0xFFB77913),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                data['time'],
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: muted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // IDENTITAS PENYETOR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FD),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: darkGreen,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    data['initials'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  data['name'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EDFC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data['class'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          // DETAIL SAMPAH
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Sampah',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.recycling_rounded,
                            size: 13,
                            color: green,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data['category'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Bobot & Nilai Kas',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['weight'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data['reward'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          // TOMBOL VERIFIKASI
          SizedBox(
            width: double.infinity,
            height: 37,
            child: ElevatedButton.icon(
              onPressed: () {
                showMessage(
                  'Membuka verifikasi setoran ${data['name']}',
                );
              },
              icon: const Icon(
                Icons.verified_user_outlined,
                size: 13,
              ),
              label: const Text(
                'Verifikasi Sekarang',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}

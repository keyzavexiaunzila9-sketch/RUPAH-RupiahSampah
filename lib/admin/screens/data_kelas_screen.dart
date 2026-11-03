
import 'package:flutter/material.dart';
import '../widgets/admin_widgets.dart';
import 'edit_kelas_screen.dart';
import 'form_kelas_screen.dart';

class _Kelas {
  final String nama, wali, username, saldo, total;
  final IconData icon;

  const _Kelas(
    this.nama,
    this.wali,
    this.username,
    this.saldo,
    this.total,
    this.icon,
  );
}

const _data = [
  _Kelas(
    'XI RPL 1',
    'Ibu Rina S.Pd',
    '@eko_xirpl1',
    'Rp 127.500',
    '42.5 Kg',
    Icons.laptop_mac,
  ),
  _Kelas(
    'XI TKJ D',
    'Drs. Bambang Sudiro',
    '@eko_xiimipa1',
    'Rp 185.000',
    '58.2 Kg',
    Icons.science_outlined,
  ),
  _Kelas(
    'XII TKJ C',
    'Siti Rahmawati M.Pd',
    '@eko_xmipa2',
    'Rp 114.000',
    '38.0 Kg',
    Icons.biotech_outlined,
  ),
];

class DataKelasScreen extends StatelessWidget {
  const DataKelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER DENGAN LOGO RUPAH
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AdminColors.border,
              ),
            ),
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
                      'Master Akun & Kredensial • 32 Kelas',
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormKelasScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 17,
                  ),
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

        // DAFTAR DATA KELAS
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AdminSearch(),
              for (final k in _data) _KelasCard(k),
            ],
          ),
        ),
      ],
    );
  }
}

class _KelasCard extends StatelessWidget {
  final _Kelas k;

  const _KelasCard(this.k);

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  k.icon,
                  color: AdminColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  k.nama,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const AdminPill(
                'Akun Aktif',
                bg: AdminColors.primaryLight,
                fg: AdminColors.primary,
                icon: Icons.check_circle_outline,
                size: 10,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.blueSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Wali Kelas:',
                  style: TextStyle(fontSize: 11),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    k.wali,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AdminColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 18,
                  color: AdminColors.muted,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    '${k.username} • ••••••••',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.primary,
                    ),
                  ),
                ),

                const Icon(
                  Icons.copy,
                  size: 16,
                  color: AdminColors.muted,
                ),

                const SizedBox(width: 10),

                const Icon(
                  Icons.lock_reset,
                  size: 18,
                  color: AdminColors.muted,
                ),
              ],
            ),
          ),

          const Divider(height: 22),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Saldo Kas',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      k.saldo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Total Setor',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      k.total,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 22),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditKelasScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                  ),
                  label: const Text(
                    'Edit Data dan Akun',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.primary,
                    side: const BorderSide(
                      color: AdminColors.primary,
                    ),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
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
            ],
          ),
        ],
      ),
    );
  }
}

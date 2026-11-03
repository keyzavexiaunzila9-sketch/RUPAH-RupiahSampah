import 'package:flutter/material.dart';
import '../widgets/admin_widgets.dart';

class EditKelasScreen extends StatefulWidget {
  const EditKelasScreen({super.key});
  @override
  State<EditKelasScreen> createState() => _EditKelasScreenState();
}

class _EditKelasScreenState extends State<EditKelasScreen> {
  bool _hide = false;

  Widget _head(IconData icon, String title, String sub) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AdminColors.primaryLight,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: AdminColors.primary),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(sub, style: const TextStyle(fontSize: 10, color: AdminColors.muted)),
            ]),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdminColors.bg,
        appBar: adminBackBar(context, 'Form Data Kelas'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE3F4EA), Color(0xFFD5F5F3)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFE0CB))),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.eco, size: 18, color: AdminColors.primary),
              SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Pembaruan data kelas akan langsung terhubung ke buku tabungan Adiwiyata & riwayat setor sampah daur ulang.',
                      style: TextStyle(fontSize: 11))),
            ]),
          ),
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _head(Icons.school, 'Informasi Kelas', 'Identitas tingkatan rombel sekolah'),
              const AdminField(
                  label: 'Nama Tingkat & Kelas',
                  required: true,
                  initial: 'XI RPL 1',
                  suffix: Icon(Icons.verified_outlined,
                      size: 18, color: AdminColors.primary)),
              const SizedBox(height: 14),
              const AdminField(
                  label: 'Jurusan / Peminatan',
                  required: true,
                  initial: 'Rekayasa Perangkat Lunak'),
              const SizedBox(height: 14),
              const AdminField(
                  label: 'Nama Wali Kelas', required: true, initial: 'Ibu Rina S.Pd'),
            ]),
          ),
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _head(Icons.lock, 'Akun & Kredensial Login',
                  'Akses akun kelas di aplikasi siswa'),
              const AdminField(
                  label: 'Username Kelas',
                  required: true,
                  initial: 'eko_xirpl1',
                  prefix: Icon(Icons.alternate_email, size: 18),
                  suffix: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Center(
                          widthFactor: 1,
                          child: AdminPill('TERSEDIA',
                              bg: AdminColors.primaryLight,
                              fg: AdminColors.primary,
                              size: 8)))),
              const SizedBox(height: 14),
              const Row(children: [
                Expanded(
                    child: Text.rich(TextSpan(
                        text: 'Kata Sandi (Password)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        children: [
                          TextSpan(
                              text: ' *', style: TextStyle(color: AdminColors.danger))
                        ]))),
                Text('Reset Sandi',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.primary)),
              ]),
              const SizedBox(height: 8),
              AdminField(
                initial: 'Rahasia123!',
                obscure: _hide,
                suffix: IconButton(
                    icon: Icon(
                        _hide
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18),
                    onPressed: () => setState(() => _hide = !_hide)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AdminColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFE0CB))),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.shield_outlined, size: 16, color: AdminColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Kredensial ini digunakan pengurus kelas untuk setor sampah mandiri di aplikasi.',
                          style: TextStyle(fontSize: 10, color: AdminColors.primary))),
                ]),
              ),
            ]),
          ),
        ]),
        bottomNavigationBar: AdminActionBar(
            saveLabel: 'Simpan Data Kelas',
            icon: Icons.check_circle_outline,
            onSave: () => Navigator.pop(context)),
      );
}
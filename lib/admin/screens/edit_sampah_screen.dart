import 'package:flutter/material.dart';
import '../widgets/admin_widgets.dart';

class EditSampahScreen extends StatelessWidget {
  const EditSampahScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdminColors.bg,
        appBar: adminBackBar(context, 'Edit Data Sampah'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AdminSection(Icons.payments_outlined, 'Tarif Sampah',
                  trailing: 'Per Kilogram (Kg)'),
              const Text('Tarif Beli dari Siswa', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 8),
              const AdminField(
                  initial: '3.000',
                  keyboard: TextInputType.number,
                  prefix: Padding(
                      padding: EdgeInsets.only(left: 14, right: 8),
                      child: Center(
                          widthFactor: 1,
                          child: Text('Rp', style: TextStyle(fontSize: 14)))),
                  suffix: Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Center(
                          widthFactor: 1,
                          child: Text('/Kg', style: TextStyle(fontSize: 11))))),
              const SizedBox(height: 6),
              const Text('Nominal yang masuk ke buku tabungan siswa saat setor.',
                  style: TextStyle(fontSize: 10, color: AdminColors.muted)),
            ]),
          ),
          AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.inventory_2_outlined, color: AdminColors.primary),
                SizedBox(width: 10),
                Expanded(
                    child: Text('Stok Gudang Saat\nIni',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15, height: 1.2))),
                AdminPill('Rak B2 • Gudang\nUtama',
                    bg: Color(0xFFEDEFF3), fg: AdminColors.muted, size: 9),
              ]),
              const Divider(height: 24),
              const Text('Berat Bersih Tersedia', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 8),
              const AdminField(
                  initial: '285.0',
                  keyboard: TextInputType.number,
                  suffix: Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Center(
                          widthFactor: 1,
                          child: Text('Kg', style: TextStyle(fontSize: 13))))),
            ]),
          ),
          const AdminCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AdminSection(Icons.notes, 'Keterangan & Catatan', trailing: 'Opsional'),
              Text('Catatan Sortir / Petugas', style: TextStyle(fontSize: 11)),
              SizedBox(height: 8),
              AdminField(
                  maxLines: 4,
                  initial:
                      'Pastikan botol plastik bersih dari sisa cairan dan label telah dilepas sebelum ditimbang.'),
            ]),
          ),
        ]),
        bottomNavigationBar: AdminActionBar(
            saveLabel: 'Simpan Perubahan', onSave: () => Navigator.pop(context)),
      );
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widget/rupah_widgets.dart';
import 'detail_setoran_screen.dart';
import 'dashboard_screens.dart';

class StatusSetorScreen extends StatelessWidget {
  final String category;
  final double weight;
  final String note;
  final Uint8List? photoBytes;

  const StatusSetorScreen({
    super.key,
    this.category = 'Plastik',
    this.weight = 5,
    this.note = '',
    this.photoBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const DashboardScreens(),
              ),
              (_) => false,
            );
          },
        ),
        title: Text(
          'Status Setoran',
          style: RupahTheme.heading(
            size: 18,
            color: RupahColors.green,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 74,
                    height: 74,
                    decoration: const BoxDecoration(
                      color: RupahColors.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 42,
                      color: RupahColors.green,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Setoran Berhasil Dikirim!',
                    textAlign: TextAlign.center,
                    style: RupahTheme.heading(
                      size: 19,
                      color: RupahColors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Setoranmu sudah dikirim dan menunggu verifikasi admin.',
                    textAlign: TextAlign.center,
                    style: RupahTheme.body(
                      size: 11.5,
                      color: RupahColors.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const StatusPill(
                    text: 'Menunggu Verifikasi Admin',
                    color: RupahColors.warning,
                    background: Color(0xFFFFF2D9),
                    icon: Icons.hourglass_top_rounded,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Estimasi verifikasi maksimal 24 jam kerja',
                    textAlign: TextAlign.center,
                    style: RupahTheme.body(
                      size: 10,
                      color: RupahColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RupahColors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: RupahColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Setoran',
                    style: RupahTheme.heading(size: 16),
                  ),
                  const SizedBox(height: 14),
                  _detailRow('Kategori Sampah', category),
                  _detailRow(
                    'Berat Sampah',
                    '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} Kg',
                  ),
                  if (note.trim().isNotEmpty)
                    _detailRow('Catatan', note.trim()),

                  if (photoBytes != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Foto Bukti Timbangan',
                      style: RupahTheme.body(
                        size: 12,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        photoBytes!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RupahColors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: RupahColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proses Verifikasi Setoran',
                    style: RupahTheme.heading(size: 16),
                  ),
                  const SizedBox(height: 13),
                  _timeline(
                    'Setoran Dikirim',
                    'Data setoran sudah dikirim dari formulir.',
                    true,
                    'Selesai',
                    RupahColors.green,
                  ),
                  _timeline(
                    'Pemeriksaan Fisik & Validasi',
                    'Admin akan memeriksa data dan bukti setoran.',
                    false,
                    'Menunggu',
                    RupahColors.warning,
                  ),
                  _timeline(
                    'Pencairan Saldo Kelas',
                    'Saldo masuk setelah setoran disetujui admin.',
                    false,
                    'Menunggu',
                    RupahColors.muted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            RupahPrimaryButton(
              label: 'Lihat Detail Setoran',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSetoranScreen(
                      category: category,
                      weight: weight,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 9),

            RupahPrimaryButton(
              label: 'Kembali ke Dashboard',
              icon: Icons.home_outlined,
              outlined: true,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardScreens(),
                  ),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: RupahTheme.body(
                size: 11,
                color: RupahColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: RupahTheme.body(
                size: 12,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeline(
    String title,
    String subtitle,
    bool done,
    String meta,
    Color color,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: done
                      ? color
                      : color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  done ? Icons.check : Icons.circle,
                  size: done ? 14 : 8,
                  color: done ? Colors.white : color,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: color.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: RupahTheme.body(
                            size: 12,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        meta,
                        style: RupahTheme.body(
                          size: 9.5,
                          color: color,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: RupahTheme.body(
                      size: 10.5,
                      color: RupahColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

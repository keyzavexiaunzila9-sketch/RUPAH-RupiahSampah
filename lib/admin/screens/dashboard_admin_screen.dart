
import 'package:flutter/material.dart';

class DashboardAdminScreen extends StatefulWidget {
  final VoidCallback? onOpenVerification;

  const DashboardAdminScreen({
    super.key,
    this.onOpenVerification,
  });

  @override
  State<DashboardAdminScreen> createState() =>
      _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  static const Color green = Color(0xFF007545);
  static const Color darkGreen = Color(0xFF006B43);
  static const Color background = Color(0xFFF5F7FC);
  static const Color ink = Color(0xFF202B38);
  static const Color muted = Color(0xFF68766F);
  static const Color border = Color(0xFFE9EDF2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 17),
                    _statistics(),
                    const SizedBox(height: 20),
                    _queueTitle(),
                    const SizedBox(height: 9),
                    _verificationCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Image.asset(
          'assets/logo_rupah.png',
          width: 40,
          height: 45,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              width: 40,
              height: 45,
              child: Icon(
                Icons.recycling_rounded,
                color: green,
                size: 35,
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bank Sampah',
                style: TextStyle(
                  fontSize: 13,
                  color: darkGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'SMKN 8 MALANG',
                style: TextStyle(
                  fontSize: 13,
                  color: darkGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ibu.Sugiyanti • Penanggung Jawab',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statistics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Antrean Verifikasi',
                value: '8',
                subtitle: 'Menunggu',
                icon: Icons.hourglass_top_rounded,
                accent: const Color(0xFFC45C00),
                subtitleColor: muted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                title: 'Sampah Hari Ini',
                value: '142.5',
                unit: 'Kg',
                subtitle: '↗ +18% pekan lalu',
                icon: Icons.eco_outlined,
                accent: green,
                subtitleColor: green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Kas Terdistribusi',
                value: 'Rp 428.500',
                subtitle: 'Kas kelas mitra aktif',
                icon: Icons.account_balance_wallet_outlined,
                accent: const Color(0xFF087F83),
                subtitleColor: muted,
                valueSize: 15,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                title: 'Kepatuhan Adiwiyata',
                value: '24',
                unit: '/ 32 Kelas',
                subtitle: '',
                icon: Icons.school_outlined,
                accent: const Color(0xFF43A7A5),
                subtitleColor: muted,
                valueSize: 17,
                progress: 24 / 32,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color subtitleColor,
    String? unit,
    double valueSize = 19,
    double? progress,
  }) {
    return Container(
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF0F2F5),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            color: accent,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 9, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            height: 1.15,
                            color: Color(0xFF48534C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        icon,
                        size: 14,
                        color: accent,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: valueSize,
                            height: 1.05,
                            color: ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (unit != null) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            unit,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8.5,
                              color: muted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        height: 1.3,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (progress != null) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: const Color(0xFFE8EDF4),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(green),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _queueTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Antrean Butuh Verifikasi',
            style: TextStyle(
              fontSize: 14,
              color: ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        InkWell(
          onTap: widget.onOpenVerification,
          child: const Text(
            'Lihat Semua (8) →',
            style: TextStyle(
              fontSize: 9.5,
              color: green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _verificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 27,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DP',
                  style: TextStyle(
                    fontSize: 10,
                    color: green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Dimas Pratama',
                          style: TextStyle(
                            fontSize: 10,
                            color: ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'XI RPL 1',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF596675),
                            backgroundColor: Color(0xFFE8EDF3),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.3,
                          color: Color(0xFF48534C),
                        ),
                        children: [
                          TextSpan(
                            text: 'Botol PET Bening Grade A • ',
                          ),
                          TextSpan(
                            text: 'Estimasi ',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '5.0 Kg',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.access_time,
                size: 11,
                color: muted,
              ),
              const SizedBox(width: 3),
              const Text(
                '10 mnt\nlalu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  height: 1.25,
                  color: ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(
            height: 1,
            color: Color(0xFFEDF0F4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potensi Nilai Kas',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: muted,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Rp 15.000',
                      style: TextStyle(
                        fontSize: 11,
                        color: green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: widget.onOpenVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verifikasi Sekarang',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

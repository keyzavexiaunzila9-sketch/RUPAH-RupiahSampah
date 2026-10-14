import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UserBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const UserBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RupahColors.white,
        border: Border(
          top: BorderSide(
            color: RupahColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [
              _item(
                0,
                Icons.dashboard_rounded,
                'Dashboard',
              ),
              _item(
                1,
                Icons.recycling_rounded,
                'Setor',
              ),
              _item(
                2,
                Icons.history_rounded,
                'Riwayat',
              ),
              _item(
                3,
                Icons.person_outline_rounded,
                'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    int index,
    IconData icon,
    String label,
  ) {
    final active = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? RupahColors.green
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: active
                      ? RupahColors.white
                      : RupahColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: RupahTheme.body(
                  size: 9.5,
                  color: active
                      ? RupahColors.green
                      : RupahColors.text,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
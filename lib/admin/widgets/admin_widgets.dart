import 'package:flutter/material.dart';

const String kLogoPath = 'lib/assets/logo_rupah.png';

class AdminColors {
  static const primary = Color(0xFF006C35);
  static const primaryLight = Color(0xFFE3F4EA);
  static const teal = Color(0xFF00696B);
  static const tealLight = Color(0xFFD5F5F3);
  static const bg = Color(0xFFF8F9FF);
  static const text = Color(0xFF191C24);
  static const muted = Color(0xFF6F7A72);
  static const border = Color(0xFFC4C9C4);
  static const blueSoft = Color(0xFFEEF2FF);
  static const orange = Color(0xFFB4560A);
  static const amber = Color(0xFFB45309);
  static const amberBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFFBA1A1A);
  static const dangerBg = Color(0xFFFFE9E7);
}

class AdminCard extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final Color? borderColor;
  final EdgeInsets padding;
  final double bottom;
  const AdminCard({
    super.key,
    required this.child,
    this.accent,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
    this.bottom = 14,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (accent != null) Container(width: 5, color: accent),
              Expanded(child: Padding(padding: padding, child: child)),
            ]),
          ),
        ),
      );
}

class AdminPill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final IconData? icon;
  final double size;
  const AdminPill(this.text,
      {super.key, required this.bg, required this.fg, this.icon, this.size = 11});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: size + 2, color: fg), const SizedBox(width: 4)],
          Flexible(
              child: Text(text,
                  style: TextStyle(color: fg, fontSize: size, fontWeight: FontWeight.w600))),
        ]),
      );
}

class AdminButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  const AdminButton(this.label,
      {super.key, this.icon, this.onTap, this.color = AdminColors.primary, this.height = 52});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          ]),
        ),
      );
}

class AdminField extends StatelessWidget {
  final String? label, hint, initial;
  final Widget? prefix, suffix;
  final bool obscure, required, readOnly;
  final int maxLines;
  final TextInputType? keyboard;
  const AdminField({
    super.key,
    this.label,
    this.hint,
    this.initial,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.required = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text.rich(TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  children: [
                    if (required)
                      const TextSpan(text: ' *', style: TextStyle(color: AdminColors.danger))
                  ])),
            ),
          TextFormField(
            initialValue: initial,
            obscureText: obscure,
            maxLines: maxLines,
            readOnly: readOnly,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AdminColors.muted, fontSize: 13),
              prefixIcon: prefix,
              suffixIcon: suffix,
              filled: true,
              fillColor: readOnly ? AdminColors.blueSoft : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AdminColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AdminColors.primary, width: 1.5)),
            ),
          ),
        ],
      );
}

class AdminSearch extends StatelessWidget {
  const AdminSearch({super.key});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 48,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AdminColors.border)),
        child: const Row(children: [
          Icon(Icons.search, color: AdminColors.muted),
          Expanded(
              child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8)))),
          Icon(Icons.tune, color: AdminColors.muted),
        ]),
      );
}

class AdminHeader extends StatelessWidget {
  final String title, subtitle;
  final Widget? trailing;
  const AdminHeader({super.key, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(children: [
          Image.asset(kLogoPath, width: 52, height: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, height: 1.2)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

PreferredSizeWidget adminBackBar(BuildContext context, String title, {String? subtitle}) =>
    AppBar(
      backgroundColor: AdminColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.primary),
          onPressed: () => Navigator.maybePop(context)),
      titleSpacing: 0,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: AdminColors.primary, fontWeight: FontWeight.w700, fontSize: 17)),
        if (subtitle != null)
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
      ]),
    );

class AdminActionBar extends StatelessWidget {
  final String saveLabel;
  final IconData icon;
  final VoidCallback onSave;
  const AdminActionBar(
      {super.key, required this.saveLabel, required this.onSave, this.icon = Icons.check});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        color: Colors.white,
        child: Row(children: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: AdminColors.teal, fontSize: 14))),
          const SizedBox(width: 8),
          Expanded(child: AdminButton(saveLabel, icon: icon, onTap: onSave)),
        ]),
      );
}

class AdminInitial extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final double size;
  const AdminInitial(this.text,
      {super.key,
      this.bg = AdminColors.primaryLight,
      this.fg = AdminColors.primary,
      this.size = 44});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
      );
}

class AdminSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  const AdminSection(this.icon, this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AdminColors.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: AdminColors.primary)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
          ]),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
        ]),
      );
}
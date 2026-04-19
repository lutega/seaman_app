import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum SrBadgeVariant { success, warning, danger, info, neutral }

class SrBadge extends StatelessWidget {
  final String label;
  final SrBadgeVariant variant;

  const SrBadge({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SrSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(SrRadius.xs),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colors.$2,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (Color, Color) _colors() => switch (variant) {
        SrBadgeVariant.success => (SrColors.successBg, SrColors.successText),
        SrBadgeVariant.warning => (SrColors.warningBg, SrColors.warningText),
        SrBadgeVariant.danger => (SrColors.dangerBg, SrColors.dangerText),
        SrBadgeVariant.info => (SrColors.infoBg, SrColors.infoText),
        SrBadgeVariant.neutral => (SrColors.cardBg, SrColors.textMuted),
      };
}

SrBadge certificateStatusBadge(DateTime expiryDate) {
  final days = expiryDate.difference(DateTime.now()).inDays;
  if (days < 0) return const SrBadge(label: 'Expired', variant: SrBadgeVariant.danger);
  if (days <= 7) return SrBadge(label: '$days hari lagi', variant: SrBadgeVariant.danger);
  if (days <= 30) return SrBadge(label: '${(days / 30).ceil()} bln lagi', variant: SrBadgeVariant.warning);
  return const SrBadge(label: 'Valid', variant: SrBadgeVariant.success);
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class SrCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final double? borderRadius;

  const SrCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? SrColors.cardBg,
      borderRadius: BorderRadius.circular(borderRadius ?? SrRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? SrRadius.md),
        child: Container(
          padding: padding ?? const EdgeInsets.all(SrSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? SrRadius.md),
            border: border ?? Border.all(color: SrColors.border, width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SrCertificateCard extends StatelessWidget {
  final String name;
  final DateTime expiryDate;
  final String? issuer;
  final VoidCallback? onTap;

  const SrCertificateCard({
    super.key,
    required this.name,
    required this.expiryDate,
    this.issuer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = expiryDate.difference(DateTime.now()).inDays;
    final statusColor = days < 0
        ? SrColors.danger
        : days <= 7
            ? SrColors.danger
            : days <= 30
                ? SrColors.warning
                : SrColors.success;

    return SrCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Container(width: 3, height: 64, color: statusColor,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SrRadius.md),
                  bottomLeft: Radius.circular(SrRadius.md),
                ),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SrSpacing.md, vertical: SrSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_outlined, size: 24, color: statusColor),
                  const SizedBox(width: SrSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        if (issuer != null)
                          Text(issuer!, style: const TextStyle(fontSize: 12, color: SrColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Berlaku s/d', style: TextStyle(fontSize: 11, color: SrColors.textMuted)),
                      Text(
                        '${expiryDate.day} ${_monthName(expiryDate.month)} ${expiryDate.year}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m - 1];
  }
}

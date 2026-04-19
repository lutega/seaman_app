import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SrColors.white,
      borderRadius: BorderRadius.circular(SrRadius.md),
      child: InkWell(
        onTap: () => context.push('/courses/${course.id}'),
        borderRadius: BorderRadius.circular(SrRadius.md),
        child: Container(
          padding: const EdgeInsets.all(SrSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SrRadius.md),
            border: Border.all(color: SrColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PartnerAvatar(name: course.partnerName, logoUrl: course.partnerLogoUrl),
                  const SizedBox(width: SrSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: SrColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${course.partnerName}${course.durationDays != null ? ' · ${course.durationDays} hari' : ''}',
                          style: const TextStyle(fontSize: 12, color: SrColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  _CategoryChip(category: course.category),
                ],
              ),
              const SizedBox(height: SrSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: SrSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.priceIdr.toRupiah(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: SrColors.primary,
                      ),
                    ),
                  ),
                  _DeadlineBadge(course: course),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  const _PartnerAvatar({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(SrRadius.xs),
        child: Image.network(logoUrl!, width: 48, height: 48, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback()),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: SrColors.lightMint,
          borderRadius: BorderRadius.circular(SrRadius.xs),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SrColors.primary),
          ),
        ),
      );
}

class _CategoryChip extends StatelessWidget {
  final CourseCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final (bg, text) = switch (category) {
      CourseCategory.renewal => (SrColors.warningBg, SrColors.warningText),
      CourseCategory.rating => (SrColors.infoBg, SrColors.infoText),
      CourseCategory.initial => (SrColors.successBg, SrColors.successText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(SrRadius.xs)),
      child: Text(category.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text)),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final Course course;
  const _DeadlineBadge({required this.course});

  @override
  Widget build(BuildContext context) {
    final days = course.daysUntilDeadline;
    if (days < 0) {
      return const Text('Pendaftaran tutup',
          style: TextStyle(fontSize: 11, color: SrColors.textMuted));
    }

    final (icon, color, text) = days <= 3
        ? (Icons.timer_outlined, SrColors.danger, 'Tutup $days hari lagi')
        : (Icons.event_outlined, SrColors.textMuted,
            'Mulai ${course.startsAt.toDisplayDate()}');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

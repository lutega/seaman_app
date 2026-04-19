import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/sr_badge.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../domain/entities/quest.dart';
import '../providers/quest_providers.dart';

class QuestDetailScreen extends ConsumerWidget {
  final String enrollmentId;
  final String questId;

  const QuestDetailScreen({
    super.key,
    required this.enrollmentId,
    required this.questId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(questDetailProvider(questId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Quest')),
      body: questAsync.when(
        loading: () => const SrLoadingView(itemCount: 4),
        error: (e, _) => SrErrorView(message: e.toString()),
        data: (quest) => _QuestDetailBody(quest: quest),
      ),
    );
  }
}

class _QuestDetailBody extends StatelessWidget {
  final Quest quest;
  const _QuestDetailBody({required this.quest});

  @override
  Widget build(BuildContext context) {
    final badgeVariant = switch (quest.status) {
      QuestStepStatus.done => SrBadgeVariant.success,
      QuestStepStatus.current => SrBadgeVariant.info,
      QuestStepStatus.locked => SrBadgeVariant.neutral,
    };
    final badgeLabel = switch (quest.status) {
      QuestStepStatus.done => 'Selesai',
      QuestStepStatus.current => 'Berlangsung',
      QuestStepStatus.locked => 'Terkunci',
    };

    return ListView(
      padding: const EdgeInsets.all(SrSpacing.md),
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(quest.stepLabel,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: SrColors.textPrimary)),
            ),
            SrBadge(label: badgeLabel, variant: badgeVariant),
          ],
        ),
        const SizedBox(height: SrSpacing.sm),

        // Points reward
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SrSpacing.sm, vertical: 6),
          decoration: BoxDecoration(
            color: SrColors.successBg,
            borderRadius: BorderRadius.circular(SrRadius.xs),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFFFD700)),
              const SizedBox(width: 4),
              Text('+${quest.pointsAwarded ?? 0} poin',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: SrColors.successText)),
            ],
          ),
        ),

        if (quest.isCurrent && quest.hintDeadline != null) ...[
          const SizedBox(height: SrSpacing.md),
          _BonusCallout(deadline: quest.hintDeadline!, points: quest.pointsAwarded ?? 0),
        ],

        const SizedBox(height: SrSpacing.lg),

        // Info rows
        if (quest.hintLocation != null)
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: quest.hintLocation!,
            color: SrColors.primary,
          ),
        if (quest.hintContact != null)
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Kontak PJ',
            value: quest.hintContact!,
            color: SrColors.teal,
          ),
        if (quest.hintDeadline != null)
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Batas Waktu',
            value: quest.hintDeadline!.toDisplayDateTime(),
            color: SrColors.danger,
          ),
        if (quest.completedAt != null)
          _InfoRow(
            icon: Icons.check_circle_outline,
            label: 'Diselesaikan',
            value: quest.completedAt!.toDisplayDateTime(),
            color: SrColors.success,
          ),

        const SizedBox(height: SrSpacing.xl),

        if (quest.isCurrent)
          Container(
            padding: const EdgeInsets.all(SrSpacing.md),
            decoration: BoxDecoration(
              color: SrColors.infoBg,
              borderRadius: BorderRadius.circular(SrRadius.md),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: SrColors.info),
                SizedBox(width: SrSpacing.sm),
                Expanded(
                  child: Text(
                    'Status quest diperbarui otomatis setelah dikonfirmasi oleh partner.',
                    style: TextStyle(fontSize: 13, color: SrColors.infoText),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BonusCallout extends StatelessWidget {
  final DateTime deadline;
  final int points;
  const _BonusCallout({required this.deadline, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: SrColors.warningBg,
        borderRadius: BorderRadius.circular(SrRadius.md),
        border: Border.all(color: SrColors.warning.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 20, color: SrColors.warning),
          const SizedBox(width: SrSpacing.sm),
          Expanded(
            child: Text(
              'Bonus +${(points * 0.15).round()} poin jika selesai sebelum ${deadline.toDisplayDateTime()}',
              style: const TextStyle(fontSize: 13, color: SrColors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SrSpacing.sm),
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: SrColors.cardBg,
        borderRadius: BorderRadius.circular(SrRadius.sm),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: SrSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, color: SrColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../domain/entities/quest.dart';
import '../providers/quest_providers.dart';

class QuestOverviewScreen extends ConsumerWidget {
  final String enrollmentId;
  const QuestOverviewScreen({super.key, required this.enrollmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(questsForEnrollmentProvider(enrollmentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Quest Kursus')),
      body: questsAsync.when(
        loading: () => const SrLoadingView(itemCount: 5),
        error: (e, _) => SrErrorView(message: e.toString()),
        data: (quests) => _QuestList(quests: quests, enrollmentId: enrollmentId),
      ),
    );
  }
}

class _QuestList extends StatelessWidget {
  final List<Quest> quests;
  final String enrollmentId;
  const _QuestList({required this.quests, required this.enrollmentId});

  @override
  Widget build(BuildContext context) {
    final done = quests.where((q) => q.isDone).length;
    final totalPoints = quests.where((q) => q.isDone).fold(0, (s, q) => s + (q.pointsAwarded ?? 0));
    final maxPoints = quests.fold(0, (s, q) => s + (q.pointsAwarded ?? 0));

    return ListView(
      padding: const EdgeInsets.all(SrSpacing.md),
      children: [
        _PointsHeroCard(totalPoints: totalPoints, maxPoints: maxPoints),
        const SizedBox(height: SrSpacing.md),
        _ProgressCard(done: done, total: quests.length),
        const SizedBox(height: SrSpacing.md),
        const Text('LANGKAH QUEST',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: SrColors.textMuted, letterSpacing: 1.5)),
        const SizedBox(height: SrSpacing.sm),
        ...quests.map((q) => _QuestItem(
              quest: q,
              onTap: q.isCurrent
                  ? () => context.push('/quest/$enrollmentId/${q.id}')
                  : null,
            )),
      ],
    );
  }
}

class _PointsHeroCard extends StatelessWidget {
  final int totalPoints;
  final int maxPoints;
  const _PointsHeroCard({required this.totalPoints, required this.maxPoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SrSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SrColors.primaryDark, SrColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SrRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(SrRadius.sm),
            ),
            child: const Icon(Icons.stars_rounded, size: 32, color: Color(0xFFFFD700)),
          ),
          const SizedBox(width: SrSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalPoints poin',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SrColors.white),
                ),
                Text(
                  'dari $maxPoints poin tersedia',
                  style: const TextStyle(fontSize: 13, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: SrColors.cardBg,
        borderRadius: BorderRadius.circular(SrRadius.md),
        border: Border.all(color: SrColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$done dari $total quest selesai',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${(done / total * 100).round()}%',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SrColors.primary)),
            ],
          ),
          const SizedBox(height: SrSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 8,
              backgroundColor: SrColors.border,
              valueColor: const AlwaysStoppedAnimation(SrColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestItem extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;
  const _QuestItem({required this.quest, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (iconColor, bgColor, icon) = switch (quest.status) {
      QuestStepStatus.done => (SrColors.success, SrColors.successBg, Icons.check_circle),
      QuestStepStatus.current => (SrColors.primary, SrColors.infoBg, Icons.radio_button_checked),
      QuestStepStatus.locked => (SrColors.border, SrColors.cardBg, Icons.lock_outline),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: SrSpacing.xs),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(SrRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SrRadius.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: SrSpacing.md, vertical: SrSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SrRadius.sm),
              border: Border.all(
                color: quest.isCurrent ? SrColors.primary : SrColors.border,
                width: quest.isCurrent ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  quest.isFinalStep && quest.isDone ? Icons.emoji_events : icon,
                  size: 22,
                  color: quest.isFinalStep && quest.isDone ? const Color(0xFFFFD700) : iconColor,
                ),
                const SizedBox(width: SrSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quest.stepLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: quest.isLocked ? SrColors.textMuted : SrColors.textPrimary,
                          )),
                      if (quest.isCurrent)
                        const Text('Tap untuk melihat detail',
                            style: TextStyle(fontSize: 11, color: SrColors.primary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: quest.isDone ? SrColors.successBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(SrRadius.xs),
                  ),
                  child: Text(
                    '+${quest.pointsAwarded ?? 0}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: quest.isDone ? SrColors.successText : SrColors.textMuted,
                    ),
                  ),
                ),
                if (quest.isCurrent) ...[
                  const SizedBox(width: SrSpacing.xs),
                  const Icon(Icons.chevron_right, size: 18, color: SrColors.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

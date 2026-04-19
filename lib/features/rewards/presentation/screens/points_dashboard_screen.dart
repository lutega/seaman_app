import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_empty_state.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../domain/entities/reward.dart';
import '../providers/reward_providers.dart';

class PointsDashboardScreen extends ConsumerWidget {
  const PointsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(userPointsProvider);
    final txAsync = ref.watch(pointTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poin Saya'),
        actions: [
          TextButton(
            onPressed: () => context.push('/reward-catalog'),
            child: const Text('Tukarkan'),
          ),
        ],
      ),
      body: pointsAsync.when(
        loading: () => const SrLoadingView(itemCount: 4),
        error: (e, _) => SrErrorView(message: e.toString()),
        data: (points) => _buildBody(context, points, txAsync),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserPoints? points,
      AsyncValue<List<PointTransaction>> txAsync) {
    final total = points?.totalPoints ?? 0;
    final streak = points?.streakCount ?? 0;

    return ListView(
      padding: const EdgeInsets.all(SrSpacing.md),
      children: [
        _HeroCard(total: total),
        if (streak > 0) ...[
          const SizedBox(height: SrSpacing.sm),
          _StreakCard(streak: streak),
        ],
        const SizedBox(height: SrSpacing.md),
        SrButton(
          label: 'Tukarkan Poin',
          leadingIcon: Icons.card_giftcard_outlined,
          onPressed: () => context.push('/reward-catalog'),
        ),
        const SizedBox(height: SrSpacing.lg),
        const Text('PEROLEHAN TERBARU',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: SrColors.textMuted, letterSpacing: 1.5)),
        const SizedBox(height: SrSpacing.sm),
        txAsync.when(
          loading: () => const SrLoadingView(itemCount: 3),
          error: (_, __) => const SizedBox.shrink(),
          data: (txs) {
            final earnings = txs.where((t) => t.isEarning).toList();
            if (earnings.isEmpty) {
              return SrEmptyState(
                title: 'Belum ada poin',
                subtitle: 'Selesaikan quest untuk mendapatkan poin',
                icon: Icons.stars_outlined,
              );
            }
            return Column(
              children: earnings.take(10).map((t) => _TxRow(tx: t)).toList(),
            );
          },
        ),
        const SizedBox(height: SrSpacing.lg),
        txAsync.maybeWhen(
          data: (txs) {
            final redeems = txs.where((t) => !t.isEarning).toList();
            if (redeems.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RIWAYAT PENUKARAN',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: SrColors.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: SrSpacing.sm),
                ...redeems.take(5).map((t) => _TxRow(tx: t)),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int total;
  const _HeroCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SrSpacing.lg),
      decoration: BoxDecoration(
        color: SrColors.warning,
        borderRadius: BorderRadius.circular(SrRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, size: 48, color: Color(0xFFFFD700)),
          const SizedBox(width: SrSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$total',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: SrColors.white)),
              const Text('poin terkumpul',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: SrColors.successBg,
        borderRadius: BorderRadius.circular(SrRadius.sm),
        border: Border.all(color: SrColors.success.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: SrSpacing.sm),
          Text(
            '$streak quest berturut-turut cepat!',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SrColors.successText),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final PointTransaction tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SrSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tx.isEarning ? SrColors.successBg : SrColors.dangerBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.isEarning ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: tx.isEarning ? SrColors.success : SrColors.danger,
            ),
          ),
          const SizedBox(width: SrSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.reason, style: const TextStyle(fontSize: 13, color: SrColors.textPrimary)),
                Text(tx.createdAt.toDisplayDate(),
                    style: const TextStyle(fontSize: 11, color: SrColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${tx.isEarning ? '+' : ''}${tx.points}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: tx.isEarning ? SrColors.success : SrColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

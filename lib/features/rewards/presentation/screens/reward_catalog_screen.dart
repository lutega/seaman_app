import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sr_badge.dart';
import '../../domain/entities/reward.dart';
import '../providers/reward_providers.dart';
import 'redeem_result_screen.dart';

class RewardCatalogScreen extends ConsumerWidget {
  const RewardCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(userPointsProvider);
    final userPoints = pointsAsync.valueOrNull?.totalPoints ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tukarkan Poin'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SrSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, size: 18, color: Color(0xFFFFD700)),
                const SizedBox(width: 4),
                Text('$userPoints poin',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(SrSpacing.md),
        itemCount: mvpRewards.length,
        separatorBuilder: (_, __) => const SizedBox(height: SrSpacing.sm),
        itemBuilder: (_, i) => _RewardCard(
          reward: mvpRewards[i],
          userPoints: userPoints,
        ),
      ),
    );
  }
}

class _RewardCard extends ConsumerWidget {
  final Reward reward;
  final int userPoints;
  const _RewardCard({required this.reward, required this.userPoints});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRedeem = reward.isAvailable && userPoints >= reward.pointsCost;
    final redeemState = ref.watch(redeemControllerProvider);
    final isLoading = redeemState is AsyncLoading;

    return Container(
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: reward.isAvailable ? SrColors.white : SrColors.cardBg,
        borderRadius: BorderRadius.circular(SrRadius.md),
        border: Border.all(
          color: canRedeem ? SrColors.success : SrColors.border,
          width: canRedeem ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          _RewardIcon(reward: reward),
          const SizedBox(width: SrSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: reward.isAvailable ? SrColors.textPrimary : SrColors.textMuted,
                    )),
                Text(reward.subtitle,
                    style: const TextStyle(fontSize: 12, color: SrColors.textMuted)),
                const SizedBox(height: 4),
                if (reward.pointsCost > 0)
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFFFD700)),
                      const SizedBox(width: 2),
                      Text('${reward.pointsCost} poin',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SrColors.warning)),
                    ],
                  )
                else
                  const Text('Gratis',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SrColors.success)),
              ],
            ),
          ),
          const SizedBox(width: SrSpacing.sm),
          _buildAction(context, ref, isLoading),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, WidgetRef ref, bool isLoading) {
    if (!reward.isAvailable) {
      final phaseLabel = reward.phase == RewardPhase.phase2 ? 'Fase 2' : 'Fase 3';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: SrColors.cardBg,
          borderRadius: BorderRadius.circular(SrRadius.xs),
          border: Border.all(color: SrColors.border),
        ),
        child: Text(phaseLabel,
            style: const TextStyle(fontSize: 11, color: SrColors.textMuted)),
      );
    }

    if (reward.pointsCost == 0) {
      return const SrBadge(label: 'Auto', variant: SrBadgeVariant.success);
    }

    return SizedBox(
      width: 72,
      height: 36,
      child: ElevatedButton(
        onPressed: userPoints >= reward.pointsCost && !isLoading
            ? () => _confirmRedeem(context, ref)
            : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: SrColors.primary,
          disabledBackgroundColor: SrColors.border,
        ),
        child: isLoading
            ? const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Tukar', style: TextStyle(fontSize: 13)),
      ),
    );
  }

  Future<void> _confirmRedeem(BuildContext context, WidgetRef ref) async {
    final pointsAsync = ref.read(userPointsProvider);
    final currentPoints = pointsAsync.valueOrNull?.totalPoints ?? 0;
    final remaining = currentPoints - reward.pointsCost;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(SrRadius.lg))),
      builder: (_) => _RedeemConfirmSheet(
        reward: reward,
        currentPoints: currentPoints,
        remainingPoints: remaining,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final voucher = await ref.read(redeemControllerProvider.notifier).redeem(userId, reward);
    if (voucher != null && context.mounted) {
      ref.invalidate(userPointsProvider);
      ref.invalidate(pointTransactionsProvider);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RedeemResultScreen(voucher: voucher)),
      );
    }
  }
}

class _RewardIcon extends StatelessWidget {
  final Reward reward;
  const _RewardIcon({required this.reward});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (reward.id) {
      String id when id.startsWith('badge') => (Icons.workspace_premium, SrColors.warning),
      String id when id.startsWith('voucher-cafetaria') => (Icons.restaurant_outlined, SrColors.primary),
      String id when id.startsWith('voucher-parkir') => (Icons.local_parking_outlined, SrColors.teal),
      String id when id.startsWith('tshirt') => (Icons.checkroom_outlined, SrColors.textMuted),
      _ => (Icons.card_giftcard_outlined, SrColors.textMuted),
    };
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: reward.isAvailable ? SrColors.lightMint : SrColors.cardBg,
        borderRadius: BorderRadius.circular(SrRadius.sm),
      ),
      child: Icon(icon, size: 28, color: color),
    );
  }
}

class _RedeemConfirmSheet extends StatelessWidget {
  final Reward reward;
  final int currentPoints;
  final int remainingPoints;

  const _RedeemConfirmSheet({
    required this.reward,
    required this.currentPoints,
    required this.remainingPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SrSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 4,
            decoration: BoxDecoration(color: SrColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: SrSpacing.md),
          Text('Tukar ${reward.name}?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: SrSpacing.md),
          _row('Harga', '${reward.pointsCost} poin', SrColors.primary),
          const Divider(),
          _row('Poin Anda', '$currentPoints poin', SrColors.textPrimary),
          _row('Sisa Poin', '$remainingPoints poin',
              remainingPoints >= 0 ? SrColors.success : SrColors.danger),
          const SizedBox(height: SrSpacing.sm),
          const Text(
            'Voucher berlaku 30 hari setelah diterbitkan. Tidak dapat dikembalikan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: SrColors.textMuted),
          ),
          const SizedBox(height: SrSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: SrSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Konfirmasi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: SrColors.textMuted)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}


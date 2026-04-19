import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/reward_repository_impl.dart';
import '../../domain/entities/reward.dart';
import '../../domain/repositories/reward_repository.dart';

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepositoryImpl(Supabase.instance.client);
});

final userPointsProvider = FutureProvider<UserPoints?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  final result = await ref.watch(rewardRepositoryProvider).getUserPoints(userId);
  return result.fold((_) => null, (p) => p);
});

final pointTransactionsProvider = FutureProvider<List<PointTransaction>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  final result = await ref.watch(rewardRepositoryProvider).getTransactions(userId);
  return result.fold((_) => [], (t) => t);
});

class RedeemController extends StateNotifier<AsyncValue<RedeemVoucher?>> {
  final RewardRepository _repo;
  RedeemController(this._repo) : super(const AsyncValue.data(null));

  Future<RedeemVoucher?> redeem(String userId, Reward reward) async {
    state = const AsyncValue.loading();
    final result = await _repo.redeemReward(userId: userId, reward: reward);
    return result.fold(
      (f) {
        state = AsyncValue.error(f.message, StackTrace.current);
        return null;
      },
      (voucher) {
        state = AsyncValue.data(voucher);
        return voucher;
      },
    );
  }
}

final redeemControllerProvider =
    StateNotifierProvider.autoDispose<RedeemController, AsyncValue<RedeemVoucher?>>((ref) {
  return RedeemController(ref.watch(rewardRepositoryProvider));
});

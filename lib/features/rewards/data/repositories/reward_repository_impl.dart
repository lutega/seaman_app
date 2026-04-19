import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reward.dart';
import '../../domain/repositories/reward_repository.dart';

class RewardRepositoryImpl implements RewardRepository {
  final SupabaseClient _client;
  RewardRepositoryImpl(this._client);

  @override
  Future<Either<Failure, UserPoints?>> getUserPoints(String userId) async {
    try {
      final data = await _client
          .from('user_points')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return right(null);
      return right(UserPoints(
        userId: data['user_id'] as String,
        totalPoints: data['total_points'] as int? ?? 0,
        streakCount: data['streak_count'] as int? ?? 0,
        updatedAt: DateTime.parse(data['updated_at'] as String),
      ));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<PointTransaction>>> getTransactions(String userId) async {
    try {
      final data = await _client
          .from('point_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      return right((data as List).map((e) => PointTransaction(
            id: e['id'] as String,
            userId: e['user_id'] as String,
            points: e['points'] as int,
            reason: e['reason'] as String,
            createdAt: DateTime.parse(e['created_at'] as String),
          )).toList());
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, RedeemVoucher>> redeemReward({
    required String userId,
    required Reward reward,
  }) async {
    try {
      // Check sufficient points
      final pointsResult = await getUserPoints(userId);
      final points = pointsResult.fold((_) => null, (p) => p);
      if (points == null || points.totalPoints < reward.pointsCost) {
        return left(const ValidationFailure('Poin tidak cukup'));
      }

      // Deduct points
      await _client.from('point_transactions').insert({
        'user_id': userId,
        'points': -reward.pointsCost,
        'reason': 'Redeem: ${reward.name}',
      });

      await _client.from('user_points').upsert({
        'user_id': userId,
        'total_points': points.totalPoints - reward.pointsCost,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Generate voucher code
      final code = _generateCode(reward.id);
      return right(RedeemVoucher(
        code: code,
        rewardName: reward.name,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ));
    } on PostgrestException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  String _generateCode(String rewardId) {
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    final prefix = rewardId.split('-').first.toUpperCase().substring(0, 3);
    return '$prefix-$rand';
  }
}

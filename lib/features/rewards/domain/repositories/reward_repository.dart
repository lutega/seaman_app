import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reward.dart';

abstract interface class RewardRepository {
  Future<Either<Failure, UserPoints?>> getUserPoints(String userId);
  Future<Either<Failure, List<PointTransaction>>> getTransactions(String userId);
  Future<Either<Failure, RedeemVoucher>> redeemReward({
    required String userId,
    required Reward reward,
  });
}

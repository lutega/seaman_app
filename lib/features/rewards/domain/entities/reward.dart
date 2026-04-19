class UserPoints {
  final String userId;
  final int totalPoints;
  final int streakCount;
  final DateTime updatedAt;

  const UserPoints({
    required this.userId,
    required this.totalPoints,
    required this.streakCount,
    required this.updatedAt,
  });
}

enum RewardPhase { mvp, phase2, phase3 }

class Reward {
  final String id;
  final String name;
  final String subtitle;
  final int pointsCost;
  final RewardPhase phase;
  final String? thumbnailUrl;

  const Reward({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.pointsCost,
    required this.phase,
    this.thumbnailUrl,
  });

  bool get isAvailable => phase == RewardPhase.mvp;
}

class PointTransaction {
  final String id;
  final String userId;
  final int points;
  final String reason;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.reason,
    required this.createdAt,
  });

  bool get isEarning => points > 0;
}

class RedeemVoucher {
  final String code;
  final String rewardName;
  final DateTime expiresAt;

  const RedeemVoucher({
    required this.code,
    required this.rewardName,
    required this.expiresAt,
  });
}

// MVP rewards catalog (hardcoded for MVP)
final mvpRewards = [
  const Reward(
    id: 'badge-bst',
    name: 'Badge BST',
    subtitle: 'Digital badge Basic Safety Training',
    pointsCost: 0,
    phase: RewardPhase.mvp,
  ),
  const Reward(
    id: 'voucher-cafetaria',
    name: 'Voucher Cafetaria',
    subtitle: 'Rp 25.000 di cafetaria PMTC',
    pointsCost: 50,
    phase: RewardPhase.mvp,
  ),
  const Reward(
    id: 'voucher-parkir',
    name: 'Voucher Parkir',
    subtitle: 'Parkir gratis 1 hari di PMTC',
    pointsCost: 30,
    phase: RewardPhase.mvp,
  ),
  const Reward(
    id: 'tshirt-pmtc',
    name: 'Kaos PMTC',
    subtitle: 'Merchandise eksklusif PMTC',
    pointsCost: 200,
    phase: RewardPhase.phase2,
  ),
  const Reward(
    id: 'discount-course',
    name: 'Diskon Kursus 10%',
    subtitle: 'Potongan biaya kursus berikutnya',
    pointsCost: 300,
    phase: RewardPhase.phase3,
  ),
];

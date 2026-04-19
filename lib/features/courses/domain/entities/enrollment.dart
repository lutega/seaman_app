class Enrollment {
  final String id;
  final String userId;
  final String courseId;
  final DateTime referralClickedAt;
  final DateTime? partnerConfirmedAt;
  final String? partnerConfirmedStatus;
  final int? commissionAmountIdr;

  const Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.referralClickedAt,
    this.partnerConfirmedAt,
    this.partnerConfirmedStatus,
    this.commissionAmountIdr,
  });
}

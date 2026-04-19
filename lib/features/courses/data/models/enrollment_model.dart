import '../../domain/entities/enrollment.dart';

class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final String referralClickedAt;
  final String? partnerConfirmedAt;
  final String? partnerConfirmedStatus;
  final int? commissionAmountIdr;

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.referralClickedAt,
    this.partnerConfirmedAt,
    this.partnerConfirmedStatus,
    this.commissionAmountIdr,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) => EnrollmentModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        courseId: json['course_id'] as String,
        referralClickedAt: json['referral_clicked_at'] as String,
        partnerConfirmedAt: json['partner_confirmed_at'] as String?,
        partnerConfirmedStatus: json['partner_confirmed_status'] as String?,
        commissionAmountIdr: json['commission_amount_idr'] as int?,
      );

  Enrollment toDomain() => Enrollment(
        id: id,
        userId: userId,
        courseId: courseId,
        referralClickedAt: DateTime.parse(referralClickedAt),
        partnerConfirmedAt:
            partnerConfirmedAt != null ? DateTime.parse(partnerConfirmedAt!) : null,
        partnerConfirmedStatus: partnerConfirmedStatus,
        commissionAmountIdr: commissionAmountIdr,
      );
}

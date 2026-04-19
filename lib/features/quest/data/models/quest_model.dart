import '../../domain/entities/quest.dart';

class QuestModel {
  final String id;
  final String enrollmentId;
  final String stepKey;
  final String stepLabel;
  final String status;
  final int? pointsAwarded;
  final String? hintLocation;
  final String? hintContact;
  final String? hintDeadline;
  final String? completedAt;

  const QuestModel({
    required this.id,
    required this.enrollmentId,
    required this.stepKey,
    required this.stepLabel,
    required this.status,
    this.pointsAwarded,
    this.hintLocation,
    this.hintContact,
    this.hintDeadline,
    this.completedAt,
  });

  factory QuestModel.fromJson(Map<String, dynamic> j) => QuestModel(
        id: j['id'] as String,
        enrollmentId: j['enrollment_id'] as String,
        stepKey: j['step_key'] as String,
        stepLabel: j['step_label'] as String,
        status: j['status'] as String? ?? 'locked',
        pointsAwarded: j['points_awarded'] as int?,
        hintLocation: j['hint_location'] as String?,
        hintContact: j['hint_contact'] as String?,
        hintDeadline: j['hint_deadline'] as String?,
        completedAt: j['completed_at'] as String?,
      );

  Quest toDomain() => Quest(
        id: id,
        enrollmentId: enrollmentId,
        stepKey: stepKey,
        stepLabel: stepLabel,
        status: _parseStatus(status),
        pointsAwarded: pointsAwarded,
        hintLocation: hintLocation,
        hintContact: hintContact,
        hintDeadline: hintDeadline != null ? DateTime.parse(hintDeadline!) : null,
        completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      );

  static QuestStepStatus _parseStatus(String s) => switch (s) {
        'done' => QuestStepStatus.done,
        'current' => QuestStepStatus.current,
        _ => QuestStepStatus.locked,
      };
}

enum QuestStepStatus { locked, current, done }

class Quest {
  final String id;
  final String enrollmentId;
  final String stepKey;
  final String stepLabel;
  final QuestStepStatus status;
  final int? pointsAwarded;
  final String? hintLocation;
  final String? hintContact;
  final DateTime? hintDeadline;
  final DateTime? completedAt;

  const Quest({
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

  bool get isDone => status == QuestStepStatus.done;
  bool get isCurrent => status == QuestStepStatus.current;
  bool get isLocked => status == QuestStepStatus.locked;
  bool get isFinalStep => stepKey == 'certificate_received';
}

const questSteps = [
  ('payment_done', 'Pembayaran Selesai', 10),
  ('docs_uploaded', 'Dokumen Diupload', 25),
  ('partner_verified', 'Verifikasi Partner', 20),
  ('briefing_attended', 'Briefing Dihadiri', 30),
  ('checked_in', 'Check-in', 15),
  ('class_attended', 'Kelas Dihadiri', 20),
  ('exam_passed', 'Ujian Lulus', 30),
  ('certificate_received', 'Sertifikat Diterima', 100),
];

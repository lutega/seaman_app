import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';
import '../models/quest_model.dart';

class QuestRepositoryImpl implements QuestRepository {
  final SupabaseClient _client;
  QuestRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<Quest>>> getQuestsForEnrollment(String enrollmentId) async {
    try {
      final data = await _client
          .from('quests')
          .select()
          .eq('enrollment_id', enrollmentId)
          .order('created_at');

      if ((data as List).isEmpty) {
        // Return placeholder quests if none in DB
        return right(_placeholderQuests(enrollmentId));
      }
      return right(data.map((e) => QuestModel.fromJson(e).toDomain()).toList());
    } catch (_) {
      return right(_placeholderQuests(enrollmentId));
    }
  }

  @override
  Future<Either<Failure, Quest>> getQuestById(String questId) async {
    try {
      final data = await _client.from('quests').select().eq('id', questId).single();
      return right(QuestModel.fromJson(data).toDomain());
    } catch (_) {
      return left(const NotFoundFailure());
    }
  }

  List<Quest> _placeholderQuests(String enrollmentId) {
    return [
      ('payment_done', 'Pembayaran Selesai', 10, QuestStepStatus.current),
      ('docs_uploaded', 'Dokumen Diupload', 25, QuestStepStatus.locked),
      ('partner_verified', 'Verifikasi Partner', 20, QuestStepStatus.locked),
      ('briefing_attended', 'Briefing Dihadiri', 30, QuestStepStatus.locked),
      ('checked_in', 'Check-in Lokasi', 15, QuestStepStatus.locked),
      ('class_attended', 'Kelas Dihadiri', 20, QuestStepStatus.locked),
      ('exam_passed', 'Ujian Lulus', 30, QuestStepStatus.locked),
      ('certificate_received', 'Sertifikat Diterima', 100, QuestStepStatus.locked),
    ].indexed.map((e) => Quest(
          id: 'placeholder-${e.$1}',
          enrollmentId: enrollmentId,
          stepKey: e.$2.$1,
          stepLabel: e.$2.$2,
          status: e.$2.$4,
          pointsAwarded: e.$2.$3,
        )).toList();
  }
}

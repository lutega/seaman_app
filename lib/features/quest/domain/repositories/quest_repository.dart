import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quest.dart';

abstract interface class QuestRepository {
  Future<Either<Failure, List<Quest>>> getQuestsForEnrollment(String enrollmentId);
  Future<Either<Failure, Quest>> getQuestById(String questId);
}

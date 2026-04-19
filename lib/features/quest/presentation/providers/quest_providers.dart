import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/quest_repository_impl.dart';
import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return QuestRepositoryImpl(Supabase.instance.client);
});

final questsForEnrollmentProvider =
    FutureProvider.family<List<Quest>, String>((ref, enrollmentId) async {
  final repo = ref.watch(questRepositoryProvider);
  final result = await repo.getQuestsForEnrollment(enrollmentId);
  return result.fold((f) => throw f.message, (q) => q);
});

final questDetailProvider = FutureProvider.family<Quest, String>((ref, questId) async {
  final repo = ref.watch(questRepositoryProvider);
  final result = await repo.getQuestById(questId);
  return result.fold((f) => throw f.message, (q) => q);
});

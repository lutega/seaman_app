import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/course_repository.dart';
import '../models/course_model.dart';
import '../models/enrollment_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final SupabaseClient _client;

  CourseRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<Course>>> getCourses({
    CourseCategory? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('courses')
          .select('*, partners(name, logo_url)')
          .eq('is_active', true)
          .order('starts_at')
          .range(offset, offset + limit - 1);

      if (category != null) {
        query = query.eq('category', category.name);
      }

      if (search != null && search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      final data = await query;
      final courses = (data as List).map((e) => CourseModel.fromJson(e).toDomain()).toList();
      return right(courses);
    } on PostgrestException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
    try {
      final data = await _client
          .from('courses')
          .select('*, partners(name, logo_url)')
          .eq('id', id)
          .single();
      return right(CourseModel.fromJson(data).toDomain());
    } on PostgrestException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Enrollment>> createEnrollment({
    required String userId,
    required String courseId,
  }) async {
    try {
      final data = await _client
          .from('enrollments')
          .insert({'user_id': userId, 'course_id': courseId})
          .select()
          .single();
      return right(EnrollmentModel.fromJson(data).toDomain());
    } on PostgrestException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getTrackingUrl({
    required String userId,
    required String courseId,
    required String externalUrl,
    required String referralSlug,
  }) async {
    try {
      // Ideally call Edge Function track-referral; for MVP build URL client-side
      final uri = Uri.parse(externalUrl);
      final tracked = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'ref': 'seaready',
        'partner': referralSlug,
        'uid': userId.substring(0, 8),
      });
      return right(tracked.toString());
    } catch (_) {
      return right(externalUrl);
    }
  }

  @override
  Future<Either<Failure, List<Enrollment>>> getUserEnrollments(String userId) async {
    try {
      final data = await _client
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final enrollments =
          (data as List).map((e) => EnrollmentModel.fromJson(e).toDomain()).toList();
      return right(enrollments);
    } catch (_) {
      return left(const NetworkFailure());
    }
  }
}

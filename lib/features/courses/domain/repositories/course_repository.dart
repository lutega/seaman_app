import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course.dart';
import '../entities/enrollment.dart';

abstract interface class CourseRepository {
  Future<Either<Failure, List<Course>>> getCourses({
    CourseCategory? category,
    String? search,
    int limit,
    int offset,
  });

  Future<Either<Failure, Course>> getCourseById(String id);

  Future<Either<Failure, Enrollment>> createEnrollment({
    required String userId,
    required String courseId,
  });

  Future<Either<Failure, String>> getTrackingUrl({
    required String userId,
    required String courseId,
    required String externalUrl,
    required String referralSlug,
  });

  Future<Either<Failure, List<Enrollment>>> getUserEnrollments(String userId);
}

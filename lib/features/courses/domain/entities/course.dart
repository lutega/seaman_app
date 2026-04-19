class Course {
  final String id;
  final String partnerId;
  final String partnerName;
  final String? partnerLogoUrl;
  final String name;
  final String code;
  final CourseCategory category;
  final int? durationDays;
  final int priceIdr;
  final String? description;
  final String externalUrl;
  final DateTime startsAt;
  final DateTime registrationDeadline;
  final int? quota;
  final bool isActive;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    this.partnerLogoUrl,
    required this.name,
    required this.code,
    required this.category,
    this.durationDays,
    required this.priceIdr,
    this.description,
    required this.externalUrl,
    required this.startsAt,
    required this.registrationDeadline,
    this.quota,
    required this.isActive,
    required this.createdAt,
  });

  bool get isRegistrationOpen => registrationDeadline.isAfter(DateTime.now());
  bool get isUpcoming => startsAt.isAfter(DateTime.now());

  int get daysUntilDeadline =>
      registrationDeadline.difference(DateTime.now()).inDays;
}

enum CourseCategory { renewal, rating, initial }

extension CourseCategoryX on CourseCategory {
  String get label => switch (this) {
        CourseCategory.renewal => 'Renewal',
        CourseCategory.rating => 'Rating',
        CourseCategory.initial => 'Initial',
      };
}

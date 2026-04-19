import '../../domain/entities/course.dart';

class CourseModel {
  final String id;
  final String partnerId;
  final String? partnerName;
  final String? partnerLogoUrl;
  final String name;
  final String code;
  final String category;
  final int? durationDays;
  final int priceIdr;
  final String? description;
  final String externalUrl;
  final String startsAt;
  final String registrationDeadline;
  final int? quota;
  final bool isActive;
  final String createdAt;

  const CourseModel({
    required this.id,
    required this.partnerId,
    this.partnerName,
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

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final partner = json['partners'] as Map<String, dynamic>?;
    return CourseModel(
      id: json['id'] as String,
      partnerId: json['partner_id'] as String,
      partnerName: partner?['name'] as String? ?? json['partner_name'] as String?,
      partnerLogoUrl: partner?['logo_url'] as String?,
      name: json['name'] as String,
      code: json['code'] as String,
      category: json['category'] as String,
      durationDays: json['duration_days'] as int?,
      priceIdr: (json['price_idr'] as num).toInt(),
      description: json['description'] as String?,
      externalUrl: json['external_url'] as String,
      startsAt: json['starts_at'] as String,
      registrationDeadline: json['registration_deadline'] as String,
      quota: json['quota'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String,
    );
  }

  Course toDomain() => Course(
        id: id,
        partnerId: partnerId,
        partnerName: partnerName ?? 'Unknown',
        partnerLogoUrl: partnerLogoUrl,
        name: name,
        code: code,
        category: _parseCategory(category),
        durationDays: durationDays,
        priceIdr: priceIdr,
        description: description,
        externalUrl: externalUrl,
        startsAt: DateTime.parse(startsAt),
        registrationDeadline: DateTime.parse(registrationDeadline),
        quota: quota,
        isActive: isActive,
        createdAt: DateTime.parse(createdAt),
      );

  static CourseCategory _parseCategory(String s) => switch (s) {
        'renewal' => CourseCategory.renewal,
        'rating' => CourseCategory.rating,
        _ => CourseCategory.initial,
      };
}

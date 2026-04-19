import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sea_profile.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, SeaProfile?>> getProfile(String userId);
  Future<Either<Failure, SeaProfile>> createProfile(CreateProfileParams params);
  Future<Either<Failure, SeaProfile>> updateProfile(UpdateProfileParams params);
  Future<Either<Failure, String>> uploadDocument(String filePath, String fileName);
}

class CreateProfileParams {
  final String userId;
  final String fullName;
  final DateTime birthDate;
  final String nik;
  final String address;
  final String? seafarerNumber;
  final String? phone;
  final String? ktpDocumentUrl;
  final String? selfieDocumentUrl;

  const CreateProfileParams({
    required this.userId,
    required this.fullName,
    required this.birthDate,
    required this.nik,
    required this.address,
    this.seafarerNumber,
    this.phone,
    this.ktpDocumentUrl,
    this.selfieDocumentUrl,
  });
}

class UpdateProfileParams {
  final String userId;
  final String? fullName;
  final DateTime? birthDate;
  final String? address;
  final String? seafarerNumber;
  final String? phone;
  final String? avatarUrl;

  const UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.birthDate,
    this.address,
    this.seafarerNumber,
    this.phone,
    this.avatarUrl,
  });
}

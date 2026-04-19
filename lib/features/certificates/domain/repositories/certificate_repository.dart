import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/certificate.dart';

abstract interface class CertificateRepository {
  Future<Either<Failure, List<Certificate>>> getCertificates(String userId);
  Future<Either<Failure, Certificate>> getCertificateById(String id);
  Future<Either<Failure, Certificate>> addCertificate(AddCertParams params);
  Future<Either<Failure, Certificate>> updateCertificate(UpdateCertParams params);
  Future<Either<Failure, Unit>> deleteCertificate(String id);
  Future<Either<Failure, String>> uploadDocument(String filePath, String certId);
}

class AddCertParams {
  final String userId;
  final String name;
  final String type;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String? issuer;
  final String? documentUrl;

  const AddCertParams({
    required this.userId,
    required this.name,
    required this.type,
    required this.issuedDate,
    required this.expiryDate,
    this.issuer,
    this.documentUrl,
  });
}

class UpdateCertParams {
  final String id;
  final String? name;
  final String? type;
  final DateTime? issuedDate;
  final DateTime? expiryDate;
  final String? issuer;
  final String? documentUrl;

  const UpdateCertParams({
    required this.id,
    this.name,
    this.type,
    this.issuedDate,
    this.expiryDate,
    this.issuer,
    this.documentUrl,
  });
}

import '../../domain/entities/certificate.dart';

class CertificateModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String issuedDate;
  final String expiryDate;
  final String? issuer;
  final String? documentUrl;
  final bool isVerified;
  final String createdAt;

  const CertificateModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.issuedDate,
    required this.expiryDate,
    this.issuer,
    this.documentUrl,
    required this.isVerified,
    required this.createdAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> j) => CertificateModel(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        issuedDate: j['issued_date'] as String,
        expiryDate: j['expiry_date'] as String,
        issuer: j['issuer'] as String?,
        documentUrl: j['document_url'] as String?,
        isVerified: j['is_verified'] as bool? ?? false,
        createdAt: j['created_at'] as String,
      );

  Certificate toDomain() => Certificate(
        id: id,
        userId: userId,
        name: name,
        type: type,
        issuedDate: DateTime.parse(issuedDate),
        expiryDate: DateTime.parse(expiryDate),
        issuer: issuer,
        documentUrl: documentUrl,
        isVerified: isVerified,
        createdAt: DateTime.parse(createdAt),
      );
}

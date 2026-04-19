import '../../domain/entities/sea_profile.dart';

class ProfileModel {
  final String id;
  final String fullName;
  final String birthDate;
  final String nikEncrypted;
  final String nikLast4;
  final String address;
  final String? seafarerNumber;
  final String? phone;
  final String? avatarUrl;
  final String? ktpDocumentUrl;
  final String? selfieDocumentUrl;
  final String verificationStatus;
  final String createdAt;
  final String updatedAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.nikEncrypted,
    required this.nikLast4,
    required this.address,
    this.seafarerNumber,
    this.phone,
    this.avatarUrl,
    this.ktpDocumentUrl,
    this.selfieDocumentUrl,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        birthDate: json['birth_date'] as String,
        nikEncrypted: json['nik_encrypted'] as String,
        nikLast4: json['nik_last_4'] as String,
        address: json['address'] as String,
        seafarerNumber: json['seafarer_number'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        ktpDocumentUrl: json['ktp_document_url'] as String?,
        selfieDocumentUrl: json['selfie_document_url'] as String?,
        verificationStatus: json['verification_status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'birth_date': birthDate,
        'nik_encrypted': nikEncrypted,
        'nik_last_4': nikLast4,
        'address': address,
        if (seafarerNumber != null) 'seafarer_number': seafarerNumber,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (ktpDocumentUrl != null) 'ktp_document_url': ktpDocumentUrl,
        if (selfieDocumentUrl != null) 'selfie_document_url': selfieDocumentUrl,
        'verification_status': verificationStatus,
      };

  SeaProfile toDomain() => SeaProfile(
        id: id,
        fullName: fullName,
        birthDate: DateTime.parse(birthDate),
        nikEncrypted: nikEncrypted,
        nikLast4: nikLast4,
        address: address,
        seafarerNumber: seafarerNumber,
        phone: phone,
        avatarUrl: avatarUrl,
        ktpDocumentUrl: ktpDocumentUrl,
        selfieDocumentUrl: selfieDocumentUrl,
        verificationStatus: _parseStatus(verificationStatus),
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );

  static VerificationStatus _parseStatus(String s) => switch (s) {
        'verified' => VerificationStatus.verified,
        'rejected' => VerificationStatus.rejected,
        _ => VerificationStatus.pending,
      };
}

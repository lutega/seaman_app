enum VerificationStatus { pending, verified, rejected }

class SeaProfile {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String nikEncrypted;
  final String nikLast4;
  final String address;
  final String? seafarerNumber;
  final String? phone;
  final String? avatarUrl;
  final String? ktpDocumentUrl;
  final String? selfieDocumentUrl;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SeaProfile({
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

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool get isVerified => verificationStatus == VerificationStatus.verified;
  bool get isPending => verificationStatus == VerificationStatus.pending;
}

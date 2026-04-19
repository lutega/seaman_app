enum CertStatus { valid, warning, urgent, expired }

class Certificate {
  final String id;
  final String userId;
  final String name;
  final String type;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String? issuer;
  final String? documentUrl;
  final bool isVerified;
  final DateTime createdAt;

  const Certificate({
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

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  CertStatus get status {
    final d = daysUntilExpiry;
    if (d < 0) return CertStatus.expired;
    if (d <= 7) return CertStatus.urgent;
    if (d <= 30) return CertStatus.warning;
    return CertStatus.valid;
  }
}

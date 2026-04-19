import 'package:flutter/material.dart';

class CertificateDetailScreen extends StatelessWidget {
  final String certId;
  const CertificateDetailScreen({super.key, required this.certId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Sertifikat')),
      body: Center(child: Text('Certificate: $certId')),
    );
  }
}

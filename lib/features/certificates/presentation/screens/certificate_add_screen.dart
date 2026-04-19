import 'package:flutter/material.dart';

class CertificateAddScreen extends StatelessWidget {
  const CertificateAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Sertifikat')),
      body: const Center(child: Text('Form tambah sertifikat')),
    );
  }
}

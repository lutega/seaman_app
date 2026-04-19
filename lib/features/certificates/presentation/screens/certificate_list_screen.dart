import 'package:flutter/material.dart';
import '../../../../shared/widgets/sr_empty_state.dart';

class CertificateListScreen extends StatelessWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sertifikat Saya')),
      body: SrEmptyState(
        title: 'Belum ada sertifikat',
        subtitle: 'Tambahkan sertifikat untuk mendapat pengingat kedaluwarsa',
        icon: Icons.workspace_premium_outlined,
        actionLabel: 'Tambah Sertifikat',
        onAction: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

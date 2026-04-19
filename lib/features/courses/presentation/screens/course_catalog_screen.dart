import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sr_empty_state.dart';

class CourseCatalogScreen extends StatelessWidget {
  const CourseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kursus Tersedia'),
        actions: [IconButton(icon: const Icon(Icons.tune_outlined), onPressed: () {})],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SrSpacing.md),
            child: SearchBar(
              hintText: 'Cari kursus...',
              leading: const Icon(Icons.search, size: 20),
            ),
          ),
          Expanded(
            child: SrEmptyState(
              title: 'Belum ada kursus',
              subtitle: 'Kursus dari PMTC akan tersedia segera',
              icon: Icons.school_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

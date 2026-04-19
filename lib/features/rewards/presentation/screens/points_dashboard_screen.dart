import 'package:flutter/material.dart';
import '../../../../shared/widgets/sr_empty_state.dart';

class PointsDashboardScreen extends StatelessWidget {
  const PointsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poin Saya')),
      body: SrEmptyState(
        title: 'Belum ada poin',
        subtitle: 'Selesaikan quest untuk mendapatkan poin',
        icon: Icons.stars_outlined,
      ),
    );
  }
}

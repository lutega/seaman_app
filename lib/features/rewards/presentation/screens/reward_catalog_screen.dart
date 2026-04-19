import 'package:flutter/material.dart';
import '../../../../shared/widgets/sr_empty_state.dart';

class RewardCatalogScreen extends StatelessWidget {
  const RewardCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tukarkan Poin')),
      body: SrEmptyState(
        title: 'Reward segera tersedia',
        subtitle: 'Kumpulkan poin dari quest untuk ditukar reward',
        icon: Icons.card_giftcard_outlined,
      ),
    );
  }
}

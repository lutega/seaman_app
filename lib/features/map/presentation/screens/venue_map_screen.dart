import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class VenueMapScreen extends StatelessWidget {
  final String partnerId;
  const VenueMapScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peta Lokasi')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: SrColors.cardBg,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: SrColors.textMuted),
                    SizedBox(height: SrSpacing.md),
                    Text('Peta 2D PMTC', style: TextStyle(color: SrColors.textMuted)),
                    Text('Tampilan 3D segera hadir',
                        style: TextStyle(fontSize: 12, color: SrColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SrSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.navigation_outlined, size: 18),
              label: const Text('Mulai Navigasi'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
            ),
          ),
        ],
      ),
    );
  }
}

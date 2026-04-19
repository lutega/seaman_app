import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class SrLoadingView extends StatelessWidget {
  final int itemCount;
  const SrLoadingView({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(SrSpacing.md),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: SrSpacing.sm),
      itemBuilder: (_, __) => _ShimmerItem(),
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: SrColors.border,
      highlightColor: SrColors.cardBg,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: SrColors.white,
          borderRadius: BorderRadius.circular(SrRadius.md),
        ),
      ),
    );
  }
}

class SrErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const SrErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SrSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: SrColors.textMuted),
            const SizedBox(height: SrSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: SrColors.textMuted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: SrSpacing.md),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


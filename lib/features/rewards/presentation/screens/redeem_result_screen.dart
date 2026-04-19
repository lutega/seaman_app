import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/reward.dart';

class RedeemResultScreen extends StatelessWidget {
  final RedeemVoucher voucher;

  const RedeemResultScreen({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voucher Berhasil')),
      body: Padding(
        padding: const EdgeInsets.all(SrSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: SrSpacing.xl),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: SrColors.successBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline, size: 48, color: SrColors.success),
            ),
            const SizedBox(height: SrSpacing.lg),
            Text(
              'Voucher ${voucher.rewardName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SrColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SrSpacing.md),
            Container(
              padding: const EdgeInsets.all(SrSpacing.lg),
              decoration: BoxDecoration(
                color: SrColors.cardBg,
                borderRadius: BorderRadius.circular(SrRadius.md),
                border: Border.all(color: SrColors.border),
              ),
              child: Column(
                children: [
                  const Text('Kode Voucher', style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
                  const SizedBox(height: SrSpacing.sm),
                  Text(
                    voucher.code,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: SrColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: SrSpacing.sm),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: voucher.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode disalin')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Salin kode'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SrSpacing.md),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 14, color: SrColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Berlaku hingga ${voucher.expiresAt.toDisplayDate()}',
                  style: const TextStyle(fontSize: 12, color: SrColors.textMuted),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}

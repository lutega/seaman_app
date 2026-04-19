import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sr_button.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SrSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SrColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.how_to_reg_outlined, size: 40, color: SrColors.success),
              ),
              const SizedBox(height: SrSpacing.lg),
              const Text(
                'Pendaftaran Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SrColors.textPrimary),
              ),
              const SizedBox(height: SrSpacing.sm),
              const Text(
                'Cek email Anda untuk verifikasi akun.\nSetelah verifikasi, tim kami akan memproses dokumen Anda dalam 1-2 hari kerja.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: SrColors.textMuted, height: 1.6),
              ),
              const SizedBox(height: SrSpacing.lg),
              Container(
                padding: const EdgeInsets.all(SrSpacing.md),
                decoration: BoxDecoration(
                  color: SrColors.infoBg,
                  borderRadius: BorderRadius.circular(SrRadius.md),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: SrColors.info),
                    SizedBox(width: SrSpacing.sm),
                    Expanded(
                      child: Text(
                        'Menunggu verifikasi dokumen (1-2 hari kerja)',
                        style: TextStyle(fontSize: 13, color: SrColors.infoText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SrSpacing.xl),
              SrButton(
                label: 'Masuk ke Aplikasi',
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

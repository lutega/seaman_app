import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sr_badge.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../providers/profile_providers.dart';
import '../../domain/entities/sea_profile.dart';

class ProfileViewScreen extends ConsumerWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Pelaut'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const SrLoadingView(itemCount: 4),
        error: (e, _) => SrErrorView(message: e.toString()),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_outlined, size: 48, color: SrColors.textMuted),
                  const SizedBox(height: SrSpacing.md),
                  const Text('Profil belum diisi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: SrSpacing.sm),
                  const Text('Lengkapi data diri untuk verifikasi akun',
                      style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
                  const SizedBox(height: SrSpacing.lg),
                  ElevatedButton(
                    onPressed: () => context.push('/profile/setup'),
                    child: const Text('Lengkapi Sekarang'),
                  ),
                ],
              ),
            );
          }
          return _ProfileContent(profile: profile);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final SeaProfile profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SrSpacing.md),
      children: [
        _buildVerificationBanner(),
        const SizedBox(height: SrSpacing.md),
        _buildSection('Data Pribadi', [
          _infoRow('Nama Lengkap', profile.fullName),
          _infoRow('Tanggal Lahir', _formatDate(profile.birthDate)),
          _infoRow('Usia', '${profile.age} tahun'),
          _infoRow('No. KTP (NIK)', '●●●● ●●●● ●●●● ${profile.nikLast4}'),
          _infoRow('Alamat', profile.address),
          if (profile.seafarerNumber != null)
            _infoRow('No. Pelaut', profile.seafarerNumber!),
        ]),
        const SizedBox(height: SrSpacing.md),
        _buildSection('Dokumen', [
          _documentRow('Foto KTP', profile.ktpDocumentUrl != null),
          _documentRow('Selfie Verifikasi', profile.selfieDocumentUrl != null),
        ]),
      ],
    );
  }

  Widget _buildVerificationBanner() {
    final (bg, border, icon, text, badgeVariant) = switch (profile.verificationStatus) {
      VerificationStatus.verified => (
          SrColors.successBg,
          SrColors.success,
          Icons.verified_outlined,
          'Akun Anda telah terverifikasi',
          SrBadgeVariant.success,
        ),
      VerificationStatus.rejected => (
          SrColors.dangerBg,
          SrColors.danger,
          Icons.cancel_outlined,
          'Verifikasi ditolak. Hubungi admin untuk informasi lebih lanjut.',
          SrBadgeVariant.danger,
        ),
      VerificationStatus.pending => (
          SrColors.warningBg,
          SrColors.warning,
          Icons.hourglass_top_outlined,
          'Menunggu verifikasi dari tim (1-2 hari kerja)',
          SrBadgeVariant.warning,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SrRadius.md),
        border: Border.all(color: border.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: border),
          const SizedBox(width: SrSpacing.sm),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: border))),
          SrBadge(label: profile.verificationStatus.name, variant: badgeVariant),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: SrColors.textMuted, letterSpacing: 1.2)),
        const SizedBox(height: SrSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: SrColors.cardBg,
            borderRadius: BorderRadius.circular(SrRadius.md),
            border: Border.all(color: SrColors.border, width: 0.5),
          ),
          child: Column(
            children: children.indexed
                .map((e) => Column(
                      children: [
                        e.$2,
                        if (e.$1 < children.length - 1)
                          const Divider(height: 1, indent: SrSpacing.md),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SrSpacing.md, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: SrColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: SrColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _documentRow(String label, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SrSpacing.md, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: SrColors.textMuted)),
          ),
          Icon(
            uploaded ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 18,
            color: uploaded ? SrColors.success : SrColors.border,
          ),
          const SizedBox(width: 4),
          Text(
            uploaded ? 'Terupload' : 'Belum',
            style: TextStyle(
              fontSize: 12,
              color: uploaded ? SrColors.success : SrColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';
}

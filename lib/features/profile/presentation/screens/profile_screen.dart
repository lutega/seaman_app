import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/sea_profile.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileAsync.when(
        loading: () => _buildSkeleton(),
        error: (_, __) => _buildBody(context, ref, null),
        data: (profile) => _buildBody(context, ref, profile),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, SeaProfile? profile) {
    return ListView(
      children: [
        const SizedBox(height: SrSpacing.lg),
        _buildHero(context, profile),
        const SizedBox(height: SrSpacing.md),
        if (profile != null) _buildStatsRow(profile),
        const Divider(height: SrSpacing.lg),
        _menuItem(context,
            icon: Icons.person_outline,
            label: 'Buku Pelaut',
            subtitle: profile != null ? 'Lihat & edit data diri' : 'Belum diisi',
            onTap: () => profile != null
                ? context.push('/profile/view')
                : context.push('/profile/setup')),
        _menuItem(context,
            icon: Icons.edit_outlined,
            label: 'Edit Profil',
            onTap: () => profile != null
                ? context.push('/profile/edit')
                : context.push('/profile/setup')),
        _menuItem(context,
            icon: Icons.notifications_outlined,
            label: 'Pengaturan Notifikasi',
            onTap: () {}),
        _menuItem(context, icon: Icons.help_outline, label: 'Bantuan', onTap: () {}),
        const Divider(),
        _menuItem(
          context,
          icon: Icons.logout,
          label: 'Keluar',
          color: SrColors.danger,
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Keluar'),
                content: const Text('Yakin ingin keluar dari akun?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Keluar', style: TextStyle(color: SrColors.danger)),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            }
          },
        ),
        const SizedBox(height: SrSpacing.xl),
      ],
    );
  }

  Widget _buildHero(BuildContext context, SeaProfile? profile) {
    final verificationWidget = profile == null
        ? _statusChip('Belum diisi', SrColors.textMuted, SrColors.cardBg)
        : switch (profile.verificationStatus) {
            VerificationStatus.verified =>
              _statusChip('Terverifikasi', SrColors.successText, SrColors.successBg),
            VerificationStatus.pending =>
              _statusChip('Menunggu verifikasi', SrColors.warningText, SrColors.warningBg),
            VerificationStatus.rejected =>
              _statusChip('Ditolak', SrColors.dangerText, SrColors.dangerBg),
          };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SrSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: SrColors.lightMint,
            backgroundImage: profile?.avatarUrl != null
                ? NetworkImage(profile!.avatarUrl!)
                : null,
            child: profile?.avatarUrl == null
                ? const Icon(Icons.person, size: 32, color: SrColors.primary)
                : null,
          ),
          const SizedBox(width: SrSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.fullName ?? 'Nama belum diisi',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text('Pelaut', style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
                const SizedBox(height: 4),
                verificationWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(SeaProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SrSpacing.lg),
      child: Row(
        children: [
          _statCard('Sertifikat Aktif', '—'),
          const SizedBox(width: SrSpacing.sm),
          _statCard('Kursus Selesai', '—'),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SrSpacing.md),
        decoration: BoxDecoration(
          color: SrColors.cardBg,
          borderRadius: BorderRadius.circular(SrRadius.sm),
          border: Border.all(color: SrColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: SrColors.primary)),
            Text(label, style: const TextStyle(fontSize: 12, color: SrColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SrRadius.xs),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600)),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final textColor = color ?? SrColors.textPrimary;
    return ListTile(
      leading: Icon(icon, size: 22, color: textColor),
      title: Text(label, style: TextStyle(fontSize: 15, color: textColor)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: SrColors.textMuted))
          : null,
      trailing: color == null
          ? const Icon(Icons.chevron_right, size: 20, color: SrColors.textMuted)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSkeleton() {
    return const Center(child: CircularProgressIndicator());
  }
}

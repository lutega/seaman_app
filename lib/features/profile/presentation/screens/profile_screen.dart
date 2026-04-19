import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          const SizedBox(height: SrSpacing.lg),
          _buildHero(context),
          const SizedBox(height: SrSpacing.md),
          const Divider(),
          _menuItem(context, icon: Icons.edit_outlined, label: 'Edit Profil', onTap: () {}),
          _menuItem(context, icon: Icons.book_outlined, label: 'Buku Pelaut', onTap: () => context.push('/profile/setup')),
          _menuItem(context, icon: Icons.notifications_outlined, label: 'Pengaturan Notifikasi', onTap: () {}),
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
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
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
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SrSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: SrColors.lightMint,
            child: const Icon(Icons.person, size: 32, color: SrColors.primary),
          ),
          const SizedBox(width: SrSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Pelaut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Pelaut', style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: SrColors.warningBg,
                    borderRadius: BorderRadius.circular(SrRadius.xs),
                  ),
                  child: const Text('Menunggu verifikasi',
                      style: TextStyle(fontSize: 11, color: SrColors.warningText, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final textColor = color ?? SrColors.textPrimary;
    return ListTile(
      leading: Icon(icon, size: 22, color: textColor),
      title: Text(label, style: TextStyle(fontSize: 15, color: textColor)),
      trailing: color == null ? const Icon(Icons.chevron_right, size: 20, color: SrColors.textMuted) : null,
      onTap: onTap,
    );
  }
}

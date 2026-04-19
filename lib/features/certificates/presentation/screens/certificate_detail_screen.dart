import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/sr_badge.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../domain/entities/certificate.dart';
import '../providers/certificate_providers.dart';

class CertificateDetailScreen extends ConsumerWidget {
  final String certId;
  const CertificateDetailScreen({super.key, required this.certId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certAsync = ref.watch(certificateDetailProvider(certId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Sertifikat'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: SrColors.danger))),
            ],
            onSelected: (v) async {
              if (v == 'delete') await _confirmDelete(context, ref);
            },
          ),
        ],
      ),
      body: certAsync.when(
        loading: () => const SrLoadingView(itemCount: 4),
        error: (e, _) => SrErrorView(message: e.toString()),
        data: (cert) => _CertDetail(cert: cert),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Sertifikat'),
        content: const Text('Sertifikat yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: SrColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final repo = ref.read(certificateRepositoryProvider);
    await repo.deleteCertificate(certId);
    ref.invalidate(certificatesProvider);
    if (context.mounted) context.pop();
  }
}

class _CertDetail extends StatelessWidget {
  final Certificate cert;
  const _CertDetail({required this.cert});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (cert.status) {
      CertStatus.valid => SrColors.success,
      CertStatus.warning => SrColors.warning,
      CertStatus.urgent || CertStatus.expired => SrColors.danger,
    };
    final badgeVariant = switch (cert.status) {
      CertStatus.valid => SrBadgeVariant.success,
      CertStatus.warning => SrBadgeVariant.warning,
      CertStatus.urgent || CertStatus.expired => SrBadgeVariant.danger,
    };
    final statusLabel = switch (cert.status) {
      CertStatus.valid => 'Valid',
      CertStatus.warning => '${cert.daysUntilExpiry} hari lagi',
      CertStatus.urgent => '${cert.daysUntilExpiry} hari lagi',
      CertStatus.expired => 'Expired',
    };

    return ListView(
      padding: const EdgeInsets.all(SrSpacing.md),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(SrSpacing.lg),
          decoration: BoxDecoration(
            color: SrColors.primaryDark,
            borderRadius: BorderRadius.circular(SrRadius.md),
          ),
          child: Column(
            children: [
              Icon(Icons.workspace_premium, size: 48, color: statusColor),
              const SizedBox(height: SrSpacing.sm),
              Text(cert.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SrColors.white)),
              if (cert.issuer != null)
                Text(cert.issuer!,
                    style: const TextStyle(fontSize: 13, color: Colors.white60)),
              const SizedBox(height: SrSpacing.sm),
              SrBadge(label: statusLabel, variant: badgeVariant),
            ],
          ),
        ),
        const SizedBox(height: SrSpacing.md),

        // Info
        _section('Informasi Sertifikat', [
          _row('Jenis', cert.type),
          _row('Tanggal Terbit', cert.issuedDate.toDisplayDate()),
          _row('Berlaku Hingga', cert.expiryDate.toDisplayDate(),
              valueColor: statusColor),
          _row('Status Verifikasi', cert.isVerified ? 'Terverifikasi' : 'Belum diverifikasi',
              valueColor: cert.isVerified ? SrColors.success : SrColors.textMuted),
        ]),

        if (cert.status != CertStatus.valid) ...[
          const SizedBox(height: SrSpacing.md),
          _renewalBanner(context, cert),
        ],

        if (cert.documentUrl != null) ...[
          const SizedBox(height: SrSpacing.md),
          SrButton(
            label: 'Lihat Dokumen',
            variant: SrButtonVariant.secondary,
            leadingIcon: Icons.file_open_outlined,
            onPressed: () async {
              final uri = Uri.parse(cert.documentUrl!);
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
          ),
        ],
      ],
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: SrColors.textMuted, letterSpacing: 1.2)),
        const SizedBox(height: SrSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: SrColors.cardBg,
            borderRadius: BorderRadius.circular(SrRadius.md),
            border: Border.all(color: SrColors.border, width: 0.5),
          ),
          child: Column(
            children: rows.indexed
                .map((e) => Column(children: [
                      e.$2,
                      if (e.$1 < rows.length - 1) const Divider(height: 1, indent: SrSpacing.md),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SrSpacing.md, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: SrColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? SrColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _renewalBanner(BuildContext context, Certificate cert) {
    return Container(
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: SrColors.warningBg,
        borderRadius: BorderRadius.circular(SrRadius.md),
        border: Border.all(color: SrColors.warning.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: SrColors.warning),
              SizedBox(width: SrSpacing.xs),
              Text('Perlu Renewal',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SrColors.warningText)),
            ],
          ),
          const SizedBox(height: SrSpacing.xs),
          const Text('Cari kursus renewal untuk memperbarui sertifikat ini.',
              style: TextStyle(fontSize: 12, color: SrColors.warningText)),
          const SizedBox(height: SrSpacing.sm),
          SrButton(
            label: 'Cari Kursus Renewal',
            variant: SrButtonVariant.secondary,
            isFullWidth: false,
            onPressed: () => context.go('/courses'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sr_badge.dart';
import '../../../../shared/widgets/sr_empty_state.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../domain/entities/certificate.dart';
import '../providers/certificate_providers.dart';

class CertificateListScreen extends ConsumerWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(certificatesProvider);
    final filter = ref.watch(certFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sertifikat Saya')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/certificates/add'),
        child: const Icon(Icons.add),
      ),
      body: certsAsync.when(
        loading: () => const SrLoadingView(itemCount: 4),
        error: (e, _) => SrErrorView(
          message: 'Gagal memuat sertifikat',
          onRetry: () => ref.invalidate(certificatesProvider),
        ),
        data: (certs) {
          final filtered = filter == null
              ? certs
              : certs.where((c) => c.status == filter).toList();

          return Column(
            children: [
              if (certs.isNotEmpty) _StatsCard(certs: certs),
              _FilterChips(selected: filter),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? SrEmptyState(
                        title: filter == null
                            ? 'Belum ada sertifikat'
                            : 'Tidak ada sertifikat ${_filterLabel(filter)}',
                        subtitle: filter == null
                            ? 'Tap + untuk menambahkan sertifikat pertama Anda'
                            : null,
                        icon: Icons.workspace_premium_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(certificatesProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(SrSpacing.md),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: SrSpacing.sm),
                          itemBuilder: (_, i) => _CertificateCard(cert: filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _filterLabel(CertStatus s) => switch (s) {
        CertStatus.valid => 'valid',
        CertStatus.warning => 'expiring soon',
        CertStatus.urgent => 'urgent',
        CertStatus.expired => 'expired',
      };
}

class _StatsCard extends StatelessWidget {
  final List<Certificate> certs;
  const _StatsCard({required this.certs});

  @override
  Widget build(BuildContext context) {
    final active = certs.where((c) => c.status != CertStatus.expired).length;
    final expiring = certs.where((c) =>
        c.status == CertStatus.warning || c.status == CertStatus.urgent).length;

    return Container(
      margin: const EdgeInsets.all(SrSpacing.md),
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SrColors.primaryDark, SrColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SrRadius.md),
      ),
      child: Row(
        children: [
          Expanded(child: _stat('$active', 'Aktif', SrColors.white)),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _stat(
              '$expiring',
              'Segera kedaluwarsa',
              expiring > 0 ? const Color(0xFFFFD700) : SrColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}

class _FilterChips extends ConsumerWidget {
  final CertStatus? selected;
  const _FilterChips({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = <(CertStatus?, String)>[
      (null, 'Semua'),
      (CertStatus.valid, 'Valid'),
      (CertStatus.warning, 'Expiring soon'),
      (CertStatus.expired, 'Expired'),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SrSpacing.md, vertical: SrSpacing.xs),
        children: options.map((opt) {
          final isSelected = opt.$1 == selected;
          return Padding(
            padding: const EdgeInsets.only(right: SrSpacing.xs),
            child: FilterChip(
              label: Text(opt.$2),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) =>
                  ref.read(certFilterProvider.notifier).state = opt.$1,
              selectedColor: SrColors.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? SrColors.white : SrColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(color: isSelected ? SrColors.primary : SrColors.border, width: 0.5),
              backgroundColor: SrColors.white,
              padding: EdgeInsets.zero,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final Certificate cert;
  const _CertificateCard({required this.cert});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (cert.status) {
      CertStatus.valid => SrColors.success,
      CertStatus.warning => SrColors.warning,
      CertStatus.urgent => SrColors.danger,
      CertStatus.expired => SrColors.danger,
    };

    final badgeVariant = switch (cert.status) {
      CertStatus.valid => SrBadgeVariant.success,
      CertStatus.warning => SrBadgeVariant.warning,
      CertStatus.urgent => SrBadgeVariant.danger,
      CertStatus.expired => SrBadgeVariant.danger,
    };

    final badgeLabel = switch (cert.status) {
      CertStatus.valid => 'Valid',
      CertStatus.warning => '${cert.daysUntilExpiry} hari',
      CertStatus.urgent => '${cert.daysUntilExpiry}h lagi',
      CertStatus.expired => 'Expired',
    };

    return Material(
      color: SrColors.white,
      borderRadius: BorderRadius.circular(SrRadius.md),
      child: InkWell(
        onTap: () => context.push('/certificates/${cert.id}'),
        borderRadius: BorderRadius.circular(SrRadius.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SrRadius.md),
            border: Border.all(color: SrColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 72,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(SrRadius.md),
                    bottomLeft: Radius.circular(SrRadius.md),
                  ),
                ),
              ),
              const SizedBox(width: SrSpacing.sm),
              Icon(Icons.workspace_premium, size: 28, color: statusColor),
              const SizedBox(width: SrSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SrSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (cert.issuer != null)
                        Text(cert.issuer!,
                            style: const TextStyle(fontSize: 12, color: SrColors.textMuted)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: SrSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SrBadge(label: badgeLabel, variant: badgeVariant),
                    const SizedBox(height: 4),
                    Text(
                      's/d ${_fmtDate(cert.expiryDate)}',
                      style: const TextStyle(fontSize: 11, color: SrColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${m[d.month - 1]} ${d.year}';
  }
}

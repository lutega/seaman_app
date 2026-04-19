import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/sr_badge.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../domain/entities/course.dart';
import '../providers/course_providers.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      body: courseAsync.when(
        loading: () => const Scaffold(body: SrLoadingView(itemCount: 5)),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: SrErrorView(message: e.toString()),
        ),
        data: (course) => _CourseDetailBody(course: course),
      ),
    );
  }
}

class _CourseDetailBody extends ConsumerStatefulWidget {
  final Course course;
  const _CourseDetailBody({required this.course});

  @override
  ConsumerState<_CourseDetailBody> createState() => _CourseDetailBodyState();
}

class _CourseDetailBodyState extends ConsumerState<_CourseDetailBody> {
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final enrollState = ref.watch(enrollmentControllerProvider);
    final isEnrolling = enrollState is AsyncLoading;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, course),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(SrSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(course),
                  const SizedBox(height: SrSpacing.md),
                  _buildStatsRow(course),
                  const SizedBox(height: SrSpacing.md),
                  if (course.description != null) ...[
                    _buildDescription(course.description!),
                    const SizedBox(height: SrSpacing.md),
                  ],
                  _buildScheduleSection(course),
                  const SizedBox(height: 100), // bottom bar space
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, course, isEnrolling),
    );
  }

  Widget _buildAppBar(BuildContext context, Course course) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white70,
          radius: 16,
          child: Icon(Icons.arrow_back, size: 18, color: SrColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: SrColors.primaryDark,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.anchor, size: 48, color: Colors.white30),
              Text(
                course.partnerName,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CategoryBadge(category: course.category),
            const SizedBox(width: SrSpacing.xs),
            if (!course.isRegistrationOpen)
              const SrBadge(label: 'Ditutup', variant: SrBadgeVariant.danger)
            else if (course.daysUntilDeadline <= 3)
              SrBadge(
                  label: 'Tutup ${course.daysUntilDeadline}h lagi',
                  variant: SrBadgeVariant.warning),
          ],
        ),
        const SizedBox(height: SrSpacing.sm),
        Text(course.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.xs),
        Row(
          children: [
            const Icon(Icons.business_outlined, size: 14, color: SrColors.textMuted),
            const SizedBox(width: 4),
            Text(course.partnerName,
                style: const TextStyle(fontSize: 13, color: SrColors.textMuted)),
            const SizedBox(width: SrSpacing.sm),
            const Icon(Icons.qr_code_outlined, size: 14, color: SrColors.textMuted),
            const SizedBox(width: 4),
            Text(course.code, style: const TextStyle(fontSize: 12, color: SrColors.textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(Course course) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.schedule_outlined,
          label: 'Durasi',
          value: course.durationDays != null ? '${course.durationDays} hari' : '-',
        ),
        const SizedBox(width: SrSpacing.sm),
        _StatCard(
          icon: Icons.verified_outlined,
          label: 'Standar',
          value: 'STCW',
        ),
        const SizedBox(width: SrSpacing.sm),
        _StatCard(
          icon: Icons.category_outlined,
          label: 'Kategori',
          value: course.category.label,
        ),
      ],
    );
  }

  Widget _buildDescription(String desc) {
    final isLong = desc.length > 200;
    final displayText = isLong && !_descExpanded ? '${desc.substring(0, 200)}...' : desc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskripsi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                color: SrColors.textMuted, letterSpacing: 1.2)),
        const SizedBox(height: SrSpacing.xs),
        Text(displayText,
            style: const TextStyle(fontSize: 14, color: SrColors.textPrimary, height: 1.6)),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Text(
              _descExpanded ? 'Lihat lebih sedikit' : 'Lihat lebih lanjut',
              style: const TextStyle(fontSize: 13, color: SrColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleSection(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jadwal',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                color: SrColors.textMuted, letterSpacing: 1.2)),
        const SizedBox(height: SrSpacing.sm),
        Container(
          padding: const EdgeInsets.all(SrSpacing.md),
          decoration: BoxDecoration(
            color: SrColors.cardBg,
            borderRadius: BorderRadius.circular(SrRadius.md),
            border: Border.all(color: SrColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              _scheduleRow(Icons.event_available_outlined, 'Mulai',
                  course.startsAt.toDisplayDate(), SrColors.primary),
              const Divider(height: SrSpacing.md),
              _scheduleRow(Icons.event_busy_outlined, 'Batas Daftar',
                  course.registrationDeadline.toDisplayDate(),
                  course.isRegistrationOpen ? SrColors.warning : SrColors.danger),
              if (course.quota != null) ...[
                const Divider(height: SrSpacing.md),
                _scheduleRow(Icons.people_outline, 'Kuota',
                    '${course.quota} peserta', SrColors.textMuted),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _scheduleRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: SrSpacing.sm),
        Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: SrColors.textMuted))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Course course, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(SrSpacing.md, SrSpacing.sm, SrSpacing.md, SrSpacing.lg),
      decoration: const BoxDecoration(
        color: SrColors.white,
        border: Border(top: BorderSide(color: SrColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Biaya', style: TextStyle(fontSize: 12, color: SrColors.textMuted)),
              Text(course.priceIdr.toRupiah(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: SrColors.primary)),
            ],
          ),
          const SizedBox(width: SrSpacing.md),
          Expanded(
            child: SrButton(
              label: course.isRegistrationOpen ? 'Daftar & Bayar' : 'Pendaftaran Ditutup',
              onPressed: course.isRegistrationOpen ? () => _enroll(context, course) : null,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enroll(BuildContext context, Course course) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Daftar Kursus'),
        content: Text(
          'Anda akan diarahkan ke situs ${course.partnerName} untuk menyelesaikan pendaftaran.\n\n'
          'Biaya: ${course.priceIdr.toRupiah()}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true), child: const Text('Lanjut')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final url = await ref.read(enrollmentControllerProvider.notifier).enroll(
          userId: userId,
          courseId: course.id,
          externalUrl: course.externalUrl,
          referralSlug: 'seaready',
        );

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SrSpacing.sm, horizontal: SrSpacing.xs),
        decoration: BoxDecoration(
          color: SrColors.cardBg,
          borderRadius: BorderRadius.circular(SrRadius.sm),
          border: Border.all(color: SrColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: SrColors.primary),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: SrColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 11, color: SrColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final CourseCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final variant = switch (category) {
      CourseCategory.renewal => SrBadgeVariant.warning,
      CourseCategory.rating => SrBadgeVariant.info,
      CourseCategory.initial => SrBadgeVariant.success,
    };
    return SrBadge(label: category.label, variant: variant);
  }
}

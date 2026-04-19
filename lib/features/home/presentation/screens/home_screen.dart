import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../../certificates/presentation/providers/certificate_providers.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/providers/course_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../rewards/presentation/providers/reward_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final certsAsync = ref.watch(certificatesProvider);
    final coursesAsync = ref.watch(courseListControllerProvider);
    final pointsAsync = ref.watch(userPointsProvider);

    final name = profileAsync.valueOrNull?.fullName.split(' ').first ?? 'Pelaut';
    final points = pointsAsync.valueOrNull?.totalPoints ?? 0;

    final urgentCerts = certsAsync.valueOrNull
            ?.where((c) => c.status == CertStatus.urgent || c.status == CertStatus.expired)
            .toList() ??
        [];

    final upcomingCourses = coursesAsync.courses
        .where((c) => c.isUpcoming && c.isRegistrationOpen)
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SeaReady'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(certificatesProvider);
          ref.invalidate(currentProfileProvider);
          ref.invalidate(userPointsProvider);
          await ref.read(courseListControllerProvider.notifier).load();
        },
        child: ListView(
          padding: const EdgeInsets.all(SrSpacing.md),
          children: [
            _GreetingCard(name: name, urgentCount: urgentCerts.length, points: points),
            if (urgentCerts.isNotEmpty) ...[
              const SizedBox(height: SrSpacing.md),
              _UrgentCertCard(cert: urgentCerts.first),
            ],
            const SizedBox(height: SrSpacing.md),
            _QuickActions(),
            if (upcomingCourses.isNotEmpty) ...[
              const SizedBox(height: SrSpacing.lg),
              _SectionHeader('Jadwal Kursus', onTap: () => context.go('/courses')),
              const SizedBox(height: SrSpacing.sm),
              _UpcomingCourses(courses: upcomingCourses),
            ],
            const SizedBox(height: SrSpacing.lg),
            _SectionHeader('Rekomendasi Kursus', onTap: () => context.go('/courses')),
            const SizedBox(height: SrSpacing.sm),
            _RecommendedCourses(
              courses: coursesAsync.courses
                  .where((c) => c.category == CourseCategory.renewal)
                  .take(3)
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  final int urgentCount;
  final int points;

  const _GreetingCard({required this.name, required this.urgentCount, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $name 👋',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SrColors.white)),
                const SizedBox(height: 4),
                if (urgentCount > 0)
                  Text(
                    '$urgentCount sertifikat perlu perhatian',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  )
                else
                  const Text('Semua sertifikat aman', style: TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.stars_rounded, size: 24, color: Color(0xFFFFD700)),
              Text('$points', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SrColors.white)),
              const Text('poin', style: TextStyle(fontSize: 11, color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }
}

class _UrgentCertCard extends StatelessWidget {
  final Certificate cert;
  const _UrgentCertCard({required this.cert});

  @override
  Widget build(BuildContext context) {
    final isExpired = cert.status == CertStatus.expired;
    return Container(
      padding: const EdgeInsets.all(SrSpacing.md),
      decoration: BoxDecoration(
        color: SrColors.dangerBg,
        borderRadius: BorderRadius.circular(SrRadius.md),
        border: Border.all(color: SrColors.danger.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 24, color: SrColors.danger),
          const SizedBox(width: SrSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: SrColors.dangerText)),
                Text(
                  isExpired
                      ? 'Kedaluwarsa ${cert.expiryDate.toDisplayDate()}'
                      : '${cert.daysUntilExpiry} hari lagi — ${cert.expiryDate.toDisplayDate()}',
                  style: const TextStyle(fontSize: 12, color: SrColors.dangerText),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/courses'),
            child: const Text('Renewal', style: TextStyle(fontSize: 13, color: SrColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: SrSpacing.xs,
      children: [
        _QuickAction(icon: Icons.school_outlined, label: 'Kursus', onTap: () => context.go('/courses')),
        _QuickAction(icon: Icons.wallet_outlined, label: 'Wallet', onTap: () => context.go('/certificates')),
        _QuickAction(icon: Icons.emoji_events_outlined, label: 'Quest', onTap: () {}),
        _QuickAction(icon: Icons.person_outline, label: 'Profil', onTap: () => context.go('/profile')),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: SrColors.cardBg,
              borderRadius: BorderRadius.circular(SrRadius.md),
              border: Border.all(color: SrColors.border, width: 0.5),
            ),
            child: Icon(icon, size: 26, color: SrColors.primary),
          ),
          const SizedBox(height: SrSpacing.xs),
          Text(label, style: const TextStyle(fontSize: 12, color: SrColors.textMuted)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _SectionHeader(this.title, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SrColors.textPrimary)),
        const Spacer(),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text('Lihat semua',
                style: TextStyle(fontSize: 13, color: SrColors.primary)),
          ),
      ],
    );
  }
}

class _UpcomingCourses extends StatelessWidget {
  final List<Course> courses;
  const _UpcomingCourses({required this.courses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: SrSpacing.sm),
        itemBuilder: (_, i) => _UpcomingCourseChip(course: courses[i]),
      ),
    );
  }
}

class _UpcomingCourseChip extends StatelessWidget {
  final Course course;
  const _UpcomingCourseChip({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/courses/${course.id}'),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(SrSpacing.sm),
        decoration: BoxDecoration(
          color: SrColors.cardBg,
          borderRadius: BorderRadius.circular(SrRadius.md),
          border: Border.all(color: SrColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.partnerName,
                style: const TextStyle(fontSize: 11, color: SrColors.textMuted)),
            const SizedBox(height: 2),
            Expanded(
              child: Text(course.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 12, color: SrColors.textMuted),
                const SizedBox(width: 3),
                Text(course.startsAt.toDisplayDate(),
                    style: const TextStyle(fontSize: 11, color: SrColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCourses extends StatelessWidget {
  final List<Course> courses;
  const _RecommendedCourses({required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const Text('Tidak ada rekomendasi saat ini',
          style: TextStyle(fontSize: 13, color: SrColors.textMuted));
    }
    return Column(
      children: courses
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: SrSpacing.sm),
                child: GestureDetector(
                  onTap: () => context.push('/courses/${c.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(SrSpacing.sm),
                    decoration: BoxDecoration(
                      color: SrColors.cardBg,
                      borderRadius: BorderRadius.circular(SrRadius.sm),
                      border: Border.all(color: SrColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: SrColors.lightMint,
                            borderRadius: BorderRadius.circular(SrRadius.xs),
                          ),
                          child: const Icon(Icons.school_outlined, size: 20, color: SrColors.primary),
                        ),
                        const SizedBox(width: SrSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(c.partnerName,
                                  style: const TextStyle(fontSize: 11, color: SrColors.textMuted)),
                            ],
                          ),
                        ),
                        Text(c.priceIdr.toRupiah(),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold, color: SrColors.primary)),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

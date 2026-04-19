import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/certificates/presentation/screens/certificate_list_screen.dart';
import '../../features/certificates/presentation/screens/certificate_detail_screen.dart';
import '../../features/certificates/presentation/screens/certificate_add_screen.dart';
import '../../features/courses/presentation/screens/course_catalog_screen.dart';
import '../../features/courses/presentation/screens/course_detail_screen.dart';
import '../../features/quest/presentation/screens/quest_overview_screen.dart';
import '../../features/quest/presentation/screens/quest_detail_screen.dart';
import '../../features/rewards/presentation/screens/points_dashboard_screen.dart';
import '../../features/rewards/presentation/screens/reward_catalog_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_setup_screen.dart';
import '../../features/profile/presentation/screens/profile_view_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/map/presentation/screens/venue_map_screen.dart';
import '../../shared/layouts/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/email-verification', builder: (_, __) => const EmailVerificationScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/courses',
            builder: (_, __) => const CourseCatalogScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => CourseDetailScreen(courseId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/certificates',
            builder: (_, __) => const CertificateListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => CertificateDetailScreen(certId: state.pathParameters['id']!),
              ),
              GoRoute(path: 'add', builder: (_, __) => const CertificateAddScreen()),
            ],
          ),
          GoRoute(
            path: '/quest/:enrollmentId',
            builder: (_, state) => QuestOverviewScreen(enrollmentId: state.pathParameters['enrollmentId']!),
            routes: [
              GoRoute(
                path: ':questId',
                builder: (_, state) => QuestDetailScreen(
                  enrollmentId: state.pathParameters['enrollmentId']!,
                  questId: state.pathParameters['questId']!,
                ),
              ),
            ],
          ),
          GoRoute(path: '/rewards', builder: (_, __) => const PointsDashboardScreen()),
          GoRoute(path: '/reward-catalog', builder: (_, __) => const RewardCatalogScreen()),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'setup', builder: (_, __) => const ProfileSetupScreen()),
              GoRoute(path: 'view', builder: (_, __) => const ProfileViewScreen()),
              GoRoute(path: 'edit', builder: (_, __) => const ProfileEditScreen()),
            ],
          ),
          GoRoute(
            path: '/map/:partnerId',
            builder: (_, state) => VenueMapScreen(partnerId: state.pathParameters['partnerId']!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Halaman tidak ditemukan', style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: () => context.go('/home'), child: const Text('Kembali ke Beranda')),
          ],
        ),
      ),
    ),
  );
});

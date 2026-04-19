import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(Supabase.instance.client);
});

// ── Catalog filter state ───────────────────────────────────────────────────

class CatalogFilter {
  final CourseCategory? category;
  final String search;

  const CatalogFilter({this.category, this.search = ''});

  CatalogFilter copyWith({CourseCategory? category, String? search, bool clearCategory = false}) =>
      CatalogFilter(
        category: clearCategory ? null : (category ?? this.category),
        search: search ?? this.search,
      );
}

class CatalogFilterNotifier extends StateNotifier<CatalogFilter> {
  CatalogFilterNotifier() : super(const CatalogFilter());

  void setCategory(CourseCategory? cat) =>
      state = state.copyWith(clearCategory: cat == null, category: cat);

  void setSearch(String q) => state = state.copyWith(search: q);

  void reset() => state = const CatalogFilter();
}

final catalogFilterProvider =
    StateNotifierProvider<CatalogFilterNotifier, CatalogFilter>((ref) {
  return CatalogFilterNotifier();
});

// ── Course list (paginated) ────────────────────────────────────────────────

class CourseListState {
  final List<Course> courses;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const CourseListState({
    this.courses = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  CourseListState copyWith({
    List<Course>? courses,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) =>
      CourseListState(
        courses: courses ?? this.courses,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error,
      );
}

const _pageSize = 20;

class CourseListController extends StateNotifier<CourseListState> {
  final CourseRepository _repo;
  CatalogFilter _filter;

  CourseListController(this._repo, this._filter) : super(const CourseListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, courses: [], hasMore: true, error: null);
    final result = await _repo.getCourses(
      category: _filter.category,
      search: _filter.search.isEmpty ? null : _filter.search,
      limit: _pageSize,
      offset: 0,
    );
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (courses) => state = state.copyWith(
        isLoading: false,
        courses: courses,
        hasMore: courses.length == _pageSize,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _repo.getCourses(
      category: _filter.category,
      search: _filter.search.isEmpty ? null : _filter.search,
      limit: _pageSize,
      offset: state.courses.length,
    );
    result.fold(
      (_) => state = state.copyWith(isLoadingMore: false),
      (more) => state = state.copyWith(
        isLoadingMore: false,
        courses: [...state.courses, ...more],
        hasMore: more.length == _pageSize,
      ),
    );
  }

  void applyFilter(CatalogFilter filter) {
    _filter = filter;
    load();
  }
}

final courseListControllerProvider =
    StateNotifierProvider<CourseListController, CourseListState>((ref) {
  final repo = ref.watch(courseRepositoryProvider);
  final filter = ref.watch(catalogFilterProvider);
  final ctrl = CourseListController(repo, filter);
  ref.listen(catalogFilterProvider, (_, next) => ctrl.applyFilter(next));
  return ctrl;
});

// ── Single course detail ───────────────────────────────────────────────────

final courseDetailProvider = FutureProvider.family<Course, String>((ref, id) async {
  final repo = ref.watch(courseRepositoryProvider);
  final result = await repo.getCourseById(id);
  return result.fold((f) => throw f.message, (c) => c);
});

// ── Enrollment state ───────────────────────────────────────────────────────

class EnrollmentController extends StateNotifier<AsyncValue<void>> {
  final CourseRepository _repo;

  EnrollmentController(this._repo) : super(const AsyncValue.data(null));

  Future<String?> enroll({
    required String userId,
    required String courseId,
    required String externalUrl,
    required String referralSlug,
  }) async {
    state = const AsyncValue.loading();

    // 1. Record enrollment
    await _repo.createEnrollment(userId: userId, courseId: courseId);

    // 2. Get tracking URL
    final urlResult = await _repo.getTrackingUrl(
      userId: userId,
      courseId: courseId,
      externalUrl: externalUrl,
      referralSlug: referralSlug,
    );

    state = const AsyncValue.data(null);
    return urlResult.fold((_) => externalUrl, (url) => url);
  }
}

final enrollmentControllerProvider =
    StateNotifierProvider.autoDispose<EnrollmentController, AsyncValue<void>>((ref) {
  return EnrollmentController(ref.watch(courseRepositoryProvider));
});

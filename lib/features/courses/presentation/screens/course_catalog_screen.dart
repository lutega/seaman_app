import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sr_empty_state.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../domain/entities/course.dart';
import '../providers/course_providers.dart';
import '../widgets/course_card.dart';

class CourseCatalogScreen extends ConsumerStatefulWidget {
  const CourseCatalogScreen({super.key});

  @override
  ConsumerState<CourseCatalogScreen> createState() => _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends ConsumerState<CourseCatalogScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(courseListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(courseListControllerProvider);
    final filter = ref.watch(catalogFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kursus Tersedia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _showFilterSheet(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(filter.search),
          _buildFilterChips(filter.category),
          const Divider(height: 1),
          Expanded(child: _buildList(listState)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String currentSearch) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SrSpacing.md, SrSpacing.sm, SrSpacing.md, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (q) => ref.read(catalogFilterProvider.notifier).setSearch(q),
        decoration: InputDecoration(
          hintText: 'Cari kursus...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: currentSearch.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(catalogFilterProvider.notifier).setSearch('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips(CourseCategory? selected) {
    final options = [
      (null, 'Semua'),
      (CourseCategory.renewal, 'Renewal'),
      (CourseCategory.rating, 'Rating'),
      (CourseCategory.initial, 'Initial'),
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
              onSelected: (_) =>
                  ref.read(catalogFilterProvider.notifier).setCategory(opt.$1),
              selectedColor: SrColors.primary,
              labelStyle: TextStyle(
                fontSize: 13,
                color: isSelected ? SrColors.white : SrColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? SrColors.primary : SrColors.border,
                width: 0.5,
              ),
              backgroundColor: SrColors.white,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: SrSpacing.xs),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(CourseListState state) {
    if (state.isLoading) return const SrLoadingView(itemCount: 6);

    if (state.error != null) {
      return SrErrorView(
        message: state.error!,
        onRetry: () => ref.read(courseListControllerProvider.notifier).load(),
      );
    }

    if (state.courses.isEmpty) {
      return SrEmptyState(
        title: 'Kursus tidak ditemukan',
        subtitle: 'Coba ubah filter atau kata kunci pencarian',
        icon: Icons.school_outlined,
        actionLabel: 'Reset Filter',
        onAction: () {
          _searchCtrl.clear();
          ref.read(catalogFilterProvider.notifier).reset();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(courseListControllerProvider.notifier).load(),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(SrSpacing.md),
        itemCount: state.courses.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: SrSpacing.sm),
        itemBuilder: (context, i) {
          if (i == state.courses.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: SrSpacing.md),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return CourseCard(course: state.courses[i]);
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SrRadius.lg)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(catalogFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(SrSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: SrColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: SrSpacing.md),
          const Text('Filter Kursus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: SrSpacing.md),
          const Text('Kategori',
              style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
          const SizedBox(height: SrSpacing.sm),
          Wrap(
            spacing: SrSpacing.sm,
            children: [
              _chip(context, ref, null, 'Semua', filter.category),
              _chip(context, ref, CourseCategory.renewal, 'Renewal', filter.category),
              _chip(context, ref, CourseCategory.rating, 'Rating', filter.category),
              _chip(context, ref, CourseCategory.initial, 'Initial', filter.category),
            ],
          ),
          const SizedBox(height: SrSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(catalogFilterProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: SrSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, WidgetRef ref, CourseCategory? cat, String label,
      CourseCategory? selected) {
    final isSelected = cat == selected;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref.read(catalogFilterProvider.notifier).setCategory(cat),
      selectedColor: SrColors.primary,
      labelStyle: TextStyle(color: isSelected ? SrColors.white : SrColors.textPrimary),
      showCheckmark: false,
    );
  }
}

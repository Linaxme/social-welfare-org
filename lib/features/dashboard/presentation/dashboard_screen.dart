import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/data/org_settings.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/dashboard_repository.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    AppSession.instance.addListener(_onSession);
    OrgSettings.instance.addListener(_onSession);
  }

  @override
  void dispose() {
    AppSession.instance.removeListener(_onSession);
    OrgSettings.instance.removeListener(_onSession);
    super.dispose();
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance;
    final orgName = OrgSettings.instance.orgName;
    final user = session.user;
    final s = AppStrings.current;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DashboardSummary>(
        stream: DashboardRepository.instance.watchSummary(year: _selectedYear),
        builder: (context, dashSnap) {
          final yearSummary = dashSnap.data ??
              const DashboardSummary(
                totalCollection: 0,
                totalDonation: 0,
                thisMonthCollection: 0,
                totalDonorCount: 0,
                monthlyCollections: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
              );

          return StreamBuilder<DashboardSummary>(
            stream: DashboardRepository.instance.watchAllTimeSummary(),
            builder: (context, allTimeSnap) {
              final allTime = allTimeSnap.data ??
                  const DashboardSummary(
                    totalCollection: 0,
                    totalDonation: 0,
                    thisMonthCollection: 0,
                    totalDonorCount: 0,
                    monthlyCollections: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  );
              final allTimeBalance = allTime.totalCollection - allTime.totalDonation;

          return StreamBuilder<List<AppUser>>(
            stream: UserRepository.instance.watchMembers(),
            builder: (context, membersSnap) {
              final members = membersSnap.data ?? [];
              final memberCount = members.countMemberEligibleUsers();

              return StreamBuilder<List<DonationRecord>>(
                stream: DonationRepository.instance.watchRecent(limit: 8),
                builder: (context, recentSnap) {
                  final recent = recentSnap.data ?? [];

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      setState(() {});
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: AppPageHeader.home(
                          title: orgName,
                          welcomeName: user.name,
                          welcomeRole: appWelcomeRoleLabel(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatChip(
                                  label: s.totalCollection,
                                  value: Formatters.money(
                                      allTime.totalCollection),
                                  filled: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatChip(
                                  label: s.totalDonation,
                                  value: Formatters.money(
                                      allTime.totalDonation),
                                  valueColor: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatChip(
                                  label: s.currentBalance,
                                  value: Formatters.money(allTimeBalance),
                                  valueColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatChip(
                                  label: s.totalMembers,
                                  value:
                                      '${Formatters.toDigits('$memberCount')} ${s.person}',
                                  valueColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatChip(
                                  label: s.thisMonthCollection,
                                  value: Formatters.money(
                                      yearSummary.thisMonthCollection),
                                  valueColor: AppColors.secondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (session.canRecordDonation)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Material(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(14),
                              elevation: 2,
                              shadowColor:
                                  AppColors.secondary.withValues(alpha: 0.4),
                              child: InkWell(
                                onTap: () => context.push('/donation/new'),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_rounded,
                                          color: Colors.white, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        s.enterCollection,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (session.canManageMembers ||
                          session.canEnterHelp ||
                          session.canSeeReports) ...[
                        SliverToBoxAdapter(
                          child: SectionHeader(title: s.quickActions),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                if (session.canManageMembers)
                                  Expanded(
                                    child: QuickActionItem(
                                      icon: Icons.person_add_alt_1_rounded,
                                      label: s.members,
                                      onTap: () =>
                                          context.push('/members/new'),
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                if (session.canEnterHelp)
                                  Expanded(
                                    child: QuickActionItem(
                                      icon: Icons.volunteer_activism,
                                      label: s.help,
                                      onTap: () =>
                                          context.go('/home/help'),
                                      color: AppColors.success,
                                    ),
                                  ),
                                if (session.canSeeReports)
                                  Expanded(
                                    child: QuickActionItem(
                                      icon: Icons.summarize_outlined,
                                      label: s.reports,
                                      onTap: () =>
                                          context.push('/reports'),
                                      color: AppColors.secondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      // ── Top Donors Carousel ─────────────────────
                      SliverToBoxAdapter(
                        child: TopDonorCarousel(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(12, 14, 12, 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.monthlyCollectionGraph,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _pickYear(context),
                                      icon: const Icon(
                                        Icons.more_horiz,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 180,
                                  child: _MonthlyChart(
                                    values: yearSummary.monthlyCollections,
                                  ),
                                ),
                                Text(
                                  Formatters.toDigits('$_selectedYear'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: s.recentCollections,
                          actionLabel: s.viewAll,
                          onAction: () => context.push('/collections'),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: recent.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    s.noCollectionsYet,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (var i = 0; i < recent.length; i++) ...[
                                      if (i > 0)
                                        const Divider(indent: 72, height: 1),
                                      ListTile(
                                        leading: AvatarCircle(
                                            name: recent[i].donorName),
                                        title: Text(
                                          recent[i].donorName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                          Formatters.shortDate(
                                              recent[i].paidAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              Formatters.money(recent[i].amount),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            if (session.isAdmin) ...[
                                              const SizedBox(width: 4),
                                              PopupMenuButton<String>(
                                                padding: EdgeInsets.zero,
                                                iconSize: 18,
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  size: 18,
                                                  color: AppColors.textSecondary,
                                                ),
                                                onSelected: (v) {
                                                  if (v == 'edit') {
                                                    context.push(
                                                      '/donation/${recent[i].id}/edit',
                                                      extra: recent[i],
                                                    );
                                                  } else if (v == 'delete') {
                                                    _confirmDelete(context, recent[i]);
                                                  }
                                                },
                                                itemBuilder: (_) => [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.edit_outlined,
                                                            size: 18,
                                                            color: AppColors.primary),
                                                        const SizedBox(width: 8),
                                                        Text(s.editDonation),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.delete_outline,
                                                            size: 18,
                                                            color: AppColors.error),
                                                        const SizedBox(width: 8),
                                                        Text(s.delete),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                         onTap: (session.isAdmin ||
                                                 session.isCollector ||
                                                 recent[i].donorId == session.user.id)
                                             ? () => context.push(
                                                 '/members/${recent[i].donorId}')
                                             : null,
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                    );
                },
              );
            },
          );
            },
          );
        },
      ),
    );
  }

  Future<void> _pickYear(BuildContext context) async {
    final years = [
      DateTime.now().year - 1,
      DateTime.now().year,
      DateTime.now().year + 1,
    ];
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final y in years)
              ListTile(
                title: Text(Formatters.toDigits('$y')),
                trailing: y == _selectedYear
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, y),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _selectedYear = picked);
  }

  Future<void> _confirmDelete(BuildContext context, DonationRecord d) async {
    final s = AppStrings.current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.moveToTrash),
        content: Text(s.moveToTrashConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(s.moveToTrash),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await DonationRepository.instance.softDelete(d.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.itemMovedToTrash)),
        );
      }
    }
  }
}

// ─── Top Donor Carousel ─────────────────────────────────────────────────────

class TopDonorCarousel extends StatefulWidget {
  const TopDonorCarousel({super.key});

  @override
  State<TopDonorCarousel> createState() => _TopDonorCarouselState();
}

class _TopDonorCarouselState extends State<TopDonorCarousel> {
  late final PageController _pageController;
  late final Stream<List<TopDonorStat>> _topDonorsStream;
  int _currentPage = 0;
  Timer? _autoTimer;
  List<TopDonorStat> _currentDonors = [];

  @override
  void initState() {
    super.initState();
    _topDonorsStream = DonationRepository.instance.watchTopDonors(limit: 5);
    _pageController = PageController(viewportFraction: 0.92, initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _currentDonors.length <= 1) return;
      if (!_pageController.hasClients) return;
      try {
        final next = _currentPage + 1;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        debugPrint('Carousel slide error: $e');
      }
    });
  }

  void _onPageChanged(int page) {
    if (_currentPage != page) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Section header + View All action ─────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.secondary, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.topDonors,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push('/top-donors'),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        s.viewAll,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // ── Cards ────────────────────────────────────────────────
        StreamBuilder<List<TopDonorStat>>(
          stream: _topDonorsStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              );
            }
            final donors = snap.data ?? [];
            _currentDonors = donors;

            if (donors.isEmpty) {
              return _EmptyDonorCard(label: s.noTopDonorsYet);
            }

            final totalDonors = donors.length;
            final isMulti = totalDonors > 1;
            final currentActiveIndex = _currentPage % totalDonors;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 166,
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: isMulti ? 10000 : 1,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, i) {
                          final idx = i % totalDonors;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: TopDonorCard(
                              stat: donors[idx],
                              rank: idx + 1,
                              subLabel: s.allTimeDonation,
                            ),
                          );
                        },
                      ),
                    ),
                    // Prev button
                    if (isMulti && _currentPage > 0)
                      Positioned(
                        left: 14,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Next button
                    if (isMulti)
                      Positioned(
                        right: 14,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // ── Dot indicators ─────────────────────────────
                if (isMulti) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalDonors, (i) {
                      final isActive = currentActiveIndex == i;
                      return GestureDetector(
                        onTap: () {
                          final base =
                              _currentPage - (_currentPage % totalDonors);
                          final target = base + i;
                          _pageController.animateToPage(
                            target,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          width: isActive ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 6),
              ],
            );
          },
        ),
      ],
    );
  }
}



class _EmptyDonorCard extends StatelessWidget {
  const _EmptyDonorCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.leaderboard_outlined,
                  color: AppColors.primary.withValues(alpha: 0.3), size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopDonorCard extends StatelessWidget {
  const TopDonorCard({
    super.key,
    required this.stat,
    required this.rank,
    required this.subLabel,
  });

  final TopDonorStat stat;
  final int rank;
  final String subLabel;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final medal = _medalData(rank);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
          colors: medal.gradientColors,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: medal.shadowColor.withValues(alpha: 0.45),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // ── Background decorative shapes ──────────────────────
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // ── Large background icon ─────────────────────────────
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                medal.bgIcon,
                size: 96,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // ── Content ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rank icon column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        medal.rankIcon,
                        color: medal.rankIconColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        Formatters.toDigits('$rank'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                // Donor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat.donorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Amount with icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 15,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Formatters.money(stat.totalAmount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Sub label chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${Formatters.toDigits('${stat.count}')} ${s.times} · $subLabel',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalData {
  final IconData rankIcon;
  final Color rankIconColor;
  final IconData bgIcon;
  final List<Color> gradientColors;
  final Color shadowColor;
  const _MedalData({
    required this.rankIcon,
    required this.rankIconColor,
    required this.bgIcon,
    required this.gradientColors,
    required this.shadowColor,
  });
}

_MedalData _medalData(int rank) {
  switch (rank) {
    case 1:
      return const _MedalData(
        rankIcon: Icons.workspace_premium_rounded,
        rankIconColor: Color(0xFFFFE082),
        bgIcon: Icons.emoji_events_rounded,
        gradientColors: [
          Color(0xFF593F00),
          Color(0xFFA87900),
          Color(0xFFD9B45C),
        ],
        shadowColor: Color(0x77D9B45C),
      );
    case 2:
      return const _MedalData(
        rankIcon: Icons.military_tech_rounded,
        rankIconColor: Color(0xFFF5F5F5),
        bgIcon: Icons.emoji_events_rounded,
        gradientColors: [
          Color(0xFF2E3340),
          Color(0xFF5A6378),
          Color(0xFF8D9CB5),
        ],
        shadowColor: Color(0x778D9CB5),
      );
    case 3:
      return const _MedalData(
        rankIcon: Icons.stars_rounded,
        rankIconColor: Color(0xFFFFCCBC),
        bgIcon: Icons.emoji_events_rounded,
        gradientColors: [
          Color(0xFF542200),
          Color(0xFF9E4800),
          Color(0xFFD4723B),
        ],
        shadowColor: Color(0x77D4723B),
      );
    default:
      return const _MedalData(
        rankIcon: Icons.military_tech_outlined,
        rankIconColor: Colors.white,
        bgIcon: Icons.workspace_premium_outlined,
        gradientColors: [
          Color(0xFF004D34),
          Color(0xFF007A52),
          Color(0xFF0D9467),
        ],
        shadowColor: Color(0x66007A52),
      );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.filled = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool filled;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: filled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF007A52), Color(0xFF005237)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFFAFBFD)],
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: filled
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: filled
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: filled
                    ? Colors.white
                    : (valueColor ?? AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final maxRaw =
        values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxRaw * 1.2).clamp(1000, double.infinity).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i > 11) return const SizedBox.shrink();
                final shorts = s.monthShortNames;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    shorts[i],
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length && i < 12; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i].toDouble(),
                  color: AppColors.primary,
                  width: 11,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final val = values[group.x];
              if (val == 0) return null;
              return BarTooltipItem(
                Formatters.toDigits('$val'),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

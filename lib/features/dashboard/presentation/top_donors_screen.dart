import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class TopDonorsScreen extends StatefulWidget {
  const TopDonorsScreen({super.key});

  @override
  State<TopDonorsScreen> createState() => _TopDonorsScreenState();
}

class _TopDonorsScreenState extends State<TopDonorsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;

    return AppPageScaffold(
      title: s.topDonorsList,
      showBack: true,
      body: Column(
        children: [
          // ── Tab Bar ───────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: s.top10),
                Tab(text: s.allDonors),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // ── Tab Views ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TopDonorList(limit: 10),
                _TopDonorList(limit: 1000),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopDonorList extends StatelessWidget {
  const _TopDonorList({required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;

    return StreamBuilder<List<TopDonorStat>>(
      stream: DonationRepository.instance.watchTopDonors(limit: limit),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          );
        }

        final donors = snap.data ?? [];
        if (donors.isEmpty) {
          return Center(
            child: Text(
              s.noTopDonorsYet,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          itemCount: donors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final donor = donors[index];
            final rank = index + 1;
            return _TopDonorTile(stat: donor, rank: rank);
          },
        );
      },
    );
  }
}

class _TopDonorTile extends StatelessWidget {
  const _TopDonorTile({required this.stat, required this.rank});

  final TopDonorStat stat;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final badgeData = _rankBadgeData(rank);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: rank <= 3
            ? Border.all(
                color: badgeData.borderColor.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: rank <= 3
                ? badgeData.shadowColor.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.05),
            blurRadius: rank <= 3 ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: badgeData.gradient,
            color: badgeData.gradient == null ? badgeData.bgColor : null,
            shape: BoxShape.circle,
            border: Border.all(
              color: badgeData.borderColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: badgeData.shadowColor != Colors.transparent
                ? [
                    BoxShadow(
                      color: badgeData.shadowColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: badgeData.icon != null
                ? Icon(
                    badgeData.icon,
                    color: Colors.white,
                    size: 24,
                  )
                : Text(
                    Formatters.toDigits('$rank'),
                    style: TextStyle(
                      color: badgeData.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
        title: Text(
          stat.donorName,
          style: TextStyle(
            fontWeight: rank <= 3 ? FontWeight.w800 : FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${Formatters.toDigits('${stat.count}')} ${s.times} ${s.donationHistory}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        trailing: Text(
          Formatters.money(stat.totalAmount),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: rank <= 10 ? AppColors.primary : AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        onTap: () {
          final isOwnProfile = stat.donorId == AppSession.instance.user.id;
          if (stat.donorId.isNotEmpty &&
              (AppSession.instance.isAdmin ||
                  AppSession.instance.isCollector ||
                  isOwnProfile)) {
            context.push('/members/${stat.donorId}');
          }
        },
      ),
    );
  }
}

class _RankBadge {
  final IconData? icon;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;
  final LinearGradient? gradient;

  const _RankBadge({
    this.icon,
    this.bgColor = const Color(0xFFF2F4F7),
    this.textColor = AppColors.textSecondary,
    this.borderColor = Colors.transparent,
    this.shadowColor = Colors.transparent,
    this.gradient,
  });
}

_RankBadge _rankBadgeData(int rank) {
  if (rank == 1) {
    return const _RankBadge(
      icon: Icons.workspace_premium_rounded,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD4AF37), Color(0xFF997A15)],
      ),
      borderColor: Color(0xFFD4AF37),
      shadowColor: Color(0xFFD4AF37),
      textColor: Colors.white,
    );
  } else if (rank == 2) {
    return const _RankBadge(
      icon: Icons.military_tech_rounded,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFA6B4C9), Color(0xFF63738A)],
      ),
      borderColor: Color(0xFFA6B4C9),
      shadowColor: Color(0xFFA6B4C9),
      textColor: Colors.white,
    );
  } else if (rank == 3) {
    return const _RankBadge(
      icon: Icons.stars_rounded,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
      ),
      borderColor: Color(0xFFCD7F32),
      shadowColor: Color(0xFFCD7F32),
      textColor: Colors.white,
    );
  } else if (rank <= 10) {
    return const _RankBadge(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primaryDark, AppColors.primary],
      ),
      borderColor: AppColors.primary,
      shadowColor: AppColors.primary,
      textColor: Colors.white,
    );
  } else {
    return const _RankBadge(
      bgColor: Color(0xFFF2F4F7),
      textColor: AppColors.textPrimary,
      borderColor: Color(0xFFE5E7EB),
    );
  }
}

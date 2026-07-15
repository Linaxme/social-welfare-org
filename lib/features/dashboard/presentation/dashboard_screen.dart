import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DashboardSummary>(
        stream: DashboardRepository.instance.watchSummary(),
        builder: (context, dashSnap) {
          final summary = dashSnap.data ??
              const DashboardSummary(
                totalCollection: 0,
                totalDonation: 0,
                thisMonthCollection: 0,
                totalDonorCount: 0,
                monthlyCollections: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
              );
          final balance =
              summary.totalCollection - summary.totalDonation;

          return StreamBuilder<List<AppUser>>(
            stream: UserRepository.instance.watchMembers(),
            builder: (context, membersSnap) {
              final members = membersSnap.data ?? [];
              final memberCount = members
                  .where((m) =>
                      m.role == UserRole.member ||
                      m.role == UserRole.collector)
                  .length;

              return StreamBuilder<List<DonationRecord>>(
                stream: DonationRepository.instance.watchRecent(limit: 8),
                builder: (context, recentSnap) {
                  final recent = recentSnap.data ?? [];

                  return CustomScrollView(
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
                                  label: 'মোট কালেকশন',
                                  value: Formatters.money(
                                      summary.totalCollection),
                                  filled: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatChip(
                                  label: 'মোট ডোনেশন',
                                  value: Formatters.money(
                                      summary.totalDonation),
                                  valueColor: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatChip(
                                  label: 'বর্তমান ব্যালেন্স',
                                  value: Formatters.money(balance),
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
                                  label: 'মোট মেম্বার',
                                  value:
                                      '${Formatters.toBnDigits('$memberCount')} জন',
                                  valueColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatChip(
                                  label: 'এই মাসের কালেকশন',
                                  value: Formatters.money(
                                      summary.thisMonthCollection),
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
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_rounded,
                                          color: Colors.white, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'কালেকশন এন্ট্রি করুন',
                                        style: TextStyle(
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
                        const SliverToBoxAdapter(
                          child: SectionHeader(title: 'কুইক অ্যাকশন'),
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
                                      label: 'মেম্বার',
                                      onTap: () =>
                                          context.push('/members/new'),
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                if (session.canEnterHelp)
                                  Expanded(
                                    child: QuickActionItem(
                                      icon: Icons.volunteer_activism,
                                      label: 'সাহায্য',
                                      onTap: () =>
                                          context.go('/home/help'),
                                      color: AppColors.success,
                                    ),
                                  ),
                                if (session.canSeeReports)
                                  Expanded(
                                    child: QuickActionItem(
                                      icon: Icons.summarize_outlined,
                                      label: 'রিপোর্ট',
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
                                    const Expanded(
                                      child: Text(
                                        'মান্থলি কালেকশন গ্রাফ',
                                        style: TextStyle(
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
                                    values: summary.monthlyCollections,
                                  ),
                                ),
                                Text(
                                  Formatters.toBnDigits('$_selectedYear'),
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
                          title: 'সাম্প্রতিক কালেকশন',
                          actionLabel: 'সব দেখুন',
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
                              ? const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'এখনো কোনো কালেকশন নেই',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
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
                                        trailing: Text(
                                          Formatters.money(recent[i].amount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        onTap: () => context.push(
                                            '/members/${recent[i].donorId}'),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ],
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
                title: Text(Formatters.toBnDigits('$y')),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: filled ? 0.25 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: filled ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
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
                const shorts = [
                  'জা',
                  'ফে',
                  'মা',
                  'এ',
                  'মে',
                  'জু',
                  'জু',
                  'আ',
                  'সে',
                  'অ',
                  'ন',
                  'ডি',
                ];
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
      ),
    );
  }
}

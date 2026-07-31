import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/services/receipt_service.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class CollectorHistoryScreen extends StatefulWidget {
  const CollectorHistoryScreen({
    super.key,
    this.collectorId,
    this.collectorName,
  });

  final String? collectorId;
  final String? collectorName;

  @override
  State<CollectorHistoryScreen> createState() => _CollectorHistoryScreenState();
}

class _CollectorHistoryScreenState extends State<CollectorHistoryScreen> {
  final _search = TextEditingController();
  String _query = '';
  int _yearFilter = DateTime.now().year;
  int? _monthFilter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _targetCollectorId =>
      widget.collectorId ?? AppSession.instance.user.id;

  List<DonationRecord> _filter(List<DonationRecord> all) {
    var list = all.where((d) => d.paidAt.year == _yearFilter).toList();
    if (_monthFilter != null) {
      list = list.where((d) => d.paidAt.month == _monthFilter).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((d) =>
              d.donorName.toLowerCase().contains(q) ||
              d.receiptNo.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final title = widget.collectorName != null
        ? '${widget.collectorName} - ${s.collectionHistory}'
        : s.myCollectionHistory;

    return AppPageScaffold(
      title: title,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.searchNameOrReceipt,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                FilterChip(
                  label: Text(Formatters.toDigits('$_yearFilter')),
                  selected: true,
                  onSelected: (_) => _pickYear(),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                    _monthFilter == null
                        ? s.allMonths
                        : s.monthNames[_monthFilter! - 1],
                  ),
                  selected: _monthFilter != null,
                  onSelected: (_) => _pickMonth(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DonationRecord>>(
              stream:
                  DonationRepository.instance.watchByCollector(_targetCollectorId),
              builder: (context, snap) {
                if (snap.hasError) {
                  return ErrorState(
                    message: '${s.loading} ${s.retry}',
                    onRetry: () => setState(() {}),
                  );
                }
                if (!snap.hasData) {
                  return const ShimmerList();
                }
                final list = _filter(snap.data!);
                if (list.isEmpty) {
                  return EmptyState(message: s.noCollectionsFound);
                }

                final totalAmount =
                    list.fold<int>(0, (sum, d) => sum + d.amount);

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${s.total} (${Formatters.toDigits('${list.length}')} ${s.totalEntries}):',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            Formatters.money(totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => setState(() {}),
                        child: ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const Divider(indent: 76, height: 1),
                          itemBuilder: (context, index) {
                            final d = list[index];
                            return ListTile(
                              leading: AvatarCircle(name: d.donorName),
                              title: Text(d.donorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${Formatters.shortDate(d.paidAt)} · ${d.receiptNo}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    Formatters.money(d.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () =>
                                        ReceiptService.preview(context, d),
                                    child: const Icon(
                                      Icons.receipt_long,
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: (AppSession.instance.isAdmin ||
                                      AppSession.instance.isCollector ||
                                      d.donorId == AppSession.instance.user.id)
                                  ? () => context.push('/members/${d.donorId}')
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickYear() async {
    final y = DateTime.now().year;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final year in [y - 2, y - 1, y, y + 1])
              ListTile(
                title: Text(Formatters.toDigits('$year')),
                selected: year == _yearFilter,
                onTap: () => Navigator.pop(ctx, year),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _yearFilter = picked);
  }

  Future<void> _pickMonth() async {
    final s = AppStrings.current;
    final picked = await showModalBottomSheet<int?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(s.allMonths),
                selected: _monthFilter == null,
                onTap: () => Navigator.pop(ctx, null),
              ),
              const Divider(height: 1),
              for (var i = 0; i < 12; i++)
                ListTile(
                  title: Text(s.monthNames[i]),
                  selected: _monthFilter == i + 1,
                  onTap: () => Navigator.pop(ctx, i + 1),
                ),
            ],
          ),
        ),
      ),
    );
    setState(() => _monthFilter = picked);
  }
}

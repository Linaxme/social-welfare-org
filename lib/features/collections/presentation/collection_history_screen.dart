import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/services/receipt_service.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class CollectionHistoryScreen extends StatefulWidget {
  const CollectionHistoryScreen({super.key});

  @override
  State<CollectionHistoryScreen> createState() =>
      _CollectionHistoryScreenState();
}

class _CollectionHistoryScreenState extends State<CollectionHistoryScreen> {
  final _search = TextEditingController();
  String _query = '';
  int? _monthFilter;
  int _yearFilter = DateTime.now().year;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
    return AppPageScaffold(
      title: s.collectionHistory,
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
              stream: DonationRepository.instance.watchAll(),
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
                  return EmptyState(
                      message: s.noCollectionsFound);
                }
                return RefreshIndicator(
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
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${Formatters.shortDate(d.paidAt)} · ${d.receiptNo}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                            if (d.enteredByName != null &&
                                d.enteredByName!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  if (d.enteredById != null &&
                                      d.enteredById!.isNotEmpty) {
                                    context.push(
                                      '/my-collections?collectorId=${d.enteredById}&collectorName=${Uri.encodeComponent(d.enteredByName!)}',
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.person_pin_outlined,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${s.entryBy}: ${d.enteredByName}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.money(d.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                            if (AppSession.instance.isAdmin)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.push(
                                      '/donation/${d.id}/edit',
                                      extra: d,
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _confirmDelete(context, d),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
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
            for (final year in [y - 1, y, y + 1])
              ListTile(
                title: Text(Formatters.toDigits('$year')),
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
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (var i = 1; i <= 12; i++)
              ListTile(
                title: Text(s.monthNames[i - 1]),
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _monthFilter = picked);
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

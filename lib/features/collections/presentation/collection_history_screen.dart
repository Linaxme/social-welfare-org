import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/services/receipt_service.dart';
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
    return AppPageScaffold(
      title: 'কালেকশন হিস্ট্রি',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'নাম বা রিসিপ্ট নং',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                FilterChip(
                  label: Text(Formatters.toBnDigits('$_yearFilter')),
                  selected: true,
                  onSelected: (_) => _pickYear(),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                    _monthFilter == null
                        ? 'সব মাস'
                        : Formatters.monthNamesBn[_monthFilter! - 1],
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
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = _filter(snap.data!);
                if (list.isEmpty) {
                  return const EmptyState(
                      message: 'কোনো কালেকশন পাওয়া যায়নি');
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const Divider(indent: 76, height: 1),
                  itemBuilder: (context, index) {
                    final d = list[index];
                    return ListTile(
                      leading: AvatarCircle(name: d.donorName),
                      title: Text(d.donorName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${Formatters.shortDate(d.paidAt)} · ${d.receiptNo}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
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
                          GestureDetector(
                            onTap: () => ReceiptService.preview(context, d),
                            child: const Text(
                              'রিসিপ্ট',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => context.push('/members/${d.donorId}'),
                    );
                  },
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
                title: Text(Formatters.toBnDigits('$year')),
                onTap: () => Navigator.pop(ctx, year),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _yearFilter = picked);
  }

  Future<void> _pickMonth() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (var i = 1; i <= 12; i++)
              ListTile(
                title: Text(Formatters.monthNamesBn[i - 1]),
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _monthFilter = picked);
  }
}

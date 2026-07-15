import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/disbursement_repository.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class HelpListScreen extends StatefulWidget {
  const HelpListScreen({super.key});

  @override
  State<HelpListScreen> createState() => _HelpListScreenState();
}

class _HelpListScreenState extends State<HelpListScreen> {
  final _search = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = value);
    });
  }

  List<DisbursementRecord> _filter(List<DisbursementRecord> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((h) {
      return h.beneficiaryName.toLowerCase().contains(q) ||
          h.phone.contains(q) ||
          h.nidNumber.contains(q) ||
          h.reason.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppTabScaffold(
      title: 'সাহায্য বিতরণ',
      floatingActionButton: AppSession.instance.canEnterHelp
          ? FloatingActionButton.extended(
              heroTag: 'add_help_fab',
              onPressed: () => context.push('/help/new'),
              icon: const Icon(Icons.add),
              label: const Text('নতুন সাহায্য'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'নাম, ফোন বা এনআইডি দিয়ে খুঁজুন',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DisbursementRecord>>(
              stream: DisbursementRepository.instance.watchAll(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return ErrorState(
                    message: 'ডাটা লোড করা যায়নি। আবার চেষ্টা করুন।',
                    onRetry: () => setState(() {}),
                  );
                }
                if (!snap.hasData) {
                  return const ShimmerList();
                }
                final list = _filter(snap.data!);
                if (list.isEmpty) {
                  return const EmptyState(
                    message: 'কোনো সাহায্য রেকর্ড নেই',
                    icon: Icons.volunteer_activism_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const Divider(indent: 76, height: 1),
                    itemBuilder: (context, index) {
                      final h = list[index];
                      return ListTile(
                        leading: AvatarCircle(
                          name: h.beneficiaryName,
                          backgroundColor: AppColors.successLight,
                        ),
                        title: Text(
                          h.beneficiaryName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${Formatters.shortDate(h.date)} · ${h.reason}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          Formatters.money(h.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        onTap: () => context.push('/help/${h.id}'),
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
}

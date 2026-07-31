import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
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
    final s = AppStrings.current;
    return AppTabScaffold(
      title: s.helpDistribution,
      floatingActionButton: AppSession.instance.canEnterHelp
          ? FloatingActionButton.extended(
              heroTag: 'add_help_fab',
              onPressed: () => context.push('/help/new'),
              icon: const Icon(Icons.add),
              label: Text(s.newHelp),
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
                hintText: s.searchNamePhoneOrNid,
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
                    message: s.noHelpRecords,
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
                          '${Formatters.shortDate(h.date)} · ${h.reasonLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Formatters.money(h.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (AppSession.instance.isAdmin) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _confirmDelete(context, h),
                                child: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
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

  Future<void> _confirmDelete(
      BuildContext context, DisbursementRecord h) async {
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
      await DisbursementRepository.instance.softDelete(h.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.itemMovedToTrash)),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/disbursement_repository.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return AppPageScaffold(
      title: s.trash,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_forever_outlined),
          tooltip: s.emptyTrash,
          onPressed: () => _confirmEmptyTrash(context),
        ),
      ],
      body: Column(
        children: [
          TabBar(
            controller: _tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: s.collections),
              Tab(text: s.help),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _DonationTrashTab(),
                _DisbursementTrashTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmEmptyTrash(BuildContext context) async {
    final s = AppStrings.current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.emptyTrash),
        content: Text(s.emptyTrashConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(s.permanentlyDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await DonationRepository.instance.emptyTrash();
      await DisbursementRepository.instance.emptyTrash();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.trashEmptied)),
        );
      }
    }
  }
}

class _DonationTrashTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return StreamBuilder<List<DonationRecord>>(
      stream: DonationRepository.instance.watchTrash(),
      builder: (context, snap) {
        if (!snap.hasData) return const ShimmerList();
        final list = snap.data!;
        if (list.isEmpty) {
          return EmptyState(
            message: s.noTrashItems,
            icon: Icons.delete_outline,
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(indent: 76, height: 1),
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
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _handleAction(context, v, d),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'restore', child: Text(s.restore)),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(s.permanentlyDelete,
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleAction(
      BuildContext context, String action, DonationRecord d) async {
    final s = AppStrings.current;
    if (action == 'restore') {
      await DonationRepository.instance.restore(d.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.itemRestored)),
        );
      }
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.permanentlyDelete),
          content: Text(s.permanentlyDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(s.permanentlyDelete),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        await DonationRepository.instance.permanentDelete(d.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.itemPermanentlyDeleted)),
          );
        }
      }
    }
  }
}

class _DisbursementTrashTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return StreamBuilder<List<DisbursementRecord>>(
      stream: DisbursementRepository.instance.watchTrash(),
      builder: (context, snap) {
        if (!snap.hasData) return const ShimmerList();
        final list = snap.data!;
        if (list.isEmpty) {
          return EmptyState(
            message: s.noTrashItems,
            icon: Icons.delete_outline,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(indent: 76, height: 1),
          itemBuilder: (context, index) {
            final h = list[index];
            return ListTile(
              leading: AvatarCircle(
                name: h.beneficiaryName,
                backgroundColor: AppColors.successLight,
              ),
              title: Text(h.beneficiaryName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${Formatters.shortDate(h.date)} · ${h.reasonLabel}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) => _handleAction(context, v, h),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'restore', child: Text(s.restore)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(s.permanentlyDelete,
                        style: const TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAction(
      BuildContext context, String action, DisbursementRecord h) async {
    final s = AppStrings.current;
    if (action == 'restore') {
      await DisbursementRepository.instance.restore(h.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.itemRestored)),
        );
      }
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.permanentlyDelete),
          content: Text(s.permanentlyDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(s.permanentlyDelete),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        await DisbursementRepository.instance.permanentDelete(h.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.itemPermanentlyDeleted)),
          );
        }
      }
    }
  }
}

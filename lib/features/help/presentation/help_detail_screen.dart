import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/repositories/disbursement_repository.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class HelpDetailScreen extends StatelessWidget {
  const HelpDetailScreen({super.key, required this.helpId});

  final String helpId;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return AppPageScaffold(
      title: s.helpDetail,
      actions: [
        if (AppSession.instance.isAdmin)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
      ],
      body: FutureBuilder(
        future: DisbursementRepository.instance.getById(helpId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const ShimmerList(itemCount: 3);
          }
          if (snap.hasError) {
            return ErrorState(
              message: s.recordLoadError,
              onRetry: () => Navigator.of(context).pop(),
            );
          }
          final h = snap.data;
          if (h == null) {
            return EmptyState(message: s.recordNotFoundMsg);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    AvatarCircle(
                      name: h.beneficiaryName,
                      size: 64,
                      backgroundColor: AppColors.successLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      h.beneficiaryName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.money(h.amount),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _row(s.date, Formatters.shortDate(h.date)),
                    _row(s.reason, h.reasonLabel),
                    if (h.nidNumber.isNotEmpty)
                      _row(s.nidNumber, Formatters.toDigits(h.nidNumber)),
                    _row(s.phone, Formatters.phone(h.phone)),
                    _row(s.address, h.address),
                    if (h.description != null && h.description!.isNotEmpty)
                      _row(s.descriptionNote, h.description!),
                    if (h.enteredByName != null)
                      _row(s.entryBy, h.enteredByName!),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final s = AppStrings.current;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.moveToTrash),
        content: Text(s.moveToTrashConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await DisbursementRepository.instance.softDelete(helpId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.itemMovedToTrash)),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.failedPrefix}: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(s.moveToTrash),
          ),
        ],
      ),
    );
  }
}

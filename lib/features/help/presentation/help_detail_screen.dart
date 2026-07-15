import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return AppPageScaffold(
      title: 'সাহায্যের বিবরণ',
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
              message: 'রেকর্ড লোড করা যায়নি।',
              onRetry: () => Navigator.of(context).pop(),
            );
          }
          final h = snap.data;
          if (h == null) {
            return const EmptyState(message: 'রেকর্ড পাওয়া যায়নি');
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
                    _row('তারিখ', Formatters.shortDate(h.date)),
                    _row('কারণ', h.reason),
                    _row('এনআইডি', Formatters.toBnDigits(h.nidNumber)),
                    _row('ফোন', Formatters.phone(h.phone)),
                    _row('ঠিকানা', h.address),
                    if (h.description != null && h.description!.isNotEmpty)
                      _row('বিবরণ', h.description!),
                    if (h.enteredByName != null)
                      _row('এন্ট্রি করেছেন', h.enteredByName!),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('সাহায্য রেকর্ড মুছুন'),
        content: const Text('আপনি কি নিশ্চিত এই রেকর্ড মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await DisbursementRepository.instance.delete(helpId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('রেকর্ড মুছে ফেলা হয়েছে')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ব্যর্থ: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
  }
}

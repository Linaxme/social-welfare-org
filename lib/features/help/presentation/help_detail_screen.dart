import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
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
      body: FutureBuilder(
        future: DisbursementRepository.instance.getById(helpId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
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
}

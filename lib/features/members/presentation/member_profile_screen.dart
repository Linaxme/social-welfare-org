import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/services/receipt_service.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key, required this.memberId});

  final String memberId;

  Map<String, int> _monthlyBreakdown(List<DonationRecord> donations) {
    final map = <String, int>{};
    for (final d in donations) {
      final key =
          '${Formatters.monthNamesBn[d.paidAt.month - 1]} ${Formatters.toBnDigits('${d.paidAt.year}')}';
      map[key] = (map[key] ?? 0) + d.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = AppSession.instance.canEditMemberProfile ||
        AppSession.instance.isAdmin;
    final canDonate = AppSession.instance.canRecordDonation;

    return AppPageScaffold(
      title: 'মেম্বার প্রোফাইল',
      actions: [
        if (canEdit)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/members/$memberId/edit'),
          ),
        if (AppSession.instance.isAdmin)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
      ],
      body: FutureBuilder(
        future: UserRepository.instance.getById(memberId),
        builder: (context, userSnap) {
          if (userSnap.connectionState != ConnectionState.done) {
            return const ShimmerList(itemCount: 3);
          }
          if (userSnap.hasError) {
            return ErrorState(
              message: 'মেম্বার তথ্য লোড করা যায়নি।',
              onRetry: () => Navigator.of(context).pop(),
            );
          }
          final member = userSnap.data;
          if (member == null) {
            return const EmptyState(message: 'মেম্বার পাওয়া যায়নি');
          }

          return StreamBuilder<List<DonationRecord>>(
            stream: DonationRepository.instance.watchForDonor(memberId),
            builder: (context, histSnap) {
              final history = histSnap.data ?? [];
              final monthly = _monthlyBreakdown(history);

              return ListView(
                children: [
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      children: [
                        AvatarCircle(
                          name: member.name,
                          size: 72,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          member.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.phone(member.phone),
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                        if (member.nidNumber != null &&
                            member.nidNumber!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'এনআইডি: ${Formatters.toBnDigits(member.nidNumber!)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (member.address != null &&
                            member.address!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            member.address!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: 'মোট ডোনেশন',
                                value:
                                    Formatters.money(member.totalDonation),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatBox(
                                label: 'মোট বার',
                                value: Formatters.toBnDigits(
                                    '${member.donationCount}'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (canDonate)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () => context
                            .push('/donation/new?donorId=$memberId'),
                        icon: const Icon(Icons.add_card),
                        label: const Text('নতুন ডোনেশন এন্ট্রি'),
                      ),
                    ),
                  if (monthly.isNotEmpty) ...[
                    const SectionHeader(title: 'মাসভিত্তিক সারাংশ'),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (final entry in monthly.entries)
                            ListTile(
                              dense: true,
                              title: Text(entry.key),
                              trailing: Text(
                                Formatters.money(entry.value),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SectionHeader(title: 'ডোনেশন হিস্ট্রি'),
                  if (history.isEmpty)
                    const EmptyState(message: 'এখনো কোনো ডোনেশন নেই')
                  else
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < history.length; i++) ...[
                            if (i > 0) const Divider(indent: 16),
                            ListTile(
                              title:
                                  Text(Formatters.money(history[i].amount)),
                              subtitle: Text(
                                '${Formatters.shortDate(history[i].paidAt)} · ${history[i].receiptNo}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: TextButton(
                                onPressed: () => ReceiptService.preview(
                                    context, history[i]),
                                child: const Text('রিসিপ্ট'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('মেম্বার মুছুন'),
        content: const Text('আপনি কি নিশ্চিত এই মেম্বারকে মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await UserRepository.instance.delete(memberId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('মেম্বার মুছে ফেলা হয়েছে')),
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

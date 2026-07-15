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
        if (AppSession.instance.isSuperAdmin)
          FutureBuilder<AppUser?>(
            future: UserRepository.instance.getById(memberId),
            builder: (context, userSnap) {
              return IconButton(
                icon: const Icon(Icons.badge_outlined),
                onPressed: userSnap.data != null
                    ? () => _showChangeRoleDialog(context, userSnap.data!)
                    : null,
                tooltip: 'রোল পরিবর্তন',
              );
            },
          ),
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
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(member.role),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            member.roleLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  void _showChangeRoleDialog(BuildContext context, AppUser member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ChangeRoleDialog(member: member),
    );
  }

  Color _getRoleColor(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => const Color(0xFFD32F2F),
      UserRole.collector => const Color(0xFF1976D2),
      UserRole.member => const Color(0xFF388E3C),
    };
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

class _ChangeRoleDialog extends StatefulWidget {
  const _ChangeRoleDialog({required this.member});

  final AppUser member;

  @override
  State<_ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<_ChangeRoleDialog> {
  late UserRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.role;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'রোল পরিবর্তন করুন',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.member.name} এর রোল পরিবর্তন করুন',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ...[
            UserRole.member,
            UserRole.collector,
            UserRole.superAdmin,
          ].map((role) {
            final isCurrentRole = _selectedRole == role;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _isLoading ? null : () => setState(() => _selectedRole = role),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCurrentRole ? AppColors.primary : Colors.grey.shade300,
                      width: isCurrentRole ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isCurrentRole ? AppColors.primaryLight : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Radio<UserRole>(
                        value: role,
                        groupValue: _selectedRole,
                        onChanged: _isLoading ? null : (value) {
                          if (value != null) {
                            setState(() => _selectedRole = value);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getRoleLabel(role),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getRoleDescription(role),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  child: const Text('বাতিল'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedRole == widget.member.role
                      ? null
                      : _updateRole,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('সংরক্ষণ করুন'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateRole() async {
    setState(() => _isLoading = true);
    try {
      await UserRepository.instance.updateUserRole(
        userId: widget.member.id,
        newRole: _selectedRole,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('রোল সফলভাবে পরিবর্তন করা হয়েছে')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getRoleLabel(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => 'সুপার অ্যাডমিন',
      UserRole.collector => 'কালেক্টর',
      UserRole.member => 'মেম্বার',
    };
  }

  String _getRoleDescription(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => 'সম্পূর্ণ অ্যাক্সেস - সব কিছু পরিচালনা করতে পারবেন',
      UserRole.collector => 'কালেকশন রেকর্ড এবং ডেটা ম্যানেজমেন্ট',
      UserRole.member => 'শুধুমাত্র দেখার অ্যাক্সেস',
    };
  }
}

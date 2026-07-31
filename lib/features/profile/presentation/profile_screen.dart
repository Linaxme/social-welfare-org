import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    AppSession.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AppSession.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSession.instance.user;
    final s = AppStrings.current;

    return AppPageScaffold(
      title: s.myProfile,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                AvatarCircle(name: user.name, size: 72),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.roleLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (user.email != null && user.email!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    user.email!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                if (user.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    Formatters.phone(user.phone),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                if (user.address != null && user.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.address!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (AppSession.instance.isMember ||
              AppSession.instance.isCollector) ...[
            const SizedBox(height: 16),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.history, color: AppColors.primary),
                title: Text(s.myDonationHistory),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/members/${user.id}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

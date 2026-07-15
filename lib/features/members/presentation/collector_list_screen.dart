import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

/// Collectors list (members with collector role)
class CollectorListScreen extends StatelessWidget {
  const CollectorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTabScaffold(
      title: 'কালেক্টর',
      body: StreamBuilder<List<AppUser>>(
        stream: UserRepository.instance.watchMembers(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = (snap.data ?? [])
              .where((m) => m.role == UserRole.collector)
              .toList();

          if (list.isEmpty) {
            return const EmptyState(
              message: 'এখনো কোনো কালেক্টর নেই',
              icon: Icons.badge_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = list[i];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: AvatarCircle(name: m.name),
                  title: Text(
                    m.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(Formatters.phone(m.phone)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/members/${m.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

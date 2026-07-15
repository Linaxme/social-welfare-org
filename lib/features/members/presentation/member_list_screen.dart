import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AppUser> _filter(List<AppUser> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.phone.contains(q) ||
          m.uniqueId.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppTabScaffold(
      title: 'মেম্বার তালিকা',
      floatingActionButton: AppSession.instance.canManageMembers
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/members/new'),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('নতুন মেম্বার'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'নাম বা ফোন দিয়ে খুঁজুন',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                suffixIcon: _query.isNotEmpty
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
            child: StreamBuilder<List<AppUser>>(
              stream: UserRepository.instance.watchMembers(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return EmptyState(message: 'লোড ব্যর্থ: ${snap.error}');
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = _filter(snap.data!);
                if (list.isEmpty) {
                  return const EmptyState(message: 'কোনো মেম্বার পাওয়া যায়নি');
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const Divider(indent: 76, height: 1),
                  itemBuilder: (context, index) {
                    final m = list[index];
                    return ListTile(
                      leading: AvatarCircle(name: m.name),
                      title: Text(
                        m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${Formatters.phone(m.phone)} · ${m.roleLabel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Text(
                        Formatters.money(m.totalDonation),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => context.push('/members/${m.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

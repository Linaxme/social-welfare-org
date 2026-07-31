import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
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
    final s = AppStrings.current;
    return AppTabScaffold(
      title: s.memberList,
      floatingActionButton: AppSession.instance.canManageMembers
          ? FloatingActionButton.extended(
              heroTag: 'add_member_fab',
              onPressed: () => context.push('/members/new'),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(s.newMember),
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
                hintText: s.searchNameOrPhone,
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
            child: StreamBuilder<List<AppUser>>(
              stream: UserRepository.instance.watchMembers(),
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
                  return EmptyState(message: '${s.members} ${s.recordNotFound}');
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const Divider(indent: 76, height: 1),
                    itemBuilder: (context, index) {
                      final m = list[index];
                      final canViewFullProfile = AppSession.instance.isAdmin ||
                          AppSession.instance.isCollector ||
                          m.id == AppSession.instance.user.id;

                      final subtitleText = canViewFullProfile
                          ? '${Formatters.phone(m.phone)} · ${m.roleLabel}${m.email != null && m.email!.isNotEmpty ? '\n${m.email}' : ''}'
                          : m.roleLabel;

                      return ListTile(
                        leading: AvatarCircle(
                          name: m.name,
                        ),
                        title: Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          subtitleText,
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
                        onTap: canViewFullProfile
                            ? () => context.push('/members/${m.id}')
                            : null,
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
}

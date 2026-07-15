import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/data/org_settings.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/app_page_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _orgNameController = TextEditingController();
  late final OrgSettings _settings;

  bool get _isAdmin => AppSession.instance.isAdmin;

  @override
  void initState() {
    super.initState();
    _settings = OrgSettings.instance;
    _orgNameController.text = _settings.orgName;
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _orgNameController.dispose();
    super.dispose();
  }

  void _saveOrgName() {
    _settings.updateOrgName(_orgNameController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('সংগঠনের নাম সংরক্ষিত হয়েছে')),
    );
  }

  void _showChangePasswordSheet() {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'পাসওয়ার্ড পরিবর্তন',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: current,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'বর্তমান পাসওয়ার্ড'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: next,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'নতুন পাসওয়ার্ড'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirm,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'নতুন পাসওয়ার্ড নিশ্চিত করুন'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (next.text.isEmpty || next.text != confirm.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('নতুন পাসওয়ার্ড মিলছে না'),
                      ),
                    );
                    return;
                  }
                  try {
                    await AuthService.instance.changePassword(
                      currentPassword: current.text,
                      newPassword: next.text,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('পাসওয়ার্ড আপডেট হয়েছে')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('$e'.replaceFirst('Exception: ', '')),
                        ),
                      );
                    }
                  }
                },
                child: const Text('সংরক্ষণ'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'সোমিতি',
      applicationVersion: '১.০.০',
      applicationIcon: const Icon(
        Icons.diversity_3_rounded,
        color: AppColors.primary,
        size: 40,
      ),
      children: const [
        Text(
          'সমাজ কল্যাণ সংগঠনের হিসাব, ডোনেশন ও সাহায্য বিতরণ ম্যানেজমেন্ট অ্যাপ।',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppTabScaffold(
      title: 'সেটিংস',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'অ্যাকাউন্ট'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.primary),
                title: const Text('আমার প্রোফাইল'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                title: const Text('পাসওয়ার্ড পরিবর্তন'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showChangePasswordSheet,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.primary),
                title: const Text('লগআউট'),
                onTap: () async {
                  await AppSession.instance.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'রিপোর্ট'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.summarize_outlined,
                    color: AppColors.primary),
                title: const Text('কাস্টম রিপোর্ট'),
                subtitle: const Text('Excel / PDF এক্সপোর্ট'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/reports'),
              ),
            ],
          ),
          if (_isAdmin) ...[
            const SizedBox(height: 16),
            _SectionTitle(title: 'সংগঠন'),
            _SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'সংগঠনের নাম',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _orgNameController,
                        decoration: const InputDecoration(
                          hintText: 'সংগঠনের নাম লিখুন',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saveOrgName,
                        child: const Text('নাম সংরক্ষণ'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionTitle(title: 'কালেক্টর পারমিশন'),
            Text(
              'সুপার অ্যাডমিন থেকে কালেক্টরদের ক্ষমতা নিয়ন্ত্রণ করুন',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                SwitchListTile(
                  title: const Text('মেম্বার প্রোফাইল এডিট'),
                  subtitle: const Text(
                    'কালেক্টর মেম্বারের নাম ও তথ্য সম্পাদনা করতে পারবে',
                  ),
                  activeThumbColor: AppColors.primary,
                  value: _settings.collectorCanEditProfile,
                  onChanged: _settings.setCollectorCanEditProfile,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('সাহায্য / আউটগোয়িং এন্ট্রি'),
                  subtitle: const Text(
                    'কালেক্টর সাহায্য বিতরণ রেকর্ড করতে পারবে',
                  ),
                  activeThumbColor: AppColors.primary,
                  value: _settings.collectorCanEnterDonation,
                  onChanged: _settings.setCollectorCanEnterDonation,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _SectionTitle(title: 'অ্যাপ'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text('অ্যাপ সম্পর্কে'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showAbout,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const ListTile(
                leading: Icon(Icons.language, color: AppColors.primary),
                title: Text('ভাষা'),
                subtitle: Text('বাংলা'),
                trailing: Text(
                  'শুধু বাংলা',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

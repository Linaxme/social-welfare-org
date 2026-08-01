import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/data/locale_provider.dart';
import '../../../shared/data/org_settings.dart';
import '../../../shared/data/theme_provider.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/widgets.dart';

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
    final s = AppStrings.current;
    if (_orgNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.enterOrgName)),
      );
      return;
    }
    _settings.updateOrgName(_orgNameController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.orgNameSaved)),
    );
  }

  void _showChangePasswordSheet() {
    final s = AppStrings.current;
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.changePassword,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: current,
                  obscureText: true,
                  validator: Validators.password,
                  decoration: InputDecoration(labelText: s.currentPassword),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: next,
                  obscureText: true,
                  validator: Validators.password,
                  decoration: InputDecoration(labelText: s.newPassword),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirm,
                  obscureText: true,
                  validator: (v) => Validators.confirmPassword(v, next.text),
                  decoration:
                      InputDecoration(labelText: s.confirmPassword),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      await AuthService.instance.changePassword(
                        currentPassword: current.text,
                        newPassword: next.text,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.passwordUpdated)),
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
                  child: Text(s.save),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAbout() {
    final s = AppStrings.current;
    final org = OrgSettings.instance.orgName;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            color: Theme.of(ctx).colorScheme.surface,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header Banner ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF007A52), Color(0xFF004D34)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.diversity_3_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          org.isNotEmpty ? org : 'সমিতি ও সংগঠন ম্যানেজমেন্ট',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'Version 1.0.0.1 (Final Release)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Content ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bengali Comprehensive Section
                        const Text(
                          'স্মার্ট সমিতি ও সংগঠন প্ল্যাটফর্ম',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'সমিতি ও সমাজকল্যাণ সংস্থা ম্যানেজমেন্ট সিস্টেম হল একটি আধুনিক, সর্বাধুনিক প্রযুক্তিতে তৈরি ডিজিটাল সমাধান। এটি সমিতি, অলাভজনক প্রতিষ্ঠান, ক্লাব ও সামাজিক ফান্ডসমূহের দৈনন্দিন কালেকশন, সদস্য ডিরেক্টরি এবং অটোমেটেড অনুদান সংগ্রহ প্রক্রিয়াকে সহজ, সুরক্ষিত ও স্বচ্ছ করার উদ্দেশ্যে নির্মিত।',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '📌 মূল সুবিধাসমূহ:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '• ডিজিটাল কালেকশন এন্ট্রি ও অটোমেটেড পিডিএফ রিসিট\n'
                                '• রিয়েল-টাইম আয়-ব্যয়, মাসিক গ্রাফ ও ব্যালেন্স সামারি\n'
                                '• সদস্য ডিরেক্টরি ও রোল-ভিত্তিক ডাটা প্রাইভেসি\n'
                                '• সেরা দাতা স্লাইডার ও র‍্যাঙ্কিং লিডারবোর্ড',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // English Detailed Section
                        const Text(
                          'Smart & Automated System (English)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Somiti & Welfare Organization Management System is an enterprise-grade digital platform engineered to streamline financial tracking, membership directories, collection logging, real-time analytics, and automated PDF receipt printing for societies and non-profit organizations.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Small Subtle Developed By Footer
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Developed By',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Saif Ahmed Limon',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Compact Contact Row
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                        const ClipboardData(text: 'linaxme@gmail.com'),
                                      );
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text('Copied: linaxme@gmail.com'),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.email_outlined, size: 12, color: AppColors.textSecondary),
                                        SizedBox(width: 3),
                                        Text(
                                          'linaxme@gmail.com',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Text('·', style: TextStyle(color: AppColors.textSecondary)),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                        const ClipboardData(text: '+8801826090490'),
                                      );
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text('Copied: +88 01826090490'),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                                        SizedBox(width: 3),
                                        Text(
                                          '+88 01826090490',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Close Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(s.close),
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
      },
    );
  }

  Future<void> _downloadApk() async {
    final url = OrgSettings.instance.apkDownloadUrl;
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('এপিকে ডাউনলোড লিঙ্ক এখনো যুক্ত করা হয়নি'),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url.trim());
      if (kIsWeb) {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_self',
        );
      } else {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('লিঙ্ক খুলতে ব্যর্থ হয়েছে')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    }
  }

  void _showEditApkUrlDialog() {
    final controller = TextEditingController(text: OrgSettings.instance.apkDownloadUrl);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('এপিকে ডাউনলোড লিঙ্ক সম্পাদনা'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://... (এপিকে ডাউনলোডের লিঙ্ক)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              OrgSettings.instance.updateApkDownloadUrl(controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ডাউনলোড লিঙ্ক আপডেট করা হয়েছে')),
              );
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final s = AppStrings.current;
    final currentLocale = LocaleProvider.instance.localeCode;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text('বাংলা'),
              trailing: currentLocale == 'bn'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                LocaleProvider.instance.setLocale(const Locale('bn'));
                Navigator.pop(ctx);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: Text(s.english),
              trailing: currentLocale == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                LocaleProvider.instance.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final currentLocale = LocaleProvider.instance.localeCode;
    final currentLangName = currentLocale == 'bn' ? s.bengali : s.english;

    return AppTabScaffold(
      title: s.settings,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: s.account),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.primary),
                title: Text(s.myProfileSettings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                title: Text(s.changePassword),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showChangePasswordSheet,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.primary),
                title: Text(s.logout),
                onTap: () async {
                  await AppSession.instance.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          if (AppSession.instance.canSeeReports) ...[
            const SizedBox(height: 16),
            _SectionTitle(title: s.reportSection),
            _SettingsCard(
              children: [
                if (AppSession.instance.isCollector || AppSession.instance.isAdmin)
                  ListTile(
                    leading: const Icon(Icons.history, color: AppColors.primary),
                    title: Text(s.myCollectionHistory),
                    subtitle: Text(s.viewCollectionHistory),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/my-collections'),
                  ),
                if (AppSession.instance.isCollector || AppSession.instance.isAdmin)
                  const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.summarize_outlined,
                      color: AppColors.primary),
                  title: Text(s.customReportExport),
                  subtitle: Text(s.excelPdfExport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/reports'),
                ),
              ],
            ),
          ],
          if (_isAdmin) ...[
            const SizedBox(height: 16),
            _SectionTitle(title: s.organization),
            _SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.organizationName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _orgNameController,
                        decoration: InputDecoration(
                          hintText: s.enterOrgName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saveOrgName,
                        child: Text(s.saveName),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: LocaleProvider.instance.isEn
                  ? 'Dashboard Slider Settings'
                  : 'ড্যাশবোর্ড স্লাইডশো সেটিংস (Slider Settings)',
            ),
            _SettingsCard(
              children: [
                SwitchListTile(
                  title: Text(
                    LocaleProvider.instance.isEn
                        ? 'Show Dashboard Slider'
                        : 'ড্যাশবোর্ড স্লাইডশো প্রদর্শন',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    LocaleProvider.instance.isEn
                        ? 'Enable or disable top slider carousel on home screen'
                        : 'ড্যাশবোর্ডের স্লাইডশো চালু বা বন্ধ করুন',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  activeThumbColor: AppColors.primary,
                  value: _settings.showDashboardSlider,
                  onChanged: _settings.updateShowDashboardSlider,
                ),
                if (_settings.showDashboardSlider) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleProvider.instance.isEn
                              ? 'Select Slider Content Mode:'
                              : 'স্লাইডশো মোড নির্বাচন (Content Mode):',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RadioListTile<String>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded, size: 18, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Text(
                                LocaleProvider.instance.isEn
                                    ? '🏆 Top Donors Leaderboard'
                                    : '🏆 সেরা দাতা (Top Donors)',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            LocaleProvider.instance.isEn
                                ? 'Show leaderboard carousel of top donors'
                                : 'কেবলমাত্র সেরা ডোনারদের র‍্যাঙ্কিং স্লাইডশো দেখাবে',
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: 'donors',
                          groupValue: _settings.sliderContentType,
                          onChanged: (val) {
                            if (val != null) _settings.updateSliderContentType(val);
                          },
                        ),
                        RadioListTile<String>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: Row(
                            children: [
                              const Icon(Icons.volunteer_activism_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                LocaleProvider.instance.isEn
                                    ? '🤝 Aid & Welfare Disbursements'
                                    : '🤝 সহায়তা ও প্রদেয় অনুদান (Aid Cards)',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            LocaleProvider.instance.isEn
                                ? 'Show colorful cards of aid disbursements'
                                : 'সংগঠনের প্রদানকৃত সহায়তা কার্ডসমূহ রঙিন স্লাইডশো দেখাবে',
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: 'aids',
                          groupValue: _settings.sliderContentType,
                          onChanged: (val) {
                            if (val != null) _settings.updateSliderContentType(val);
                          },
                        ),
                        RadioListTile<String>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: Row(
                            children: [
                              const Icon(Icons.swap_horizontal_circle_rounded, size: 18, color: AppColors.primaryDark),
                              const SizedBox(width: 8),
                              Text(
                                LocaleProvider.instance.isEn
                                    ? '🔄 Both (Top Donors & Aid Cards)'
                                    : '🔄 উভয়ই (Both Donors & Aids)',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            LocaleProvider.instance.isEn
                                ? 'Automatically alternate between top donors and aid cards'
                                : 'সেরা দাতা ও প্রদেয় অনুদান উভয়ই স্বয়ংক্রিয় স্লাইডশো হবে',
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: 'both',
                          groupValue: _settings.sliderContentType,
                          onChanged: (val) {
                            if (val != null) _settings.updateSliderContentType(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _SectionTitle(title: s.collectorPermission),
            Text(
              s.collectorPermDesc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                SwitchListTile(
                  title: Text(s.memberProfileEdit),
                  subtitle: Text(
                    s.memberProfileEditDesc,
                  ),
                  activeThumbColor: AppColors.primary,
                  value: _settings.collectorCanEditProfile,
                  onChanged: _settings.setCollectorCanEditProfile,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: Text(s.helpOutgoingEntry),
                  subtitle: Text(
                    s.helpOutgoingDesc,
                  ),
                  activeThumbColor: AppColors.primary,
                  value: _settings.collectorCanEnterDonation,
                  onChanged: _settings.setCollectorCanEnterDonation,
                ),
              ],
            ),
          ],
          if (_isAdmin || AppSession.instance.isCollector) ...[
            const SizedBox(height: 16),
            _SectionTitle(title: s.collectorCollectionSummary),
            _SettingsCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.pie_chart_outline, color: AppColors.primary),
                  title: Text(s.collectorCollectionSummary),
                  subtitle: Text(s.collectorCollectionSummaryDesc),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/collector-summary'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _SectionTitle(title: s.appSection),
          _SettingsCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                title: Text(s.darkMode),
                subtitle: Text(s.darkModeDesc),
                activeThumbColor: AppColors.primary,
                value: ThemeProvider.instance.isDark,
                onChanged: (value) {
                  ThemeProvider.instance.toggleTheme();
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.language, color: AppColors.primary),
                title: Text(s.language),
                subtitle: Text(currentLangName),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLanguagePicker,
              ),
              if (_isAdmin) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text(s.trash),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/trash'),
                ),
              ],
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: Text(s.aboutApp),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showAbout,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.android,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Download Android APK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isAdmin)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                        onPressed: _showEditApkUrlDialog,
                        tooltip: 'লিঙ্ক সেট করুন',
                      ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.file_download_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                onTap: _downloadApk,
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



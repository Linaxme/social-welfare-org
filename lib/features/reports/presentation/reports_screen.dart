import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/services/report_export_service.dart';
import '../../../shared/widgets/app_page_header.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _year = 2026;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'কাস্টম রিপোর্ট',
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'বছর',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _year,
                items: [2024, 2025, 2026]
                    .map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text(Formatters.toBnDigits('$y')),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _year = v);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'এক্সপোর্ট',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              _ReportTile(
                icon: Icons.people_outline,
                title: 'মেম্বার তালিকা',
                subtitle: 'Excel (.xlsx)',
                onTap: () => _run(
                  () => ReportExportService.exportMembersExcel(context),
                ),
              ),
              _ReportTile(
                icon: Icons.payments_outlined,
                title: 'মাসিক কালেকশন শিট',
                subtitle: 'Excel — নির্বাচিত বছর',
                onTap: () => _run(
                  () => ReportExportService.exportCollectionsExcel(
                    context,
                    year: _year,
                  ),
                ),
              ),
              _ReportTile(
                icon: Icons.bar_chart_outlined,
                title: 'মাসিক কালেকশন সারাংশ',
                subtitle: 'PDF — মাস অনুযায়ী',
                onTap: () => _run(
                  () => ReportExportService.exportMonthlyCollectionPdf(
                    context,
                    year: _year,
                  ),
                ),
              ),
              _ReportTile(
                icon: Icons.volunteer_activism_outlined,
                title: 'সাহায্য বিতরণ রিপোর্ট',
                subtitle: 'PDF',
                onTap: () =>
                    _run(() => ReportExportService.exportHelpPdf(context)),
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.download_outlined),
        onTap: onTap,
      ),
    );
  }
}

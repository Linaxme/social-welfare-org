import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
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
  int _year = DateTime.now().year;
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
    final s = AppStrings.current;
    return AppPageScaffold(
      title: s.customReport,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                s.year,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _year,
                items: [2024, 2025, 2026, 2027]
                    .map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text(Formatters.toDigits('$y')),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _year = v);
                },
              ),
              const SizedBox(height: 20),

              _SectionTitle(s.yearlySummary),
              _ExportRow(
                icon: Icons.summarize_outlined,
                title: s.yearlySummary,
                onPdf: () => _run(
                  () => ReportExportService.exportYearlySummaryPdf(
                    context,
                    year: _year,
                  ),
                ),
                onExcel: () => _run(
                  () => ReportExportService.exportYearlySummaryExcel(
                    context,
                    year: _year,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _SectionTitle(s.members),
              _ExportRow(
                icon: Icons.people_outline,
                title: s.memberListReport,
                onPdf: () => _run(
                  () => ReportExportService.exportMembersPdf(context),
                ),
                onExcel: () => _run(
                  () => ReportExportService.exportMembersExcel(context),
                ),
              ),
              const SizedBox(height: 16),

              _SectionTitle(s.collectionReport),
              _ExportRow(
                icon: Icons.payments_outlined,
                title: s.collectionReport,
                subtitle: s.selectedYear,
                onPdf: () => _run(
                  () => ReportExportService.exportCollectionsPdf(
                    context,
                    year: _year,
                  ),
                ),
                onExcel: () => _run(
                  () => ReportExportService.exportCollectionsExcel(
                    context,
                    year: _year,
                  ),
                ),
              ),
              _ExportRow(
                icon: Icons.bar_chart_outlined,
                title: s.monthlyCollectionSummary,
                subtitle: s.byMonth,
                onPdf: () => _run(
                  () => ReportExportService.exportMonthlyCollectionPdf(
                    context,
                    year: _year,
                  ),
                ),
                onExcel: () => _run(
                  () => ReportExportService.exportMonthlyCollectionExcel(
                    context,
                    year: _year,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _SectionTitle(s.helpDistribution),
              _ExportRow(
                icon: Icons.volunteer_activism_outlined,
                title: s.helpDistributionReport,
                onPdf: () => _run(
                  () => ReportExportService.exportHelpPdf(context),
                ),
                onExcel: () => _run(
                  () => ReportExportService.exportHelpExcel(context),
                ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

class _ExportRow extends StatelessWidget {
  const _ExportRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onPdf,
    required this.onExcel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

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
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
              tooltip: 'PDF',
              onPressed: onPdf,
            ),
            IconButton(
              icon: const Icon(Icons.table_chart, color: Colors.green),
              tooltip: 'Excel',
              onPressed: onExcel,
            ),
          ],
        ),
      ),
    );
  }
}

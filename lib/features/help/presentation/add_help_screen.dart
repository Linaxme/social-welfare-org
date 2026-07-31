import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/disbursement_repository.dart';
import '../../../shared/widgets/app_page_header.dart';

class AddHelpScreen extends StatefulWidget {
  const AddHelpScreen({super.key});

  @override
  State<AddHelpScreen> createState() => _AddHelpScreenState();
}

class _AddHelpScreenState extends State<AddHelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now();
  final _reasonController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _description.dispose();
    _amount.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;

    return AppPageScaffold(
      title: s.newHelpTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label(context, s.recipientName),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(hintText: s.fullName),
              validator: Validators.name,
            ),
            const SizedBox(height: 14),
            _label(context, s.phoneNumber),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '01XXXXXXXX'),
              validator: Validators.phone,
            ),
            const SizedBox(height: 14),
            _label(context, s.fullAddress),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: s.addressHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? s.enterName : null,
            ),
            const SizedBox(height: 14),
            _label(context, s.reason),
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(hintText: s.reason),
              validator: (v) => (v == null || v.trim().isEmpty) ? s.enterName : null,
            ),
            const SizedBox(height: 14),
            _label(context, s.descriptionNote),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(hintText: s.additionalInfo),
            ),
            const SizedBox(height: 14),
            _label(context, '${s.amountTaka} *'),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
              validator: Validators.amount,
            ),
            const SizedBox(height: 14),
            _label(context, '${s.date} *'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(Formatters.shortDate(_date)),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.recordHelp),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final s = AppStrings.current;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final amount = Validators.cleanAmount(_amount.text) ?? 0;
      await DisbursementRepository.instance.add(
        DisbursementRecord(
          id: '',
          beneficiaryName: _name.text.trim(),
          nidNumber: '',
          phone: Validators.cleanPhone(_phone.text),
          address: _address.text.trim(),
          reason: _reasonController.text.trim(),
          amount: amount,
          date: _date,
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.helpRecordSaved)),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final _nid = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now();
  String _reason = 'চিকিৎসা';
  bool _loading = false;

  static const _reasons = ['চিকিৎসা', 'শিক্ষা', 'বিধবা সাহায্য', 'অন্যান্য'];

  @override
  void dispose() {
    _name.dispose();
    _nid.dispose();
    _phone.dispose();
    _address.dispose();
    _description.dispose();
    _amount.dispose();
    super.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final amount = Validators.cleanAmount(_amount.text) ?? 0;
      await DisbursementRepository.instance.add(
        DisbursementRecord(
          id: '',
          beneficiaryName: _name.text.trim(),
          nidNumber: _nid.text.trim(),
          phone: Validators.cleanPhone(_phone.text),
          address: _address.text.trim(),
          reason: _reason,
          amount: amount,
          date: _date,
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সাহায্য রেকর্ড সংরক্ষিত হয়েছে')),
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

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'নতুন সাহায্য',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label(context, 'নাম *'),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(hintText: 'প্রাপকের নাম'),
              validator: Validators.name,
            ),
            const SizedBox(height: 14),
            _label(context, 'এনআইডি নম্বর *'),
            TextFormField(
              controller: _nid,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '১৩ ডিজিট'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'এনআইডি দিন';
                return Validators.nid(v);
              },
            ),
            const SizedBox(height: 14),
            _label(context, 'ফোন নম্বর *'),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '০১৭XXXXXXXX'),
              validator: Validators.phone,
            ),
            const SizedBox(height: 14),
            _label(context, 'ঠিকানা *'),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'গ্রাম, উপজেলা, জেলা',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'ঠিকানা দিন' : null,
            ),
            const SizedBox(height: 14),
            _label(context, 'কেন (কারণ) *'),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              items: _reasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _reason = v ?? _reason),
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 14),
            _label(context, 'বিবরণ নোট'),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'অতিরিক্ত তথ্য'),
            ),
            const SizedBox(height: 14),
            _label(context, 'পরিমাণ (টাকা) *'),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '০'),
              validator: Validators.amount,
            ),
            const SizedBox(height: 14),
            _label(context, 'তারিখ *'),
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
                  : const Text('সাহায্য রেকর্ড করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

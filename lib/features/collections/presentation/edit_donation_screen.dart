import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/widgets/app_page_header.dart';

class EditDonationScreen extends StatefulWidget {
  const EditDonationScreen({super.key, required this.donation});

  final DonationRecord donation;

  @override
  State<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends State<EditDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _date;
  late String _paymentMode;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _amount =
        TextEditingController(text: Formatters.toDigits('${widget.donation.amount}'));
    _note = TextEditingController(text: widget.donation.note ?? '');
    _date = widget.donation.paidAt;
    _paymentMode = _normalizePaymentMode(widget.donation.paymentMode);
  }

  String _normalizePaymentMode(String mode) {
    return switch (mode) {
      'নগদ' || 'cash' => 'cash',
      'বিকাশ' || 'bkash' => 'bkash',
      _ => 'other',
    };
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final amount = Validators.cleanAmount(_amount.text) ?? 0;
      await DonationRepository.instance.updateDonation(
        id: widget.donation.id,
        newAmount: amount,
        newPaidAt: _date,
        newPaymentMode: _paymentMode,
        newNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.current.donationUpdated)),
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
    final s = AppStrings.current;
    return AppPageScaffold(
      title: s.editDonation,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(s.donor, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: const InputDecoration(),
              child: Text(
                '${widget.donation.donorName} · ${Formatters.shortDate(widget.donation.paidAt)}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 14),
            Text(s.amountTaka, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              validator: Validators.amount,
            ),
            const SizedBox(height: 14),
            Text(s.paymentMode, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _paymentMode,
              items: [
                DropdownMenuItem(value: 'cash', child: Text(s.cash)),
                DropdownMenuItem(value: 'bkash', child: Text(s.bkash)),
                DropdownMenuItem(value: 'other', child: Text(s.other)),
              ],
              onChanged: (v) =>
                  setState(() => _paymentMode = v ?? _paymentMode),
            ),
            const SizedBox(height: 14),
            Text(s.date, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(Formatters.shortDate(_date)),
              ),
            ),
            const SizedBox(height: 14),
            Text(s.note, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(controller: _note, maxLines: 2),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.save),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/donation_repository.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/services/receipt_service.dart';
import '../../../shared/widgets/app_page_header.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key, this.preselectedDonorId});

  final String? preselectedDonorId;

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  AppUser? _donor;
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  String _paymentMode = 'cash';
  bool _loading = false;
  List<AppUser> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final list = await UserRepository.instance.fetchMembers();
    setState(() {
      _members = list
          .where((m) =>
              m.role == UserRole.member ||
              m.role == UserRole.collector ||
              m.role == UserRole.superAdmin)
          .toList();

      if (widget.preselectedDonorId != null) {
        try {
          _donor =
              _members.firstWhere((m) => m.id == widget.preselectedDonorId);
        } catch (_) {}
      }
    });
  }

  void _selectSelf() {
    final me = AppSession.instance.userOrNull;
    if (me == null || me.id.isEmpty) return;
    try {
      final fromList = _members.firstWhere((m) => m.id == me.id);
      setState(() => _donor = fromList);
    } catch (_) {
      setState(() => _donor = me);
      if (!_members.any((m) => m.id == me.id)) {
        _members = [me, ..._members];
      }
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDonor() async {
    final s = AppStrings.current;
    final picked = await showModalBottomSheet<AppUser>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.selectDonor,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _members.length,
                itemBuilder: (_, i) {
                  final m = _members[i];
                  return ListTile(
                    title: Text(m.name),
                    subtitle: Text(
                      '${Formatters.phone(m.phone)}${m.role == UserRole.superAdmin ? ' · ${s.admin}' : ''}',
                    ),
                    onTap: () => Navigator.pop(ctx, m),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _donor = picked);
  }

  Future<void> _save() async {
    final s = AppStrings.current;
    if (_donor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.selectDonor)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final amount = Validators.cleanAmount(_amount.text) ?? 0;
      final record = await DonationRepository.instance.addDonation(
        donor: _donor!,
        amount: amount,
        paidAt: _date,
        paymentMode: _paymentMode,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      final openReceipt = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.donationSaved),
          content: Text(
            '${s.receiptNo}: ${record.receiptNo}\n'
            '${s.members}: ${record.donorName}\n'
            '${s.amount}: ${Formatters.money(record.amount)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.close),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.receiptPdf),
            ),
          ],
        ),
      );
      if (openReceipt == true && mounted) {
        await ReceiptService.preview(context, record);
      }
      if (mounted) context.pop();
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
      title: s.collectDonation,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(s.donor, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDonor,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _donor == null
                      ? s.selectDonor
                      : '${_donor!.name} · ${Formatters.phone(_donor!.phone)}',
                  style: TextStyle(
                    color: _donor == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                if (AppSession.instance.isAdmin)
                  TextButton.icon(
                    onPressed: _selectSelf,
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: Text(s.selfCollection),
                  ),
                const Spacer(),
                if (AppSession.instance.canManageMembers)
                  TextButton(
                    onPressed: () => context.push('/members/new'),
                    child: Text(s.newMemberPlus),
                  ),
              ],
            ),
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
              onChanged: (v) => setState(() => _paymentMode = v ?? _paymentMode),
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
                  : Text(s.saveAndReceipt),
            ),
          ],
        ),
      ),
    );
  }
}

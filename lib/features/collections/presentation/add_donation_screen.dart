import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
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
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  String _paymentMode = 'নগদ';
  bool _loading = false;
  List<AppUser> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final list = await UserRepository.instance.fetchMembers();
    final session = AppSession.instance;
    setState(() {
      // সবাই দান করতে পারে — অ্যাডমিনসহ
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
      } else if (session.isAdmin) {
        // সুপার অ্যাডমিন ডিফল্টে নিজেকে সিলেক্ট করতে পারবেন চাইলে বাটন দিয়ে
      }
    });
  }

  void _selectSelf() {
    final me = AppSession.instance.userOrNull;
    if (me == null || me.id.isEmpty) return;
    // Prefer Firestore-loaded profile if in list
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
    final picked = await showModalBottomSheet<AppUser>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'দাতা নির্বাচন',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                      '${Formatters.phone(m.phone)}${m.role == UserRole.superAdmin ? ' · অ্যাডমিন' : ''}',
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
    if (_donor == null || _amount.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দাতা ও পরিমাণ দিন')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final amount = int.tryParse(_amount.text) ?? 0;
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
          title: const Text('ডোনেশন সংরক্ষিত'),
          content: Text(
            'রিসিপ্ট: ${record.receiptNo}\n'
            'মেম্বার: ${record.donorName}\n'
            'পরিমাণ: ${Formatters.money(record.amount)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('বন্ধ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('রিসিপ্ট PDF'),
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
    return AppPageScaffold(
      title: 'জমা নিন',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('দাতা', style: Theme.of(context).textTheme.labelLarge),
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
                    ? 'দাতা বেছে নিন'
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
                  label: const Text('নিজের জমা'),
                ),
              const Spacer(),
              if (AppSession.instance.canManageMembers)
                TextButton(
                  onPressed: () => context.push('/members/new'),
                  child: const Text('+ নতুন মেম্বার'),
                ),
            ],
          ),
          Text('পরিমাণ (টাকা)', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          Text('পেমেন্ট মোড', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _paymentMode,
            items: const [
              DropdownMenuItem(value: 'নগদ', child: Text('নগদ')),
              DropdownMenuItem(value: 'বিকাশ', child: Text('বিকাশ')),
              DropdownMenuItem(value: 'অন্যান্য', child: Text('অন্যান্য')),
            ],
            onChanged: (v) => setState(() => _paymentMode = v ?? _paymentMode),
          ),
          const SizedBox(height: 14),
          Text('তারিখ', style: Theme.of(context).textTheme.labelLarge),
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
          Text('নোট', style: Theme.of(context).textTheme.labelLarge),
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
                : const Text('সেভ ও রিসিপ্ট'),
          ),
        ],
      ),
    );
  }
}

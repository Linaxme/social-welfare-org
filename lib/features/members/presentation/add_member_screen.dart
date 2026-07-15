import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/app_page_header.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _nid = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController(text: '123456');
  UserRole _role = UserRole.member;
  String? _previewId;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _nid.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  void _updatePreview(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    setState(() {
      if (digits.length >= 11) {
        _previewId = digits.length > 11
            ? digits.substring(digits.length - 11)
            : digits;
      } else {
        _previewId = digits.isEmpty ? null : digits;
      }
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || (_previewId?.length ?? 0) < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('নাম ও সঠিক ফোন নম্বর দিন')),
      );
      return;
    }
    if (_address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ঠিকানা দিন')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.createUserAccount(
        name: _name.text,
        phone: _previewId!,
        password: _password.text,
        role: _role,
        nidNumber: _nid.text.trim().isEmpty ? null : _nid.text.trim(),
        address: _address.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'যোগ হয়েছে · আইডি: ${Formatters.phone(user.phone)}',
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'নতুন মেম্বার',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('নাম', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'পূর্ণ নাম'),
          ),
          const SizedBox(height: 16),
          Text('ফোন নম্বর', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '০১৭XXXXXXXX'),
            onChanged: _updatePreview,
          ),
          if (_previewId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ইউজার আইডি (অটো): ${Formatters.phone(_previewId!)}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('এনআইডি নং (অপশনাল)',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nid,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'জাতীয় পরিচয়পত্র নম্বর'),
          ),
          const SizedBox(height: 16),
          Text('ঠিকানা', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _address,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'গ্রাম/এলাকা, থানা, জেলা',
            ),
          ),
          const SizedBox(height: 16),
          Text('রোল', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            initialValue: _role,
            items: const [
              DropdownMenuItem(value: UserRole.member, child: Text('মেম্বার')),
              DropdownMenuItem(
                value: UserRole.collector,
                child: Text('কালেক্টর'),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _role = v);
            },
          ),
          const SizedBox(height: 16),
          Text('প্রাথমিক পাসওয়ার্ড',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(controller: _password),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('মেম্বার যোগ করুন'),
          ),
        ],
      ),
    );
  }
}

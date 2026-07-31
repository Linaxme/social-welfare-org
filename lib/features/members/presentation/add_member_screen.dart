import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/app_page_header.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController(text: '123456');
  UserRole _role = UserRole.member;
  String? _previewId;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.createUserAccount(
        name: _name.text,
        phone: _previewId!,
        password: _password.text,
        role: _role,
        nidNumber: null,
        address: _address.text.trim(),
      );
      if (!mounted) return;
      final s = AppStrings.current;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${s.members} · ${s.userIdAuto}: ${Formatters.phone(user.phone)}',
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
    final s = AppStrings.current;
    return AppPageScaffold(
      title: s.newMember,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(s.name, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: s.fullName),
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            Text(s.phone, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '01XXXXXXXX'),
              onChanged: _updatePreview,
              validator: Validators.phone,
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
                  '${s.userIdAuto}: ${Formatters.phone(_previewId!)}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(s.address, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _address,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: s.addressHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? s.enterName : null,
            ),
            const SizedBox(height: 16),
            Text(s.role, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              items: [
                DropdownMenuItem(value: UserRole.member, child: Text(s.memberRole)),
                DropdownMenuItem(
                  value: UserRole.collector,
                  child: Text(s.collector),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _role = v);
              },
            ),
            const SizedBox(height: 16),
            Text(s.initialPassword,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _password,
              validator: Validators.password,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.addMember),
            ),
          ],
        ),
      ),
    );
  }
}

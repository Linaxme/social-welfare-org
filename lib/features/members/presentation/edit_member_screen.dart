import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/widgets/app_page_header.dart';

class EditMemberScreen extends StatefulWidget {
  const EditMemberScreen({super.key, required this.memberId});

  final String memberId;

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _nid = TextEditingController();
  final _address = TextEditingController();
  bool _active = true;
  bool _loading = true;
  bool _saving = false;
  var _missing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await UserRepository.instance.getById(widget.memberId);
    if (m == null) {
      setState(() {
        _missing = true;
        _loading = false;
      });
      return;
    }
    _name.text = m.name;
    _phone.text = m.phone;
    _nid.text = m.nidNumber ?? '';
    _address.text = m.address ?? '';
    _active = m.isActive;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _nid.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final s = AppStrings.current;
    final phone = Validators.cleanPhone(_phone.text);
    setState(() => _saving = true);
    try {
      await UserRepository.instance.updateProfile(
        id: widget.memberId,
        name: _name.text,
        phone: phone,
        nidNumber: _nid.text.trim().isEmpty ? null : _nid.text.trim(),
        address: _address.text.trim(),
        status: _active ? 'active' : 'inactive',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.profileUpdated)),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    if (_loading) {
      return AppPageScaffold(
        title: s.profileEdit,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_missing) {
      return AppPageScaffold(
        title: s.profileEdit,
        body: Center(child: Text('${s.memberRole} ${s.recordNotFound}')),
      );
    }

    return AppPageScaffold(
      title: s.profileEdit,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(s.name, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            Text(s.phone, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            Text(s.nidOptional,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nid,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: s.nidHint),
              validator: Validators.nid,
            ),
            const SizedBox(height: 16),
            Text(s.address, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _address,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: s.addressHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? s.enterName : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.activeMember),
              value: _active,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.save),
            ),
            const SizedBox(height: 8),
            Text(
              '${s.userIdAuto}: ${Formatters.phone(Validators.cleanPhone(_phone.text))}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

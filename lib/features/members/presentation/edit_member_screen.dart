import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/firebase/phone_id.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/widgets/app_page_header.dart';

class EditMemberScreen extends StatefulWidget {
  const EditMemberScreen({super.key, required this.memberId});

  final String memberId;

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
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
    final phone = PhoneId.normalize(_phone.text);
    if (_name.text.trim().isEmpty || !PhoneId.isValidBdMobile(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক নাম ও ফোন দিন')),
      );
      return;
    }
    if (_address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ঠিকানা দিন')),
      );
      return;
    }
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
        const SnackBar(content: Text('প্রোফাইল আপডেট হয়েছে')),
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
    if (_loading) {
      return const AppPageScaffold(
        title: 'এডিট',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_missing) {
      return const AppPageScaffold(
        title: 'এডিট',
        body: Center(child: Text('মেম্বার পাওয়া যায়নি')),
      );
    }

    return AppPageScaffold(
      title: 'প্রোফাইল এডিট',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('নাম', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(controller: _name),
          const SizedBox(height: 16),
          Text('ফোন নম্বর', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
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
            decoration: const InputDecoration(
              hintText: 'গ্রাম/এলাকা, থানা, জেলা',
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('সক্রিয় মেম্বার'),
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
                : const Text('সংরক্ষণ'),
          ),
          const SizedBox(height: 8),
          Text(
            'আইডি: ${Formatters.phone(PhoneId.normalize(_phone.text))}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

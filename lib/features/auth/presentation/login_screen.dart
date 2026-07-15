import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/data/app_session.dart';
import '../../../shared/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailController =
      TextEditingController(text: 'linaxme@gmail.com');
  final _nameController = TextEditingController(text: 'সুপার অ্যাডমিন');
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _registerMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_tabController.index == 0) {
        if (_registerMode) {
          final user = await AuthService.instance.registerSuperAdmin(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          );
          await AppSession.instance.setUser(user);
        } else {
          final user = await AuthService.instance.signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
          await AppSession.instance.setUser(user);
        }
      } else {
        final user = await AuthService.instance.signInWithPhoneId(
          phoneOrId: _phoneController.text,
          password: _passwordController.text,
        );
        await AppSession.instance.setUser(user);
      }
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authMessage(e));
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _authMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'ইউজার পাওয়া যায়নি — প্রথমবার হলে অ্যাডমিন রেজিস্টার করুন',
      'wrong-password' || 'invalid-credential' => 'ইমেইল/পাসওয়ার্ড ভুল',
      'email-already-in-use' => 'ইমেইল ইতিমধ্যে ব্যবহৃত',
      'weak-password' => 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে',
      'invalid-email' => 'ইমেইল সঠিক নয়',
      'operation-not-allowed' =>
        'Email/Password Auth চালু করুন Firebase Console → Authentication',
      _ => e.message ?? e.code,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              Color(0xFF0D7A56),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.diversity_3_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'হিলফুল ফুযুল',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'কেশবপুর পশ্চিমপাড়া',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryLight,
                    ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        onTap: (_) => setState(() {
                              _error = null;
                              _registerMode = false;
                            }),
                        tabs: const [
                          Tab(text: 'অ্যাডমিন'),
                          Tab(text: 'মেম্বার / কালেক্টর'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _adminForm(),
                            _memberForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_registerMode) ...[
            Text('নাম', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(controller: _nameController),
            const SizedBox(height: 16),
          ],
          Text('ইমেইল', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Text('পাসওয়ার্ড', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_registerMode ? 'প্রথম অ্যাডমিন তৈরি' : 'লগইন'),
          ),
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() {
                      _registerMode = !_registerMode;
                      _error = null;
                    }),
            child: Text(
              _registerMode
                  ? 'আগে থেকে অ্যাকাউন্ট আছে? লগইন'
                  : 'প্রথমবার? অ্যাডমিন রেজিস্টার',
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ফোন নম্বর / ইউজার আইডি',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '০১৭XXXXXXXX'),
          ),
          const SizedBox(height: 16),
          Text('পাসওয়ার্ড', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('লগইন'),
          ),
          const SizedBox(height: 8),
          Text(
            'অ্যাডমিন মেম্বার যোগ করলে ফোন নম্বরই ইউজার আইডি',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

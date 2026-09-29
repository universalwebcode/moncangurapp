import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'familia@moncangur.ad');
  final _password = TextEditingController(text: 'demo1234');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final state = AppScope.of(context);
    final account = state.login(_email.text, _password.text);
    if (account == null || !mounted) return;
    Navigator.of(context).pushReplacementNamed(routeForRole(account.role));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Align(alignment: Alignment.centerRight, child: LanguageMenu()),
              BrandHeader(title: state.tr('welcome'), subtitle: state.tr('welcomeSub')),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: state.tr('email')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: state.tr('password'),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot'),
                        child: Text(state.tr('forgot')),
                      ),
                    ),
                    if (state.banner != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(state.banner!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                      ),
                    FilledButton(onPressed: _submit, child: Text(state.tr('signIn'))),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text('${state.tr('noAccount')} ${state.tr('createYours')}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.tr('demoAccounts'), style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('familia@moncangur.ad'),
                    const Text('cangur@moncangur.ad'),
                    const Text('admin@moncangur.ad'),
                    const SizedBox(height: 4),
                    const Text('demo1234', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(state.tr('demoNote'), style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final state = AppScope.of(context);
    final error = state.signUp(
      nombre: _name.text,
      email: _email.text,
      password: _password.text,
      confirm: _confirm.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    state.flash(state.tr('accountCreated'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(state.tr('back')),
                ),
              ),
              Center(child: Image.asset('assets/images/signupImage.png', height: 140)),
              const SizedBox(height: 8),
              Text(state.tr('createYours'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30)),
              const SizedBox(height: 14),
              SurfaceCard(
                child: Column(
                  children: [
                    TextField(controller: _name, decoration: InputDecoration(labelText: state.tr('yourName'))),
                    const SizedBox(height: 12),
                    TextField(controller: _email, decoration: InputDecoration(labelText: state.tr('email'))),
                    const SizedBox(height: 12),
                    TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: state.tr('password'))),
                    const SizedBox(height: 12),
                    TextField(controller: _confirm, obscureText: true, decoration: InputDecoration(labelText: state.tr('confirmPassword'))),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                    ],
                    const SizedBox(height: 14),
                    FilledButton(onPressed: _submit, child: Text(state.tr('createAccount'))),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('${state.tr('haveAccount')} ${state.tr('signInHere')}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _email = TextEditingController();
  String? _message;
  bool _ok = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final state = AppScope.of(context);
    final email = _email.text.trim();
    final valid = email.contains('@') && email.contains('.');
    setState(() {
      _ok = valid;
      _message = valid ? state.tr('recoverSent') : state.tr('invalidEmail');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageWidth(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(state.tr('back')),
                ),
              ),
              Text(state.tr('recover'), style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30)),
              const SizedBox(height: 8),
              Text(state.tr('recoverHint'), style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  children: [
                    TextField(controller: _email, decoration: InputDecoration(labelText: state.tr('email'))),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _ok ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    FilledButton(onPressed: _submit, child: Text(state.tr('recover'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

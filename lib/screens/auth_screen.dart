import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';

enum _Step { role, login, register, acces }

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const _EntranceScreen();
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) => const _EntranceScreen(initial: _Step.register);
}

class _EntranceScreen extends StatefulWidget {
  const _EntranceScreen({this.initial = _Step.role});

  final _Step initial;

  @override
  State<_EntranceScreen> createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<_EntranceScreen> {
  late _Step _step = widget.initial;
  bool _busy = false;
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirm = TextEditingController();
  final _cangurEmail = TextEditingController();
  final _cangurPassword = TextEditingController();
  String? _registerError;

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    _registerConfirm.dispose();
    _cangurEmail.dispose();
    _cangurPassword.dispose();
    super.dispose();
  }

  void _go(_Step step) {
    if (_busy) return;
    AppScope.of(context).clearBanner();
    setState(() {
      _registerError = null;
      _step = step;
    });
  }

  Future<void> _signIn(String email, String password) async {
    if (_busy) return;
    setState(() => _busy = true);
    final state = AppScope.of(context);
    final account = await state.login(email, password);
    if (!mounted) return;
    setState(() => _busy = false);
    if (account == null) return;
    Navigator.of(context).pushReplacementNamed(routeForRole(account.role));
  }

  Future<void> _register() async {
    if (_busy) return;
    setState(() => _busy = true);
    final state = AppScope.of(context);
    final error = await state.signUp(
      nombre: '',
      email: _registerEmail.text,
      password: _registerPassword.text,
      confirm: _registerConfirm.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _registerError = error;
      });
      return;
    }
    state.flash(state.tr('accountCreated'));
    setState(() {
      _busy = false;
      _registerError = null;
      _step = _Step.login;
    });
  }

  void _google() {
    final state = AppScope.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.tr('entryGoogleSoon'))));
  }

  void _contact() {
    final state = AppScope.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.tr('contact'))));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _Palette.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Nunito', bodyColor: colors.text, displayColor: colors.ink),
        splashColor: colors.menta15,
        highlightColor: colors.menta15,
      ),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: SizedBox.expand(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (current, previous) {
                      return Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          ...previous,
                          if (current != null) current,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontFamilyFallback: const ['Segoe UI Emoji', 'Apple Color Emoji', 'Noto Color Emoji'],
                          color: colors.text,
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                        child: _step == _Step.role
                            ? _RoleStep(colors: colors, state: state, onParent: () => _go(_Step.login), onCangur: () => _go(_Step.acces))
                            : _step == _Step.login
                            ? _LoginStep(
                                colors: colors,
                                state: state,
                                email: _loginEmail,
                                password: _loginPassword,
                                busy: _busy,
                                onBack: () => _go(_Step.role),
                                onSubmit: () => _signIn(_loginEmail.text, _loginPassword.text),
                                onForgot: () => Navigator.pushNamed(context, '/forgot'),
                                onGoogle: _google,
                                onRegister: () => _go(_Step.register),
                              )
                            : _step == _Step.register
                            ? _RegisterStep(
                                colors: colors,
                                state: state,
                                email: _registerEmail,
                                password: _registerPassword,
                                confirm: _registerConfirm,
                                error: _registerError,
                                busy: _busy,
                                onBack: () => _go(_Step.login),
                                onSubmit: _register,
                                onGoogle: _google,
                                onLogin: () => _go(_Step.login),
                              )
                            : _CangurStep(
                                colors: colors,
                                state: state,
                                email: _cangurEmail,
                                password: _cangurPassword,
                                busy: _busy,
                                onBack: () => _go(_Step.role),
                                onSubmit: () => _signIn(_cangurEmail.text, _cangurPassword.text),
                                onContact: _contact,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleStep extends StatelessWidget {
  const _RoleStep({required this.colors, required this.state, required this.onParent, required this.onCangur});

  final _Palette colors;
  final AppState state;
  final VoidCallback onParent;
  final VoidCallback onCangur;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _LangPills(colors: colors, lang: state.lang, onLang: state.setLang),
          ),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
        _Brand(
          colors: colors,
          mark: _LogoMark(colors: colors),
          title: state.tr('entryWelcome'),
          subtitle: state.tr('entryWelcomeSub'),
        ),
        Expanded(
          child: _CenteredScroll(
            child: Column(
              children: [
                Text(state.tr('entryHow'), textAlign: TextAlign.center, style: _title20(colors)),
                const SizedBox(height: 6),
                Text(
                  state.tr('entryHowSub'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colors.text2),
                ),
                const SizedBox(height: 24),
                _RoleCard(
                  colors: colors,
                  emoji: '👨‍👩‍👧',
                  title: state.tr('entryParent'),
                  subtitle: state.tr('entryParentSub'),
                  onTap: onParent,
                ),
                _RoleCard(
                  colors: colors,
                  emoji: '🦘',
                  title: state.tr('entryCangur'),
                  subtitle: state.tr('entryCangurSub'),
                  onTap: onCangur,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginStep extends StatelessWidget {
  const _LoginStep({
    required this.colors,
    required this.state,
    required this.email,
    required this.password,
    required this.onBack,
    required this.onSubmit,
    required this.onForgot,
    required this.onGoogle,
    required this.onRegister,
    this.busy = false,
  });

  final _Palette colors;
  final AppState state;
  final TextEditingController email;
  final TextEditingController password;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onForgot;
  final VoidCallback onGoogle;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BackBar(
          colors: colors,
          label: state.tr('entryBack'),
          onPressed: onBack,
          trailing: _LangPills(colors: colors, lang: state.lang, onLang: state.setLang),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        _Brand(
          colors: colors,
          mark: _EmojiMark(colors: colors, emoji: '👋'),
          title: state.tr('entryHello'),
          subtitle: state.tr('entryHelloSub'),
        ),
        Expanded(
          child: _CenteredScroll(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Field(colors: colors, label: state.tr('entryEmail'), hint: state.tr('entryEmailHint'), controller: email, keyboard: TextInputType.emailAddress),
                _Field(
                  colors: colors,
                  label: state.tr('password'),
                  hint: state.tr('entryPasswordHint'),
                  controller: password,
                  obscure: true,
                  bottom: 10,
                  onSubmitted: (_) => onSubmit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 16),
                    child: _Link(colors: colors, text: state.tr('forgot'), size: 12.5, weight: FontWeight.w700, onTap: onForgot),
                  ),
                ),
                if (state.banner != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(state.banner!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 13.5)),
                  ),
                ],
                _PrimaryButton(colors: colors, label: state.tr('entryEnter'), busy: busy, onPressed: onSubmit),
                _OrDivider(colors: colors, label: state.tr('entryOr')),
                _GoogleButton(colors: colors, label: state.tr('entryGoogle'), onPressed: onGoogle),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13.5, color: colors.text2, fontFamily: 'Nunito'),
                    children: [
                      TextSpan(text: '${state.tr('noAccount')} '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: _Link(colors: colors, text: state.tr('entryCreateOne'), size: 13.5, weight: FontWeight.w800, onTap: onRegister),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterStep extends StatelessWidget {
  const _RegisterStep({
    required this.colors,
    required this.state,
    required this.email,
    required this.password,
    required this.confirm,
    required this.error,
    required this.onBack,
    required this.onSubmit,
    required this.onGoogle,
    required this.onLogin,
    this.busy = false,
  });

  final _Palette colors;
  final AppState state;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirm;
  final String? error;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BackBar(
          colors: colors,
          label: state.tr('entryBack'),
          onPressed: onBack,
          trailing: _LangPills(colors: colors, lang: state.lang, onLang: state.setLang),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        _Brand(
          colors: colors,
          mark: _EmojiMark(colors: colors, emoji: '✨'),
          title: state.tr('createYours'),
          subtitle: state.tr('entryCreateSub'),
        ),
        Expanded(
          child: _CenteredScroll(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Field(colors: colors, label: state.tr('entryEmail'), hint: state.tr('entryEmailHint'), controller: email, keyboard: TextInputType.emailAddress),
                _Field(colors: colors, label: state.tr('password'), hint: state.tr('entryPasswordMin'), controller: password, obscure: true),
                _Field(
                  colors: colors,
                  label: state.tr('entryRepeat'),
                  hint: state.tr('entryRepeat'),
                  controller: confirm,
                  obscure: true,
                  onSubmitted: (_) => onSubmit(),
                ),
                if (error != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 13.5)),
                  ),
                ],
                _PrimaryButton(colors: colors, label: state.tr('createAccount'), busy: busy, onPressed: onSubmit),
                _OrDivider(colors: colors, label: state.tr('entryOr')),
                _GoogleButton(colors: colors, label: state.tr('entryGoogle'), onPressed: onGoogle),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, height: 1.5, color: colors.text2, fontFamily: 'Nunito'),
                    children: [
                      TextSpan(text: state.tr('entryLegalBefore')),
                      TextSpan(
                        text: state.tr('entryTerms'),
                        style: TextStyle(color: colors.mentaD, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: state.tr('entryLegalMid')),
                      TextSpan(
                        text: state.tr('entryPrivacy'),
                        style: TextStyle(color: colors.mentaD, fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13.5, color: colors.text2, fontFamily: 'Nunito'),
                    children: [
                      TextSpan(text: '${state.tr('haveAccount')} '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: _Link(colors: colors, text: state.tr('entryEnterShort'), size: 13.5, weight: FontWeight.w800, onTap: onLogin),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CangurStep extends StatelessWidget {
  const _CangurStep({
    required this.colors,
    required this.state,
    required this.email,
    required this.password,
    required this.onBack,
    required this.onSubmit,
    required this.onContact,
    this.busy = false,
  });

  final _Palette colors;
  final AppState state;
  final TextEditingController email;
  final TextEditingController password;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BackBar(
          colors: colors,
          label: state.tr('entryBack'),
          onPressed: onBack,
          trailing: _LangPills(colors: colors, lang: state.lang, onLang: state.setLang),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        _Brand(
          colors: colors,
          mark: _LogoMark(colors: colors),
          title: state.tr('entryCangurTitle'),
          subtitle: state.tr('entryCangurArea'),
        ),
        Expanded(
          child: _CenteredScroll(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 20, height: 1.2)),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 13.5, height: 1.5, color: colors.text, fontFamily: 'Nunito'),
                            children: [
                              TextSpan(
                                text: state.tr('entryStaffOnly'),
                                style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink),
                              ),
                              TextSpan(text: ' ${state.tr('entryStaffNote')}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _Field(
                  colors: colors,
                  label: state.tr('entryEmail'),
                  hint: state.tr('entryCangurEmailHint'),
                  controller: email,
                  keyboard: TextInputType.emailAddress,
                ),
                _Field(
                  colors: colors,
                  label: state.tr('password'),
                  hint: state.tr('entryPasswordHint'),
                  controller: password,
                  obscure: true,
                  onSubmitted: (_) => onSubmit(),
                ),
                if (state.banner != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(state.banner!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 13.5)),
                  ),
                ],
                _PrimaryButton(colors: colors, label: state.tr('entryEnter'), busy: busy, onPressed: onSubmit),
                const SizedBox(height: 18),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13.5, color: colors.text2, fontFamily: 'Nunito'),
                    children: [
                      TextSpan(text: '${state.tr('entryNoAccess')} '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: _Link(colors: colors, text: state.tr('entryContactLink'), size: 13.5, weight: FontWeight.w700, onTap: onContact),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CenteredScroll extends StatelessWidget {
  const _CenteredScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 22), child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({required this.colors, required this.label, required this.onPressed, this.trailing});

  final _Palette colors;
  final String label;
  final VoidCallback onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: label,
            child: Material(
              color: colors.menta15,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(child: _Chevron(color: colors.ink, left: true)),
                ),
              ),
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class _LangPills extends StatelessWidget {
  const _LangPills({required this.colors, required this.lang, required this.onLang});

  final _Palette colors;
  final AppLang lang;
  final ValueChanged<AppLang> onLang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in AppLang.values)
            GestureDetector(
              onTap: () => onLang(value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: lang == value ? colors.menta : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  value.name.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: lang == value ? colors.mentaD : colors.text2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.colors, required this.mark, required this.title, required this.subtitle});

  final _Palette colors;
  final Widget mark;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        mark,
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 25, height: 1.15, color: colors.ink),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, height: 1.5, color: colors.text2),
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.colors});

  final _Palette colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(color: colors.menta, borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset('assets/images/entrada_mark.jpg', fit: BoxFit.cover, semanticLabel: 'Mon Cangur'),
    );
  }
}

class _EmojiMark extends StatelessWidget {
  const _EmojiMark({required this.colors, required this.emoji});

  final _Palette colors;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.menta, borderRadius: BorderRadius.circular(22)),
      child: Text(emoji, style: const TextStyle(fontSize: 36, height: 1)),
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({required this.colors, required this.emoji, required this.title, required this.subtitle, required this.onTap});

  final _Palette colors;
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _hover ? colors.menta : colors.line, width: 1.5),
            boxShadow: [BoxShadow(color: colors.shadow, blurRadius: colors.shadowBlur, offset: const Offset(0, 4))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(17)),
                      child: Text(widget.emoji, style: const TextStyle(fontSize: 28, height: 1)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink, height: 1.2)),
                          const SizedBox(height: 3),
                          Text(widget.subtitle, style: TextStyle(fontSize: 13.5, height: 1.4, color: colors.text2)),
                        ],
                      ),
                    ),
                    _Chevron(color: colors.mentaD),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.colors,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboard,
    this.bottom = 14,
    this.onSubmitted,
  });

  final _Palette colors;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboard;
  final double bottom;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: 1.5),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 7),
            child: Text(widget.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: colors.ink)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              boxShadow: _focus.hasFocus ? [BoxShadow(color: colors.menta15, spreadRadius: 4)] : const [],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              obscureText: widget.obscure,
              keyboardType: widget.keyboard,
              textInputAction: widget.onSubmitted == null ? TextInputAction.next : TextInputAction.done,
              onSubmitted: widget.onSubmitted,
              autocorrect: !widget.obscure && widget.keyboard != TextInputType.emailAddress,
              enableSuggestions: !widget.obscure,
              style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, fontWeight: FontWeight.w500, color: colors.ink),
              cursorColor: colors.mentaD,
              decoration: InputDecoration(
                hintText: widget.hint,
                isDense: true,
                filled: true,
                fillColor: colors.card,
                hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, fontWeight: FontWeight.w500, color: colors.text2.withValues(alpha: 0.7)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                border: border(colors.line),
                enabledBorder: border(colors.line),
                focusedBorder: border(colors.menta),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.colors, required this.label, required this.onPressed, this.busy = false});

  final _Palette colors;
  final String label;
  final VoidCallback onPressed;
  final bool busy;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _hover ? colors.brun : colors.mentaD,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Color(0x668CA598), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.busy ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.busy
                  ? const SizedBox(
                      height: 20,
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
                    )
                  : Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatefulWidget {
  const _GoogleButton({required this.colors, required this.label, required this.onPressed});

  final _Palette colors;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _hover ? colors.brun : colors.line, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomPaint(size: Size(19, 19), painter: _GoogleLogoPainter()),
                  const SizedBox(width: 11),
                  Text(
                    widget.label,
                    style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.colors, required this.label});

  final _Palette colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: colors.line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.text2)),
          ),
          Expanded(child: Container(height: 1, color: colors.line)),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.colors, required this.text, required this.size, required this.weight, required this.onTap});

  final _Palette colors;
  final String text;
  final double size;
  final FontWeight weight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(fontFamily: 'Nunito', color: colors.mentaD, fontWeight: weight, fontSize: size, height: 1.2),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color, this.left = false});

  final Color color;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(22, 22), painter: _ChevronPainter(color, left));
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color, this.left);

  final Color color;
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    if (left) {
      path.moveTo(size.width * 15 / 24, size.height * 18 / 24);
      path.lineTo(size.width * 9 / 24, size.height * 12 / 24);
      path.lineTo(size.width * 15 / 24, size.height * 6 / 24);
    } else {
      path.moveTo(size.width * 9 / 24, size.height * 18 / 24);
      path.lineTo(size.width * 15 / 24, size.height * 12 / 24);
      path.lineTo(size.width * 9 / 24, size.height * 6 / 24);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) => oldDelegate.color != color || oldDelegate.left != left;
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    Paint arc(Color color) {
      return Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
    }

    canvas.drawArc(rect, -math.pi * 0.15, math.pi * 0.72, false, arc(const Color(0xFF4285F4)));
    canvas.drawArc(rect, math.pi * 0.57, math.pi * 0.48, false, arc(const Color(0xFF34A853)));
    canvas.drawArc(rect, math.pi * 1.05, math.pi * 0.48, false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, math.pi * 1.53, math.pi * 0.55, false, arc(const Color(0xFFEA4335)));
    final bar = arc(const Color(0xFF4285F4))..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.5), Offset(size.width * 0.9, size.height * 0.5), bar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Palette {
  const _Palette({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.menta15,
    required this.brun,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
    required this.shadow,
    required this.shadowBlur,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color mentaD;
  final Color menta15;
  final Color brun;
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color shadow;
  final double shadowBlur;

  static const light = _Palette(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF4F4A45),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    shadow: Color(0x0F000000),
    shadowBlur: 16,
  );

  static const dark = _Palette(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFCFC9C0),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    shadow: Color(0x66000000),
    shadowBlur: 18,
  );

  static _Palette of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

TextStyle _title20(_Palette colors) {
  return TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: colors.ink, height: 1.2);
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

  Future<void> _submit() async {
    final state = AppScope.of(context);
    final error = await state.resetPassword(_email.text);
    if (!mounted) return;
    setState(() {
      _ok = error == null;
      _message = error ?? state.tr('recoverSent');
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

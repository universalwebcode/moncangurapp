import 'package:flutter/material.dart';

import '../l10n/legal_docs.dart';
import '../l10n/menu_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'family_profile_screen.dart';
import 'legal_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({required this.onOpenServices, required this.onOpenBookings, super.key});

  final VoidCallback onOpenServices;
  final VoidCallback onOpenBookings;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _MenuColors.of(context);
    final user = state.user;
    final name = user?.nombre.trim() ?? '';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : (email.isNotEmpty ? email[0].toUpperCase() : 'M');
    return ColoredBox(
      color: colors.bg,
      child: Column(
        children: [
          _TopBar(colors: colors, title: mn(lang, 'title'), onBack: onOpenServices, lang: lang, onLang: state.setLang),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    _UserCard(colors: colors, initial: initial, name: name, email: email, onTap: () => _openProfile(context)),
                    const SizedBox(height: 26),
                    _Group(
                      colors: colors,
                      title: mn(lang, 'account'),
                      rows: [
                        _RowData(Icons.person_outline, mn(lang, 'profile'), onTap: () => _openProfile(context)),
                        _RowData(Icons.people_outline, mn(lang, 'kids'), onTap: () => _openProfile(context, scrollToKids: true)),
                      ],
                    ),
                    _Group(
                      colors: colors,
                      title: mn(lang, 'bookings'),
                      rows: [
                        _RowData(Icons.calendar_today_outlined, mn(lang, 'myBookings'), onTap: onOpenBookings),
                        _RowData(Icons.schedule, mn(lang, 'history'), soon: mn(lang, 'soon')),
                      ],
                    ),
                    _Group(
                      colors: colors,
                      title: mn(lang, 'comms'),
                      rows: [
                        _RowData(Icons.chat_bubble_outline, mn(lang, 'chat'), soon: mn(lang, 'soon')),
                        _RowData(Icons.help_outline, mn(lang, 'help'), soon: mn(lang, 'soon')),
                      ],
                    ),
                    _Group(
                      colors: colors,
                      title: mn(lang, 'services'),
                      rows: [
                        _RowData(Icons.grid_view_rounded, mn(lang, 'ourServices'), onTap: onOpenServices),
                      ],
                    ),
                    _Group(
                      colors: colors,
                      title: mn(lang, 'legal'),
                      rows: [
                        _RowData(Icons.description_outlined, mn(lang, 'terms'), onTap: () => _openLegal(context, LegalSection.terms)),
                        _RowData(Icons.shield_outlined, mn(lang, 'privacy'), onTap: () => _openLegal(context, LegalSection.privacy)),
                        _RowData(Icons.autorenew, mn(lang, 'cancel'), onTap: () => _openLegal(context, LegalSection.cancel)),
                      ],
                    ),
                    _LogoutButton(
                      colors: colors,
                      label: state.tr('signOut'),
                      onTap: () {
                        state.signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Mon Cangur · v1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context, {bool scrollToKids = false}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FamilyProfileScreen(scrollToKids: scrollToKids)));
  }

  void _openLegal(BuildContext context, LegalSection section) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LegalScreen(section: section)));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.colors, required this.title, required this.onBack, this.lang, this.onLang});

  final _MenuColors colors;
  final String title;
  final VoidCallback onBack;
  final AppLang? lang;
  final ValueChanged<AppLang>? onLang;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.bg, border: Border(bottom: BorderSide(color: colors.line))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(
          children: [
            Material(
              color: colors.menta15,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink)),
            ),
            if (lang != null && onLang != null) _LangPills(colors: colors, lang: lang!, onLang: onLang!),
          ],
        ),
      ),
    );
  }
}

class _LangPills extends StatelessWidget {
  const _LangPills({required this.colors, required this.lang, required this.onLang});

  final _MenuColors colors;
  final AppLang lang;
  final ValueChanged<AppLang> onLang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.line)),
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
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: lang == value ? colors.mentaD : colors.text2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.colors, required this.initial, required this.name, required this.email, required this.onTap});

  final _MenuColors colors;
  final String initial;
  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.line, width: 1.5),
            boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.menta, borderRadius: BorderRadius.circular(16)),
                child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF2C3A33))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.mentaD),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowData {
  const _RowData(this.icon, this.label, {this.onTap, this.soon});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? soon;
}

class _Group extends StatelessWidget {
  const _Group({required this.colors, required this.title, required this.rows});

  final _MenuColors colors;
  final String title;
  final List<_RowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 1.6, color: colors.mentaD),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.line, width: 1.5),
            boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, thickness: 1, color: colors.line),
                _MenuRow(colors: colors, data: rows[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.colors, required this.data});

  final _MenuColors colors;
  final _RowData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(11)),
                child: Icon(data.icon, size: 20, color: colors.brun),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(data.label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 15, color: colors.ink)),
              ),
              if (data.soon != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    data.soon!.toUpperCase(),
                    style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.3, color: colors.brun),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(Icons.chevron_right, size: 18, color: colors.text2),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.colors, required this.label, required this.onTap});

  final _MenuColors colors;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFC0705F);
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: red,
        side: BorderSide(color: colors.line, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15),
      ),
      icon: const Icon(Icons.logout, size: 19),
      label: Text(label),
    );
  }
}

class _MenuColors {
  const _MenuColors({
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

  static const light = _MenuColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x0F000000),
    shadow: Color(0x0D000000),
  );

  static const dark = _MenuColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x17FFFFFF),
    shadow: Color(0x66000000),
  );

  static _MenuColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

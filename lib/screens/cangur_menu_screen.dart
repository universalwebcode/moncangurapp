import 'package:flutter/material.dart';

import '../l10n/cangur_copy.dart';
import '../l10n/menu_copy.dart';
import '../widgets/mc_widgets.dart';
import 'cangur_chat_screen.dart';

class CangurMenuScreen extends StatelessWidget {
  const CangurMenuScreen({required this.onOpenProfile, required this.onOpenBookings, required this.onOpenAvailability, super.key});

  final VoidCallback onOpenProfile;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenAvailability;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _MenuColors.of(context);
    final user = state.user;
    final name = user?.nombre.trim() ?? '';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : (email.isNotEmpty ? email[0].toUpperCase() : 'C');
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Material(
                          color: colors.menta15,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(child: Text(cg(lang, 'menu'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                          decoration: BoxDecoration(color: colors.brun, borderRadius: BorderRadius.circular(999)),
                          child: Text(cg(lang, 'rolePill').toUpperCase(), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.4, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      Material(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: onOpenProfile,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.line, width: 1.5)),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: const Color(0xFF6E82A6), borderRadius: BorderRadius.circular(16)),
                                  child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white)),
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
                                Icon(Icons.chevron_right, color: colors.menta),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _group(colors, mn(lang, 'account'), [
                        _Row(Icons.person_outline, mn(lang, 'profile'), onTap: onOpenProfile),
                      ]),
                      _group(colors, cg(lang, 'myWork'), [
                        _Row(Icons.calendar_today_outlined, mn(lang, 'myBookings'), onTap: onOpenBookings),
                        _Row(Icons.schedule, cg(lang, 'myAvailability'), onTap: onOpenAvailability),
                      ]),
                      _group(colors, mn(lang, 'comms'), [
                        _Row(Icons.chat_bubble_outline, cg(lang, 'chatParents'), onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CangurChatScreen()));
                        }),
                        _Row(Icons.help_outline, cg(lang, 'support'), onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CangurChatScreen(openTeam: true)));
                        }),
                      ]),
                      OutlinedButton.icon(
                        onPressed: () {
                          state.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                        },
                        icon: const Icon(Icons.logout, size: 19),
                        label: Text(state.tr('signOut'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC0705F),
                          side: BorderSide(color: colors.line, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(cg(lang, 'appVersion'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _group(_MenuColors colors, String title, List<_Row> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
          child: Text(title.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.8, color: colors.menta)),
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
                if (i > 0) Divider(height: 1, color: colors.line),
                rows[i].build(colors),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row {
  const _Row(this.icon, this.label, {this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  Widget build(_MenuColors colors) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 20, color: colors.brun),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 15, color: colors.ink))),
            Icon(Icons.chevron_right, size: 18, color: colors.text2),
          ],
        ),
      ),
    );
  }
}

class _MenuColors {
  const _MenuColors({
    required this.bg,
    required this.card,
    required this.menta,
    required this.menta15,
    required this.ink,
    required this.text2,
    required this.line,
    required this.brun,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color menta15;
  final Color ink;
  final Color text2;
  final Color line;
  final Color brun;
  final Color shadow;

  static const light = _MenuColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    text2: Color(0xFF6B6560),
    line: Color(0x0F000000),
    brun: Color(0xFFA98E7B),
    shadow: Color(0x0D000000),
  );

  static const dark = _MenuColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    text2: Color(0xFFA49D93),
    line: Color(0x17FFFFFF),
    brun: Color(0xFFA98E7B),
    shadow: Color(0x66000000),
  );

  static _MenuColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

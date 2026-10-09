import 'package:flutter/material.dart';

import '../l10n/bookings_copy.dart';
import '../l10n/cangur_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'booking_detail_screen.dart';
import 'cangur_bookings_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = AppScope.of(context);
      state.refreshCanguros();
      state.refreshBookings();
      state.refreshReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _Look.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = [
      for (final booking in state.bookings)
        if (!DateTime(booking.fecha.year, booking.fecha.month, booking.fecha.day).isBefore(today)) booking,
    ]..sort((a, b) {
        final byDay = a.fecha.compareTo(b.fecha);
        return byDay != 0 ? byDay : a.horaInicio.compareTo(b.horaInicio);
      });
    final shown = upcoming.take(5).toList();
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            _home(state, colors, lang, shown),
            const CangurBookingsScreen(embedded: true, showChat: true),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colors.card,
          indicatorColor: colors.menta,
          labelTextStyle: WidgetStateProperty.all(TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.ink)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          backgroundColor: colors.card,
          indicatorColor: colors.menta,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            NavigationDestination(icon: Icon(Icons.home_outlined, color: colors.mentaD), label: cg(lang, 'home')),
            NavigationDestination(icon: Icon(Icons.event_note_outlined, color: colors.mentaD), label: state.tr('bookings')),
          ],
        ),
      ),
    );
  }

  Widget _home(dynamic state, _Look colors, AppLang lang, List<Booking> shown) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _LangPills(colors: colors, lang: lang, onLang: state.setLang),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.tr('manage'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, height: 1.1, color: colors.ink)),
                      const SizedBox(height: 4),
                      Text(state.tr('manageHint'), style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.4, color: colors.text2)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: colors.menta15,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _AdminMenu())),
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(width: 44, height: 44, child: Icon(Icons.menu, color: colors.ink)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _Stat(colors: colors, value: '${state.canguros.length}', label: state.tr('totalCanguros'))),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(colors: colors, value: '${state.bookings.length}', label: state.tr('totalBookings'))),
                  ],
                ),
                const SizedBox(height: 26),
                Text(cg(lang, 'properes'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink)),
                const SizedBox(height: 11),
                if (shown.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.line, width: 1.5)),
                    child: Column(
                      children: [
                        const Text('🗓️', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 10),
                        Text(bk(lang, 'noUpcoming'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2)),
                      ],
                    ),
                  )
                else
                  for (final booking in shown) ...[
                    _Card(colors: colors, booking: booking),
                    const SizedBox(height: 14),
                  ],
          ],
        ),
      ),
    );
  }

}

class _AdminMenu extends StatelessWidget {
  const _AdminMenu();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _Look.of(context);
    final user = state.user;
    final name = (user?.nombre ?? '').trim();
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : (email.isNotEmpty ? email[0].toUpperCase() : 'A');
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
                        Expanded(child: Text(state.tr('menu'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                          decoration: BoxDecoration(color: colors.brun, borderRadius: BorderRadius.circular(999)),
                          child: const Text('ADMIN', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.4, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.line, width: 1.5),
                        ),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
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
}

class _Stat extends StatelessWidget {
  const _Stat({required this.colors, required this.value, required this.label});

  final _Look colors;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 32, height: 1, color: colors.ink)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13, color: colors.text2)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.colors, required this.booking});

  final _Look colors;
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final family = booking.padreNombre.trim().isEmpty ? '—' : booking.padreNombre.trim();
    final pill = booking.estadoPago == 'fallido'
        ? _Pill(state.tr('failed'), _Kind.wait)
        : booking.estado == 'confirmada'
            ? _Pill(state.tr('confirmed'), _Kind.ok)
            : _Pill(state.tr('pending'), _Kind.wait);
    final carer = _carer(state, booking);
    final price = booking.total == null ? '—' : '${booking.total!.toStringAsFixed(2).replaceAll('.', ',')} €';
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking))),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.line, width: 1.5),
            boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(13)),
                    child: Text(bookingEmoji(booking.tipoServicio), style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookingServiceTitle(lang, booking.tipoServicio), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, height: 1.1, color: colors.ink)),
                        const SizedBox(height: 2),
                        Text(family, style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: pill.background, borderRadius: BorderRadius.circular(999)),
                    child: Text(pill.label.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.3, color: pill.foreground)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _fact(colors, bk(lang, 'date'), bookingDate(lang, booking.fecha))),
                  const SizedBox(width: 14),
                  Expanded(child: _fact(colors, bk(lang, 'schedule'), _schedule(booking))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _fact(
                      colors,
                      bk(lang, 'cangur'),
                      '',
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Color(_carerColor(state, booking)), borderRadius: BorderRadius.circular(7)),
                            child: Text(carer.isEmpty ? '?' : carer[0].toUpperCase(), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(carer, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14.5, color: colors.ink))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _fact(colors, bk(lang, 'price'), price, pay: true)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangPills extends StatelessWidget {
  const _LangPills({required this.colors, required this.lang, required this.onLang});

  final _Look colors;
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

class _Pill {
  const _Pill(this.label, this.kind);
  final String label;
  final _Kind kind;

  Color get background {
    switch (kind) {
      case _Kind.ok:
        return const Color(0x296F9E86);
      case _Kind.wait:
        return const Color(0x29C08457);
    }
  }

  Color get foreground {
    switch (kind) {
      case _Kind.ok:
        return const Color(0xFF6F9E86);
      case _Kind.wait:
        return const Color(0xFFC08457);
    }
  }
}

enum _Kind { ok, wait }

Widget _fact(_Look colors, String label, String value, {bool pay = false, Widget? child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, letterSpacing: 0.4, color: colors.text2)),
      const SizedBox(height: 2),
      child ?? Text(value, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14.5, color: pay ? colors.mentaD : colors.ink)),
    ],
  );
}

String _carer(dynamic state, Booking booking) {
  final stored = booking.canguroNombre?.trim() ?? '';
  if (stored.isNotEmpty) return stored;
  final profile = state.profileFor(booking.canguroId ?? '');
  final name = profile?.nombre as String? ?? '';
  if (name.trim().isNotEmpty) return name.trim();
  return bk(state.lang as AppLang, 'unassigned');
}

int _carerColor(dynamic state, Booking booking) {
  final profile = state.profileFor(booking.canguroId ?? '');
  final color = profile?.color;
  if (color is int && (booking.canguroId ?? '').isNotEmpty) return color;
  const palette = [0xFF6E82A6, 0xFF8CA598, 0xFFA98E7B, 0xFF9487B3, 0xFFC08457];
  final name = booking.canguroNombre ?? booking.canguroId ?? '';
  if (name.isEmpty) return palette[1];
  return palette[name.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % palette.length];
}

String _schedule(Booking booking) {
  if (booking.horaInicio.isEmpty) return '—';
  final start = _minutes(booking.horaInicio);
  final end = _minutes(booking.horaFin);
  final range = booking.horaFin.isEmpty ? booking.horaInicio : '${booking.horaInicio} – ${booking.horaFin}';
  if (start == null || end == null || end <= start) return range;
  final minutes = end - start;
  final whole = minutes / 60;
  final hours = minutes % 60 == 0 ? '${whole.toInt()}' : whole.toStringAsFixed(1);
  return '$range · $hours h';
}

int? _minutes(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}

class _Look {
  const _Look({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.menta15,
    required this.ink,
    required this.brun,
    required this.text2,
    required this.line,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color mentaD;
  final Color menta15;
  final Color ink;
  final Color brun;
  final Color text2;
  final Color line;
  final Color shadow;

  static const light = _Look(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    brun: Color(0xFFA98E7B),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    shadow: Color(0x0D000000),
  );

  static const dark = _Look(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    brun: Color(0xFFA98E7B),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    shadow: Color(0x66000000),
  );

  static _Look of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

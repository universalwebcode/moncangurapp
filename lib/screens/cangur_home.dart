import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/availability.dart';
import '../l10n/bookings_copy.dart';
import '../l10n/cangur_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'booking_detail_screen.dart';

const _shortDays = [
  ['Dl', 'Dt', 'Dc', 'Dj', 'Dv', 'Ds', 'Dg'],
  ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do'],
  ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
  ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'],
];

const _shortMonths = [
  ['gen', 'febr', 'març', 'abr', 'maig', 'juny', 'jul', 'ag', 'set', 'oct', 'nov', 'des'],
  ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  ['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'],
];

class CangurHomeTab extends StatefulWidget {
  const CangurHomeTab({required this.onOpenBookings, required this.onOpenAvailability, required this.onOpenMenu, super.key});

  final VoidCallback onOpenBookings;
  final VoidCallback onOpenAvailability;
  final VoidCallback onOpenMenu;

  @override
  State<CangurHomeTab> createState() => _CangurHomeTabState();
}

class _CangurHomeTabState extends State<CangurHomeTab> {
  final Map<String, bool> _resolved = {};
  String? _toast;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _respond(Booking booking, bool accept) async {
    final state = AppScope.of(context);
    final error = await state.respondToBooking(booking, accept: accept);
    if (!mounted) return;
    if (error != null) {
      state.flash(state.tr(error));
      return;
    }
    setState(() {
      _resolved[booking.id] = accept;
      _toast = cg(state.lang, accept ? 'acceptedToast' : 'declinedToast');
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _HomeColors.of(context);
    final mine = state.bookingsForCurrent();
    final requests = [
      for (final booking in mine)
        if (booking.estado == 'pendiente' || _resolved.containsKey(booking.id)) booking,
    ]..sort((a, b) => a.fecha.compareTo(b.fecha));
    final pendingCount = requests.where((booking) => booking.estado == 'pendiente' && !_resolved.containsKey(booking.id)).length;
    final next = _nextBooking(mine);
    final name = _firstName(state.user?.nombre ?? '');
    return Stack(
      children: [
        Align(
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
                          Text(cg(lang, 'hello', {'name': name}), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, height: 1.1, color: colors.ink)),
                          const SizedBox(height: 3),
                          Text(cg(lang, pendingCount > 0 ? 'helloWork' : 'helloClear'), style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                        ],
                      ),
                    ),
                    Material(
                      color: colors.menta15,
                      borderRadius: BorderRadius.circular(13),
                      child: InkWell(
                        onTap: widget.onOpenMenu,
                        borderRadius: BorderRadius.circular(13),
                        child: SizedBox(width: 44, height: 44, child: Icon(Icons.menu, color: colors.ink)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _heading(colors, cg(lang, 'requests'), badge: pendingCount),
                if (requests.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.line, width: 1.5)),
                    child: Text(cg(lang, 'noRequests'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: colors.text2)),
                  )
                else
                  for (final booking in requests) _requestCard(colors, lang, booking),
                const SizedBox(height: 14),
                _heading(colors, cg(lang, 'nextBooking'), trailing: cg(lang, 'seeAll'), onTrailing: widget.onOpenBookings),
                if (next == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.line, width: 1.5)),
                    child: Text(cg(lang, 'noNext'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: colors.text2)),
                  )
                else
                  _nextCard(colors, lang, next),
                const SizedBox(height: 26),
                _heading(colors, cg(lang, 'weekTitle')),
                _weekCard(colors, lang, state.profileFor(state.user?.id ?? '')),
              ],
            ),
          ),
        ),
        if (_toast != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(999)),
                child: Text(_toast!, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: colors.bg)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _requestCard(_HomeColors colors, AppLang lang, Booking booking) {
    final resolved = _resolved[booking.id];
    final border = resolved == null ? colors.brun : (resolved ? colors.ok : colors.line);
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: border, width: 4))),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(12)),
                    child: Text(bookingEmoji(booking.tipoServicio), style: const TextStyle(fontSize: 21)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookingServiceTitle(lang, booking.tipoServicio), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15.5, height: 1.1, color: colors.ink)),
                        const SizedBox(height: 2),
                        Text(booking.padreNombre, style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2)),
                      ],
                    ),
                  ),
                  if (resolved == null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0x26C0705F), borderRadius: BorderRadius.circular(999)),
                      child: Text(cg(lang, 'newRequest').toUpperCase(), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 10.5, letterSpacing: 0.3, color: Color(0xFFC0705F))),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _fact(colors, cg(lang, 'when'), _when(lang, booking))),
                  Expanded(child: _fact(colors, cg(lang, 'area'), _area(booking))),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(child: _fact(colors, cg(lang, 'children'), _kids(lang, booking.numeroNinos))),
                  Expanded(child: _fact(colors, cg(lang, 'yourPay'), booking.total == null ? '—' : _euro(booking.total!), pay: true)),
                ],
              ),
              const SizedBox(height: 14),
              if (resolved == null)
                Row(
                  children: [
                    Expanded(child: _action(cg(lang, 'deny'), colors.text2, colors.line, () => _respond(booking, false))),
                    const SizedBox(width: 10),
                    Expanded(child: _action(cg(lang, 'accept'), Colors.white, colors.mentaD, () => _respond(booking, true), fill: colors.mentaD)),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(resolved ? Icons.check : Icons.close, size: 18, color: resolved ? colors.ok : colors.text2),
                    const SizedBox(width: 8),
                    Expanded(child: Text(cg(lang, resolved ? 'accepted' : 'declined'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: resolved ? colors.ok : colors.text2))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextCard(_HomeColors colors, AppLang lang, Booking booking) {
    final family = booking.padreNombre.trim().isEmpty ? '—' : booking.padreNombre.trim();
    final initial = family[0].toUpperCase();
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking))),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.line, width: 1.5)),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFF6E82A6), borderRadius: BorderRadius.circular(13)),
                child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: Colors.white)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$family · ${bookingServiceTitle(lang, booking.tipoServicio)}', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15.5, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text('${_compact(lang, booking.fecha)} · ${_range(booking)} · ${_area(booking)}', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.text2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekCard(_HomeColors colors, AppLang lang, CangurProfile? profile) {
    final today = DateUtils.dateOnly(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(child: _dayCell(colors, lang, monday.add(Duration(days: i)), profile)),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 13,
            runSpacing: 6,
            children: [
              _legend(colors, const Color(0xFFE0A93B), cg(lang, 'morning')),
              _legend(colors, const Color(0xFFC0845F), cg(lang, 'afternoon')),
              _legend(colors, const Color(0xFF6D78B5), cg(lang, 'night')),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: colors.menta15,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: widget.onOpenAvailability,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 17, color: colors.brun),
                      const SizedBox(width: 8),
                      Text(cg(lang, 'editWeek'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(_HomeColors colors, AppLang lang, DateTime day, CangurProfile? profile) {
    final marks = _periods(_availability(profile, day));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Text(_shortDays[lang.index][day.weekday - 1], style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: colors.text2)),
          const SizedBox(height: 5),
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(11)),
              child: Center(
                child: marks.isEmpty
                    ? Text('·', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, color: colors.ink))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final mark in marks) ...[
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: _periodColor(mark), shape: BoxShape.circle)),
                            const SizedBox(width: 2),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(_HomeColors colors, String title, {int? badge, String? trailing, VoidCallback? onTrailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Flexible(child: Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink))),
          if (badge != null && badge > 0) ...[
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFC0705F), borderRadius: BorderRadius.all(Radius.circular(999))),
              child: Text('$badge', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
            ),
          ],
          const Spacer(),
          if (trailing != null)
            InkWell(
              onTap: onTrailing,
              child: Text(trailing, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.mentaD)),
            ),
        ],
      ),
    );
  }

  Widget _fact(_HomeColors colors, String label, String value, {bool pay = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.3, color: colors.text2)),
        const SizedBox(height: 1),
        Text(value, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: pay ? colors.mentaD : colors.ink)),
      ],
    );
  }

  Widget _action(String label, Color foreground, Color border, VoidCallback tap, {Color? fill}) {
    return Material(
      color: fill ?? Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 1.5)),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: foreground)),
        ),
      ),
    );
  }

  Widget _legend(_HomeColors colors, Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, color: colors.text2)),
      ],
    );
  }
}

Booking? _nextBooking(List<Booking> items) {
  final today = DateUtils.dateOnly(DateTime.now());
  final upcoming = [
    for (final booking in items)
      if (booking.estado == 'confirmada' && !DateUtils.dateOnly(booking.fecha).isBefore(today)) booking,
  ]..sort((a, b) {
      final byDay = a.fecha.compareTo(b.fecha);
      if (byDay != 0) return byDay;
      return a.horaInicio.compareTo(b.horaInicio);
    });
  return upcoming.isEmpty ? null : upcoming.first;
}

DayAvailability? _availability(CangurProfile? profile, DateTime day) {
  if (profile == null) return null;
  final iso = isoDate(day);
  for (final exception in profile.exceptions) {
    if (exception.fecha == iso) return DayAvailability(disponible: exception.disponible, franjas: exception.franjas);
  }
  return profile.week[dayKey(day)];
}

List<String> _periods(DayAvailability? day) {
  if (day == null || !day.disponible) return const [];
  final marks = <String>[];
  var morning = false;
  var afternoon = false;
  var night = false;
  for (final band in day.franjas) {
    if (band.torn == 'mati') {
      morning = true;
      continue;
    }
    if (band.torn == 'tarda') {
      afternoon = true;
      continue;
    }
    if (band.torn == 'nit') {
      night = true;
      continue;
    }
    final start = _minutes(band.inicio);
    final end = _minutes(band.fin);
    if (start == null || end == null) continue;
    if (end <= start) {
      night = true;
      continue;
    }
    if (start < 14 * 60 && end > 8 * 60) morning = true;
    if (start < 20 * 60 && end > 14 * 60) afternoon = true;
    if (end > 20 * 60) night = true;
  }
  if (morning) marks.add('mati');
  if (afternoon) marks.add('tarda');
  if (night) marks.add('nit');
  return marks;
}

Color _periodColor(String mark) {
  switch (mark) {
    case 'tarda':
      return const Color(0xFFC0845F);
    case 'nit':
      return const Color(0xFF6D78B5);
    default:
      return const Color(0xFFE0A93B);
  }
}

String _when(AppLang lang, Booking booking) {
  final today = DateUtils.dateOnly(DateTime.now());
  final day = DateUtils.dateOnly(booking.fecha) == today ? cg(lang, 'today') : _compact(lang, booking.fecha);
  final hours = _hours(booking);
  final range = _range(booking);
  return hours.isEmpty ? '$day · $range' : '$day · $range · $hours';
}

String _compact(AppLang lang, DateTime date) {
  final weekday = _shortDays[lang.index][date.weekday - 1].toLowerCase();
  final month = _shortMonths[lang.index][date.month - 1];
  return '$weekday ${date.day} $month';
}

String _range(Booking booking) {
  if (booking.horaInicio.isEmpty) return '—';
  if (booking.horaFin.isEmpty) return booking.horaInicio;
  return '${booking.horaInicio}–${booking.horaFin}';
}

String _hours(Booking booking) {
  final start = _minutes(booking.horaInicio);
  final end = _minutes(booking.horaFin);
  if (start == null || end == null || end <= start) return '';
  final minutes = end - start;
  final whole = minutes / 60;
  final label = minutes % 60 == 0 ? '${whole.toInt()}' : whole.toStringAsFixed(1);
  return '$label h';
}

String _kids(AppLang lang, int count) {
  if (count == 1) return bk(lang, 'oneChild');
  return bk(lang, 'manyChildren').replaceAll('{n}', '$count');
}

String _area(Booking booking) {
  final address = booking.direccionServicio.trim();
  if (address.isEmpty) return '—';
  final parts = address.split(',');
  return parts.last.trim();
}

String _euro(double value) => '${value.toStringAsFixed(2).replaceAll('.', ',')} €';

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.split(RegExp(r'\s+')).first;
}

int? _minutes(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}

class _LangPills extends StatelessWidget {
  const _LangPills({required this.colors, required this.lang, required this.onLang});

  final _HomeColors colors;
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

class _HomeColors {
  const _HomeColors({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.menta15,
    required this.ink,
    required this.text2,
    required this.line,
    required this.brun,
    required this.ok,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color mentaD;
  final Color menta15;
  final Color ink;
  final Color text2;
  final Color line;
  final Color brun;
  final Color ok;
  final Color shadow;

  static const light = _HomeColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    brun: Color(0xFFA98E7B),
    ok: Color(0xFF6F9E86),
    shadow: Color(0x0D000000),
  );

  static const dark = _HomeColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    brun: Color(0xFFA98E7B),
    ok: Color(0xFF6F9E86),
    shadow: Color(0x66000000),
  );

  static _HomeColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

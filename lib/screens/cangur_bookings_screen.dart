import 'package:flutter/material.dart';

import '../l10n/bookings_copy.dart';
import '../l10n/cangur_copy.dart';
import '../l10n/chat_copy.dart';
import '../l10n/menu_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'booking_detail_screen.dart';
import 'chat_screen.dart';

class CangurBookingsScreen extends StatefulWidget {
  const CangurBookingsScreen({this.embedded = false, this.showChat = false, super.key});

  final bool embedded;
  final bool showChat;

  @override
  State<CangurBookingsScreen> createState() => _CangurBookingsScreenState();
}

class _CangurBookingsScreenState extends State<CangurBookingsScreen> {
  var _history = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = AppScope.of(context);
      state.refreshBookings();
      state.refreshReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _Look.of(context);
    final items = state.bookingsForCurrent().where((booking) => booking.estado != 'denegada' && booking.estado != 'presupuesto').toList();
    final upcoming = [for (final booking in items) if (!_past(booking)) booking]..sort((a, b) => a.fecha.compareTo(b.fecha));
    final history = [for (final booking in items) if (_past(booking)) booking]..sort((a, b) => b.fecha.compareTo(a.fecha));
    final shown = _history ? history : upcoming;
    final body = Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: colors.bg, border: Border(bottom: BorderSide(color: colors.line))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    if (!widget.embedded) ...[
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
                    ],
                    Expanded(child: Text(mn(lang, 'myBookings'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _tab(colors, lang, cg(lang, 'properes'), upcoming.length, !_history, () => setState(() => _history = false)),
                    _tab(colors, lang, bk(lang, 'history'), history.length, _history, () => setState(() => _history = true)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? _empty(colors, _history)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  itemCount: shown.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _Card(colors: colors, booking: shown[index], history: _history, showChat: widget.showChat),
                  ),
                ),
        ),
      ],
    );
    if (widget.embedded) {
      return ColoredBox(
        color: colors.bg,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: body),
        ),
      );
    }
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget _tab(_Look colors, AppLang lang, String label, int count, bool on, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: on ? colors.ink : colors.text2),
                  children: [
                    TextSpan(text: ' ($count)', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.text2)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: on ? colors.mentaD : Colors.transparent, borderRadius: BorderRadius.circular(3))),
          ],
        ),
      ),
    );
  }

  Widget _empty(_Look colors, bool history) {
    final lang = AppScope.of(context).lang;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Column(
        children: [
          Text(history ? '📋' : '🗓️', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            history ? bk(lang, 'emptyHistory') : cg(lang, 'emptyUpcoming'),
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.colors, required this.booking, required this.history, this.showChat = false});

  final _Look colors;
  final Booking booking;
  final bool history;
  final bool showChat;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final review = history ? state.reviewOnBooking(booking.id) : null;
    final family = booking.padreNombre.trim().isEmpty ? '—' : booking.padreNombre.trim();
    final pill = history ? _Pill(bk(lang, 'completed'), _Kind.done) : (booking.estado == 'confirmada' ? _Pill(state.tr('confirmed'), _Kind.ok) : _Pill(state.tr('pending'), _Kind.wait));
    final price = booking.total == null ? '—' : _euro(booking.total!);
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
                    decoration: BoxDecoration(color: pill.background(colors), borderRadius: BorderRadius.circular(999)),
                    child: Text(pill.label.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.3, color: pill.foreground(colors))),
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
                  Expanded(child: _fact(colors, cg(lang, 'zone'), booking.direccionServicio.isEmpty ? '—' : booking.direccionServicio)),
                  const SizedBox(width: 14),
                  Expanded(child: _fact(colors, cg(lang, 'children'), _kids(lang, booking.numeroNinos))),
                ],
              ),
              const SizedBox(height: 10),
              _fact(colors, cg(lang, 'yourPay'), price, pay: true),
              if (showChat) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(booking: booking))),
                    icon: Icon(Icons.chat_bubble_outline, size: 18, color: colors.ink),
                    label: Text(cx(lang, 'openThread')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.ink,
                      side: BorderSide(color: colors.line, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                  ),
                ),
              ],
              if (review != null) ...[
                const SizedBox(height: 14),
                Divider(height: 1, color: colors.line),
                const SizedBox(height: 12),
                Text(cg(lang, 'familyReview').toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, letterSpacing: 0.4, color: colors.text2)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    for (var star = 1; star <= 5; star++)
                      Icon(star <= review.stars ? Icons.star : Icons.star_border, size: 17, color: star <= review.stars ? colors.gold : colors.line),
                  ],
                ),
                if (review.comentario.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text('“${review.comentario.trim()}”', style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.5, fontStyle: FontStyle.italic, color: colors.text)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill {
  const _Pill(this.label, this.kind);
  final String label;
  final _Kind kind;

  Color background(_Look colors) {
    switch (kind) {
      case _Kind.ok:
        return const Color(0x296F9E86);
      case _Kind.wait:
        return const Color(0x29C08457);
      case _Kind.done:
        return colors.menta15;
    }
  }

  Color foreground(_Look colors) {
    switch (kind) {
      case _Kind.ok:
        return const Color(0xFF6F9E86);
      case _Kind.wait:
        return const Color(0xFFC08457);
      case _Kind.done:
        return colors.mentaD;
    }
  }
}

enum _Kind { ok, wait, done }

Widget _fact(_Look colors, String label, String value, {bool pay = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, letterSpacing: 0.4, color: colors.text2)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14.5, color: pay ? colors.mentaD : colors.ink)),
    ],
  );
}

bool _past(Booking booking) {
  if (booking.estado == 'completada' || booking.estado == 'completado') return true;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(booking.fecha.year, booking.fecha.month, booking.fecha.day);
  if (!day.isBefore(today)) return false;
  return booking.estado != 'pendiente' && booking.estado != 'presupuesto';
}

String _kids(AppLang lang, int count) {
  if (count == 1) return bk(lang, 'oneChild');
  return bk(lang, 'manyChildren').replaceAll('{n}', '$count');
}

String _schedule(Booking booking) {
  if (booking.horaInicio.isEmpty) return '—';
  final hours = _hours(booking);
  final range = booking.horaFin.isEmpty ? booking.horaInicio : '${booking.horaInicio} – ${booking.horaFin}';
  return hours.isEmpty ? range : '$range · $hours';
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

int? _minutes(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}

String _euro(double value) => '${value.toStringAsFixed(2).replaceAll('.', ',')} €';

class _Look {
  const _Look({
    required this.bg,
    required this.card,
    required this.mentaD,
    required this.menta15,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
    required this.gold,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color mentaD;
  final Color menta15;
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color gold;
  final Color shadow;

  static const light = _Look(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    gold: Color(0xFFE0A93B),
    shadow: Color(0x0D000000),
  );

  static const dark = _Look(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    gold: Color(0xFFE0A93B),
    shadow: Color(0x66000000),
  );

  static _Look of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/bookings_copy.dart';
import '../l10n/menu_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'booking_detail_screen.dart';

class FatherBookingsTab extends StatefulWidget {
  const FatherBookingsTab({required this.onBack, this.pane = 0, super.key});

  final VoidCallback onBack;
  final int pane;

  @override
  State<FatherBookingsTab> createState() => _FatherBookingsTabState();
}

class _FatherBookingsTabState extends State<FatherBookingsTab> {
  late int _tab;
  bool _toast = false;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _tab = widget.pane == 1 ? 1 : 0;
  }

  @override
  void didUpdateWidget(FatherBookingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pane != oldWidget.pane) _tab = widget.pane == 1 ? 1 : 0;
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _review(Booking booking, String carer, String dateLabel) async {
    final state = AppScope.of(context);
    final result = await showModalBottomSheet<_ReviewResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewSheet(carer: carer, dateLabel: dateLabel, lang: state.lang),
    );
    if (result == null || !mounted) return;
    final error = await state.addReview(
      booking: booking,
      stars: result.stars,
      comentario: result.text,
      compartir: result.share,
    );
    if (!mounted) return;
    if (error != null) {
      state.flash(state.tr(error));
      return;
    }
    setState(() => _toast = true);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _toast = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _BookColors.of(context);
    final items = state.bookingsForCurrent();
    final current = [for (final booking in items) if (!isPastBooking(booking)) booking]..sort((a, b) => b.fecha.compareTo(a.fecha));
    final history = [for (final booking in items) if (isPastBooking(booking)) booking]..sort((a, b) => b.fecha.compareTo(a.fecha));
    final shown = _tab == 0 ? current : history;
    return Stack(
      children: [
        Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: colors.bg, border: Border(bottom: BorderSide(color: colors.line))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Material(
                          color: colors.menta15,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: widget.onBack,
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(mn(lang, 'myBookings'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _tabButton(colors, bk(lang, 'actuals'), current.length, 0),
                        _tabButton(colors, bk(lang, 'history'), history.length, 1),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: shown.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                          child: Text(
                            '${_tab == 0 ? '🗓️' : '📋'}\n${_tab == 0 ? bk(lang, 'emptyActuals') : bk(lang, 'emptyHistory')}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                          itemCount: shown.length,
                          itemBuilder: (context, index) {
                            final booking = shown[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _BookingCard(
                                colors: colors,
                                booking: booking,
                                history: _tab == 1,
                                onReview: () => _review(booking, _carerName(state, booking), bookingDate(lang, booking.fecha)),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
        if (_toast)
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(999)),
                child: Text(bk(lang, 'sent'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: colors.bg)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _tabButton(_BookColors colors, String label, int count, int index) {
    final on = _tab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = index),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  text: label,
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: on ? colors.ink : colors.text2),
                  children: [
                    TextSpan(text: ' ($count)', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.text2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: on ? colors.mentaD : Colors.transparent, borderRadius: BorderRadius.circular(3))),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.colors, required this.booking, required this.history, required this.onReview});

  final _BookColors colors;
  final Booking booking;
  final bool history;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final review = state.reviewForBooking(booking.id);
    final pill = _pill(state, booking, history);
    final carer = _carerName(state, booking);
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
                        Text(bookingServiceTitle(lang, booking.tipoServicio), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink, height: 1.1)),
                        const SizedBox(height: 2),
                        Text(_kids(lang, booking.numeroNinos), style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2)),
                      ],
                    ),
                  ),
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
                  Expanded(child: _fact(colors, bk(lang, 'price'), price, price: true)),
                ],
              ),
              if (history && review != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.line))),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bk(lang, 'yourReview').toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, letterSpacing: 0.4, color: colors.text2)),
                          const SizedBox(height: 5),
                          _Stars(value: review.stars, size: 17, colors: colors),
                          if (review.comentario.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Text('“${review.comentario}”', style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.5, fontStyle: FontStyle.italic, color: colors.text)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (history && review == null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Material(
                    color: const Color(0x17A98E7B),
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      onTap: onReview,
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: colors.brun.withValues(alpha: 0.32), width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_border, size: 16, color: colors.brun),
                            const SizedBox(width: 8),
                            Text(bk(lang, 'leaveReview'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.brun)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.carer, required this.dateLabel, required this.lang});

  final String carer;
  final String dateLabel;
  final AppLang lang;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final _text = TextEditingController();
  int _stars = 0;
  bool _share = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _BookColors.of(context);
    final lang = widget.lang;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: colors.line, borderRadius: BorderRadius.circular(999)))),
                  const SizedBox(height: 16),
                  Text(bk(lang, 'howWas'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: colors.ink)),
                  const SizedBox(height: 4),
                  Text(
                    bk(lang, 'rateWith').replaceAll('{name}', widget.carer).replaceAll('{date}', widget.dateLabel),
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.5, color: colors.text2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          key: Key('review-star-$i'),
                          onPressed: () => setState(() => _stars = i),
                          icon: Icon(i <= _stars ? Icons.star : Icons.star_border, size: 38, color: const Color(0xFFE0A93B)),
                        ),
                    ],
                  ),
                  Text(bk(lang, 'experience'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.ink)),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('review-text'),
                    controller: _text,
                    minLines: 4,
                    maxLines: 6,
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
                    decoration: InputDecoration(
                      hintText: bk(lang, 'experienceHint'),
                      filled: true,
                      fillColor: colors.bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.line, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.menta, width: 1.6)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => setState(() => _share = !_share),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 1),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _share ? colors.mentaD : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: _share ? colors.mentaD : colors.line, width: 2),
                          ),
                          child: Icon(Icons.check, size: 14, color: _share ? Colors.white : Colors.transparent),
                        ),
                        const SizedBox(width: 11),
                        Expanded(child: Text.rich(_marked(bk(lang, 'share'), TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.45, color: colors.text), TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w800, color: colors.ink)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Opacity(
                    opacity: _stars == 0 ? 0.45 : 1,
                    child: Material(
                      color: colors.mentaD,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: _stars == 0 ? null : () => Navigator.pop(context, _ReviewResult(_stars, _text.text, _share)),
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(bk(lang, 'send'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(13)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📩', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(child: Text.rich(_marked(bk(lang, 'intern'), TextStyle(fontFamily: 'Nunito', fontSize: 12.5, height: 1.5, color: colors.text), TextStyle(fontFamily: 'Nunito', fontSize: 12.5, height: 1.5, fontWeight: FontWeight.w800, color: colors.ink)))),
                      ],
                    ),
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

class _ReviewResult {
  const _ReviewResult(this.stars, this.text, this.share);

  final int stars;
  final String text;
  final bool share;
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, required this.size, required this.colors});

  final int value;
  final double size;
  final _BookColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(i <= value ? Icons.star : Icons.star_border, size: size, color: i <= value ? const Color(0xFFE0A93B) : colors.line),
      ],
    );
  }
}

class _Pill {
  const _Pill(this.label, this.kind);

  final String label;
  final _PillKind kind;

  Color get background {
    switch (kind) {
      case _PillKind.ok:
        return const Color(0x296F9E86);
      case _PillKind.wait:
        return const Color(0x29C08457);
      case _PillKind.done:
        return const Color(0x26B3CFC4);
    }
  }

  Color get foreground {
    switch (kind) {
      case _PillKind.ok:
        return const Color(0xFF6F9E86);
      case _PillKind.wait:
        return const Color(0xFFC08457);
      case _PillKind.done:
        return const Color(0xFF8CA598);
    }
  }
}

enum _PillKind { ok, wait, done }

Widget _fact(_BookColors colors, String label, String value, {bool price = false, Widget? child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, letterSpacing: 0.4, color: colors.text2)),
      const SizedBox(height: 2),
      child ?? Text(value, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14.5, color: price ? colors.mentaD : colors.ink)),
    ],
  );
}

bool isPastBooking(Booking booking) {
  if (booking.estado == 'completada' || booking.estado == 'completado') return true;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(booking.fecha.year, booking.fecha.month, booking.fecha.day);
  if (!day.isBefore(today)) return false;
  return booking.estado != 'pendiente' && booking.estado != 'presupuesto';
}

_Pill _pill(dynamic state, Booking booking, bool history) {
  final lang = state.lang as AppLang;
  if (history) return _Pill(bk(lang, 'completed'), _PillKind.done);
  if (booking.estadoPago == 'fallido') return _Pill(state.tr('failed') as String, _PillKind.wait);
  if (booking.estado == 'presupuesto') return _Pill(state.tr('quote') as String, _PillKind.wait);
  if (booking.estado == 'confirmada') return _Pill(state.tr('confirmed') as String, _PillKind.ok);
  return _Pill(state.tr('pending') as String, _PillKind.wait);
}

String _carerName(dynamic state, Booking booking) {
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
  if (color is int) return color;
  const palette = [0xFF6E82A6, 0xFF8CA598, 0xFFA98E7B, 0xFF9487B3, 0xFFC08457];
  final name = booking.canguroNombre ?? booking.canguroId ?? '';
  if (name.isEmpty) return palette[1];
  return palette[name.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % palette.length];
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

String _euro(double value) {
  return '${value.toStringAsFixed(2).replaceAll('.', ',')} €';
}

TextSpan _marked(String source, TextStyle base, TextStyle bold) {
  final parts = source.split('**');
  return TextSpan(
    children: [
      for (var i = 0; i < parts.length; i++) TextSpan(text: parts[i], style: i.isOdd ? bold : base),
    ],
  );
}

class _BookColors {
  const _BookColors({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.menta15,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
    required this.brun,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color mentaD;
  final Color menta15;
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color brun;
  final Color shadow;

  static const light = _BookColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    brun: Color(0xFFA98E7B),
    shadow: Color(0x0D000000),
  );

  static const dark = _BookColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    brun: Color(0xFFA98E7B),
    shadow: Color(0x66000000),
  );

  static _BookColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

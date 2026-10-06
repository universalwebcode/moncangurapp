import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../l10n/app_copy.dart';
import '../l10n/menu_copy.dart';
import '../l10n/reserva_copy.dart';
import '../models/models.dart';
import '../services/redsys_browser.dart';
import '../services/redsys_payment.dart';
import '../state/app_state.dart';
import '../widgets/mc_widgets.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({required this.booking, super.key});

  final Booking booking;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _paying = false;
  bool _confirming = false;
  String? _error;
  String? _order;

  Booking get booking => widget.booking;

  bool get _pending => booking.estadoPago != 'pagada' && booking.estadoPago != 'pagado' && booking.estadoPago != 'fallido';

  bool get _canPay => _pending && (booking.total ?? 0) > 0 && !_paying && !_confirming;

  @override
  void initState() {
    super.initState();
    listenForRedsys(_onRedsys);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _DetailColors.of(context);
    final carer = booking.canguroNombre?.trim() ?? '';
    final address = booking.direccionServicio.trim();
    final when = booking.horaInicio.isEmpty
        ? state.tr('schedulePending')
        : booking.horaFin.isEmpty
        ? booking.horaInicio
        : '${booking.horaInicio} – ${booking.horaFin}';
    final kids = booking.numeroNinos == 1
        ? rt(lang, 'infant', {'n': '${booking.numeroNinos}'})
        : rt(lang, 'infants', {'n': '${booking.numeroNinos}'});
    final mine = state.user?.role == UserRole.father && state.user?.id == booking.padreId;
    final rows = <(String, String)>[
      (mn(lang, 'family'), booking.padreNombre),
      (rt(lang, 'service'), serviceName(lang, booking.tipoServicio)),
      (mn(lang, 'status'), _bookingStatus(state)),
      (mn(lang, 'payment'), _paymentStatus(state)),
      (rt(lang, 'day'), _day(lang)),
      (rt(lang, 'time'), when),
      (rt(lang, 'children'), kids),
      (rt(lang, 'cangur'), carer.isEmpty ? state.tr('noAssigned') : carer),
      (rt(lang, 'address'), address.isEmpty ? '—' : address),
      if (booking.total != null) (rt(lang, 'total'), money(booking.total!)),
    ];
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
                        Expanded(
                          child: Text(
                            mn(lang, 'detail'),
                            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    children: [
                      Text(
                        serviceName(lang, booking.tipoServicio),
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, color: colors.ink),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            statusLabel(state, booking),
                            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, color: colors.brun),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        mn(lang, 'bookings').toUpperCase(),
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 1.6, color: colors.mentaD),
                      ),
                      const SizedBox(height: 9),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.line, width: 1.5),
                          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < rows.length; i++) _row(colors, rows[i].$1, rows[i].$2, line: i < rows.length - 1),
                          ],
                        ),
                      ),
                      if (booking.notas.trim().isNotEmpty) ...[
                        const SizedBox(height: 22),
                        Text(
                          mn(lang, 'notes').toUpperCase(),
                          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 1.6, color: colors.mentaD),
                        ),
                        const SizedBox(height: 9),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.line, width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              booking.notas.trim(),
                              style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.45, color: colors.text),
                            ),
                          ),
                        ),
                      ],
                      if (mine && _pending && (booking.total ?? 0) > 0) ...[
                        const SizedBox(height: 22),
                        if (_error != null) ...[
                          Text(_error!, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, height: 1.4, color: colors.brun)),
                          const SizedBox(height: 12),
                        ],
                        if (_paying || _confirming) ...[
                          Text(
                            rt(lang, _confirming ? 'payConfirming' : 'payWaiting'),
                            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: colors.mentaD),
                          ),
                          const SizedBox(height: 12),
                        ],
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.mentaD.withValues(alpha: _canPay ? 1 : 0.45),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _canPay ? _startPay : null,
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  mn(lang, 'pay'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _startPay() async {
    if (!_canPay) return;
    final state = AppScope.of(context);
    final lang = state.lang;
    final tab = openPaymentTab();
    if (tab == null) {
      setState(() => _error = rt(lang, 'payBlocked'));
      return;
    }
    setState(() {
      _paying = true;
      _error = null;
    });
    try {
      final form = await const RedsysPayment().create(
        bookingId: booking.id,
        amountCents: ((booking.total ?? 0) * 100).round(),
      );
      _order = form.order.isEmpty ? null : form.order;
      submitRedsysForm(url: form.url, version: form.version, parameters: form.parameters, signature: form.signature);
    } catch (error) {
      final message = _payFailure(lang, error);
      tab.showMessage(rt(lang, 'payTitle'), message);
      if (mounted) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  String _payFailure(AppLang lang, Object error) {
    if (error is FirebaseFunctionsException) {
      final detail = error.message;
      if (error.code == 'unauthenticated') return rt(lang, 'paySignIn');
      if (error.code == 'permission-denied') return AppScope.of(context).tr('rulesDenied');
      if (detail != null && detail.trim().isNotEmpty) return detail.trim();
    }
    return rt(lang, 'payFailed');
  }

  void _onRedsys(bool ok, String order) {
    if (!mounted || !_pending) return;
    if (_order != null && order.isNotEmpty && order != _order) return;
    final lang = AppScope.of(context).lang;
    if (!ok) {
      setState(() => _error = rt(lang, 'payFailed'));
      return;
    }
    _waitForBank();
  }

  Future<void> _waitForBank() async {
    final lang = AppScope.of(context).lang;
    setState(() {
      _confirming = true;
      _error = null;
    });
    for (var attempt = 0; attempt < 15; attempt++) {
      final snap = await FirebaseFirestore.instance.collection('reservas').doc(booking.id).get();
      if (!mounted) return;
      final status = snap.data()?['estadoPago'];
      if (status == 'pagada' || status == 'pagado') {
        booking.estado = 'confirmada';
        AppScope.of(context).setPayment(booking.id, true);
        setState(() => _confirming = false);
        return;
      }
      if (status == 'fallido') {
        AppScope.of(context).setPayment(booking.id, false);
        setState(() {
          _confirming = false;
          _error = rt(lang, 'payFailed');
        });
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    if (!mounted) return;
    setState(() {
      _confirming = false;
      _error = rt(lang, 'payPending');
    });
  }

  String _day(AppLang lang) {
    final date = booking.fecha;
    final weekday = reservaDayShort[lang.index][date.weekday - 1];
    final month = reservaMonths[lang.index][date.month - 1];
    return '$weekday ${date.day} $month ${date.year}';
  }

  String _bookingStatus(AppState state) {
    switch (booking.estado) {
      case 'presupuesto':
        return state.tr('quote');
      case 'confirmada':
        return state.tr('confirmed');
      default:
        return state.tr('pending');
    }
  }

  String _paymentStatus(AppState state) {
    switch (booking.estadoPago) {
      case 'pagada':
      case 'pagado':
        return state.tr('paid');
      case 'fallido':
        return state.tr('failed');
      default:
        return state.tr('pending');
    }
  }

  Widget _row(_DetailColors colors, String label, String value, {required bool line}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(border: line ? Border(bottom: BorderSide(color: colors.line)) : null),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.text2)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailColors {
  const _DetailColors({
    required this.bg,
    required this.card,
    required this.menta15,
    required this.mentaD,
    required this.brun,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color menta15;
  final Color mentaD;
  final Color brun;
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color shadow;

  static const light = _DetailColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta15: Color(0x26B3CFC4),
    mentaD: Color(0xFF8CA598),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x0F000000),
    shadow: Color(0x0D000000),
  );

  static const dark = _DetailColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta15: Color(0x1FB3CFC4),
    mentaD: Color(0xFF8CA598),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    shadow: Color(0x66000000),
  );

  static _DetailColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

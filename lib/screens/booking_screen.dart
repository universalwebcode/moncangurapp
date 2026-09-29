import 'package:flutter/material.dart';

import '../domain/availability.dart';
import '../domain/pricing.dart';
import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({required this.service, super.key});

  final ServiceOffer service;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _start = '16:00';
  String _end = '19:00';
  int _children = 1;
  final _address = TextEditingController();
  List<CangurProfile>? _results;
  CangurProfile? _selected;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _search() {
    final state = AppScope.of(context);
    if (hoursBetween(_start, _end) == null) {
      setState(() {
        _error = state.tr('invalidRange');
        _results = null;
        _selected = null;
      });
      return;
    }
    final found = state.findCanguros(tipo: widget.service.tipoServicio, date: _date, start: _start, end: _end);
    setState(() {
      _error = found.isEmpty ? state.tr('noMatch') : null;
      _results = found;
      _selected = null;
    });
  }

  void _confirm() {
    final state = AppScope.of(context);
    final cangur = _selected;
    if (cangur == null) return;
    if (_address.text.trim().isEmpty) {
      setState(() => _error = state.tr('address'));
      return;
    }
    final booking = state.createBooking(
      service: widget.service,
      date: _date,
      start: _start,
      end: _end,
      children: _children,
      address: _address.text,
      cangur: cangur,
    );
    if (booking == null || !mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking, service: widget.service)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hours = hoursBetween(_start, _end);
    final quote = hours == null
        ? null
        : Pricing.quote(service: widget.service, children: _children, hours: hours);
    return Scaffold(
      body: SafeArea(
        child: PageWidth(
          maxWidth: 720,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(state.tr('back')),
                  ),
                  const Spacer(),
                  const LanguageMenu(),
                ],
              ),
              Text(
                serviceName(state.lang, widget.service.tipoServicio),
                style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 32),
              ),
              const SizedBox(height: 6),
              Text(widget.service.descripcion, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(state.tr('dateTime'), style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _pickDate, child: Text('${state.tr('date')}: ${formatDate(_date)}')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _timeButton(state.tr('start'), _start, (v) => setState(() => _start = v))),
                        const SizedBox(width: 8),
                        Expanded(child: _timeButton(state.tr('end'), _end, (v) => setState(() => _end = v))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(state.tr('children'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _children > 1 ? () => setState(() => _children -= 1) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_children', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        IconButton(
                          onPressed: _children < 25 ? () => setState(() => _children += 1) : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    Text(state.tr(caregiverNeedKey(_children)), style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _address,
                      decoration: InputDecoration(labelText: state.tr('address')),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _search, child: Text(state.tr('find'))),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
              ],
              if (_results != null && _results!.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (final profile in _results!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CangurTile(
                      profile: profile,
                      selected: _selected?.userId == profile.userId,
                      onTap: () => setState(() => _selected = profile),
                    ),
                  ),
              ],
              if (quote != null && _selected != null) ...[
                const SizedBox(height: 6),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(state.tr('summary'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 8),
                      _row(state.tr('date'), formatDate(_date)),
                      _row(state.tr('schedule'), '$_start – $_end'),
                      _row(state.tr('duration'), '${quote.hours.toStringAsFixed(quote.hours == quote.hours.roundToDouble() ? 0 : 1)} ${state.tr('hours')}'),
                      _row(state.tr('children'), '$_children'),
                      _row(state.tr('hourly'), money(quote.hourlyCaregiver)),
                      _row(state.tr('subtotal'), money(quote.subtotal)),
                      _row(state.tr('fee'), money(quote.fee)),
                      const Divider(),
                      _row(state.tr('total'), money(quote.total), strong: true),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _confirm, child: Text(state.tr('pay'))),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeButton(String label, String value, ValueChanged<String> onPick) {
    return OutlinedButton(
      onPressed: () async {
        final next = await pickTime(context, value);
        if (next != null) onPick(next);
      },
      child: Text('$label\n$value', textAlign: TextAlign.center),
    );
  }
}

class _CangurTile extends StatelessWidget {
  const _CangurTile({required this.profile, required this.selected, required this.onTap});

  final CangurProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final rating = state.reviewsFor(profile.userId);
    final avg = rating.isEmpty ? null : rating.map((r) => r.rating).reduce((a, b) => a + b) / rating.length;
    return Material(
      color: selected ? AppColors.olive.withValues(alpha: 0.55) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(profile.descripcionPersonal),
              const SizedBox(height: 6),
              Text('${profile.idiomas.join(' · ')} · ${profile.aniosExperiencia} ${state.tr('yearsExp')}'),
              if (profile.certificaciones.isNotEmpty) Text(profile.certificaciones.join(', ')),
              if (avg != null) Text('${state.tr('generalRating')}: ${avg.toStringAsFixed(1)}'),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({required this.booking, required this.service, super.key});

  final Booking booking;
  final ServiceOffer service;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hours = hoursBetween(booking.horaInicio, booking.horaFin) ?? 0;
    final quote = Pricing.quote(service: service, children: booking.numeroNinos, hours: hours);
    final paid = booking.estadoPago == 'pagada';
    final failed = booking.estadoPago == 'fallido';
    return Scaffold(
      body: SafeArea(
        child: PageWidth(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BrandHeader(
                title: paid
                    ? state.tr('paidTitle')
                    : failed
                        ? state.tr('payFail')
                        : state.tr('payState'),
                subtitle: paid ? state.tr('paidBody') : failed ? state.tr('failedBody') : state.tr('summary'),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _row(state.tr('schedule'), '${booking.horaInicio} – ${booking.horaFin}'),
                    _row(state.tr('total'), money(quote.total), strong: true),
                    _row(state.tr('payState'), statusLabel(state, booking)),
                    const SizedBox(height: 8),
                    Text(
                      'El pagament real obria Redsys i tornava a pago-ok.html o pago-ko.html, que avisen l\'app amb {source: moncangur_redsys}.',
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    if (!paid)
                      FilledButton(
                        onPressed: () => state.setPayment(booking.id, true),
                        child: Text(state.tr('pay')),
                      ),
                    if (!failed && !paid)
                      TextButton(
                        onPressed: () => state.setPayment(booking.id, false),
                        child: Text(state.tr('payFail')),
                      ),
                    TextButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.settings.name == '/father' || route.isFirst),
                      child: Text(state.tr('bookings')),
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

Widget _row(String label, String value, {bool strong = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: TextStyle(fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
      ],
    ),
  );
}

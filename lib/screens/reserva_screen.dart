import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../domain/availability.dart';
import '../domain/pricing.dart';
import '../l10n/reserva_copy.dart';
import '../models/models.dart';
import '../services/account_gateway.dart';
import '../services/redsys_browser.dart';
import '../services/redsys_payment.dart';
import '../state/app_state.dart';
import '../widgets/mc_widgets.dart';
import 'extra_form_screen.dart';
import 'fix_form_screen.dart';
import 'request_screen.dart';

enum _Kind { book, event, form }

_Kind _kindOf(ServiceOffer service) {
  switch (service.tipoServicio) {
    case 'eventos':
      return _Kind.event;
    case 'fijo':
    case 'repaso':
      return _Kind.form;
    default:
      return service.requiereFormulario ? _Kind.form : _Kind.book;
  }
}

int _minHoursOf(ServiceOffer service) => service.tipoServicio == 'eventos' ? 3 : 2;

int _maxKidsOf(ServiceOffer service) => service.tipoServicio == 'eventos' ? 35 : 5;

int _carersFor(ServiceOffer service, int children) {
  if (_kindOf(service) != _Kind.event) return 1;
  return math.max(1, (children / 7).ceil());
}

const _ocasionalRates = {1: 25.0, 2: 28.0, 3: 32.0, 4: 38.0, 5: 45.0};
const _urgentRates = {1: 35.0, 2: 40.0, 3: 50.0, 4: 60.0, 5: 70.0};
const _eventTiers = {1: 40.0, 2: 70.0, 3: 100.0, 4: 130.0, 5: 160.0};
const _avatarColors = [Color(0xFF6E82A6), Color(0xFFA98E7B), Color(0xFF8CA598), Color(0xFF9487B3), Color(0xFFC08457)];
const _minutes = ['00', '15', '30', '45'];

double _mappedRate(ServiceOffer service, int key) {
  return service.tarifasPorNinosConIGI[key] ?? service.tarifasPorNinos[key] ?? _fallbackRate(service, key);
}

double _fallbackRate(ServiceOffer service, int key) {
  switch (service.tipoServicio) {
    case 'eventos':
      return _eventTiers[key.clamp(1, 5)]!;
    case 'emergencia':
      return _urgentRates[key.clamp(1, 5)]!;
    case 'ocasional':
      return _ocasionalRates[key.clamp(1, 5)]!;
    default:
      return Pricing.clientHourly(service, key);
  }
}

String _serviceTitle(AppLang lang, ServiceOffer service) {
  switch (service.tipoServicio) {
    case 'ocasional':
      return rt(lang, 'svcOcasional');
    case 'emergencia':
      return rt(lang, 'svcUrgencia');
    case 'eventos':
      return rt(lang, 'svcEvent');
    case 'fijo':
      return rt(lang, 'svcFix');
    case 'repaso':
      return rt(lang, 'svcExtra');
    default:
      return service.nombre.isNotEmpty ? service.nombre : service.tipoServicio;
  }
}

String _serviceEmoji(String tipo) {
  switch (tipo) {
    case 'ocasional':
      return '🌙';
    case 'emergencia':
      return '⚡';
    case 'eventos':
      return '✨';
    case 'fijo':
      return '🌿';
    case 'repaso':
      return '🎨';
    default:
      return '🧸';
  }
}

String _wholeEuro(double value) => value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(2);

String _money(double value) => '${value.toStringAsFixed(2)} €';

String _endClock(String start, int hours) {
  final parts = start.split(':');
  final h = int.tryParse(parts.first) ?? 0;
  final m = parts.length > 1 ? parts[1] : '00';
  final end = h + hours;
  return '${end < 10 ? '0$end' : end}:$m';
}

String _langChip(String name) {
  const map = {
    'català': 'CA',
    'castellà': 'ES',
    'castellano': 'ES',
    'francès': 'FR',
    'francés': 'FR',
    'anglès': 'EN',
    'inglés': 'EN',
    'portuguès': 'PT',
    'portugués': 'PT',
  };
  final known = map[name.toLowerCase()];
  if (known != null) return known;
  if (name.length <= 3) return name.toUpperCase();
  return name.substring(0, 2).toUpperCase();
}

class ReservaScreen extends StatefulWidget {
  const ReservaScreen({this.initialServiceId, this.initialCangurId, super.key});

  final String? initialServiceId;
  final String? initialCangurId;

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final _scroll = ScrollController();
  final _otherAddress = TextEditingController();

  int _step = 1;
  bool _done = false;
  bool _seeded = false;
  bool _appliedCangur = false;
  bool _saving = false;
  bool _confirming = false;
  Booking? _payBooking;
  String? _order;
  String? _payError;
  ServiceOffer? _service;
  int _children = 1;
  DateTime? _date;
  String? _start;
  int _duration = 2;
  bool _profileAddress = true;
  final List<String> _picked = [];
  bool _facePaint = false;
  bool _decor = false;
  int _ageFrom = 3;
  int _ageTo = 8;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    listenForRedsys(_onRedsys);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).refreshCanguros();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seeded) {
      _seeded = true;
      final id = widget.initialServiceId;
      if (id != null) {
        for (final service in AppScope.of(context).services) {
          if (service.id != id || _kindOf(service) == _Kind.form) continue;
          _service = service;
          final minHours = _minHoursOf(service);
          if (_duration < minHours) _duration = minHours;
        }
      }
    }
    _keepRequestedCangur();
  }

  void _keepRequestedCangur({bool force = false}) {
    if (_appliedCangur && !force) return;
    final id = widget.initialCangurId;
    if (id == null || id.isEmpty) return;
    final known = AppScope.of(context).canguros.any((profile) => profile.userId == id);
    if (!known) return;
    if (!_picked.contains(id)) _picked.add(id);
    _appliedCangur = true;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _otherAddress.dispose();
    super.dispose();
  }

  bool get _isEvent => _service != null && _kindOf(_service!) == _Kind.event;

  int get _carers => _service == null ? 1 : _carersFor(_service!, _children);

  bool get _canContinue {
    switch (_step) {
      case 1:
        return _service != null;
      case 3:
        return _date != null;
      case 4:
        return _start != null;
      case 5:
        return _picked.length == _carers;
      default:
        return true;
    }
  }

  void _go(int step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _select(ServiceOffer service) {
    if (service.tipoServicio == 'fijo') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => FixFormScreen(service: service)));
      return;
    }
    if (service.tipoServicio == 'repaso') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ExtraFormScreen(service: service)));
      return;
    }
    if (_kindOf(service) == _Kind.form) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => RequestScreen(service: service)));
      return;
    }
    setState(() {
      _service = service;
      final minHours = _minHoursOf(service);
      if (_duration < minHours) _duration = minHours;
      if (_children > _maxKidsOf(service)) _children = _maxKidsOf(service);
      _picked.clear();
      _date = null;
      _keepRequestedCangur(force: true);
    });
  }

  bool _dayOpen(DateTime day) {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = DateUtils.dateOnly(day);
    if (date.isBefore(today)) return false;
    final diff = date.difference(today).inDays;
    final tipo = _service?.tipoServicio;
    if (tipo == 'emergencia') return diff <= 1;
    if (tipo == 'ocasional' && diff < 1) return false;
    if (date.weekday == DateTime.sunday) return false;
    if (date.day % 7 == 0) return false;
    return true;
  }

  List<CangurProfile> _orderedCanguros(AppState state) {
    final people = [...state.canguros];
    people.sort((a, b) {
      final openA = _cangurOpen(a);
      final openB = _cangurOpen(b);
      if (openA != openB) return openA ? -1 : 1;
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
    return people;
  }

  bool _cangurOpen(CangurProfile profile) {
    final service = _service;
    final date = _date;
    final start = _start;
    if (service == null || date == null || start == null) return false;
    if (_kindOf(service) == _Kind.event) return true;
    return cangurMatches(
      profile: profile,
      tipoServicio: service.tipoServicio,
      date: date,
      start: start,
      end: _endClock(start, _duration),
    );
  }

  void _toggleCangur(CangurProfile profile) {
    setState(() {
      if (_carers == 1) {
        _picked
          ..clear()
          ..add(profile.userId);
        return;
      }
      if (_picked.contains(profile.userId)) {
        _picked.remove(profile.userId);
      } else if (_picked.length < _carers) {
        _picked.add(profile.userId);
      }
    });
  }

  double _hourly(ServiceOffer service) {
    final key = _kindOf(service) == _Kind.event ? _carersFor(service, _children) : _children;
    return _mappedRate(service, key);
  }

  bool get _night {
    final start = _start;
    if (start == null) return false;
    final hour = int.tryParse(start.split(':').first) ?? 0;
    return hour >= 22 || hour < 8;
  }

  _Quote _quote(ServiceOffer service) {
    final hourly = _hourly(service);
    final base = hourly * _duration;
    final night = _night ? 5.0 * _duration : 0.0;
    final extras = _isEvent ? (_facePaint ? 30.0 : 0) + (_decor ? 150.0 : 0) : 0.0;
    return _Quote(hourly: hourly, base: base, night: night, total: base + night + extras);
  }

  String _addressLine(AppLang lang) {
    final profile = AppScope.of(context).user?.direccion.trim() ?? '';
    if (_profileAddress) return profile.isEmpty ? rt(lang, 'noProfileAddr') : profile;
    final other = _otherAddress.text.trim();
    return other.isEmpty ? rt(lang, 'otherAddr') : other;
  }

  Future<void> _pickTime(AppLang lang, _ReservaColors colors) async {
    var hour = 9;
    var minute = 0;
    final start = _start;
    if (start != null) {
      final parts = start.split(':');
      hour = int.tryParse(parts.first) ?? 9;
      final index = _minutes.indexOf(parts.length > 1 ? parts[1] : '00');
      minute = index < 0 ? 0 : index;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _TimeSheet(colors: colors, title: rt(lang, 'startLabel'), confirm: rt(lang, 'confirmTime'), hour: hour, minute: minute),
    );
    if (picked == null) return;
    setState(() {
      _start = picked;
      _picked.clear();
    });
  }

  Future<void> _confirmBooking() async {
    if (_saving) return;
    final state = AppScope.of(context);
    final service = _service;
    final date = _date;
    final start = _start;
    if (service == null || date == null || start == null || _picked.isEmpty) return;
    CangurProfile? first;
    final names = <String>[];
    for (final id in _picked) {
      for (final profile in state.canguros) {
        if (profile.userId != id) continue;
        first ??= profile;
        names.add(profile.nombre);
      }
    }
    final cangur = first;
    if (cangur == null) return;
    final notes = _isEvent
        ? [
            '${_ageFrom}–${_ageTo}',
            if (_facePaint) 'pintacares',
            if (_decor) 'decoració',
          ].join(' · ')
        : '';
    setState(() {
      _saving = true;
      _payError = null;
    });
    try {
      final booking = await state.placeReserva(
        service: service,
        date: date,
        start: start,
        end: _endClock(start, _duration),
        children: _children,
        address: _addressLine(state.lang),
        cangur: cangur,
        total: _quote(service).total,
        caregiverNames: names.join(', '),
        notes: notes,
      );
      if (!mounted || booking == null) return;
      setState(() => _payBooking = booking);
    } on AccountFailure catch (error) {
      if (!mounted) return;
      setState(() => _payError = state.tr(error.code));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _startPay() async {
    final booking = _payBooking;
    final state = AppScope.of(context);
    if (booking == null || _saving) return;
    final tab = openPaymentTab();
    if (tab == null) {
      setState(() => _payError = rt(state.lang, 'payBlocked'));
      return;
    }
    setState(() {
      _saving = true;
      _payError = null;
    });
    try {
      final form = await const RedsysPayment().create(
        bookingId: booking.id,
        amountCents: ((booking.total ?? 0) * 100).round(),
      );
      _order = form.order.isEmpty ? null : form.order;
      submitRedsysForm(url: form.url, version: form.version, parameters: form.parameters, signature: form.signature);
    } catch (error) {
      final message = _payFailure(state.lang, error);
      tab.showMessage(rt(state.lang, 'payTitle'), message);
      if (mounted) setState(() => _payError = message);
    } finally {
      if (mounted) setState(() => _saving = false);
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
    if (!mounted || _payBooking == null) return;
    if (_order != null && order.isNotEmpty && order != _order) return;
    final lang = AppScope.of(context).lang;
    if (!ok) {
      setState(() => _payError = rt(lang, 'payFailed'));
      return;
    }
    _waitForBank();
  }

  Future<void> _waitForBank() async {
    final booking = _payBooking;
    if (booking == null) return;
    final lang = AppScope.of(context).lang;
    setState(() {
      _confirming = true;
      _payError = null;
    });
    for (var attempt = 0; attempt < 15; attempt++) {
      final snap = await FirebaseFirestore.instance.collection('reservas').doc(booking.id).get();
      if (!mounted) return;
      final status = snap.data()?['estadoPago'];
      if (status == 'pagada' || status == 'pagado') {
        booking.estado = 'confirmada';
        AppScope.of(context).setPayment(booking.id, true);
        setState(() {
          _done = true;
          _confirming = false;
        });
        return;
      }
      if (status == 'fallido') {
        AppScope.of(context).setPayment(booking.id, false);
        setState(() {
          _confirming = false;
          _payError = rt(lang, 'payFailed');
        });
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    if (!mounted) return;
    setState(() {
      _confirming = false;
      _payError = rt(lang, 'payPending');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _ReservaColors.of(context);
    final lang = state.lang;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _done
                ? _doneView(colors, lang)
                : _payBooking != null
                    ? _payView(colors, lang)
                    : _flow(colors, lang, state),
          ),
        ),
      ),
    );
  }

  Widget _flow(_ReservaColors colors, AppLang lang, AppState state) {
    return Column(
      children: [
        _top(colors, lang),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: KeyedSubtree(key: ValueKey(_step), child: _stepBody(colors, lang, state)),
              ),
            ],
          ),
        ),
        _foot(colors, lang),
      ],
    );
  }

  Widget _top(_ReservaColors colors, AppLang lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
      child: Column(
        children: [
          Row(
            children: [
              Material(
                color: colors.menta15,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(11),
                  child: SizedBox(width: 38, height: 38, child: Icon(Icons.chevron_left, color: colors.ink)),
                ),
              ),
              const SizedBox(width: 12),
              Text(rt(lang, 'title'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(minHeight: 5, value: _step / 7, backgroundColor: colors.menta15, color: colors.mentaD),
          ),
        ],
      ),
    );
  }

  Widget _stepBody(_ReservaColors colors, AppLang lang, AppState state) {
    switch (_step) {
      case 1:
        return _services(colors, lang, state);
      case 2:
        return _childrenStep(colors, lang);
      case 3:
        return _dayStep(colors, lang);
      case 4:
        return _timeStep(colors, lang);
      case 5:
        return _cangurStep(colors, lang, state);
      case 6:
        return _addressStep(colors, lang, state);
      default:
        return _summaryStep(colors, lang);
    }
  }

  Widget _heading(_ReservaColors colors, AppLang lang, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rt(lang, 'eyebrow', {'n': '$_step', 'label': rt(lang, 'step$_step')}).toUpperCase(),
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.4, color: colors.mentaD),
        ),
        const SizedBox(height: 11),
        Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 23, height: 1.2, color: colors.ink)),
        const SizedBox(height: 6),
        Text(sub, style: TextStyle(fontFamily: 'Nunito', fontSize: 14, height: 1.5, color: colors.text2)),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _services(_ReservaColors colors, AppLang lang, AppState state) {
    final services = [...state.services];
    const rank = ['ocasional', 'emergencia', 'eventos', 'fijo', 'repaso'];
    services.sort((a, b) {
      final ia = rank.indexOf(a.tipoServicio);
      final ib = rank.indexOf(b.tipoServicio);
      return (ia < 0 ? 99 : ia).compareTo(ib < 0 ? 99 : ib);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(colors, lang, rt(lang, 'svcTitle'), rt(lang, 'svcSub')),
        for (final service in services) _serviceCard(colors, lang, service),
      ],
    );
  }

  Widget _serviceCard(_ReservaColors colors, AppLang lang, ServiceOffer service) {
    final form = _kindOf(service) == _Kind.form;
    final selected = _service?.id == service.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: selected ? colors.menta15 : colors.card,
        elevation: 0,
        shadowColor: colors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? colors.mentaD : colors.line, width: 1.5),
        ),
        child: InkWell(
          onTap: () => _select(service),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Text(_serviceEmoji(service.tipoServicio), style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_serviceTitle(lang, service), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink)),
                      const SizedBox(height: 1),
                      Text(
                        form
                            ? rt(lang, 'proposal')
                            : rt(lang, 'fromPrice', {'price': _wholeEuro(_mappedRate(service, 1)), 'min': '${_minHoursOf(service)}'}),
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13, color: colors.brun),
                      ),
                    ],
                  ),
                ),
                if (form) Icon(Icons.chevron_right, color: colors.mentaD) else _mark(colors, selected, round: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _childrenStep(_ReservaColors colors, AppLang lang) {
    final maxKids = _service == null ? 5 : _maxKidsOf(_service!);
    final count = _children == 1 ? rt(lang, 'infant', {'n': '$_children'}) : rt(lang, 'infants', {'n': '$_children'});
    final carers = _carers == 1 ? rt(lang, 'carerOne') : rt(lang, 'carerMany', {'n': '$_carers'});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(colors, lang, rt(lang, 'kidsTitle'), _isEvent ? rt(lang, 'kidsSubEvent') : rt(lang, 'kidsSub')),
        Center(child: Text(count, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 26, color: colors.mentaD))),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roundButton(colors, '−', _children > 1 ? () => setState(() { _children -= 1; _picked.clear(); }) : null),
            const SizedBox(width: 22),
            _roundButton(colors, '+', _children < maxKids ? () => setState(() { _children += 1; _picked.clear(); }) : null),
          ],
        ),
        if (_isEvent) ...[
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('👥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 11),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.5, color: colors.text),
                      children: [
                        TextSpan(text: rt(lang, 'eventWith')),
                        TextSpan(text: count, style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink)),
                        TextSpan(text: rt(lang, 'eventWill')),
                        TextSpan(text: carers, style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink)),
                        TextSpan(text: rt(lang, 'eventTail')),
                        TextSpan(text: rt(lang, 'eventExtra')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _label(colors, rt(lang, 'ageRange')),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _ageMenu(colors, lang, rt(lang, 'from'), _ageFrom, (value) => setState(() => _ageFrom = value))),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
                child: Text('–', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.text2)),
              ),
              Expanded(child: _ageMenu(colors, lang, rt(lang, 'to'), _ageTo, (value) => setState(() => _ageTo = value))),
            ],
          ),
          _label(colors, rt(lang, 'extras')),
          _extraTile(colors, lang, rt(lang, 'facePaint'), '+30 €', _facePaint, () => setState(() => _facePaint = !_facePaint)),
          _extraTile(colors, lang, rt(lang, 'decor'), '+150 €', _decor, () => setState(() => _decor = !_decor)),
        ],
      ],
    );
  }

  Widget _ageMenu(_ReservaColors colors, AppLang lang, String caption, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.line, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [
                for (var age = 0; age <= 16; age++)
                  DropdownMenuItem(value: age, child: Text(rt(lang, 'years', {'n': '$age'}), style: TextStyle(fontFamily: 'Nunito', color: colors.ink))),
              ],
              onChanged: (next) {
                if (next != null) onChanged(next);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _extraTile(_ReservaColors colors, AppLang lang, String label, String price, bool on, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: on ? colors.menta15 : colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: BorderSide(color: on ? colors.mentaD : colors.line, width: 1.5),
        ),
        child: InkWell(
          onTap: toggle,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14.5, color: colors.ink),
                      children: [
                        TextSpan(text: '$label '),
                        TextSpan(text: price, style: TextStyle(color: colors.brun)),
                      ],
                    ),
                  ),
                ),
                _mark(colors, on, round: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayStep(_ReservaColors colors, AppLang lang) {
    final first = DateTime(_month.year, _month.month);
    final offset = (first.weekday + 6) % 7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final monthName = reservaMonths[lang.index][_month.month - 1];
    final titled = monthName.isEmpty ? monthName : '${monthName[0].toUpperCase()}${monthName.substring(1)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(colors, lang, rt(lang, 'dayTitle'), rt(lang, 'daySub')),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.line, width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _navButton(colors, Icons.chevron_left, () => setState(() => _month = DateTime(_month.year, _month.month - 1))),
                  Expanded(
                    child: Text(
                      '$titled ${_month.year}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink),
                    ),
                  ),
                  _navButton(colors, Icons.chevron_right, () => setState(() => _month = DateTime(_month.year, _month.month + 1))),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final label in reservaDow[lang.index])
                    Expanded(
                      child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: colors.text2)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  for (var i = 0; i < offset; i++) const SizedBox.shrink(),
                  for (var day = 1; day <= days; day++) _dayCell(colors, DateTime(_month.year, _month.month, day)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dayCell(_ReservaColors colors, DateTime day) {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = DateUtils.dateOnly(day);
    final selected = _date != null && DateUtils.isSameDay(_date!, date);
    final past = date.isBefore(today);
    final open = !past && _dayOpen(date);
    final color = selected
        ? Colors.white
        : open
            ? colors.ink
            : colors.dis;
    return Material(
      color: selected ? colors.mentaD : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: open
            ? () => setState(() {
                  _date = date;
                  _picked.clear();
                })
            : null,
        borderRadius: BorderRadius.circular(11),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: color,
              decoration: !past && !open ? TextDecoration.lineThrough : null,
              decorationColor: colors.dis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeStep(_ReservaColors colors, AppLang lang) {
    final start = _start;
    final minHours = _service == null ? 2 : _minHoursOf(_service!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(colors, lang, rt(lang, 'timeTitle'), rt(lang, 'timeSub')),
        _label(colors, rt(lang, 'startLabel')),
        Material(
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(color: colors.line, width: 1.5),
          ),
          child: InkWell(
            onTap: () => _pickTime(lang, colors),
            borderRadius: BorderRadius.circular(13),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      start ?? rt(lang, 'pickTime'),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: start == null ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 16,
                        color: start == null ? colors.text2 : colors.ink,
                      ),
                    ),
                  ),
                  Icon(Icons.schedule, color: colors.mentaD, size: 20),
                ],
              ),
            ),
          ),
        ),
        _label(colors, rt(lang, 'duration')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _smallButton(colors, '−', _duration > minHours ? () => setState(() => _duration -= 1) : null),
              SizedBox(
                width: 120,
                child: Text(
                  rt(lang, 'hours', {'n': '$_duration'}),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.ink),
                ),
              ),
              _smallButton(colors, '+', _duration < 12 ? () => setState(() => _duration += 1) : null),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _boldPiece(colors, rt(lang, 'minNote', {'n': '$minHours'}), '$minHours h', colors.brun, size: 13),
        if (start != null) ...[
          const SizedBox(height: 8),
          _boldPiece(colors, rt(lang, 'endNote', {'time': _endClock(start, _duration), 'n': '$_duration'}), _endClock(start, _duration), colors.ink, size: 13.5),
        ],
      ],
    );
  }

  Widget _cangurStep(_ReservaColors colors, AppLang lang, AppState state) {
    final carers = _carers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          colors,
          lang,
          _isEvent ? rt(lang, 'cangurTitleEvent') : rt(lang, 'cangurTitle'),
          _isEvent ? rt(lang, 'cangurSubEvent', {'n': '$carers'}) : rt(lang, 'cangurSub'),
        ),
        if (carers > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              rt(lang, 'selectedCount', {'a': '${_picked.length}', 'b': '$carers'}),
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: colors.mentaD),
            ),
          ),
        for (final entry in _orderedCanguros(state).indexed) _cangurCard(colors, entry.$2, entry.$1),
      ],
    );
  }

  Widget _cangurAvatar(CangurProfile profile, int index) {
    final color = _avatarColors[index % _avatarColors.length];
    final letter = profile.nombre.isEmpty ? '?' : profile.nombre.substring(0, 1).toUpperCase();
    final fallback = ColoredBox(
      color: color,
      child: Center(
        child: Text(letter, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
      ),
    );
    final photo = profile.photoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 48,
        height: 48,
        child: photo == null ? fallback : Image.network(photo, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
      ),
    );
  }

  Widget _cangurCard(_ReservaColors colors, CangurProfile profile, int index) {
    final open = _cangurOpen(profile);
    final selected = _picked.contains(profile.userId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Opacity(
        opacity: open ? 1 : 0.5,
        child: Material(
          color: selected ? colors.menta15 : colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? colors.mentaD : colors.line, width: 1.5),
          ),
          child: InkWell(
            onTap: open ? () => _toggleCangur(profile) : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  _cangurAvatar(profile, index),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.nombre, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink)),
                        const SizedBox(height: 1),
                        Text(profile.descripcionPersonal, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            for (final language in profile.idiomas)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(999)),
                                child: Text(_langChip(language), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 10.5, color: colors.text)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (open)
                    _mark(colors, selected, round: true)
                  else
                    Text(rt(AppScope.of(context).lang, 'unavailable'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, color: colors.text2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressStep(_ReservaColors colors, AppLang lang, AppState state) {
    final profile = state.user?.direccion.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(colors, lang, rt(lang, 'addrTitle'), rt(lang, 'addrSub')),
        _addressCard(
          colors,
          title: rt(lang, 'profileAddr'),
          detail: profile.isEmpty ? rt(lang, 'noProfileAddr') : profile,
          selected: _profileAddress,
          onTap: () => setState(() => _profileAddress = true),
        ),
        _addressCard(
          colors,
          title: rt(lang, 'otherAddr'),
          detail: rt(lang, 'otherAddrSub'),
          selected: !_profileAddress,
          onTap: () => setState(() => _profileAddress = false),
          child: _profileAddress
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: _otherAddress,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
                    decoration: InputDecoration(
                      hintText: rt(lang, 'addrHint'),
                      filled: true,
                      fillColor: colors.card,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.line, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.menta, width: 1.5)),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _addressCard(
    _ReservaColors colors, {
    required String title,
    required String detail,
    required bool selected,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: selected ? colors.menta15 : colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? colors.mentaD : colors.line, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mark(colors, selected, round: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink)),
                      const SizedBox(height: 2),
                      Text(detail, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                      if (child != null) child,
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

  Widget _summaryStep(_ReservaColors colors, AppLang lang, {bool celebrate = false}) {
    final service = _service;
    final start = _start;
    final date = _date;
    if (service == null) return const SizedBox.shrink();
    final quote = _quote(service);
    final igi = service.igi == service.igi.roundToDouble() ? '${service.igi.round()}' : service.igi.toStringAsFixed(1).replaceAll('.', lang == AppLang.en ? '.' : ',');
    final names = <String>[];
    for (final id in _picked) {
      for (final profile in AppScope.of(context).canguros) {
        if (profile.userId == id) names.add(profile.nombre);
      }
    }
    final dayText = date == null
        ? '—'
        : '${reservaDayShort[lang.index][date.weekday - 1]} ${date.day} ${reservaMonths[lang.index][date.month - 1]}';
    final timeText = start == null ? '—' : '$start – ${_endClock(start, _duration)}';
    final kids = _children == 1 ? rt(lang, 'infant', {'n': '$_children'}) : rt(lang, 'infants', {'n': '$_children'});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!celebrate && _payError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_payError!, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: colors.brun)),
          ),
        if (!celebrate) _heading(colors, lang, rt(lang, 'summaryTitle'), rt(lang, 'summarySub')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.line, width: 1.5),
          ),
          child: Column(
            children: [
              _summaryRow(colors, rt(lang, 'service'), _serviceTitle(lang, service), line: true),
              _summaryRow(colors, names.length > 1 ? rt(lang, 'cangurs') : rt(lang, 'cangur'), names.isEmpty ? '—' : names.join(', '), line: true),
              _summaryRow(colors, rt(lang, 'day'), dayText, line: true),
              _summaryRow(colors, rt(lang, 'time'), timeText, line: true),
              _summaryRow(colors, rt(lang, 'children'), kids, line: true),
              if (_isEvent) _summaryRow(colors, rt(lang, 'ages'), rt(lang, 'agesValue', {'from': '$_ageFrom', 'to': '$_ageTo'}), line: true),
              _summaryRow(colors, rt(lang, 'address'), _addressLine(lang), line: celebrate),
              if (celebrate) _summaryRow(colors, rt(lang, 'paid'), _money(quote.total), line: false),
            ],
          ),
        ),
        if (!celebrate) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _priceLine(colors, rt(lang, 'rateLine', {'rate': _wholeEuro(quote.hourly), 'hours': '$_duration'}), _money(quote.base)),
              if (quote.night > 0) _priceLine(colors, rt(lang, 'night'), _money(quote.night)),
              if (_isEvent && _facePaint) _priceLine(colors, rt(lang, 'facePaint'), _money(30)),
              if (_isEvent && _decor) _priceLine(colors, rt(lang, 'decor'), _money(150)),
              const SizedBox(height: 10),
              Container(height: 1, color: colors.line),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(rt(lang, 'total'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink))),
                  Text(_money(quote.total), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(rt(lang, 'igi', {'n': igi}), style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2)),
              ),
              if (_isEvent) ...[
                const SizedBox(height: 10),
                Text('⚠️ ${rt(lang, 'eventExtra')}', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, height: 1.5, color: colors.brun)),
              ],
            ],
          ),
        ),
        ],
      ],
    );
  }

  Widget _summaryRow(_ReservaColors colors, String label, String value, {required bool line}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: line ? Border(bottom: BorderSide(color: colors.line)) : null),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 13.5, color: colors.text2))),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink))),
        ],
      ),
    );
  }

  Widget _priceLine(_ReservaColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: colors.text2))),
          Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: colors.ink)),
        ],
      ),
    );
  }

  Widget _foot(_ReservaColors colors, AppLang lang) {
    final last = _step == 7;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.bg.withValues(alpha: 0), colors.bg, colors.bg],
          stops: const [0, 0.26, 1],
        ),
      ),
      child: Row(
        children: [
          if (_step > 1) ...[
            OutlinedButton(
              onPressed: () => _go(_step - 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text2,
                side: BorderSide(color: colors.line, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(rt(lang, 'back'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.mentaD.withValues(alpha: _canContinue ? 1 : 0.45),
                borderRadius: BorderRadius.circular(15),
                boxShadow: _canContinue ? [BoxShadow(color: colors.mentaD.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))] : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: !_canContinue || _saving
                      ? null
                      : () {
                          if (last) {
                            _confirmBooking();
                          } else {
                            _go(_step + 1);
                          }
                        },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      last ? rt(lang, 'pay') : rt(lang, 'continue'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payView(_ReservaColors colors, AppLang lang) {
    final booking = _payBooking;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Text(
          rt(lang, 'payTitle'),
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 23, height: 1.2, color: colors.ink),
        ),
        const SizedBox(height: 6),
        Text(rt(lang, 'paySub'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14, height: 1.5, color: colors.text2)),
        const SizedBox(height: 18),
        if (booking?.total != null)
          Text(_money(booking!.total!), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 28, color: colors.ink)),
        if (_payError != null) ...[
          const SizedBox(height: 12),
          Text(_payError!, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, height: 1.4, color: colors.brun)),
        ],
        if (_confirming || _saving) ...[
          const SizedBox(height: 12),
          Text(
            rt(lang, _confirming ? 'payConfirming' : 'payWaiting'),
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: colors.mentaD),
          ),
        ],
        const SizedBox(height: 18),
        _payChoice(
          label: rt(lang, 'bizum'),
          color: const Color(0xFF05C0C7),
          onTap: _saving || _confirming ? null : _startPay,
        ),
        const SizedBox(height: 11),
        _payChoice(
          label: rt(lang, 'card'),
          color: colors.mentaD,
          onTap: _saving || _confirming ? null : _startPay,
        ),
      ],
    );
  }

  Widget _payChoice({required String label, required Color color, required VoidCallback? onTap}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: onTap == null ? 0.45 : 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _doneView(_ReservaColors colors, AppLang lang) {
    final service = _service;
    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 48, 30, 32),
      children: [
        Center(
          child: Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFB3CFC4), shape: BoxShape.circle),
            child: const Text('🎉', style: TextStyle(fontSize: 44)),
          ),
        ),
        const SizedBox(height: 22),
        Text(rt(lang, 'doneTitle'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 25, color: colors.ink)),
        const SizedBox(height: 10),
        Text(rt(lang, 'doneBody'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.6, color: colors.text2)),
        const SizedBox(height: 20),
        if (service != null) _summaryStep(colors, lang, celebrate: true),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.text2,
              side: BorderSide(color: colors.line, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(rt(lang, 'home'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _boldPiece(_ReservaColors colors, String full, String piece, Color emphasis, {required double size}) {
    final style = TextStyle(fontFamily: 'Nunito', fontSize: size, color: colors.text2);
    final index = full.indexOf(piece);
    if (index < 0) return Text(full, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: full.substring(0, index)),
          TextSpan(text: piece, style: TextStyle(fontWeight: FontWeight.w800, color: emphasis)),
          TextSpan(text: full.substring(index + piece.length)),
        ],
      ),
    );
  }

  Widget _label(_ReservaColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(text, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: colors.ink)),
    );
  }

  Widget _mark(_ReservaColors colors, bool on, {required bool round}) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? colors.mentaD : Colors.transparent,
        borderRadius: BorderRadius.circular(round ? 11 : 7),
        border: Border.all(color: on ? colors.mentaD : colors.line, width: 2),
      ),
      child: on ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }

  Widget _roundButton(_ReservaColors colors, String label, VoidCallback? onPressed) {
    return Material(
      color: colors.menta15,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 28, color: colors.ink))),
        ),
      ),
    );
  }

  Widget _smallButton(_ReservaColors colors, String label, VoidCallback? onPressed) {
    return Material(
      color: colors.menta15,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, color: colors.ink))),
        ),
      ),
    );
  }

  Widget _navButton(_ReservaColors colors, IconData icon, VoidCallback onPressed) {
    return Material(
      color: colors.menta15,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 34, height: 34, child: Icon(icon, size: 18, color: colors.ink)),
      ),
    );
  }
}

class _Quote {
  const _Quote({required this.hourly, required this.base, required this.night, required this.total});

  final double hourly;
  final double base;
  final double night;
  final double total;
}

class _TimeSheet extends StatefulWidget {
  const _TimeSheet({required this.colors, required this.title, required this.confirm, required this.hour, required this.minute});

  final _ReservaColors colors;
  final String title;
  final String confirm;
  final int hour;
  final int minute;

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late final FixedExtentScrollController _hours = FixedExtentScrollController(initialItem: widget.hour);
  late final FixedExtentScrollController _minuteWheel = FixedExtentScrollController(initialItem: widget.minute);
  late int _hour = widget.hour;
  late int _minute = widget.minute;

  @override
  void dispose() {
    _hours.dispose();
    _minuteWheel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: colors.line, borderRadius: BorderRadius.circular(999))),
            const SizedBox(height: 10),
            Text(widget.title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink)),
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 88,
                    height: 44,
                    child: DecoratedBox(decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(12))),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _wheel(colors, _hours, 24, (index) => index.toString().padLeft(2, '0'), _hour, (index) => setState(() => _hour = index)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(':', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, color: colors.ink)),
                      ),
                      _wheel(colors, _minuteWheel, _minutes.length, (index) => _minutes[index], _minute, (index) => setState(() => _minute = index)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, '${_hour.toString().padLeft(2, '0')}:${_minutes[_minute]}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.mentaD,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(widget.confirm, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wheel(_ReservaColors colors, FixedExtentScrollController controller, int count, String Function(int) label, int selected, ValueChanged<int> onChanged) {
    return SizedBox(
      width: 84,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 44,
        perspective: 0.003,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) {
            return Center(
              child: Text(
                label(index),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: index == selected ? colors.ink : colors.text2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReservaColors {
  const _ReservaColors({
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
    required this.dis,
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
  final Color dis;
  final Color shadow;

  static const light = _ReservaColors(
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
    dis: Color(0xFFC9C3BA),
    shadow: Color(0x0D000000),
  );

  static const dark = _ReservaColors(
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
    dis: Color(0xFF4A463F),
    shadow: Color(0x66000000),
  );

  static _ReservaColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

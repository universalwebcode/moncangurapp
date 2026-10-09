import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/event_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({required this.service, super.key});

  final ServiceOffer service;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  static const _total = 8;

  final _scroll = ScrollController();
  final _notes = TextEditingController();
  final _otherAddress = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  int _step = 1;
  final Set<String> _types = {};
  final Set<String> _extras = {};
  DateTime? _date;
  String _from = '17:00';
  String _until = '20:00';
  int _babies = 0;
  int _children = 0;
  bool _profileAddress = true;
  String _savedAddress = '';
  bool _profileFilled = false;
  bool _sending = false;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileFilled) return;
    _profileFilled = true;
    final account = AppScope.of(context).user;
    if (account == null) return;
    _name.text = account.nombre;
    _phone.text = account.telefono;
    _email.text = account.email;
    _savedAddress = account.direccion;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _notes.dispose();
    _otherAddress.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  String get _address => _profileAddress ? _savedAddress.trim() : _otherAddress.text.trim();

  bool get _canContinue {
    switch (_step) {
      case 1:
        return _types.isNotEmpty;
      case 2:
        return _date != null && eventSlots.indexOf(_until) > eventSlots.indexOf(_from);
      case 6:
        return _address.isNotEmpty;
      case 7:
        return _name.text.trim().isNotEmpty && _phone.text.trim().isNotEmpty && _email.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _go(int step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _next(AppLang lang) async {
    if (!_canContinue || _sending) return;
    if (_step < _total) {
      _go(_step + 1);
      return;
    }
    setState(() => _sending = true);
    final ok = await AppScope.of(context).submitFixRequest(
      service: widget.service,
      startDate: _date!,
      start: _from,
      end: _until,
      children: _babies + _children,
      resumen: _summary(lang),
      direccion: _address,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) _done = true;
    });
  }

  String _summary(AppLang lang) {
    final lines = <String>[
      _types.map((key) => ev(lang, key)).join(', '),
      '${formatDate(_date!)} · $_from – $_until',
      '${ev(lang, 'babies')} $_babies · ${babyTariff(lang, _babies)}',
      '${ev(lang, 'kids')} $_children · ${childTariff(lang, _children)}',
    ];
    if (_extras.isNotEmpty) lines.add(_extras.map((key) => ev(lang, key)).join(', '));
    if (_notes.text.trim().isNotEmpty) lines.add(_notes.text.trim());
    lines.add(_address);
    lines.add('${_name.text.trim()} · ${_phone.text.trim()} · ${_email.text.trim()}');
    return lines.join('\n');
  }

  void _changeCount(bool babies, int delta) {
    setState(() {
      if (babies) {
        final next = _babies + delta;
        _babies = next < 0 ? 0 : (next > 9 ? 9 : next);
      } else {
        final next = _children + delta;
        _children = next < 0 ? 0 : (next > 21 ? 21 : next);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).lang;
    final colors = _EventColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _done ? _doneView(colors, lang) : _wizard(colors, lang),
          ),
        ),
      ),
    );
  }

  Widget _wizard(_EventColors colors, AppLang lang) {
    return Column(
      children: [
        Container(
          height: 6,
          color: colors.menta15,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(widthFactor: _step / _total, child: Container(color: colors.mentaD)),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: colors.menta15,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(11),
                    child: SizedBox(width: 38, height: 38, child: Icon(Icons.chevron_left, color: colors.ink)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ev(lang, 'eyebrow', {'n': '$_step', 'label': ev(lang, 's$_step')}).toUpperCase(),
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 1.4, color: colors.mentaD),
              ),
              const SizedBox(height: 14),
              Text(ev(lang, 'h$_step'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, height: 1.18, color: colors.ink)),
              const SizedBox(height: 8),
              Text(ev(lang, 'sub$_step'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2)),
              const SizedBox(height: 26),
              _stepBody(colors, lang),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
          child: Row(
            children: [
              if (_step > 1) ...[
                OutlinedButton(
                  onPressed: _sending ? null : () => _go(_step - 1),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text2,
                    side: BorderSide(color: colors.line, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  child: Text(ev(lang, 'back')),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: _canContinue && !_sending ? () => _next(lang) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.mentaD,
                    disabledBackgroundColor: colors.mentaD.withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  child: _sending
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                      : Text(_step == _total ? ev(lang, 'send') : ev(lang, 'continue')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBody(_EventColors colors, AppLang lang) {
    switch (_step) {
      case 1:
        return _chips(colors, lang);
      case 2:
        return _when(colors, lang);
      case 3:
        return _counts(colors, lang);
      case 4:
        return _activities(colors, lang);
      case 5:
        return _field(colors, _notes, hint: ev(lang, 'notesHint'), lines: 6);
      case 6:
        return _addressStep(colors, lang);
      case 7:
        return _contact(colors, lang);
      default:
        return _ready(colors, lang);
    }
  }

  Widget _chips(_EventColors colors, AppLang lang) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final key in eventTypes)
          _chip(colors, ev(lang, key), _types.contains(key), () {
            setState(() {
              if (_types.contains(key)) {
                _types.remove(key);
              } else {
                _types.add(key);
              }
            });
          }),
      ],
    );
  }

  Widget _chip(_EventColors colors, String label, bool on, VoidCallback onTap) {
    return Material(
      color: on ? colors.menta : colors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: on ? const Color(0xFF2C3A33) : colors.text)),
        ),
      ),
    );
  }

  Widget _when(_EventColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ev(lang, 'date'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.ink)),
        const SizedBox(height: 8),
        Material(
          color: colors.card,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            key: const Key('event-date'),
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: colors.line, width: 1.5)),
              child: Text(
                _date == null ? ev(lang, 'pickDate') : formatDate(_date!),
                style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, color: _date == null ? colors.text2 : colors.ink),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(ev(lang, 'slot'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.ink)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _timeMenu(colors, ev(lang, 'from'), _from, (value) => setState(() => _from = value))),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 13),
              child: Text('–', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.text2)),
            ),
            Expanded(child: _timeMenu(colors, ev(lang, 'until'), _until, (value) => setState(() => _until = value))),
          ],
        ),
        const SizedBox(height: 14),
        _note(colors, '🌙', ev(lang, 'nightNote')),
      ],
    );
  }

  Widget _counts(_EventColors colors, AppLang lang) {
    return Column(
      children: [
        _counter(colors, title: ev(lang, 'babies'), detail: ev(lang, 'babiesSub'), tariff: babyTariff(lang, _babies), value: _babies, onMinus: () => _changeCount(true, -1), onPlus: () => _changeCount(true, 1)),
        const SizedBox(height: 12),
        _counter(colors, title: ev(lang, 'kids'), detail: ev(lang, 'kidsSub'), tariff: childTariff(lang, _children), value: _children, onMinus: () => _changeCount(false, -1), onPlus: () => _changeCount(false, 1)),
        const SizedBox(height: 14),
        _note(colors, '🔎', ev(lang, 'countNote')),
      ],
    );
  }

  Widget _counter(
    _EventColors colors, {
    required String title,
    required String detail,
    required String tariff,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.line, width: 1.5)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(detail, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                  ],
                ),
              ),
              Text(tariff, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.brun)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _round(colors, '−', onMinus),
              SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, color: colors.ink))),
              _round(colors, '+', onPlus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _round(_EventColors colors, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: colors.menta15,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 42, height: 42, child: Center(child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, color: colors.ink)))),
        ),
      ),
    );
  }

  Widget _activities(_EventColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ev(lang, 'activitiesLabel'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.mentaD)),
        const SizedBox(height: 8),
        for (final key in eventActivities)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _option(colors, title: ev(lang, key), detail: ev(lang, '${key}Sub'), price: ev(lang, 'perHour'), on: _extras.contains(key), onTap: () => _toggle(key)),
          ),
        const SizedBox(height: 8),
        Text(ev(lang, 'decoLabel'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.mentaD)),
        const SizedBox(height: 8),
        _option(colors, title: ev(lang, 'deco'), detail: ev(lang, 'decoSub'), price: ev(lang, 'decoPrice'), on: _extras.contains('deco'), onTap: () => _toggle('deco')),
        const SizedBox(height: 14),
        _note(colors, '🗓️', ev(lang, 'decoNote')),
      ],
    );
  }

  void _toggle(String key) {
    setState(() {
      if (_extras.contains(key)) {
        _extras.remove(key);
      } else {
        _extras.add(key);
      }
    });
  }

  Widget _option(_EventColors colors, {required String title, required String detail, required String price, required bool on, required VoidCallback onTap}) {
    return Material(
      color: on ? colors.menta15 : colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: on ? colors.mentaD : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
                child: on ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(detail, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, height: 1.35, color: colors.text2)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(price, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12.5, color: colors.brun)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressStep(_EventColors colors, AppLang lang) {
    return Column(
      children: [
        _addressCard(colors, title: ev(lang, 'addrProfile'), detail: _savedAddress, on: _profileAddress, onTap: () => setState(() => _profileAddress = true)),
        const SizedBox(height: 11),
        _addressCard(
          colors,
          title: ev(lang, 'addrOther'),
          detail: ev(lang, 'addrOtherSub'),
          on: !_profileAddress,
          onTap: () => setState(() => _profileAddress = false),
          extra: _profileAddress ? null : Padding(padding: const EdgeInsets.only(top: 12), child: _field(colors, _otherAddress, hint: ev(lang, 'addrHint'))),
        ),
      ],
    );
  }

  Widget _addressCard(_EventColors colors, {required String title, required String detail, required bool on, required VoidCallback onTap, Widget? extra}) {
    return Material(
      color: on ? colors.menta15 : colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(color: on ? colors.mentaD : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
                child: on ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink)),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(detail, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                    ],
                    ?extra,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contact(_EventColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('📇  ${ev(lang, 'fromProfile')}', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.mentaD)),
        const SizedBox(height: 14),
        _labeled(colors, ev(lang, 'name'), _name),
        const SizedBox(height: 16),
        _labeled(colors, ev(lang, 'phone'), _phone, phone: true),
        const SizedBox(height: 16),
        _labeled(colors, ev(lang, 'email'), _email, email: true),
      ],
    );
  }

  Widget _ready(_EventColors colors, AppLang lang) {
    return _note(colors, '🔎', ev(lang, 'replyBody'), title: ev(lang, 'replyTitle'));
  }

  Widget _doneView(_EventColors colors, AppLang lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 40, 34, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFB3CFC4), shape: BoxShape.circle),
            child: const Text('✨', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 24),
          Text(ev(lang, 'doneTitle'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 26, color: colors.ink)),
          const SizedBox(height: 12),
          Text(ev(lang, 'doneBody'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 15, height: 1.6, color: colors.text2)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.text2,
              side: BorderSide(color: colors.line, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
            ),
            child: Text(ev(lang, 'home')),
          ),
        ],
      ),
    );
  }

  Widget _note(_EventColors colors, String emoji, String body, {String? title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink)),
                  const SizedBox(height: 3),
                ],
                Text(body, style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.5, color: colors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeled(_EventColors colors, String label, TextEditingController controller, {bool phone = false, bool email = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.ink)),
        const SizedBox(height: 8),
        _field(colors, controller, phone: phone, email: email),
      ],
    );
  }

  Widget _field(_EventColors colors, TextEditingController controller, {String? hint, int lines = 1, bool phone = false, bool email = false}) {
    return TextField(
      controller: controller,
      minLines: lines,
      maxLines: lines,
      keyboardType: phone ? TextInputType.phone : (email ? TextInputType.emailAddress : TextInputType.text),
      inputFormatters: phone ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))] : null,
      style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, color: colors.ink),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.line, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.mentaD, width: 1.6)),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _timeMenu(_EventColors colors, String caption, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: colors.line, width: 1.5)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(13),
              dropdownColor: colors.card,
              style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, color: colors.ink),
              items: [for (final slot in eventSlots) DropdownMenuItem(value: slot, child: Text(slot))],
              onChanged: (next) {
                if (next != null) onChanged(next);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EventColors {
  const _EventColors({
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

  static const light = _EventColors(
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
  );

  static const dark = _EventColors(
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
  );

  static _EventColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

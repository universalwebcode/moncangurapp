import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/fix_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

class FixFormScreen extends StatefulWidget {
  const FixFormScreen({required this.service, super.key});

  final ServiceOffer service;

  @override
  State<FixFormScreen> createState() => _FixFormScreenState();
}

class _FixFormScreenState extends State<FixFormScreen> {
  static const _total = 8;

  final _scroll = ScrollController();
  final _other = TextEditingController();
  final _notes = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final List<TextEditingController> _ages = [TextEditingController()];

  int _step = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _indefinite = false;
  final Set<String> _days = {};
  int _startMin = 9 * 60;
  int _endMin = 13 * 60;
  final Set<String> _support = {};
  int _children = 1;
  final Set<String> _needs = {};
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
  }

  @override
  void dispose() {
    _scroll.dispose();
    _other.dispose();
    _notes.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    for (final age in _ages) {
      age.dispose();
    }
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 1:
        if (_startDate == null) return false;
        if (!_indefinite && _endDate != null && _endDate!.isBefore(_startDate!)) return false;
        return true;
      case 2:
        return _days.isNotEmpty && _endMin > _startMin;
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

  Future<void> _next(AppLang lang) async {
    if (!_canContinue || _sending) return;
    if (_step < _total) {
      _go(_step + 1);
      return;
    }
    final start = _startDate;
    if (start == null) return;
    setState(() => _sending = true);
    final ok = await AppScope.of(context).submitFixRequest(
      service: widget.service,
      startDate: start,
      start: _clock(_startMin),
      end: _clock(_endMin),
      children: _children,
      resumen: _summary(lang),
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) _done = true;
    });
  }

  String _summary(AppLang lang) {
    final lines = <String>[
      '${fx(lang, 'start')}: ${formatDate(_startDate!)}',
      if (_indefinite) fx(lang, 'indef') else if (_endDate != null) '${fx(lang, 'end')}: ${formatDate(_endDate!)}',
      '${fx(lang, 'days')}: ${_days.map((key) => fx(lang, key)).join(', ')}',
      '${_clock(_startMin)} – ${_clock(_endMin)} · ${_duration()}',
      if (_support.isNotEmpty) _support.map((key) => fx(lang, key)).join(', '),
      fx(lang, _children == 1 ? 'infant' : 'infants', {'n': '$_children'}),
    ];
    final ages = <String>[];
    for (var i = 0; i < _ages.length; i++) {
      final value = _ages[i].text.trim();
      if (value.isNotEmpty) ages.add('${i + 1}: $value');
    }
    if (ages.isNotEmpty) lines.add(ages.join(', '));
    if (_needs.isNotEmpty) lines.add(_needs.map((key) => fx(lang, key)).join(', '));
    if (_other.text.trim().isNotEmpty) lines.add(_other.text.trim());
    if (_notes.text.trim().isNotEmpty) lines.add(_notes.text.trim());
    lines.add('${_name.text.trim()} · ${_phone.text.trim()} · ${_email.text.trim()}');
    return lines.join('\n');
  }

  void _setChildren(int count) {
    setState(() {
      _children = count;
      while (_ages.length < count) {
        _ages.add(TextEditingController());
      }
      while (_ages.length > count) {
        _ages.removeLast().dispose();
      }
    });
  }

  void _shift(bool start, int delta) {
    setState(() {
      if (start) {
        _startMin = (_startMin + delta).clamp(0, 1439);
      } else {
        _endMin = (_endMin + delta).clamp(0, 1439);
      }
    });
  }

  String _clock(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _duration() {
    var span = _endMin - _startMin;
    if (span < 0) span = 0;
    final hours = span ~/ 60;
    final minutes = span % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }

  Future<void> _pickDate({required bool start, required _FixColors colors}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = start ? (_startDate ?? today) : (_endDate ?? _startDate ?? today);
    final first = start ? today : (_startDate ?? today);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: today.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: colors.mentaD, onPrimary: Colors.white, surface: colors.card),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      final day = DateTime(picked.year, picked.month, picked.day);
      if (start) {
        _startDate = day;
        if (_endDate != null && _endDate!.isBefore(day)) _endDate = null;
      } else {
        _endDate = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _FixColors.of(context);
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

  Widget _wizard(_FixColors colors, AppLang lang) {
    return Column(
      children: [
        Container(height: 6, color: colors.menta15, alignment: Alignment.centerLeft, child: FractionallySizedBox(
          widthFactor: _step / _total,
          child: Container(color: colors.mentaD),
        )),
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
                fx(lang, 'eyebrow', {'n': '$_step', 'label': fx(lang, 's$_step')}),
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 1.4, color: colors.mentaD),
              ),
              const SizedBox(height: 14),
              Text(
                fx(lang, 'h$_step'),
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, height: 1.18, color: colors.ink),
              ),
              const SizedBox(height: 8),
              Text(fx(lang, 'sub$_step'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2)),
              const SizedBox(height: 26),
              _stepBody(colors, lang),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [colors.bg.withValues(alpha: 0), colors.bg, colors.bg]),
          ),
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
                  child: Text(fx(lang, 'back')),
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
                      : Text(_step == _total ? fx(lang, 'send') : fx(lang, 'continue')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBody(_FixColors colors, AppLang lang) {
    switch (_step) {
      case 1:
        return _dates(colors, lang);
      case 2:
        return _schedule(colors, lang);
      case 3:
        return _chipsBlock(colors, lang, fixSupport, _support, note: fx(lang, 'extraNote'));
      case 4:
        return _childrenStep(colors, lang);
      case 5:
        return _chipsBlock(colors, lang, fixNeeds, _needs, extra: _field(colors, fx(lang, 'otherReq'), _other, hint: fx(lang, 'otherHint'), lines: 4));
      case 6:
        return _field(colors, '', _notes, hint: fx(lang, 'notesHint'), lines: 6);
      case 7:
        return _contact(colors, lang);
      default:
        return _ready(colors, lang);
    }
  }

  Widget _dates(_FixColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _dateField(colors, fx(lang, 'start'), _startDate, fx(lang, 'pickDate'), () => _pickDate(start: true, colors: colors)),
        const SizedBox(height: 20),
        _dateField(
          colors,
          fx(lang, 'end'),
          _endDate,
          fx(lang, 'pickDate'),
          _indefinite ? null : () => _pickDate(start: false, colors: colors),
        ),
        const SizedBox(height: 8),
        _checkCard(
          colors,
          title: fx(lang, 'indef'),
          detail: fx(lang, 'indefSub'),
          on: _indefinite,
          onTap: () => setState(() {
            _indefinite = !_indefinite;
            if (_indefinite) _endDate = null;
          }),
        ),
      ],
    );
  }

  Widget _schedule(_FixColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(colors, fx(lang, 'days')),
        const SizedBox(height: 8),
        _chipWrap(colors, lang, fixDays, _days),
        const SizedBox(height: 22),
        _label(colors, fx(lang, 'slot')),
        const SizedBox(height: 4),
        Text(
          '${_clock(_startMin)} – ${_clock(_endMin)} · ${_duration()}',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, color: colors.mentaD),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _timeColumn(colors, lang, fx(lang, 'startHour'), _startMin, true)),
            const SizedBox(width: 14),
            Expanded(child: _timeColumn(colors, lang, fx(lang, 'endHour'), _endMin, false)),
          ],
        ),
      ],
    );
  }

  Widget _timeColumn(_FixColors colors, AppLang lang, String caption, int minutes, bool start) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.line, width: 1.5)),
          child: Row(
            children: [
              Column(
                children: [
                  _stepButton(colors, '▲', () => _shift(start, 30)),
                  const SizedBox(height: 5),
                  _stepButton(colors, '▼', () => _shift(start, -30)),
                ],
              ),
              Expanded(
                child: Text(
                  _clock(minutes),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 21, color: colors.ink),
                ),
              ),
              Column(
                children: [
                  _stepButton(colors, "+1'", () => _shift(start, 1)),
                  const SizedBox(height: 5),
                  _stepButton(colors, "-1'", () => _shift(start, -1)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepButton(_FixColors colors, String label, VoidCallback onTap) {
    return Material(
      color: colors.menta15,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 38,
          height: 30,
          child: Center(child: Text(label, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF2C3A33)))),
        ),
      ),
    );
  }

  Widget _childrenStep(_FixColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          fx(lang, _children == 1 ? 'infant' : 'infants', {'n': '$_children'}),
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, color: colors.mentaD),
        ),
        Slider(
          value: _children.toDouble(),
          min: 1,
          max: 6,
          divisions: 5,
          activeColor: colors.mentaD,
          inactiveColor: colors.menta15,
          onChanged: (value) => _setChildren(value.round()),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _ages.length; i++) ...[
          _field(
            colors,
            fx(lang, 'age', {'n': '${i + 1}'}),
            _ages[i],
            hint: fx(lang, 'years'),
            number: true,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _chipsBlock(_FixColors colors, AppLang lang, List<String> keys, Set<String> selected, {String? note, Widget? extra}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _chipWrap(colors, lang, keys, selected),
        if (note != null) ...[
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 11),
                Expanded(child: Text(note, style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.55, color: colors.text))),
              ],
            ),
          ),
        ],
        if (extra != null) ...[const SizedBox(height: 20), extra],
      ],
    );
  }

  Widget _chipWrap(_FixColors colors, AppLang lang, List<String> keys, Set<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final key in keys) _chip(colors, lang, key, selected)],
    );
  }

  Widget _chip(_FixColors colors, AppLang lang, String key, Set<String> selected) {
    final on = selected.contains(key);
    return Material(
      color: on ? colors.menta : colors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => setState(() {
          if (on) {
            selected.remove(key);
          } else {
            selected.add(key);
          }
        }),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5),
          ),
          child: Text(
            fx(lang, key),
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: on ? const Color(0xFF2C3A33) : colors.text),
          ),
        ),
      ),
    );
  }

  Widget _contact(_FixColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('📇', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(fx(lang, 'fromProfile'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.mentaD)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _field(colors, fx(lang, 'name'), _name),
        const SizedBox(height: 16),
        _field(colors, fx(lang, 'phone'), _phone, phone: true),
        const SizedBox(height: 16),
        _field(colors, fx(lang, 'email'), _email, email: true),
      ],
    );
  }

  Widget _ready(_FixColors colors, AppLang lang) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔎', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fx(lang, 'replyTitle'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink)),
                const SizedBox(height: 3),
                Text(fx(lang, 'replyBody'), style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.5, color: colors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doneView(_FixColors colors, AppLang lang) {
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
            child: const Text('🌿', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 24),
          Text(fx(lang, 'doneTitle'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 26, color: colors.ink)),
          const SizedBox(height: 12),
          Text(fx(lang, 'doneBody'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 15, height: 1.6, color: colors.text2)),
          const SizedBox(height: 28),
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(fx(lang, 'home'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.mentaD)),
          ),
        ],
      ),
    );
  }

  Widget _dateField(_FixColors colors, String label, DateTime? value, String hint, VoidCallback? onTap) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(colors, label),
          const SizedBox(height: 8),
          Material(
            color: colors.card,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: colors.line, width: 1.5),
                ),
                child: Text(
                  value == null ? hint : formatDate(value),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5,
                    color: value == null ? colors.text2.withValues(alpha: 0.7) : colors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    _FixColors colors,
    String label,
    TextEditingController controller, {
    String? hint,
    int lines = 1,
    bool number = false,
    bool phone = false,
    bool email = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _label(colors, label),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          minLines: lines,
          maxLines: lines,
          keyboardType: number
              ? TextInputType.number
              : phone
                  ? TextInputType.phone
                  : email
                      ? TextInputType.emailAddress
                      : TextInputType.text,
          inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)] : null,
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, color: colors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Nunito', color: colors.text2.withValues(alpha: 0.7)),
            filled: true,
            fillColor: colors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.line, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.menta, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _checkCard(_FixColors colors, {required String title, required String detail, required bool on, required VoidCallback onTap}) {
    return Material(
      color: on ? colors.menta15 : colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? colors.mentaD : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: on ? colors.mentaD : colors.line, width: 2),
                ),
                child: on ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(detail, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, height: 1.4, color: colors.text2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(_FixColors colors, String text) {
    return Text(text, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.ink));
  }
}

class _FixColors {
  const _FixColors({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.menta15,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
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

  static const light = _FixColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
  );

  static const dark = _FixColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
  );

  static _FixColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

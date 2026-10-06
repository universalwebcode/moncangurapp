import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/extra_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

class ExtraFormScreen extends StatefulWidget {
  const ExtraFormScreen({required this.service, super.key});

  final ServiceOffer service;

  @override
  State<ExtraFormScreen> createState() => _ExtraFormScreenState();
}

class _ExtraFormScreenState extends State<ExtraFormScreen> {
  static const _total = 8;

  final _scroll = ScrollController();
  final _notes = TextEditingController();
  final _otherAddress = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final List<TextEditingController> _ages = [TextEditingController()];

  int _step = 1;
  final Set<String> _activities = {};
  final Set<String> _days = {};
  String _from = '17:00';
  String _until = '18:00';
  int _children = 1;
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
    for (final age in _ages) {
      age.dispose();
    }
    super.dispose();
  }

  String get _address => _profileAddress ? _savedAddress.trim() : _otherAddress.text.trim();

  bool get _canContinue {
    switch (_step) {
      case 1:
        return _activities.isNotEmpty;
      case 2:
        return _days.isNotEmpty;
      case 3:
        return extraSlots.indexOf(_until) > extraSlots.indexOf(_from);
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

  Future<void> _next(AppLang lang) async {
    if (!_canContinue || _sending) return;
    if (_step < _total) {
      _go(_step + 1);
      return;
    }
    setState(() => _sending = true);
    final ok = await AppScope.of(context).submitFixRequest(
      service: widget.service,
      startDate: DateTime.now(),
      start: _from,
      end: _until,
      children: _children,
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
      _activities.map((key) => ex(lang, key)).join(', '),
      _days.map((key) => ex(lang, key)).join(', '),
      '$_from – $_until',
      ex(lang, _children == 1 ? 'infant' : 'infants', {'n': '$_children'}),
    ];
    final ages = <String>[];
    for (var i = 0; i < _ages.length; i++) {
      final value = _ages[i].text.trim();
      if (value.isNotEmpty) ages.add('${i + 1}: $value');
    }
    if (ages.isNotEmpty) lines.add(ages.join(', '));
    if (_notes.text.trim().isNotEmpty) lines.add(_notes.text.trim());
    lines.add(_address);
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

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).lang;
    final colors = _ExtraColors.of(context);
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

  Widget _wizard(_ExtraColors colors, AppLang lang) {
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
                ex(lang, 'eyebrow', {'n': '$_step', 'label': ex(lang, 's$_step')}),
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 1.4, color: colors.mentaD),
              ),
              const SizedBox(height: 14),
              Text(ex(lang, 'h$_step'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, height: 1.18, color: colors.ink)),
              const SizedBox(height: 8),
              Text(ex(lang, 'sub$_step'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2)),
              const SizedBox(height: 26),
              _stepBody(colors, lang),
            ],
          ),
        ),
        Container(
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
                  child: Text(ex(lang, 'back')),
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
                      : Text(_step == _total ? ex(lang, 'send') : ex(lang, 'continue')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBody(_ExtraColors colors, AppLang lang) {
    switch (_step) {
      case 1:
        return _chipWrap(colors, lang, extraActivities, _activities);
      case 2:
        return _chipWrap(colors, lang, extraDays, _days);
      case 3:
        return _times(colors, lang);
      case 4:
        return _childrenStep(colors, lang);
      case 5:
        return _field(colors, _notes, hint: ex(lang, 'notesHint'), lines: 6);
      case 6:
        return _addressStep(colors, lang);
      case 7:
        return _contact(colors, lang);
      default:
        return _ready(colors, lang);
    }
  }

  Widget _times(_ExtraColors colors, AppLang lang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _timeMenu(colors, ex(lang, 'from'), _from, (value) => setState(() => _from = value))),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 13),
          child: Text('–', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.text2)),
        ),
        Expanded(child: _timeMenu(colors, ex(lang, 'until'), _until, (value) => setState(() => _until = value))),
      ],
    );
  }

  Widget _timeMenu(_ExtraColors colors, String caption, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: colors.line, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(13),
              dropdownColor: colors.card,
              style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, color: colors.ink),
              items: [
                for (final slot in extraSlots) DropdownMenuItem(value: slot, child: Text(slot)),
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

  Widget _childrenStep(_ExtraColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ex(lang, _children == 1 ? 'infant' : 'infants', {'n': '$_children'}),
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
          _labeledField(colors, ex(lang, 'age', {'n': '${i + 1}'}), _ages[i], hint: ex(lang, 'years'), number: true),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _addressStep(_ExtraColors colors, AppLang lang) {
    return Column(
      children: [
        _addressCard(
          colors,
          title: ex(lang, 'addrProfile'),
          detail: _savedAddress,
          on: _profileAddress,
          onTap: () => setState(() => _profileAddress = true),
        ),
        const SizedBox(height: 11),
        _addressCard(
          colors,
          title: ex(lang, 'addrOther'),
          detail: ex(lang, 'addrOtherSub'),
          on: !_profileAddress,
          onTap: () => setState(() => _profileAddress = false),
          extra: _profileAddress
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _field(colors, _otherAddress, hint: ex(lang, 'addrHint')),
                ),
        ),
      ],
    );
  }

  Widget _addressCard(
    _ExtraColors colors, {
    required String title,
    required String detail,
    required bool on,
    required VoidCallback onTap,
    Widget? extra,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: on ? colors.menta15 : colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
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
                    shape: BoxShape.circle,
                    border: Border.all(color: on ? colors.mentaD : colors.line, width: 2),
                  ),
                  child: on ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink)),
                      if (detail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(detail, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          ?extra,
        ],
      ),
    );
  }

  Widget _contact(_ExtraColors colors, AppLang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('📇', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(ex(lang, 'fromProfile'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.mentaD)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _labeledField(colors, ex(lang, 'name'), _name),
        const SizedBox(height: 16),
        _labeledField(colors, ex(lang, 'phone'), _phone, phone: true),
        const SizedBox(height: 16),
        _labeledField(colors, ex(lang, 'email'), _email, email: true),
      ],
    );
  }

  Widget _ready(_ExtraColors colors, AppLang lang) {
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
                Text(ex(lang, 'replyTitle'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink)),
                const SizedBox(height: 3),
                Text(ex(lang, 'replyBody'), style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.55, color: colors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doneView(_ExtraColors colors, AppLang lang) {
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
            child: const Text('🎨', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 24),
          Text(ex(lang, 'doneTitle'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 26, color: colors.ink)),
          const SizedBox(height: 12),
          Text(
            ex(lang, 'doneBody'),
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15, height: 1.6, color: colors.text2),
          ),
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
            child: Text(ex(lang, 'home')),
          ),
        ],
      ),
    );
  }

  Widget _chipWrap(_ExtraColors colors, AppLang lang, List<String> keys, Set<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final key in keys) _chip(colors, lang, key, selected)],
    );
  }

  Widget _chip(_ExtraColors colors, AppLang lang, String key, Set<String> selected) {
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
            ex(lang, key),
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: on ? const Color(0xFF2C3A33) : colors.text),
          ),
        ),
      ),
    );
  }

  Widget _labeledField(
    _ExtraColors colors,
    String label,
    TextEditingController controller, {
    String? hint,
    bool number = false,
    bool phone = false,
    bool email = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.ink)),
        const SizedBox(height: 8),
        _field(colors, controller, hint: hint, number: number, phone: phone, email: email),
      ],
    );
  }

  Widget _field(
    _ExtraColors colors,
    TextEditingController controller, {
    String? hint,
    int lines = 1,
    bool number = false,
    bool phone = false,
    bool email = false,
  }) {
    return TextField(
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
    );
  }
}

class _ExtraColors {
  const _ExtraColors({
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

  static const light = _ExtraColors(
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

  static const dark = _ExtraColors(
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

  static _ExtraColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

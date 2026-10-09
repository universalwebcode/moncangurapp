import 'package:flutter/material.dart';

import '../domain/availability.dart';
import '../l10n/cangur_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

final _times = [
  for (var hour = 0; hour < 24; hour++)
    for (final minute in ['00', '30']) '${hour.toString().padLeft(2, '0')}:$minute',
];

const _shortDays = [
  ['Dl', 'Dt', 'Dc', 'Dj', 'Dv', 'Ds', 'Dg'],
  ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do'],
  ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
  ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'],
];

const _fullDays = [
  ['diumenge', 'dilluns', 'dimarts', 'dimecres', 'dijous', 'divendres', 'dissabte'],
  ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'],
  ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'],
];

const _months = [
  ['gener', 'febrer', 'març', 'abril', 'maig', 'juny', 'juliol', 'agost', 'setembre', 'octubre', 'novembre', 'desembre'],
  ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'],
  ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'],
];

const _shiftOrder = ['mati', 'tarda', 'nit'];

class CangurAvailabilityScreen extends StatefulWidget {
  const CangurAvailabilityScreen({super.key});

  @override
  State<CangurAvailabilityScreen> createState() => _CangurAvailabilityScreenState();
}

class _CangurAvailabilityScreenState extends State<CangurAvailabilityScreen> {
  final _days = <String, _DayPlan>{};
  final _morning = _Shift('09:00', '13:00');
  final _afternoon = _Shift('15:00', '19:00');
  final _night = _Shift('22:00', '06:00');
  final _weekdays = <int>{};
  final _quickShifts = <String>{};
  late DateTime _view;
  bool _applied = false;
  bool _saving = false;
  String? _toast;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _view = DateTime(now.year, now.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_applied) return;
    final state = AppScope.of(context);
    final profile = state.user == null ? null : state.profileFor(state.user!.id);
    _applied = true;
    for (final exception in profile?.exceptions ?? const <AvailabilityException>[]) {
      _days[exception.fecha] = _DayPlan.from(exception);
    }
  }

  _Shift _defaultFor(String shift) {
    switch (shift) {
      case 'tarda':
        return _afternoon;
      case 'nit':
        return _night;
      default:
        return _morning;
    }
  }

  void _applyMonth(AppLang lang) {
    if (_weekdays.isEmpty || _quickShifts.isEmpty) {
      setState(() => _toast = cg(lang, 'pickFirst'));
      return;
    }
    final today = DateUtils.dateOnly(DateTime.now());
    final count = DateUtils.getDaysInMonth(_view.year, _view.month);
    setState(() {
      for (var day = 1; day <= count; day++) {
        final date = DateTime(_view.year, _view.month, day);
        if (date.isBefore(today)) continue;
        if (!_weekdays.contains(date.weekday)) continue;
        final plan = _days[isoDate(date)] ?? _DayPlan();
        for (final shift in _quickShifts) {
          plan.set(shift, _defaultFor(shift).copy());
        }
        _days[isoDate(date)] = plan;
      }
      _toast = cg(lang, 'appliedMonth');
    });
  }

  void _clearMonth(AppLang lang) {
    final prefix = '${_view.year}-${_view.month.toString().padLeft(2, '0')}-';
    setState(() {
      for (final key in _days.keys.where((item) => item.startsWith(prefix)).toList()) {
        _days[key] = _DayPlan();
      }
      _toast = cg(lang, 'clearedMonth');
    });
  }

  Future<void> _openDay(_Look colors, AppLang lang, DateTime date) async {
    final key = isoDate(date);
    final draft = (_days[key] ?? _DayPlan()).copy();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: colors.line, borderRadius: BorderRadius.circular(999)))),
                  const SizedBox(height: 14),
                  Text(_dayTitle(lang, date), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink)),
                  const SizedBox(height: 3),
                  Text(cg(lang, 'sheetHelp'), style: TextStyle(fontFamily: 'Nunito', fontSize: 13, height: 1.5, color: colors.text2)),
                  const SizedBox(height: 16),
                  for (final shift in _shiftOrder) _sheetRow(colors, lang, shift, draft, setSheet),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(color: colors.mentaD, borderRadius: BorderRadius.circular(15)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, true),
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(cg(lang, 'saveDay'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        draft.clear();
                        Navigator.pop(context, false);
                      },
                      child: Text(cg(lang, 'clearDay'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13.5, color: colors.text2, decoration: TextDecoration.underline)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (!mounted || saved == null) return;
    setState(() {
      _days[key] = draft;
      _toast = cg(lang, saved ? 'dayUpdated' : 'dayCleared');
    });
  }

  Future<void> _save(AppLang lang) async {
    final state = AppScope.of(context);
    if (state.user == null || _saving) return;
    setState(() => _saving = true);
    final days = [
      for (final entry in _days.entries)
        AvailabilityException(fecha: entry.key, disponible: entry.value.any, franjas: entry.value.bands()),
    ];
    final error = await state.saveAvailability(days);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _toast = error == null ? cg(lang, 'savedAvail') : state.tr(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _Look.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Stack(
              children: [
                Column(
                  children: [
                    _top(colors, lang),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        children: [
                          _rich(cg(lang, 'availIntro'), TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.55, color: colors.text2), TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.55, fontWeight: FontWeight.w800, color: colors.ink)),
                          const SizedBox(height: 18),
                          _heading(colors, cg(lang, 'habitual')),
                          _shiftCard(colors, lang, 'mati', cg(lang, 'morning'), cg(lang, 'defaultHours'), _morning),
                          _shiftCard(colors, lang, 'tarda', cg(lang, 'afternoon'), cg(lang, 'defaultHours'), _afternoon),
                          _shiftCard(colors, lang, 'nit', cg(lang, 'night'), cg(lang, 'nightCross'), _night, last: true),
                          const SizedBox(height: 24),
                          _heading(colors, cg(lang, 'fillMonth')),
                          _quickCard(colors, lang),
                          _heading(colors, cg(lang, 'myCalendar')),
                          _calendar(colors, lang),
                          const SizedBox(height: 12),
                          _rich(cg(lang, 'dayHint'), TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.55, color: colors.text2), TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.55, fontWeight: FontWeight.w800, color: colors.ink)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Column(
                        children: [
                          _rich(
                            _summary(lang),
                            TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13, color: colors.text2),
                            TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.ink),
                            align: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.mentaD,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [BoxShadow(color: Color(0x668CA598), blurRadius: 20, offset: Offset(0, 8))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _saving ? null : () => _save(lang),
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(cg(lang, 'saveAvail'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_toast != null)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 108,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(999)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          child: Text(_toast!, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: colors.bg)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _top(_Look colors, AppLang lang) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.bg, border: Border(bottom: BorderSide(color: colors.line))),
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
            Expanded(child: Text(cg(lang, 'myAvailability'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.ink))),
          ],
        ),
      ),
    );
  }

  Widget _shiftCard(_Look colors, AppLang lang, String shift, String name, String subtitle, _Shift hours, {bool last = false}) {
    final tone = _tone(shift);
    return Container(
      margin: EdgeInsets.only(bottom: last ? 0 : 11),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(10)),
            child: Text(_letter(lang, shift), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink)),
                const SizedBox(height: 1),
                Text(subtitle, style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2)),
              ],
            ),
          ),
          _timeBox(colors, hours.from, (value) => setState(() => hours.from = value)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 7), child: Text('–', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.text2))),
          _timeBox(colors, hours.to, (value) => setState(() => hours.to = value)),
        ],
      ),
    );
  }

  Widget _quickCard(_Look colors, AppLang lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cg(lang, 'whichDays'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13, color: colors.ink)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (var index = 0; index < 7; index++)
                _chip(
                  colors,
                  _shortDays[lang.index][index],
                  _weekdays.contains(index + 1),
                  null,
                  () => setState(() {
                    final day = index + 1;
                    if (_weekdays.contains(day)) {
                      _weekdays.remove(day);
                    } else {
                      _weekdays.add(day);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(cg(lang, 'whichShifts'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13, color: colors.ink)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final shift in _shiftOrder)
                _chip(
                  colors,
                  _shiftName(lang, shift),
                  _quickShifts.contains(shift),
                  _tone(shift),
                  () => setState(() {
                    if (_quickShifts.contains(shift)) {
                      _quickShifts.remove(shift);
                    } else {
                      _quickShifts.add(shift);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: colors.mentaD, borderRadius: BorderRadius.circular(12)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _applyMonth(lang),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(cg(lang, 'applyMonth'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _clearMonth(lang),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.line, width: 1.5)),
                    child: Text(cg(lang, 'clearMonth'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: colors.text2)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendar(_Look colors, AppLang lang) {
    final today = DateUtils.dateOnly(DateTime.now());
    final first = DateTime(_view.year, _view.month);
    final offset = first.weekday - 1;
    final count = DateUtils.getDaysInMonth(_view.year, _view.month);
    final label = '${_cap(_months[lang.index][_view.month - 1])} ${_view.year}';
    return Container(
      padding: const EdgeInsets.all(16),
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
              _nav(colors, Icons.chevron_left, () => setState(() => _view = DateTime(_view.year, _view.month - 1))),
              Expanded(child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink))),
              _nav(colors, Icons.chevron_right, () => setState(() => _view = DateTime(_view.year, _view.month + 1))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final day in _shortDays[lang.index])
                Expanded(child: Text(day, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: colors.text2))),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.82,
            children: [
              for (var i = 0; i < offset; i++) const SizedBox.shrink(),
              for (var day = 1; day <= count; day++) _dayCell(colors, lang, DateTime(_view.year, _view.month, day), today),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final shift in _shiftOrder) _legend(colors, _tone(shift), _shiftName(lang, shift)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayCell(_Look colors, AppLang lang, DateTime date, DateTime today) {
    final past = date.isBefore(today);
    final plan = _days[isoDate(date)];
    final marks = plan?.marks() ?? const <String>[];
    final has = marks.isNotEmpty;
    return Material(
      color: past ? Colors.transparent : (has ? colors.menta15 : Colors.transparent),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: past ? null : () => _openDay(colors, lang, date),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: has && !past ? colors.line : Colors.transparent, width: 1.5),
          ),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Text('${date.day}', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: past ? colors.dis : colors.ink)),
              const SizedBox(height: 3),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                runSpacing: 2,
                children: [
                  for (final mark in marks) Container(width: 7, height: 7, decoration: BoxDecoration(color: _tone(mark), shape: BoxShape.circle)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetRow(_Look colors, AppLang lang, String shift, _DayPlan draft, StateSetter setSheet) {
    final on = draft.of(shift) != null;
    final hours = draft.of(shift) ?? _defaultFor(shift);
    final tone = _tone(shift);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: on ? colors.menta15 : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setSheet(() {
              if (on) {
                draft.set(shift, null);
              } else {
                draft.set(shift, _defaultFor(shift).copy());
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 27,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: on ? colors.mentaD : colors.line, borderRadius: BorderRadius.circular(999)),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(width: 21, height: 21, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(6)),
                      child: Text(_letter(lang, shift), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
                    ),
                    const SizedBox(width: 7),
                    Text(_shiftName(lang, shift), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink)),
                  ],
                ),
                if (on) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _timeBox(colors, hours.from, (value) => setSheet(() => hours.from = value)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('–', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.text2))),
                      _timeBox(colors, hours.to, (value) => setSheet(() => hours.to = value)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBox(_Look colors, String value, ValueChanged<String> onChanged) {
    final selected = _times.contains(value) ? value : _times.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.line, width: 1.5)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colors.card,
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: colors.ink),
          items: [for (final time in _times) DropdownMenuItem(value: time, child: Text(time))],
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ),
    );
  }

  Widget _chip(_Look colors, String label, bool on, Color? tone, VoidCallback onTap) {
    final background = on ? (tone ?? colors.menta) : colors.bg;
    final border = on ? (tone ?? colors.mentaD) : colors.line;
    final ink = on ? (tone == null ? const Color(0xFF2C3A33) : Colors.white) : colors.text;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: border, width: 1.5)),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13, color: ink)),
        ),
      ),
    );
  }

  Widget _nav(_Look colors, IconData icon, VoidCallback onTap) {
    return Material(
      color: colors.menta15,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 34, height: 34, child: Icon(icon, size: 18, color: colors.ink)),
      ),
    );
  }

  Widget _legend(_Look colors, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.text2)),
      ],
    );
  }

  Widget _heading(_Look colors, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 11),
      child: Text(text.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.4, color: colors.mentaD)),
    );
  }

  String _summary(AppLang lang) {
    final prefix = '${_view.year}-${_view.month.toString().padLeft(2, '0')}-';
    var days = 0;
    var shifts = 0;
    for (final entry in _days.entries) {
      if (!entry.key.startsWith(prefix) || !entry.value.any) continue;
      days++;
      shifts += entry.value.count;
    }
    if (shifts == 0) return cg(lang, 'sumEmpty');
    return cg(lang, 'sumLine', {'shifts': '$shifts', 'days': '$days'});
  }
}

String _dayTitle(AppLang lang, DateTime date) {
  final weekday = _cap(_fullDays[lang.index][date.weekday % 7]);
  final month = _months[lang.index][date.month - 1];
  if (lang == AppLang.en) return '$weekday ${date.day} ${_cap(month)}';
  return '$weekday ${date.day} de $month';
}

String _cap(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

String _shiftName(AppLang lang, String shift) {
  switch (shift) {
    case 'tarda':
      return cg(lang, 'afternoon');
    case 'nit':
      return cg(lang, 'night');
    default:
      return cg(lang, 'morning');
  }
}

String _letter(AppLang lang, String shift) {
  final name = _shiftName(lang, shift);
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

Color _tone(String shift) {
  switch (shift) {
    case 'tarda':
      return const Color(0xFFC0845F);
    case 'nit':
      return const Color(0xFF6D78B5);
    default:
      return const Color(0xFFE0A93B);
  }
}

Widget _rich(String source, TextStyle base, TextStyle bold, {TextAlign align = TextAlign.start}) {
  final parts = source.split('**');
  return Text.rich(
    TextSpan(children: [for (var i = 0; i < parts.length; i++) TextSpan(text: parts[i], style: i.isOdd ? bold : base)]),
    textAlign: align,
  );
}

class _Shift {
  _Shift(this.from, this.to);

  String from;
  String to;

  _Shift copy() => _Shift(from, to);
}

class _DayPlan {
  _Shift? morning;
  _Shift? afternoon;
  _Shift? night;

  bool get any => morning != null || afternoon != null || night != null;
  int get count => (morning == null ? 0 : 1) + (afternoon == null ? 0 : 1) + (night == null ? 0 : 1);

  _Shift? of(String shift) {
    switch (shift) {
      case 'tarda':
        return afternoon;
      case 'nit':
        return night;
      default:
        return morning;
    }
  }

  void set(String shift, _Shift? value) {
    switch (shift) {
      case 'tarda':
        afternoon = value;
      case 'nit':
        night = value;
      default:
        morning = value;
    }
  }

  void clear() {
    morning = null;
    afternoon = null;
    night = null;
  }

  List<String> marks() => [
    if (morning != null) 'mati',
    if (afternoon != null) 'tarda',
    if (night != null) 'nit',
  ];

  List<TimeBand> bands() => [
    if (morning != null) TimeBand(morning!.from, morning!.to, torn: 'mati'),
    if (afternoon != null) TimeBand(afternoon!.from, afternoon!.to, torn: 'tarda'),
    if (night != null) TimeBand(night!.from, night!.to, torn: 'nit'),
  ];

  _DayPlan copy() {
    return _DayPlan()
      ..morning = morning?.copy()
      ..afternoon = afternoon?.copy()
      ..night = night?.copy();
  }

  static _DayPlan from(AvailabilityException exception) {
    final plan = _DayPlan();
    if (!exception.disponible) return plan;
    for (final band in exception.franjas) {
      final shift = _Shift(band.inicio, band.fin);
      final kind = band.torn ?? _guess(band);
      plan.set(kind, shift);
    }
    return plan;
  }
}

String _guess(TimeBand band) {
  final start = minutesOf(band.inicio);
  final end = minutesOf(band.fin);
  if (start == null || end == null || end <= start || start >= 20 * 60) return 'nit';
  if (start >= 14 * 60) return 'tarda';
  return 'mati';
}

class _Look {
  const _Look({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.menta15,
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
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color dis;
  final Color shadow;

  static const light = _Look(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    dis: Color(0xFFC9C3BA),
    shadow: Color(0x0D000000),
  );

  static const dark = _Look(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    dis: Color(0xFF4A463F),
    shadow: Color(0x66000000),
  );

  static _Look of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

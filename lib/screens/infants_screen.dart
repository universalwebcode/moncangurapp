import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/kids_copy.dart';
import '../l10n/profile_copy.dart';
import '../models/models.dart';
import '../services/child_photo.dart';
import '../widgets/mc_widgets.dart';

class InfantsScreen extends StatefulWidget {
  const InfantsScreen({super.key});

  @override
  State<InfantsScreen> createState() => _InfantsScreenState();
}

class _Child {
  _Child({
    this.name = '',
    this.birth,
    this.school = '',
    this.traits = const [],
    this.about = '',
    this.nap,
    this.bedtime = '',
    this.meals = '',
    this.routines = '',
    this.allergies = '',
    this.medicine = '',
    this.needs = '',
    this.likes = '',
    this.fears = '',
    this.calm = '',
    this.photo,
    this.color = 0xFF8CA598,
  });

  String name;
  DateTime? birth;
  String school;
  List<String> traits;
  String about;
  int? nap;
  String bedtime;
  String meals;
  String routines;
  String allergies;
  String medicine;
  String needs;
  String likes;
  String fears;
  String calm;
  String? photo;
  int color;

  factory _Child.fromMap(Map<dynamic, dynamic> data, int fallbackColor) {
    DateTime? birth;
    final rawDate = data['naix'];
    if (rawDate is String && rawDate.isNotEmpty) birth = DateTime.tryParse(rawDate);
    final year = data['any'];
    final month = data['mes'];
    final day = data['dia'];
    birth ??= (year is num && month is num && day is num) ? DateTime(year.toInt(), month.toInt(), day.toInt()) : null;
    final traits = <String>[];
    final rawTraits = data['caracter'];
    if (rawTraits is List) {
      for (final item in rawTraits) {
        if (item is String) traits.add(item);
      }
    }
    final allergyText = data['allergies'] is String
        ? data['allergies'] as String
        : (data['allergia'] == true && data['notes'] is String ? data['notes'] as String : '');
    return _Child(
      name: data['nombre'] is String ? data['nombre'] as String : (data['nom'] is String ? data['nom'] as String : ''),
      birth: birth,
      school: data['escola'] is String ? data['escola'] as String : '',
      traits: traits,
      about: data['com'] is String ? data['com'] as String : '',
      nap: data['migdiada'] is num ? (data['migdiada'] as num).toInt() : null,
      bedtime: data['son'] is String ? data['son'] as String : '',
      meals: data['apats'] is String ? data['apats'] as String : '',
      routines: data['rutines'] is String ? data['rutines'] as String : '',
      allergies: allergyText,
      medicine: data['medicacio'] is String ? data['medicacio'] as String : '',
      needs: data['necessitats'] is String ? data['necessitats'] as String : '',
      likes: data['agrada'] is String ? data['agrada'] as String : '',
      fears: data['pors'] is String ? data['pors'] as String : '',
      calm: data['calma'] is String ? data['calma'] as String : '',
      photo: data['foto'] is String && (data['foto'] as String).isNotEmpty ? data['foto'] as String : null,
      color: data['color'] is num ? (data['color'] as num).toInt() : fallbackColor,
    );
  }

  Map<String, Object?> toMap() {
    final birthDay = birth;
    return {
      'nombre': name.trim(),
      'nom': name.trim(),
      'naix': birthDay == null ? '' : '${birthDay.year.toString().padLeft(4, '0')}-${birthDay.month.toString().padLeft(2, '0')}-${birthDay.day.toString().padLeft(2, '0')}',
      'dia': birthDay?.day,
      'mes': birthDay?.month,
      'any': birthDay?.year,
      'escola': school.trim(),
      'caracter': traits,
      'com': about.trim(),
      'migdiada': nap,
      'son': bedtime,
      'apats': meals.trim(),
      'rutines': routines.trim(),
      'allergies': allergies.trim(),
      'allergia': allergies.trim().isNotEmpty,
      'notes': allergies.trim(),
      'medicacio': medicine.trim(),
      'necessitats': needs.trim(),
      'agrada': likes.trim(),
      'pors': fears.trim(),
      'calma': calm.trim(),
      'foto': photo,
      'color': color,
    };
  }
}

class _InfantsScreenState extends State<InfantsScreen> {
  final _name = TextEditingController();
  final _school = TextEditingController();
  final _about = TextEditingController();
  final _meals = TextEditingController();
  final _routines = TextEditingController();
  final _allergies = TextEditingController();
  final _medicine = TextEditingController();
  final _needs = TextEditingController();
  final _likes = TextEditingController();
  final _fears = TextEditingController();
  final _calm = TextEditingController();

  final List<_Child> _kids = [];
  int _index = 0;
  bool _loaded = false;
  bool _saving = false;
  bool _toast = false;
  String? _photoNote;
  Timer? _toastTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final infants = AppScope.of(context).user?.perfil['infants'];
    if (infants is List) {
      for (var i = 0; i < infants.length; i++) {
        final item = infants[i];
        if (item is Map) _kids.add(_Child.fromMap(item, kidColors[i % kidColors.length]));
      }
    }
    if (_kids.isNotEmpty) _load();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _name.dispose();
    _school.dispose();
    _about.dispose();
    _meals.dispose();
    _routines.dispose();
    _allergies.dispose();
    _medicine.dispose();
    _needs.dispose();
    _likes.dispose();
    _fears.dispose();
    _calm.dispose();
    super.dispose();
  }

  void _commit() {
    if (_kids.isEmpty) return;
    final kid = _kids[_index];
    kid
      ..name = _name.text
      ..school = _school.text
      ..about = _about.text
      ..meals = _meals.text
      ..routines = _routines.text
      ..allergies = _allergies.text
      ..medicine = _medicine.text
      ..needs = _needs.text
      ..likes = _likes.text
      ..fears = _fears.text
      ..calm = _calm.text;
  }

  void _load() {
    final kid = _kids[_index];
    _name.text = kid.name;
    _school.text = kid.school;
    _about.text = kid.about;
    _meals.text = kid.meals;
    _routines.text = kid.routines;
    _allergies.text = kid.allergies;
    _medicine.text = kid.medicine;
    _needs.text = kid.needs;
    _likes.text = kid.likes;
    _fears.text = kid.fears;
    _calm.text = kid.calm;
  }

  void _select(int index) {
    _commit();
    setState(() {
      _index = index;
      _photoNote = null;
      _load();
    });
  }

  void _add() {
    _commit();
    setState(() {
      _kids.add(_Child(color: kidColors[_kids.length % kidColors.length]));
      _index = _kids.length - 1;
      _photoNote = null;
      _load();
    });
  }

  Future<void> _pickPhoto() async {
    final photo = await pickChildPhoto();
    if (!mounted) return;
    if (photo == null || photo.length > 700000) {
      setState(() => _photoNote = photo == null ? null : kd(AppScope.of(context).lang, 'photoSoon'));
      return;
    }
    setState(() {
      _kids[_index].photo = photo;
      _photoNote = null;
    });
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final current = _kids[_index].birth ?? DateTime(now.year - 3);
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isAfter(now) ? now : current,
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _kids[_index].birth = picked);
  }

  Future<void> _pickBedtime() async {
    final picked = await pickTime(context, _kids[_index].bedtime.isEmpty ? '20:30' : _kids[_index].bedtime);
    if (picked == null) return;
    setState(() => _kids[_index].bedtime = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    final state = AppScope.of(context);
    final account = state.user;
    if (account == null) return;
    _commit();
    setState(() => _saving = true);
    final perfil = Map<String, Object?>.from(account.perfil);
    perfil['infants'] = [for (final kid in _kids) kid.toMap()];
    final display = perfil['nombreCompleto'];
    final error = await state.completeFatherProfile(
      displayName: display is String && display.trim().isNotEmpty ? display.trim() : account.nombre,
      telefono: account.telefono,
      direccion: account.direccion,
      idioma: state.lang.name,
      perfil: perfil,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _saving = false);
      state.flash(error);
      return;
    }
    setState(() {
      _saving = false;
      _toast = true;
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _toast = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).lang;
    final colors = _KidColors.of(context);
    final kid = _kids.isEmpty ? null : _kids[_index];
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
                            Expanded(child: Text(pt(lang, 'myKids'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink))),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        children: [
                          Text(kd(lang, 'intro'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14, height: 1.55, color: colors.text2)),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 108,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (var i = 0; i < _kids.length; i++) _switcher(colors, _kids[i], i == _index, () => _select(i)),
                                _addButton(colors),
                              ],
                            ),
                          ),
                          if (kid != null) ...[
                            _section(colors, kd(lang, 'photoData')),
                            _card(colors, child: _identity(colors, lang, kid)),
                            _section(colors, kd(lang, 'who')),
                            _card(colors, child: _personality(colors, lang, kid)),
                            _section(colors, kd(lang, 'routines')),
                            _card(colors, child: _routine(colors, lang, kid)),
                            _section(colors, kd(lang, 'health')),
                            _card(colors, child: _health(colors, lang)),
                            _section(colors, kd(lang, 'prefs')),
                            _card(colors, child: _preferences(colors, lang)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.mentaD,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Color(0x668CA598), blurRadius: 20, offset: Offset(0, 8))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _saving ? null : _save,
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            _saving ? '...' : pt(lang, 'saveChanges'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_toast)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 86,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(999)),
                        child: Text(pt(lang, 'saved'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: colors.bg)),
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

  Widget _switcher(_KidColors colors, _Child kid, bool on, VoidCallback tap) {
    final label = kid.name.trim().isEmpty ? '?' : kid.name.trim();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: tap,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _avatar(kid, 60, 24, border: on ? colors.mentaD : Colors.transparent),
              const SizedBox(height: 6),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: on ? colors.ink : colors.text2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addButton(_KidColors colors) {
    return InkWell(
      onTap: _add,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.brun, width: 2)),
              child: Text('+', style: TextStyle(fontFamily: 'Nunito', fontSize: 28, color: colors.brun)),
            ),
            const SizedBox(height: 6),
            Text(kd(AppScope.of(context).lang, 'add'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
          ],
        ),
      ),
    );
  }

  Widget _avatar(_Child kid, double size, double fontSize, {Color border = Colors.transparent}) {
    final initial = kid.name.trim().isEmpty ? '?' : kid.name.trim()[0].toUpperCase();
    final bytes = _photoBytes(kid.photo);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Color(kid.color), shape: BoxShape.circle, border: Border.all(color: border, width: 3)),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? Text(initial, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: fontSize, color: Colors.white))
          : Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
    );
  }

  Widget _identity(_KidColors colors, AppLang lang, _Child kid) {
    return Column(
      children: [
        Row(
          children: [
            _avatar(kid, 84, 34),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: colors.brun15,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _pickPhoto,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.brun.withValues(alpha: 0.3), width: 1.5)),
                        child: Text(kd(lang, kid.photo == null ? 'addPhoto' : 'changePhoto'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: colors.brun)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_photoNote ?? kd(lang, 'photoHint'), style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _labeled(colors, kd(lang, 'name'), _name, onChanged: (value) => setState(() => kid.name = value))),
            const SizedBox(width: 12),
            Expanded(child: _dateBox(colors, lang, kid)),
          ],
        ),
        _labeled(colors, kd(lang, 'school'), _school, hint: kd(lang, 'schoolHint')),
      ],
    );
  }

  Widget _personality(_KidColors colors, AppLang lang, _Child kid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kd(lang, 'traits'), style: _label(colors)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final trait in kidTraits)
              _chip(colors, kd(lang, trait), kid.traits.contains(trait), () {
                setState(() {
                  if (kid.traits.contains(trait)) {
                    kid.traits = kid.traits.where((item) => item != trait).toList();
                  } else {
                    kid.traits = [...kid.traits, trait];
                  }
                });
              }),
          ],
        ),
        const SizedBox(height: 14),
        _labeled(colors, kd(lang, 'about'), _about, hint: kd(lang, 'aboutHint'), lines: 4),
      ],
    );
  }

  Widget _routine(_KidColors colors, AppLang lang, _Child kid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kd(lang, 'nap'), style: _label(colors)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _seg(colors, kd(lang, const ['yes', 'no', 'sometimes'][i]), kid.nap == i, () => setState(() => kid.nap = i))),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _timeBox(colors, lang, kid)),
            const SizedBox(width: 12),
            Expanded(child: _labeled(colors, kd(lang, 'meals'), _meals, hint: kd(lang, 'mealsHint'))),
          ],
        ),
        _labeled(colors, kd(lang, 'habits'), _routines, hint: kd(lang, 'habitsHint'), lines: 4),
      ],
    );
  }

  Widget _health(_KidColors colors, AppLang lang) {
    return Column(
      children: [
        _labeled(colors, kd(lang, 'allergies'), _allergies, hint: kd(lang, 'allergiesHint')),
        _labeled(colors, kd(lang, 'medicine'), _medicine, hint: kd(lang, 'medicineHint')),
        _labeled(colors, kd(lang, 'needs'), _needs, hint: kd(lang, 'needsHint'), lines: 3),
      ],
    );
  }

  Widget _preferences(_KidColors colors, AppLang lang) {
    return Column(
      children: [
        _labeled(colors, kd(lang, 'likes'), _likes, hint: kd(lang, 'likesHint'), lines: 3),
        _labeled(colors, kd(lang, 'fears'), _fears, hint: kd(lang, 'fearsHint')),
        _labeled(colors, kd(lang, 'soothe'), _calm, hint: kd(lang, 'sootheHint'), last: true),
      ],
    );
  }

  Widget _section(_KidColors colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Text(title.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.6, color: colors.mentaD)),
    );
  }

  Widget _card(_KidColors colors, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _labeled(_KidColors colors, String label, TextEditingController controller, {String? hint, int lines = 1, bool last = false, ValueChanged<String>? onChanged}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _label(colors)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: lines,
            maxLines: lines,
            onChanged: onChanged,
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: colors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.line, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.menta, width: 1.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(_KidColors colors, AppLang lang, _Child kid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kd(lang, 'birth'), style: _label(colors)),
          const SizedBox(height: 6),
          Material(
            color: colors.bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _pickBirth,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.line, width: 1.5)),
                child: Text(
                  kid.birth == null ? kd(lang, 'pickDate') : formatDate(kid.birth!),
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: kid.birth == null ? colors.text2 : colors.ink),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBox(_KidColors colors, AppLang lang, _Child kid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kd(lang, 'bedtime'), style: _label(colors)),
          const SizedBox(height: 6),
          Material(
            color: colors.bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _pickBedtime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.line, width: 1.5)),
                child: Text(kid.bedtime.isEmpty ? '20:30' : kid.bedtime, style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(_KidColors colors, String label, bool on, VoidCallback tap) {
    return Material(
      color: on ? colors.menta : colors.bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 13.5, color: on ? const Color(0xFF2C3A33) : colors.text)),
        ),
      ),
    );
  }

  Widget _seg(_KidColors colors, String label, bool on, VoidCallback tap) {
    return Material(
      color: on ? colors.menta : colors.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: on ? const Color(0xFF2C3A33) : colors.text)),
        ),
      ),
    );
  }

  TextStyle _label(_KidColors colors) => TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2);
}

Uint8List? _photoBytes(String? photo) {
  if (photo == null || !photo.contains(',')) return null;
  try {
    return base64Decode(photo.split(',').last);
  } catch (_) {
    return null;
  }
}

class _KidColors {
  const _KidColors({
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
    required this.brun15,
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
  final Color brun15;
  final Color shadow;

  static const light = _KidColors(
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
    brun15: Color(0x1AA98E7B),
    shadow: Color(0x0D000000),
  );

  static const dark = _KidColors(
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
    brun15: Color(0x33A98E7B),
    shadow: Color(0x66000000),
  );

  static _KidColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

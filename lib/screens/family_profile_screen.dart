import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/menu_copy.dart';
import '../l10n/profile_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({this.scrollToKids = false, super.key});

  final bool scrollToKids;

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _Kid {
  _Kid({
    required this.name,
    this.day,
    this.month,
    this.year,
    this.allergy = false,
    this.notes = '',
    this.needsDetails = false,
  });

  String name;
  int? day;
  int? month;
  int? year;
  bool allergy;
  String notes;
  bool needsDetails;

  factory _Kid.fromMap(Map<dynamic, dynamic> data) {
    return _Kid(
      name: data['nombre'] is String ? data['nombre'] as String : '',
      day: data['dia'] is num ? (data['dia'] as num).toInt() : null,
      month: data['mes'] is num ? (data['mes'] as num).toInt() : null,
      year: data['any'] is num ? (data['any'] as num).toInt() : null,
      allergy: data['allergia'] == true,
      notes: data['notes'] is String ? data['notes'] as String : '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'nombre': name.trim(),
      'dia': day,
      'mes': month,
      'any': year,
      'allergia': allergy,
      'notes': notes.trim(),
    };
  }

  String ageLabel(AppLang lang) {
    final birthYear = year;
    final birthMonth = month;
    final birthDay = day;
    if (birthYear == null || birthMonth == null || birthDay == null) return '—';
    final now = DateTime.now();
    var years = now.year - birthYear;
    if (now.month < birthMonth || (now.month == birthMonth && now.day < birthDay)) years--;
    if (years < 0) years = 0;
    if (years == 1) return pt(lang, 'oneYear');
    return pt(lang, 'manyYears').replaceAll('{n}', '$years');
  }
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  static const _relations = ['mare', 'pare', 'tutor', 'avi', 'altre'];
  static const _languages = ['ca', 'es', 'en', 'fr'];
  static const _kidColors = [Color(0xFF6E82A6), Color(0xFF8CA598), Color(0xFFA98E7B), Color(0xFF9487B3), Color(0xFFC08457)];

  final _scroll = ScrollController();
  final _kidsAnchor = GlobalKey();
  final _family = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();

  String? _relation;
  String _serviceLang = 'ca';
  String? _parish;
  String _consent = 'xat';
  final List<_Kid> _kids = [];
  bool _loaded = false;
  bool _scrolled = false;
  bool _saving = false;
  bool _toast = false;
  Timer? _toastTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final state = AppScope.of(context);
    final account = state.user;
    if (account == null) return;
    final perfil = account.perfil;
    _family.text = _text(perfil['apellidoFamilia']);
    _name.text = _text(perfil['nombreCompleto']).isNotEmpty ? _text(perfil['nombreCompleto']) : account.nombre;
    _phone.text = account.telefono.isNotEmpty ? account.telefono : _text(perfil['telefono']);
    _address.text = account.direccion.isNotEmpty ? account.direccion : _text(perfil['direccion']);
    _email.text = account.email;
    _relation = perfil['parentiu'] is String ? perfil['parentiu'] as String : null;
    if (!_relations.contains(_relation)) _relation = null;
    final idioma = perfil['idiomaServicio'];
    _serviceLang = idioma is String && _languages.contains(idioma) ? idioma : state.lang.name;
    final parish = perfil['parroquia'];
    _parish = parish is String && profileParishes.contains(parish) ? parish : null;
    final consent = perfil['consentimentImatge'];
    if (consent is String && consent.isNotEmpty) _consent = consent;
    final infants = perfil['infants'];
    if (infants is List) {
      for (final item in infants) {
        if (item is Map) _kids.add(_Kid.fromMap(item));
      }
    }
  }

  String _text(Object? value) => value is String ? value : '';

  @override
  void dispose() {
    _toastTimer?.cancel();
    _scroll.dispose();
    _family.dispose();
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _email.dispose();
    super.dispose();
  }

  void _jumpToKids() {
    if (!widget.scrollToKids || _scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _kidsAnchor.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 250), alignment: 0.05);
    });
  }

  Future<void> _editKid(int index, AppLang lang, _ProfileColors colors) async {
    final updated = await showModalBottomSheet<_Kid>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _KidEditor(kid: _kids[index], lang: lang, colors: colors),
    );
    if (updated == null) return;
    setState(() => _kids[index] = updated);
  }

  Future<void> _save(AppLang lang) async {
    if (_saving) return;
    final state = AppScope.of(context);
    final account = state.user;
    if (account == null) return;
    setState(() => _saving = true);
    final perfil = Map<String, Object?>.from(account.perfil);
    final displayName = _name.text.trim();
    perfil
      ..['apellidoFamilia'] = _family.text.trim()
      ..['nombreCompleto'] = displayName
      ..['parentiu'] = _relation
      ..['telefono'] = _phone.text.trim()
      ..['idiomaServicio'] = _serviceLang
      ..['direccion'] = _address.text.trim()
      ..['parroquia'] = _parish
      ..['consentimentImatge'] = _consent
      ..['infants'] = [for (final kid in _kids) kid.toMap()];
    final error = await state.completeFatherProfile(
      displayName: displayName.isEmpty ? account.nombre : displayName,
      telefono: _phone.text.trim(),
      direccion: _address.text.trim(),
      idioma: _serviceLang,
      perfil: perfil,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _saving = false);
      state.flash(error);
      return;
    }
    state.setLang(_langOf(_serviceLang));
    setState(() {
      _saving = false;
      _toast = true;
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _toast = false);
    });
  }

  AppLang _langOf(String code) {
    for (final lang in AppLang.values) {
      if (lang.name == code) return lang;
    }
    return AppLang.ca;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _ProfileColors.of(context);
    _jumpToKids();
    final display = _name.text.trim();
    final initialSource = display.isNotEmpty ? display : _family.text.trim();
    final initial = initialSource.isNotEmpty ? initialSource[0].toUpperCase() : 'M';
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
                    _Top(colors: colors, title: mn(lang, 'profile'), onBack: () => Navigator.pop(context)),
                    Expanded(
                      child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        children: [
                          _Hero(colors: colors, initial: initial, name: display.isEmpty ? state.user?.nombre ?? '' : display, email: _email.text),
                          _label(colors, pt(lang, 'familyData')),
                          _card(
                            colors,
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _field(colors, pt(lang, 'surname'), _family)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _menu(colors, pt(lang, 'relationLabel'), _relation, pt(lang, 'select'), {
                                      for (final key in _relations) key: pt(lang, _relationKey(key)),
                                    }, (value) => setState(() => _relation = value))),
                                  ],
                                ),
                                _field(colors, pt(lang, 'yourName'), _name),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _field(colors, pt(lang, 'phone'), _phone)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _menu(colors, pt(lang, 'preferredLang'), _serviceLang, '', {
                                      'ca': pt(lang, 'langCa'),
                                      'es': pt(lang, 'langEs'),
                                      'en': pt(lang, 'langEn'),
                                      'fr': pt(lang, 'langFr'),
                                    }, (value) => setState(() => _serviceLang = value ?? _serviceLang))),
                                  ],
                                ),
                                _field(colors, pt(lang, 'email'), _email, readOnly: true),
                                _field(colors, pt(lang, 'address'), _address),
                                _menu(colors, pt(lang, 'parish'), _parish, pt(lang, 'select'), {
                                  for (final parish in profileParishes) parish: parish,
                                }, (value) => setState(() => _parish = value), last: true),
                              ],
                            ),
                          ),
                          _label(colors, pt(lang, 'myKids'), key: _kidsAnchor),
                          for (var i = 0; i < _kids.length; i++)
                            _KidCard(
                              colors: colors,
                              lang: lang,
                              kid: _kids[i],
                              color: _kidColors[i % _kidColors.length],
                              imageTag: _imageTag(lang),
                              onEdit: () => _editKid(i, lang, colors),
                            ),
                          OutlinedButton(
                            onPressed: () => setState(() {
                              _kids.add(_Kid(name: pt(lang, 'newKid'), needsDetails: true));
                            }),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.brun,
                              side: BorderSide(color: colors.brun, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5),
                            ),
                            child: Text(pt(lang, 'addInfant')),
                          ),
                          const SizedBox(height: 88),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: FilledButton(
                    onPressed: _saving ? null : () => _save(lang),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.mentaD,
                      disabledBackgroundColor: colors.mentaD.withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                        : Text(pt(lang, 'saveChanges')),
                  ),
                ),
                if (_toast)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 84,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(999)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          child: Text(pt(lang, 'saved'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: colors.bg)),
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

  String _relationKey(String key) {
    switch (key) {
      case 'mare':
        return 'relMare';
      case 'pare':
        return 'relPare';
      case 'tutor':
        return 'relTutor';
      case 'avi':
        return 'relAvi';
      default:
        return 'relAltre';
    }
  }

  String _imageTag(AppLang lang) {
    switch (_consent) {
      case 'corporatiu':
        return pt(lang, 'imageCorp');
      case 'cap':
        return pt(lang, 'imageNone');
      default:
        return pt(lang, 'imageChat');
    }
  }

  Widget _label(_ProfileColors colors, String text, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 11),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 1.4, color: colors.mentaD),
      ),
    );
  }

  Widget _card(_ProfileColors colors, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
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

  Widget _field(_ProfileColors colors, String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
            decoration: _input(colors),
          ),
        ],
      ),
    );
  }

  Widget _menu(
    _ProfileColors colors,
    String label,
    String? value,
    String hint,
    Map<String, String> options,
    ValueChanged<String?> onChanged, {
    bool last = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.line, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options.containsKey(value) ? value : null,
                hint: Text(hint, style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.text2)),
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colors.card,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
                items: [
                  for (final entry in options.entries) DropdownMenuItem(value: entry.key, child: Text(entry.value, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(_ProfileColors colors) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: colors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.line, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.menta, width: 1.5)),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.line, width: 1.5)),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({required this.colors, required this.title, required this.onBack});

  final _ProfileColors colors;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(
          children: [
            Material(
              color: colors.menta15,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink))),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.colors, required this.initial, required this.name, required this.email});

  final _ProfileColors colors;
  final String initial;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.menta, borderRadius: BorderRadius.circular(20)),
            child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 28, color: Color(0xFF2C3A33))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: colors.ink)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KidCard extends StatelessWidget {
  const _KidCard({
    required this.colors,
    required this.lang,
    required this.kid,
    required this.color,
    required this.imageTag,
    required this.onEdit,
  });

  final _ProfileColors colors;
  final AppLang lang;
  final _Kid kid;
  final Color color;
  final String imageTag;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final initial = kid.name.trim().isEmpty ? '?' : kid.name.trim()[0].toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
            child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 21, color: Colors.white)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kid.name, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink)),
                const SizedBox(height: 1),
                Text(kid.ageLabel(lang), style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (kid.needsDetails)
                      _tag(colors, pt(lang, 'fillKid'), warn: true)
                    else
                      _tag(
                        colors,
                        kid.allergy ? (kid.notes.trim().isEmpty ? pt(lang, 'allergyTag') : kid.notes.trim()) : pt(lang, 'noAllergy'),
                        warn: kid.allergy,
                      ),
                    _tag(colors, imageTag, warn: false),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: colors.menta15,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 34, height: 34, child: Icon(Icons.edit_outlined, size: 16, color: colors.brun)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(_ProfileColors colors, String text, {required bool warn}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: warn ? const Color(0x29A98E7B) : colors.menta15,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, color: warn ? colors.brun : colors.text)),
    );
  }
}

class _KidEditor extends StatefulWidget {
  const _KidEditor({required this.kid, required this.lang, required this.colors});

  final _Kid kid;
  final AppLang lang;
  final _ProfileColors colors;

  @override
  State<_KidEditor> createState() => _KidEditorState();
}

class _KidEditorState extends State<_KidEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.kid.name);
  late final TextEditingController _notes = TextEditingController(text: widget.kid.notes);
  late int? _day = widget.kid.day;
  late int? _month = widget.kid.month;
  late int? _year = widget.kid.year;
  late bool _allergy = widget.kid.allergy;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final lang = widget.lang;
    final months = profileMonths(lang);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(pt(lang, 'editKid'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.ink)),
          const SizedBox(height: 14),
          TextField(
            controller: _name,
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
            decoration: InputDecoration(labelText: pt(lang, 'kidName'), labelStyle: TextStyle(fontFamily: 'Nunito', color: colors.text2)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _numMenu(colors, pt(lang, 'day'), _day, 1, 31, (value) => setState(() => _day = value))),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: _month,
                  isExpanded: true,
                  hint: Text(pt(lang, 'month'), style: TextStyle(fontFamily: 'Nunito', color: colors.text2)),
                  items: [for (var i = 0; i < months.length; i++) DropdownMenuItem(value: i + 1, child: Text(months[i]))],
                  onChanged: (value) => setState(() => _month = value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _numMenu(colors, pt(lang, 'year'), _year, DateTime.now().year - 17, DateTime.now().year, (value) => setState(() => _year = value))),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(pt(lang, 'allergy'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: colors.ink)),
            value: _allergy,
            activeThumbColor: colors.mentaD,
            onChanged: (value) => setState(() => _allergy = value),
          ),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 3,
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
            decoration: InputDecoration(hintText: pt(lang, 'allergyHint'), hintStyle: TextStyle(fontFamily: 'Nunito', color: colors.text2)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.mentaD, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              Navigator.pop(
                context,
                _Kid(
                  name: _name.text.trim().isEmpty ? widget.kid.name : _name.text.trim(),
                  day: _day,
                  month: _month,
                  year: _year,
                  allergy: _allergy,
                  notes: _notes.text.trim(),
                ),
              );
            },
            child: Text(pt(lang, 'saveChanges'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _numMenu(_ProfileColors colors, String hint, int? value, int from, int to, ValueChanged<int?> onChanged) {
    return DropdownButton<int>(
      value: value,
      isExpanded: true,
      hint: Text(hint, style: TextStyle(fontFamily: 'Nunito', color: colors.text2, fontSize: 13)),
      items: [for (var n = from; n <= to; n++) DropdownMenuItem(value: n, child: Text('$n'))],
      onChanged: onChanged,
    );
  }
}

class _ProfileColors {
  const _ProfileColors({
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
  final Color shadow;

  static const light = _ProfileColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    shadow: Color(0x0D000000),
  );

  static const dark = _ProfileColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    brun: Color(0xFFA98E7B),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    shadow: Color(0x66000000),
  );

  static _ProfileColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

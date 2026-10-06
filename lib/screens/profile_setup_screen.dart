import 'package:flutter/material.dart';

import '../l10n/profile_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _KidFields {
  final name = TextEditingController();
  final notes = TextEditingController();
  int? day;
  int? month;
  int? year;
  bool? allergy;

  void dispose() {
    name.dispose();
    notes.dispose();
  }
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _relations = ['mare', 'pare', 'tutor', 'avi', 'altre'];

  int _step = 1;
  bool _done = false;
  bool _busy = false;
  String? _error;

  final _email = TextEditingController();
  final _family = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _petsDetail = TextEditingController();
  final _idNumber = TextEditingController();
  final _nationality = TextEditingController();
  final _kids = [_KidFields()];

  String? _relation;
  String _serviceLang = 'ca';
  String? _parish;
  bool? _pets;
  String _consent = 'xat';
  String? _source;
  String? _idType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final email = AppScope.of(context).user?.email ?? '';
    if (_email.text != email) _email.text = email;
  }

  @override
  void dispose() {
    _email.dispose();
    _family.dispose();
    _fullName.dispose();
    _phone.dispose();
    _address.dispose();
    _petsDetail.dispose();
    _idNumber.dispose();
    _nationality.dispose();
    for (final kid in _kids) {
      kid.dispose();
    }
    super.dispose();
  }

  Future<void> _next() async {
    if (_busy) return;
    if (_step < 4) {
      setState(() => _step += 1);
      return;
    }
    final state = AppScope.of(context);
    final account = state.user;
    if (account == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final displayName = _fullName.text.trim().isEmpty ? account.nombre : _fullName.text.trim();
    final error = await state.completeFatherProfile(
      displayName: displayName,
      telefono: _phone.text.trim(),
      direccion: _address.text.trim(),
      idioma: _serviceLang,
      perfil: {
        'apellidoFamilia': _family.text.trim(),
        'nombreCompleto': displayName,
        'parentiu': _relation,
        'telefono': _phone.text.trim(),
        'idiomaServicio': _serviceLang,
        'direccion': _address.text.trim(),
        'parroquia': _parish,
        'animales': _pets == true,
        'animalesDetalle': _pets == true ? _petsDetail.text.trim() : '',
        'infants': [
          for (final kid in _kids)
            {
              'nombre': kid.name.text.trim(),
              'dia': kid.day,
              'mes': kid.month,
              'any': kid.year,
              'allergia': kid.allergy == true,
              'notes': kid.notes.text.trim(),
            },
        ],
        'consentimentImatge': _consent,
        'comEnsVauConeixer': _source,
        'documentTipus': _idType,
        'documentNumero': _idNumber.text.trim(),
        'nacionalitat': _nationality.text.trim(),
      },
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    setState(() {
      _busy = false;
      _done = true;
    });
  }

  void _enterApp() {
    final account = AppScope.of(context).user;
    if (account != null) account.perfilCompleto = true;
    Navigator.of(context).pushReplacementNamed('/father');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _ProfileColors.of(context);
    final lang = state.lang;
    return Theme(
      data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(fontFamily: 'NunitoSans', bodyColor: colors.ink)),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  if (!_done) _TopBar(colors: colors, lang: lang, step: _step, onLang: state.setLang),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOut,
                      child: _done
                          ? _Done(colors: colors, lang: lang, onEnter: _enterApp)
                          : ListView(
                              key: ValueKey(_step),
                              padding: const EdgeInsets.fromLTRB(22, 8, 22, 26),
                              children: [
                                if (_step == 1) ..._stepOne(colors, lang),
                                if (_step == 2) ..._stepTwo(colors, lang),
                                if (_step == 3) ..._stepThree(colors, lang),
                                if (_step == 4) ..._stepFour(colors, lang),
                              ],
                            ),
                    ),
                  ),
                  if (!_done)
                    _Nav(
                      colors: colors,
                      backLabel: '←',
                      nextLabel: _step == 4 ? pt(lang, 'create') : pt(lang, 'continue'),
                      showBack: _step > 1,
                      busy: _busy,
                      onBack: () => setState(() => _step -= 1),
                      onNext: _next,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _stepOne(_ProfileColors colors, AppLang lang) {
    return [
      _Title(colors: colors, title: pt(lang, 'hello'), subtitle: pt(lang, 'helloSub')),
      _LabeledField(colors: colors, label: pt(lang, 'familyName'), child: _TextInput(colors: colors, controller: _family, hint: pt(lang, 'familyHint'))),
      _LabeledField(colors: colors, label: pt(lang, 'fullName'), child: _TextInput(colors: colors, controller: _fullName, hint: pt(lang, 'fullHint'))),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'relation'),
        child: _Chips(
          colors: colors,
          selected: _relation,
          options: [
            for (final key in _relations) _Option(key, pt(lang, 'rel${key[0].toUpperCase()}${key.substring(1)}')),
          ],
          onSelect: (value) => setState(() => _relation = value),
        ),
      ),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'phone'),
        child: _TextInput(colors: colors, controller: _phone, hint: pt(lang, 'phoneHint'), keyboard: TextInputType.phone),
      ),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'email'),
        optional: pt(lang, 'emailFrom'),
        child: _TextInput(colors: colors, controller: _email, readOnly: true),
      ),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'serviceLang'),
        child: _Chips(
          colors: colors,
          selected: _serviceLang,
          options: const [
            _Option('ca', ''),
            _Option('es', ''),
            _Option('en', ''),
            _Option('fr', ''),
          ].map((option) {
            final label = switch (option.value) {
              'ca' => pt(lang, 'langCa'),
              'es' => pt(lang, 'langEs'),
              'en' => pt(lang, 'langEn'),
              _ => pt(lang, 'langFr'),
            };
            return _Option(option.value, label);
          }).toList(),
          onSelect: (value) => setState(() => _serviceLang = value),
        ),
      ),
    ];
  }

  List<Widget> _stepTwo(_ProfileColors colors, AppLang lang) {
    return [
      _Title(colors: colors, title: pt(lang, 'where'), subtitle: pt(lang, 'whereSub')),
      _LabeledField(colors: colors, label: pt(lang, 'address'), child: _TextInput(colors: colors, controller: _address, hint: pt(lang, 'addressHint'))),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'parish'),
        child: _MenuField(
          colors: colors,
          value: _parish,
          hint: pt(lang, 'select'),
          options: [for (final parish in profileParishes) _Option(parish, parish)],
          onChanged: (value) => setState(() => _parish = value),
        ),
      ),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'pets'),
        child: Column(
          children: [
            _Toggle(
              colors: colors,
              value: _pets,
              no: pt(lang, 'no'),
              yes: pt(lang, 'yes'),
              onChanged: (value) => setState(() => _pets = value),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.ease,
              alignment: Alignment.topCenter,
              child: _pets == true
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _TextInput(colors: colors, controller: _petsDetail, hint: pt(lang, 'petsHint')),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _stepThree(_ProfileColors colors, AppLang lang) {
    return [
      _Title(colors: colors, title: pt(lang, 'kidsTitle'), subtitle: pt(lang, 'kidsSub')),
      for (var i = 0; i < _kids.length; i++)
        _KidCard(
          key: ObjectKey(_kids[i]),
          colors: colors,
          lang: lang,
          index: i + 1,
          kid: _kids[i],
          canRemove: _kids.length > 1,
          onChanged: () => setState(() {}),
          onRemove: () {
            final kid = _kids.removeAt(i);
            kid.dispose();
            setState(() {});
          },
        ),
      _AddButton(
        colors: colors,
        label: pt(lang, 'addKid'),
        onPressed: () => setState(() => _kids.add(_KidFields())),
      ),
    ];
  }

  List<Widget> _stepFour(_ProfileColors colors, AppLang lang) {
    return [
      _Title(colors: colors, title: pt(lang, 'almost'), subtitle: pt(lang, 'almostSub')),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'consent'),
        child: Column(
          children: [
            _ConsentCard(
              colors: colors,
              emoji: '🌤️',
              title: pt(lang, 'consentCorp'),
              body: pt(lang, 'consentCorpSub'),
              selected: _consent == 'corporatiu',
              onTap: () => setState(() => _consent = 'corporatiu'),
            ),
            const SizedBox(height: 10),
            _ConsentCard(
              colors: colors,
              emoji: '💬',
              title: pt(lang, 'consentChat'),
              body: pt(lang, 'consentChatSub'),
              selected: _consent == 'xat',
              onTap: () => setState(() => _consent = 'xat'),
            ),
            const SizedBox(height: 10),
            _ConsentCard(
              colors: colors,
              emoji: '🚫',
              title: pt(lang, 'consentNone'),
              body: pt(lang, 'consentNoneSub'),
              selected: _consent == 'cap',
              onTap: () => setState(() => _consent = 'cap'),
            ),
          ],
        ),
      ),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'source'),
        optional: pt(lang, 'optional'),
        child: _Chips(
          colors: colors,
          selected: _source,
          options: [
            _Option('instagram', pt(lang, 'srcIg')),
            _Option('recomanacio', pt(lang, 'srcRec')),
            _Option('google', pt(lang, 'srcGoogle')),
            _Option('coneixia', pt(lang, 'srcKnew')),
            _Option('altre', pt(lang, 'relAltre')),
          ],
          onSelect: (value) => setState(() => _source = value),
        ),
      ),
      _LabeledField(
        colors: colors,
        label: pt(lang, 'idDoc'),
        optional: pt(lang, 'idFor'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MenuField(
                    colors: colors,
                    value: _idType,
                    hint: pt(lang, 'idType'),
                    options: [
                      _Option('passaport', pt(lang, 'passport')),
                      _Option('dni', pt(lang, 'dni')),
                      _Option('altre', pt(lang, 'relAltre')),
                    ],
                    onChanged: (value) => setState(() => _idType = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _TextInput(colors: colors, controller: _idNumber, hint: pt(lang, 'idNumber'))),
              ],
            ),
            const SizedBox(height: 12),
            _TextInput(colors: colors, controller: _nationality, hint: pt(lang, 'nationality')),
            const SizedBox(height: 6),
            Text(pt(lang, 'idHint'), style: TextStyle(fontSize: 12.5, color: colors.muted)),
          ],
        ),
      ),
      if (_error != null) Text(_error!, style: TextStyle(color: colors.danger, fontWeight: FontWeight.w700, height: 1.35)),
    ];
  }
}

class _Option {
  const _Option(this.value, this.label);
  final String value;
  final String label;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.colors, required this.lang, required this.step, required this.onLang});

  final _ProfileColors colors;
  final AppLang lang;
  final int step;
  final ValueChanged<AppLang> onLang;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.menta, shape: BoxShape.circle),
                child: const Text('🧸', style: TextStyle(fontSize: 15, height: 1)),
              ),
              const SizedBox(width: 9),
              Text('Mon Cangur', style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 18, color: colors.sageDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.line),
                ),
                child: Row(
                  children: [
                    for (final value in AppLang.values)
                      _LangButton(
                        colors: colors,
                        label: value.name.toUpperCase(),
                        selected: lang == value,
                        onTap: () => onLang(value),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: step / 4,
              minHeight: 6,
              backgroundColor: colors.brownSoft,
              color: colors.sage,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(ptStep(lang, step), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.muted)),
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({required this.colors, required this.label, required this.selected, required this.onTap});

  final _ProfileColors colors;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: selected ? colors.menta : Colors.transparent, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? colors.sageDark : colors.muted)),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.colors, required this.title, required this.subtitle});

  final _ProfileColors colors;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 26, height: 1.15, color: colors.ink)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 14.5, color: colors.muted)),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.colors, required this.label, required this.child, this.optional});

  final _ProfileColors colors;
  final String label;
  final String? optional;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 7),
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontFamily: 'NunitoSans', fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.ink),
                children: [
                  TextSpan(text: label),
                  if (optional != null) TextSpan(text: '  $optional', style: TextStyle(fontWeight: FontWeight.w600, color: colors.muted)),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _TextInput extends StatefulWidget {
  const _TextInput({required this.colors, required this.controller, this.hint, this.keyboard, this.readOnly = false, this.maxLines = 1});

  final _ProfileColors colors;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final bool readOnly;
  final int maxLines;

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _focus.hasFocus ? [BoxShadow(color: colors.mentaSoft, spreadRadius: 4)] : const [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboard,
        maxLines: widget.maxLines,
        style: TextStyle(fontFamily: 'NunitoSans', fontSize: 15.5, color: colors.ink),
        cursorColor: colors.focus,
        decoration: _inputDecoration(colors, widget.hint),
      ),
    );
  }
}

InputDecoration _inputDecoration(_ProfileColors colors, String? hint) {
  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: color, width: 1.5));
  }

  return InputDecoration(
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: colors.card,
    hintStyle: TextStyle(fontFamily: 'NunitoSans', fontSize: 15.5, color: colors.muted.withValues(alpha: 0.7)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    border: border(colors.line),
    enabledBorder: border(colors.line),
    focusedBorder: border(colors.sage),
  );
}

class _Chips extends StatelessWidget {
  const _Chips({required this.colors, required this.options, required this.selected, required this.onSelect});

  final _ProfileColors colors;
  final List<_Option> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _Chip(colors: colors, label: option.label, selected: option.value == selected, onTap: () => onSelect(option.value)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.colors, required this.label, required this.selected, required this.onTap});

  final _ProfileColors colors;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.menta : colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: selected ? colors.sage : colors.line, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            label,
            style: TextStyle(fontFamily: 'NunitoSans', fontSize: 14, fontWeight: FontWeight.w600, color: selected ? colors.sageDark : colors.ink),
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.colors, required this.value, required this.no, required this.yes, required this.onChanged});

  final _ProfileColors colors;
  final bool? value;
  final String no;
  final String yes;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Chip(colors: colors, label: no, selected: value == false, onTap: () => onChanged(false))),
        const SizedBox(width: 8),
        Expanded(child: _Chip(colors: colors, label: yes, selected: value == true, onTap: () => onChanged(true))),
      ],
    );
  }
}

class _MenuField extends StatelessWidget {
  const _MenuField({required this.colors, required this.value, required this.hint, required this.options, required this.onChanged});

  final _ProfileColors colors;
  final String? value;
  final String hint;
  final List<_Option> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      hint: Text(hint, style: TextStyle(fontFamily: 'NunitoSans', fontSize: 15.5, color: colors.muted.withValues(alpha: 0.7))),
      decoration: _inputDecoration(colors, null),
      dropdownColor: colors.card,
      style: TextStyle(fontFamily: 'NunitoSans', fontSize: 15.5, color: colors.ink),
      items: [
        for (final option in options) DropdownMenuItem(value: option.value, child: Text(option.label)),
      ],
      onChanged: onChanged,
    );
  }
}

class _KidCard extends StatelessWidget {
  const _KidCard({
    required this.colors,
    required this.lang,
    required this.index,
    required this.kid,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final _ProfileColors colors;
  final AppLang lang;
  final int index;
  final _KidFields kid;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final months = profileMonths(lang);
    final year = DateTime.now().year;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(ptKid(lang, index), style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 16, color: colors.sageDark)),
              const Spacer(),
              if (canRemove)
                TextButton(
                  onPressed: onRemove,
                  child: Text(pt(lang, 'remove'), style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.w700, fontSize: 13, color: colors.brown)),
                ),
            ],
          ),
          _LabeledField(colors: colors, label: pt(lang, 'kidName'), child: _TextInput(colors: colors, controller: kid.name, hint: pt(lang, 'kidHint'))),
          _LabeledField(
            colors: colors,
            label: pt(lang, 'birth'),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: _MenuField(
                    colors: colors,
                    value: kid.day?.toString(),
                    hint: pt(lang, 'day'),
                    options: [for (var day = 1; day <= 31; day++) _Option('$day', '$day')],
                    onChanged: (value) {
                      kid.day = int.tryParse(value ?? '');
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 12,
                  child: _MenuField(
                    colors: colors,
                    value: kid.month?.toString(),
                    hint: pt(lang, 'month'),
                    options: [for (var month = 1; month <= 12; month++) _Option('$month', months[month - 1])],
                    onChanged: (value) {
                      kid.month = int.tryParse(value ?? '');
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 9,
                  child: _MenuField(
                    colors: colors,
                    value: kid.year?.toString(),
                    hint: pt(lang, 'year'),
                    options: [for (var y = year; y >= 2000; y--) _Option('$y', '$y')],
                    onChanged: (value) {
                      kid.year = int.tryParse(value ?? '');
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
          ),
          _LabeledField(
            colors: colors,
            label: pt(lang, 'allergy'),
            child: Column(
              children: [
                _Toggle(
                  colors: colors,
                  value: kid.allergy,
                  no: pt(lang, 'no'),
                  yes: pt(lang, 'yes'),
                  onChanged: (value) {
                    kid.allergy = value;
                    onChanged();
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.ease,
                  alignment: Alignment.topCenter,
                  child: kid.allergy == true
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _TextInput(colors: colors, controller: kid.notes, hint: pt(lang, 'allergyHint'), maxLines: 3),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.colors,
    required this.emoji,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final _ProfileColors colors;
  final String emoji;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.mentaSoft : colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? colors.sage : colors.line, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22, height: 1.2)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(body, style: TextStyle(fontSize: 13, height: 1.4, color: colors.muted)),
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.colors, required this.label, required this.onPressed});

  final _ProfileColors colors;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.brown,
        side: BorderSide(color: colors.brown, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(13),
        textStyle: const TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.w700, fontSize: 14.5),
      ),
      child: Text(label),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav({
    required this.colors,
    required this.backLabel,
    required this.nextLabel,
    required this.showBack,
    required this.busy,
    required this.onBack,
    required this.onNext,
  });

  final _ProfileColors colors;
  final String backLabel;
  final String nextLabel;
  final bool showBack;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
      child: Row(
        children: [
          if (showBack) ...[
            OutlinedButton(
              onPressed: busy ? null : onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.muted,
                side: BorderSide(color: colors.line, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                textStyle: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 16),
              ),
              child: Text(backLabel),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.sage,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: busy ? null : onNext,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: busy
                        ? const SizedBox(height: 20, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))))
                        : Text(nextLabel, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.colors, required this.lang, required this.onEnter});

  final _ProfileColors colors;
  final AppLang lang;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.menta, shape: BoxShape.circle),
            child: const Text('🎉', style: TextStyle(fontSize: 42, height: 1)),
          ),
          const SizedBox(height: 22),
          Text(pt(lang, 'doneTitle'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 26, color: colors.ink)),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(pt(lang, 'doneSub'), textAlign: TextAlign.center, style: TextStyle(color: colors.muted, fontSize: 16)),
          ),
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.sage,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEnter,
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                  child: Text(pt(lang, 'enterApp'), style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileColors {
  const _ProfileColors({
    required this.bg,
    required this.card,
    required this.sage,
    required this.sageDark,
    required this.menta,
    required this.mentaSoft,
    required this.brown,
    required this.brownSoft,
    required this.ink,
    required this.muted,
    required this.line,
    required this.shadow,
    required this.focus,
    required this.danger,
  });

  final Color bg;
  final Color card;
  final Color sage;
  final Color sageDark;
  final Color menta;
  final Color mentaSoft;
  final Color brown;
  final Color brownSoft;
  final Color ink;
  final Color muted;
  final Color line;
  final Color shadow;
  final Color focus;
  final Color danger;

  static const light = _ProfileColors(
    bg: Color(0xFFF2EFE7),
    card: Color(0xFFFCFBF7),
    sage: Color(0xFF8CA598),
    sageDark: Color(0xFF6E8B7E),
    menta: Color(0xFFB3CFC4),
    mentaSoft: Color(0xFFE4EEE8),
    brown: Color(0xFFA98E7B),
    brownSoft: Color(0xFFEDE4DB),
    ink: Color(0xFF3B403B),
    muted: Color(0xFF6C726B),
    line: Color(0xFFE2DDD1),
    shadow: Color(0x296E8B7E),
    focus: Color(0xFF5F7D70),
    danger: Color(0xFFB3261E),
  );

  static const dark = _ProfileColors(
    bg: Color(0xFF20241F),
    card: Color(0xFF282D26),
    sage: Color(0xFF8CA598),
    sageDark: Color(0xFFB3CFC4),
    menta: Color(0xFFB3CFC4),
    mentaSoft: Color(0xFF2E3A33),
    brown: Color(0xFFA98E7B),
    brownSoft: Color(0xFF33302A),
    ink: Color(0xFFEDEBE2),
    muted: Color(0xFFAAB0A5),
    line: Color(0xFF3A3F37),
    shadow: Color(0x66000000),
    focus: Color(0xFF8CA598),
    danger: Color(0xFFFFB4AB),
  );

  static _ProfileColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

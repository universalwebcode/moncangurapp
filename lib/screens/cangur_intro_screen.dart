import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/cangur_intro_copy.dart';
import '../models/models.dart';
import '../services/child_photo.dart';
import '../widgets/mc_widgets.dart';

class CangurIntroScreen extends StatefulWidget {
  const CangurIntroScreen({super.key});

  @override
  State<CangurIntroScreen> createState() => _CangurIntroScreenState();
}

class _CangurIntroScreenState extends State<CangurIntroScreen> {
  final _scroll = ScrollController();
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _qui = TextEditingController();
  final _work = TextEditingController();
  final _likes = TextEditingController();
  final _strength = TextEditingController();
  final List<String> _languages = [];
  int _step = 1;
  bool _checking = true;
  bool _done = false;
  bool _saving = false;
  String? _photo;
  String? _note;

  static const _mins = {3: 120, 4: 80, 5: 60, 6: 50};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    final state = AppScope.of(context);
    _name.text = state.user?.nombre ?? '';
    final ready = await state.adoptExistingCangurStory();
    if (!mounted) return;
    if (ready) {
      Navigator.pushReplacementNamed(context, '/cangur');
      return;
    }
    setState(() => _checking = false);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _name.dispose();
    _role.dispose();
    _qui.dispose();
    _work.dispose();
    _likes.dispose();
    _strength.dispose();
    super.dispose();
  }

  TextEditingController? get _story {
    switch (_step) {
      case 3:
        return _qui;
      case 4:
        return _work;
      case 5:
        return _likes;
      case 6:
        return _strength;
      default:
        return null;
    }
  }

  bool get _valid {
    if (_step == 1) return _name.text.trim().isNotEmpty;
    final field = _story;
    final min = _mins[_step];
    if (field == null || min == null) return true;
    return field.text.trim().length >= min;
  }

  void _go(int step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _pickPhoto() async {
    final photo = await pickChildPhoto();
    if (!mounted || photo == null) return;
    if (photo.length > 700000) {
      setState(() => _note = ci(AppScope.of(context).lang, 'photoBig'));
      return;
    }
    setState(() {
      _photo = photo;
      _note = null;
    });
  }

  Future<void> _next() async {
    if (!_valid || _saving) return;
    if (_step < 7) {
      _go(_step + 1);
      return;
    }
    final state = AppScope.of(context);
    setState(() => _saving = true);
    final error = await state.completeCangurIntro(
      nombre: _name.text,
      rol: _role.text,
      idiomas: _languages,
      qui: _qui.text,
      trayectoria: _work.text,
      agrada: _likes.text,
      puntFort: _strength.text,
      photoUrl: _photo,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _saving = false);
      state.flash(state.tr(error));
      return;
    }
    setState(() {
      _saving = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).lang;
    final colors = _IntroColors.of(context);
    if (_checking) {
      return Scaffold(backgroundColor: colors.bg, body: const Center(child: CircularProgressIndicator()));
    }
    if (_done) return _doneView(colors, lang);
    final labels = ['', ci(lang, 'welcome'), ci(lang, 'languages'), ci(lang, 'who'), ci(lang, 'experience'), ci(lang, 'withKids'), ci(lang, 'strength'), ci(lang, 'almost')];
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: _step / 7,
                    backgroundColor: colors.menta15,
                    color: colors.mentaD,
                    minHeight: 6,
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                    children: [
                      Text(introStep(lang, _step, labels[_step]).toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.4, color: colors.mentaD)),
                      const SizedBox(height: 14),
                      ..._page(colors, lang),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
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
                          child: Text(ci(lang, 'back'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Opacity(
                          opacity: _valid && !_saving ? 1 : 0.45,
                          child: Material(
                            color: colors.mentaD,
                            borderRadius: BorderRadius.circular(15),
                            child: InkWell(
                              onTap: _saving ? null : _next,
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  _saving ? '...' : (_step == 7 ? ci(lang, 'send') : ci(lang, 'next')),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _page(_IntroColors colors, AppLang lang) {
    switch (_step) {
      case 1:
        return _welcome(colors, lang);
      case 2:
        return _langs(colors, lang);
      case 3:
        return _storyPage(colors, ci(lang, 'whoTitle'), ci(lang, 'whoGuide'), ci(lang, 'whoHint'), _qui, 'cangur-qui', 120, 500, lang);
      case 4:
        return _storyPage(colors, ci(lang, 'workTitle'), ci(lang, 'workGuide'), ci(lang, 'workHint'), _work, 'cangur-work', 80, 450, lang);
      case 5:
        return _storyPage(colors, ci(lang, 'likesTitle'), ci(lang, 'likesGuide'), ci(lang, 'likesHint'), _likes, 'cangur-likes', 60, 350, lang);
      case 6:
        return _storyPage(colors, ci(lang, 'strengthTitle'), ci(lang, 'strengthGuide'), ci(lang, 'strengthHint'), _strength, 'cangur-strength', 50, 300, lang);
      default:
        return [
          Text(ci(lang, 'readyTitle'), style: _title(colors)),
          const SizedBox(height: 8),
          Text(ci(lang, 'readySub'), style: _sub(colors)),
          _guide(colors, '✅', ci(lang, 'readyGuide')),
        ];
    }
  }

  List<Widget> _welcome(_IntroColors colors, AppLang lang) {
    final initial = _name.text.trim().isEmpty ? '?' : _name.text.trim()[0].toUpperCase();
    final bytes = _photoBytes(_photo);
    return [
      Text(ci(lang, 'title1'), style: _title(colors)),
      const SizedBox(height: 8),
      Text(ci(lang, 'sub1'), style: _sub(colors)),
      Row(
        children: [
          Container(
            width: 88,
            height: 88,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFF6E82A6), borderRadius: BorderRadius.circular(26)),
            child: bytes == null
                ? Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 34, color: Colors.white))
                : Image.memory(bytes, width: 88, height: 88, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: const Color(0x1AA98E7B),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _pickPhoto,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.brun.withValues(alpha: 0.3), width: 1.5)),
                      child: Text(ci(lang, _photo == null ? 'addPhoto' : 'changePhoto'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: colors.brun)),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(_note ?? ci(lang, 'photoHint'), style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _field(colors, ci(lang, 'name'), _name, key: const Key('cangur-intro-name')),
      _field(colors, ci(lang, 'role'), _role, hint: ci(lang, 'roleHint'), key: const Key('cangur-rol'), last: true),
    ];
  }

  List<Widget> _langs(_IntroColors colors, AppLang lang) {
    return [
      Text(ci(lang, 'langTitle'), style: _title(colors)),
      const SizedBox(height: 8),
      Text(ci(lang, 'langSub'), style: _sub(colors)),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final language in introLanguages)
            _chip(colors, language, _languages.contains(language), () {
              setState(() {
                if (_languages.contains(language)) {
                  _languages.remove(language);
                } else {
                  _languages.add(language);
                }
              });
            }),
        ],
      ),
    ];
  }

  List<Widget> _storyPage(_IntroColors colors, String title, String guide, String hint, TextEditingController controller, String key, int min, int max, AppLang lang) {
    final count = controller.text.trim().length;
    final short = count > 0 && count < min;
    final counter = short
        ? ci(lang, 'missing').replaceAll('{n}', '$count').replaceAll('{left}', '${min - count}')
        : ci(lang, 'count').replaceAll('{n}', '$count').replaceAll('{max}', '$max');
    return [
      Text(title, style: _title(colors)),
      const SizedBox(height: 16),
      _guide(colors, '💡', guide),
      TextField(
        key: Key(key),
        controller: controller,
        minLines: 6,
        maxLines: 10,
        maxLength: max,
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        onChanged: (_) => setState(() {}),
        style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, height: 1.55, color: colors.ink),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: colors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.line, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.menta, width: 1.6)),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: Text(counter, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: count >= min ? colors.mentaD : (count > max ? const Color(0xFFC0705F) : colors.text2)))),
          Text(ci(lang, 'limit').replaceAll('{min}', '$min').replaceAll('{max}', '$max'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 12.5, color: colors.text2)),
        ],
      ),
    ];
  }

  Widget _doneView(_IntroColors colors, AppLang lang) {
    final name = _name.text.trim();
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
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
                Text(ci(lang, 'doneTitle'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 25, color: colors.ink)),
                const SizedBox(height: 12),
                Text(ci(lang, 'doneBody').replaceAll('{name}', name), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 15, height: 1.6, color: colors.text2)),
                const SizedBox(height: 22),
                Material(
                  color: colors.mentaD,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: () {
                      final state = AppScope.of(context);
                      state.user?.perfilCompleto = true;
                      Navigator.pushReplacementNamed(context, '/cangur');
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                      child: Text(ci(lang, 'enter'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
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

  Widget _field(_IntroColors colors, String label, TextEditingController controller, {String? hint, Key? key, bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.ink)),
          const SizedBox(height: 8),
          TextField(
            key: key,
            controller: controller,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15.5, color: colors.ink),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: colors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.line, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: colors.menta, width: 1.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guide(_IntroColors colors, String icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 17)),
          const SizedBox(width: 11),
          Expanded(child: Text.rich(_marked(text, TextStyle(fontFamily: 'Nunito', fontSize: 13, height: 1.55, color: colors.text), TextStyle(fontFamily: 'Nunito', fontSize: 13, height: 1.55, fontWeight: FontWeight.w800, color: colors.ink)))),
        ],
      ),
    );
  }

  Widget _chip(_IntroColors colors, String label, bool on, VoidCallback tap) {
    return Material(
      color: on ? colors.menta : colors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: on ? const Color(0xFF2C3A33) : colors.text)),
        ),
      ),
    );
  }

  TextStyle _title(_IntroColors colors) => TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 25, height: 1.2, color: colors.ink);

  TextStyle _sub(_IntroColors colors) => TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.55, color: colors.text2);
}

TextSpan _marked(String source, TextStyle base, TextStyle bold) {
  final parts = source.split('**');
  return TextSpan(children: [for (var i = 0; i < parts.length; i++) TextSpan(text: parts[i], style: i.isOdd ? bold : base)]);
}

Uint8List? _photoBytes(String? photo) {
  if (photo == null || !photo.contains(',')) return null;
  try {
    return base64Decode(photo.split(',').last);
  } catch (_) {
    return null;
  }
}

class _IntroColors {
  const _IntroColors({
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

  static const light = _IntroColors(
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

  static const dark = _IntroColors(
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

  static _IntroColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

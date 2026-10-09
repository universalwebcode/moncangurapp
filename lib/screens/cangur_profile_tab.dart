import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/cangur_copy.dart';
import '../l10n/cangur_intro_copy.dart';
import '../l10n/menu_copy.dart';
import '../models/models.dart';
import '../services/child_photo.dart';
import '../widgets/mc_widgets.dart';

const _profileLanguages = ['Català', 'Castellà', 'Anglès', 'Francès', 'Portuguès', 'Alemany'];

class CangurProfileTab extends StatefulWidget {
  const CangurProfileTab({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  State<CangurProfileTab> createState() => _CangurProfileTabState();
}

class _CangurProfileTabState extends State<CangurProfileTab> {
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _qui = TextEditingController();
  final _work = TextEditingController();
  final _likes = TextEditingController();
  final _strength = TextEditingController();
  bool _applied = false;
  bool _saving = false;
  bool _toast = false;
  String? _photo;
  List<String> _languages = [];
  List<String> _photos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_applied) return;
    final state = AppScope.of(context);
    final account = state.user;
    final profile = account == null ? null : state.profileFor(account.id);
    _applied = profile != null || account != null;
    _name.text = profile?.nombre ?? account?.nombre ?? '';
    _role.text = profile?.rol ?? '';
    _qui.text = _filled(profile?.qui, profile?.descripcionPersonal);
    _work.text = profile?.trayectoria ?? '';
    _likes.text = profile?.agrada ?? '';
    _strength.text = profile?.puntFort ?? '';
    _photo = profile?.photoUrl;
    _languages = [...?profile?.idiomas];
    _photos = [...?profile?.fotos];
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _qui.dispose();
    _work.dispose();
    _likes.dispose();
    _strength.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final photo = await pickChildPhoto();
    if (photo == null || !mounted) return;
    setState(() => _photo = photo);
  }

  Future<void> _addGallery() async {
    if (_photos.length >= 6) return;
    final photo = await pickChildPhoto();
    if (photo == null || !mounted) return;
    setState(() => _photos = [..._photos, photo]);
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    final account = state.user;
    if (account == null || _saving) return;
    final current = state.profileFor(account.id);
    final story = _qui.text.trim();
    setState(() => _saving = true);
    final known = {..._profileLanguages, ...introLanguages};
    final languages = _languages.where(known.contains).toList();
    final profile = CangurProfile(
      userId: account.id,
      nombre: _name.text.trim().isEmpty ? account.nombre : _name.text.trim(),
      email: current?.email ?? account.email,
      descripcionPersonal: story,
      tarifaPorHora: current?.tarifaPorHora ?? 0,
      servicios: current?.servicios ?? const [],
      certificaciones: current?.certificaciones ?? const [],
      idiomas: languages,
      week: current?.week ?? const {},
      activo: current?.activo ?? false,
      aniosExperiencia: current?.aniosExperiencia ?? 0,
      photoUrl: _photo,
      slug: current?.slug ?? '',
      rol: _role.text.trim(),
      badge: current?.badge ?? '',
      color: current?.color ?? 0xFF6E82A6,
      qui: story,
      trayectoria: _work.text.trim(),
      agrada: _likes.text.trim(),
      puntFort: _strength.text.trim(),
      habilidades: current?.habilidades,
      fotos: _photos,
      exceptions: current?.exceptions,
    );
    final error = await state.saveCangurProfile(profile);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _toast = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _Look.of(context);
    final name = _name.text.trim();
    final initial = name.isEmpty ? 'C' : name[0].toUpperCase();
    final chips = [
      ..._profileLanguages,
      for (final extra in _languages)
        if (!_profileLanguages.contains(extra) && introLanguages.contains(extra)) extra,
    ];
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: colors.bg, border: Border(bottom: BorderSide(color: colors.line))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Material(
                      color: colors.menta15,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: Text(mn(lang, 'profile'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 84,
                            height: 84,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Material(
                                  color: const Color(0xFF6E82A6),
                                  borderRadius: BorderRadius.circular(22),
                                  child: InkWell(
                                    onTap: _pickAvatar,
                                    borderRadius: BorderRadius.circular(22),
                                    child: Ink(
                                      width: 78,
                                      height: 78,
                                      decoration: BoxDecoration(color: const Color(0xFF6E82A6), borderRadius: BorderRadius.circular(22)),
                                      child: ClipRRect(borderRadius: BorderRadius.circular(22), child: _picture(_photo, initial, 78, 30)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(color: colors.mentaD, shape: BoxShape.circle, border: Border.all(color: colors.bg, width: 2.5)),
                                      child: const Icon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: colors.ink)),
                                TextButton(
                                  onPressed: _pickAvatar,
                                  style: TextButton.styleFrom(padding: const EdgeInsets.only(top: 5), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: colors.brun),
                                  child: Text(cg(lang, 'changePhoto'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _title(colors, cg(lang, 'details')),
                      _card(colors, [
                        _field(colors, cg(lang, 'fullName'), _name),
                        _field(colors, cg(lang, 'profession'), _role),
                        Text(cg(lang, 'languages'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final language in chips)
                              _chip(colors, language, _languages.contains(language), () {
                                setState(() {
                                  if (_languages.contains(language)) {
                                    _languages = _languages.where((item) => item != language).toList();
                                  } else {
                                    _languages = [..._languages, language];
                                  }
                                });
                              }),
                          ],
                        ),
                      ]),
                      _title(colors, cg(lang, 'presentation')),
                      _card(colors, [
                        _area(colors, cg(lang, 'whoYou'), _qui, 500, const Key('cangur-qui')),
                        _area(colors, cg(lang, 'whereWorked'), _work, 450, const Key('cangur-work')),
                        _area(colors, cg(lang, 'whatYouLike'), _likes, 350, const Key('cangur-likes')),
                        _area(colors, cg(lang, 'yourStrength'), _strength, 300, const Key('cangur-strength'), last: true),
                      ]),
                      _title(colors, cg(lang, 'gallery')),
                      _card(colors, [
                        Text(cg(lang, 'galleryHint'), style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, height: 1.5, color: colors.text2)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 9,
                          crossAxisSpacing: 9,
                          children: [
                            for (var i = 0; i < _photos.length; i++)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ColoredBox(color: colors.menta15, child: _cover(_photos[i])),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Material(
                                        color: const Color(0x8C000000),
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          onTap: () => setState(() => _photos = [..._photos]..removeAt(i)),
                                          customBorder: const CircleBorder(),
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Icon(Icons.close, size: 13, color: Colors.white, semanticLabel: cg(lang, 'removePhoto')),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_photos.length < 6)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _addGallery,
                                  borderRadius: BorderRadius.circular(13),
                                  child: CustomPaint(
                                    painter: _DashedBorder(colors.brun),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, color: colors.brun, size: 22),
                                          const SizedBox(height: 3),
                                          Text(cg(lang, 'addPhoto'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.brun)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ]),
                    ],
                  ),
                  if (_toast)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 8,
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(999)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            child: Text('${cg(lang, 'saved')} ✓', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: colors.bg)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
                      child: Text(cg(lang, 'save'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(_Look colors, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 11),
      child: Text(text.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.6, color: colors.mentaD)),
    );
  }

  Widget _card(_Look colors, List<Widget> children) {
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _field(_Look colors, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
            decoration: _input(colors),
          ),
        ],
      ),
    );
  }

  Widget _area(_Look colors, String label, TextEditingController controller, int max, Key key, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text2))),
              Text('${controller.text.length} / $max', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12.5, color: colors.text2)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            key: key,
            controller: controller,
            onChanged: (_) => setState(() {}),
            maxLength: max,
            minLines: 4,
            maxLines: 8,
            style: TextStyle(fontFamily: 'Nunito', fontSize: 15, height: 1.55, color: colors.ink),
            decoration: _input(colors).copyWith(counterText: ''),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(_Look colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.bg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.line, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.line, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.menta, width: 1.5)),
    );
  }

  Widget _chip(_Look colors, String label, bool on, VoidCallback onTap) {
    return Material(
      color: on ? colors.menta : colors.bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5),
          ),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: on ? const Color(0xFF2C3A33) : colors.text)),
        ),
      ),
    );
  }
}

String _filled(String? primary, String? fallback) {
  final first = primary?.trim() ?? '';
  if (first.isNotEmpty) return first;
  return fallback?.trim() ?? '';
}

Widget _picture(String? photo, String letter, double size, double font) {
  final bytes = _bytes(photo);
  if (bytes != null) return Image.memory(bytes, width: size, height: size, fit: BoxFit.cover);
  if (photo != null && photo.startsWith('http')) {
    return Image.network(
      photo,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _letter(letter, font),
    );
  }
  return _letter(letter, font);
}

Widget _cover(String? photo) {
  final bytes = _bytes(photo);
  if (bytes != null) return Image.memory(bytes, fit: BoxFit.cover);
  if (photo != null && photo.startsWith('http')) {
    return Image.network(photo, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const SizedBox.expand());
  }
  return const SizedBox.expand();
}

Widget _letter(String letter, double font) {
  return Center(child: Text(letter, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: font, color: Colors.white)));
}

Uint8List? _bytes(String? photo) {
  if (photo == null || !photo.contains(',')) return null;
  try {
    return base64Decode(photo.split(',').last);
  } catch (_) {
    return null;
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(13)));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder oldDelegate) => oldDelegate.color != color;
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
    required this.brun,
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
    brun: Color(0xFFA98E7B),
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
    brun: Color(0xFFA98E7B),
    shadow: Color(0x66000000),
  );

  static _Look of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

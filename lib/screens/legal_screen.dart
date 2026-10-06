import 'package:flutter/material.dart';

import '../l10n/legal_docs.dart';
import '../l10n/menu_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({this.section = LegalSection.terms, super.key});

  final LegalSection section;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late LegalSection _section = widget.section;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(LegalSection section) {
    if (section == _section) return;
    setState(() => _section = section);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).lang;
    final colors = _LegalColors.of(context);
    final doc = legalDocument(_section, lang);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Column(
                      children: [
                        Row(
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
                            Text(mn(lang, 'legal'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 19, color: colors.ink)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _tab(colors, lang, LegalSection.terms, 'terms'),
                              const SizedBox(width: 7),
                              _tab(colors, lang, LegalSection.privacy, 'privacy'),
                              const SizedBox(width: 7),
                              _tab(colors, lang, LegalSection.cancel, 'cancel'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
                    children: [
                      Text(doc.title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, height: 1.2, color: colors.ink)),
                      const SizedBox(height: 4),
                      Text(doc.updated, style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2)),
                      const SizedBox(height: 22),
                      for (final block in doc.blocks) _block(colors, block),
                      if (doc.footer != null) ...[
                        const SizedBox(height: 22),
                        Text(doc.footer!, style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2)),
                      ],
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

  Widget _tab(_LegalColors colors, AppLang lang, LegalSection section, String key) {
    final on = _section == section;
    return Material(
      color: on ? colors.menta : colors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => _open(section),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5),
          ),
          child: Text(
            mn(lang, key),
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13.5, color: on ? const Color(0xFF2C3A33) : colors.text2),
          ),
        ),
      ),
    );
  }

  Widget _block(_LegalColors colors, LegalBlock block) {
    switch (block.kind) {
      case 'h':
        return Padding(
          padding: EdgeInsets.only(top: block.small ? 16 : 24, bottom: block.small ? 6 : 8),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: block.small ? 14 : 16,
              color: block.small ? colors.brun : colors.ink,
            ),
          ),
        );
      case 'l':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [for (final item in block.items) _bullet(colors, item)],
          ),
        );
      case 'f':
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final row in block.rows)
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 14, height: 1.7, color: colors.text),
                    children: [
                      TextSpan(text: '${row.$1}: ', style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink)),
                      TextSpan(text: row.$2),
                    ],
                  ),
                ),
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Text.rich(TextSpan(children: _spans(colors, block.text, 14.5, 1.65))),
        );
    }
  }

  Widget _bullet(_LegalColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(top: 9, right: 11, left: 2),
            decoration: BoxDecoration(color: colors.mentaD, shape: BoxShape.circle),
          ),
          Expanded(child: Text.rich(TextSpan(children: _spans(colors, text, 14.5, 1.6)))),
        ],
      ),
    );
  }

  List<InlineSpan> _spans(_LegalColors colors, String text, double size, double height) {
    final parts = text.split('**');
    return [
      for (var i = 0; i < parts.length; i++)
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: size,
            height: height,
            fontWeight: i.isOdd ? FontWeight.w800 : FontWeight.w500,
            color: i.isOdd ? colors.ink : colors.text,
          ),
        ),
    ];
  }
}

class _LegalColors {
  const _LegalColors({
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

  static const light = _LegalColors(
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
  );

  static const dark = _LegalColors(
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
  );

  static _LegalColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

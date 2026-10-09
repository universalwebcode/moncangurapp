import 'package:flutter/material.dart';

import '../data/team_cangurs.dart';
import '../l10n/cangur_copy.dart';
import '../l10n/home_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'reserva_screen.dart';

class TeamStrip extends StatelessWidget {
  const TeamStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _TeamColors.of(context);
    final people = showcaseTeam(state.canguros);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hm(lang, 'teamEyebrow').toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 2.2, color: colors.menta)),
          const SizedBox(height: 9),
          Text(hm(lang, 'teamTitle'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 28, height: 1.15, color: colors.ink)),
          const SizedBox(height: 7),
          Text(hm(lang, 'teamSub'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2)),
          const SizedBox(height: 14),
          for (final person in people) ...[
            _TeamCard(colors: colors, person: person, lang: lang),
            const SizedBox(height: 13),
          ],
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.colors, required this.person, required this.lang});

  final _TeamColors colors;
  final TeamStory person;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeamCangurScreen(slug: person.slug))),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.line, width: 1.5),
            boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(person: person, size: 62, radius: 17, fontSize: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(person.nombre, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink)),
                        if (person.badge.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: colors.brun, borderRadius: BorderRadius.circular(999)),
                            child: Text(
                              ct(lang, 'founder').toUpperCase(),
                              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 10.5, letterSpacing: 0.4, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    if (person.rol.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(person.rol, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, height: 1.4, color: colors.text2)),
                    ],
                    if (person.idiomas.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          for (final language in person.idiomas)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(999)),
                              child: Text(language, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11, color: colors.text)),
                            ),
                        ],
                      ),
                    ],
                    if (person.puntFort.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 13, height: 1.45, color: colors.text),
                          children: [
                            TextSpan(text: '${hm(lang, 'strength')}: ', style: TextStyle(fontWeight: FontWeight.w800, color: colors.brun)),
                            TextSpan(text: person.puntFort),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Text(hm(lang, 'see'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.menta)),
                        Icon(Icons.chevron_right, size: 16, color: colors.menta),
                      ],
                    ),
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

class TeamCangurScreen extends StatefulWidget {
  const TeamCangurScreen({required this.slug, super.key});

  final String slug;

  @override
  State<TeamCangurScreen> createState() => _TeamCangurScreenState();
}

class _TeamCangurScreenState extends State<TeamCangurScreen> {
  late String _slug = widget.slug;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(String slug) {
    setState(() => _slug = slug);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _TeamColors.of(context);
    final people = showcaseTeam(state.canguros);
    final person = people.where((item) => item.slug == _slug).firstOrNull ?? people.first;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
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
                        Expanded(
                          child: Text(ct(lang, 'title'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.ink)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    children: [
                      Center(child: _Avatar(person: person, size: 104, radius: 32, fontSize: 44)),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 9,
                        runSpacing: 6,
                        children: [
                          Text(person.nombre, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 26, height: 1.1, color: colors.ink)),
                          if (person.badge.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: colors.brun, borderRadius: BorderRadius.circular(999)),
                              child: Text(
                                ct(lang, 'founder'),
                                style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.4, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      if (person.rol.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(person.rol, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, color: colors.text2)),
                      ],
                      if (person.idiomas.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final language in person.idiomas)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(999)),
                                child: Text(language, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.text)),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 22),
                      _Section(colors: colors, emoji: '🌿', title: ct(lang, 'qui'), body: person.qui),
                      _Section(colors: colors, emoji: '💼', title: ct(lang, 'work'), body: person.trayectoria),
                      _Section(colors: colors, emoji: '🎨', title: ct(lang, 'likes'), body: person.agrada),
                      _Section(colors: colors, emoji: '⭐', title: ct(lang, 'strength'), body: person.puntFort),
                      const SizedBox(height: 10),
                      Text(
                        ct(lang, 'others').toUpperCase(),
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.4, color: colors.mentaD),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: people.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final other = people[index];
                            final selected = other.slug == person.slug;
                            return InkWell(
                              onTap: () => _open(other.slug),
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 64,
                                child: Column(
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: selected ? colors.menta : Colors.transparent, width: 3),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: _Avatar(person: other, size: 54, radius: 16, fontSize: 21),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      other.firstName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, color: colors.text2),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.mentaD,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: colors.mentaD.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReservaScreen(initialCangurId: person.userId))),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            ct(lang, 'book'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16.5, color: Colors.white),
                          ),
                        ),
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
}

class _Section extends StatelessWidget {
  const _Section({required this.colors, required this.emoji, required this.title, required this.body});

  final _TeamColors colors;
  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line, width: 1.5),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 9),
              Expanded(child: Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: colors.ink))),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.62, color: colors.text)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person, required this.size, required this.radius, required this.fontSize});

  final TeamStory person;
  final double size;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final letter = person.firstName.isEmpty ? '?' : person.firstName.substring(0, 1).toUpperCase();
    final fallback = ColoredBox(
      color: Color(person.color),
      child: Center(child: Text(letter, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: fontSize, color: Colors.white))),
    );
    final photo = person.photoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: photo == null || photo.isEmpty ? fallback : Image.network(photo, fit: BoxFit.cover, errorBuilder: (context, error, stack) => fallback),
      ),
    );
  }
}

class _TeamColors {
  const _TeamColors({
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

  static const light = _TeamColors(
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
    shadow: Color(0x0D000000),
  );

  static const dark = _TeamColors(
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
    shadow: Color(0x66000000),
  );

  static _TeamColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

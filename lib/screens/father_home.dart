import 'package:flutter/material.dart';

import '../l10n/home_copy.dart';
import '../l10n/reserva_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'event_form_screen.dart';
import 'extra_form_screen.dart';
import 'fix_form_screen.dart';
import 'reserva_screen.dart';
import 'team_cangur_screen.dart';

const _order = ['ocasional', 'emergencia', 'eventos', 'fijo', 'repaso'];

const _photos = {
  'ocasional': 'assets/images/serveis/ocasional.jpg',
  'emergencia': 'assets/images/serveis/urgencia.jpg',
  'eventos': 'assets/images/serveis/esdeveniments.jpg',
  'fijo': 'assets/images/serveis/fix.jpg',
  'repaso': 'assets/images/serveis/repas.jpg',
};

class FatherServicesTab extends StatefulWidget {
  const FatherServicesTab({required this.onOpenMenu, super.key});

  final VoidCallback onOpenMenu;

  @override
  State<FatherServicesTab> createState() => _FatherServicesTabState();
}

class _FatherServicesTabState extends State<FatherServicesTab> {
  final _page = PageController(viewportFraction: 0.86);
  int _pageIndex = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  List<ServiceOffer> _ordered(List<ServiceOffer> services) {
    final copy = [...services];
    copy.sort((a, b) {
      final left = _order.indexOf(a.tipoServicio);
      final right = _order.indexOf(b.tipoServicio);
      return (left < 0 ? 99 : left).compareTo(right < 0 ? 99 : right);
    });
    return copy;
  }

  void _open(ServiceOffer service) {
    final colors = _HomeLook.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceSheet(service: service, colors: colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _HomeLook.of(context);
    final services = _ordered(state.services);
    if (_pageIndex >= services.length) _pageIndex = 0;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 36),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset('assets/images/serveis/mark.jpg', width: 42, height: 42, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mon Cangur', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, height: 1, color: colors.ink)),
                        const SizedBox(height: 2),
                        Text(hm(lang, 'place'), style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2)),
                      ],
                    ),
                  ),
                  Material(
                    color: colors.menta15,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      onTap: widget.onOpenMenu,
                      borderRadius: BorderRadius.circular(13),
                      child: SizedBox(width: 42, height: 42, child: Icon(Icons.menu, color: colors.ink)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hm(lang, 'eyebrow').toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 2.2, color: colors.menta)),
                  const SizedBox(height: 9),
                  Text(hm(lang, 'title'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 28, height: 1.15, color: colors.ink)),
                  const SizedBox(height: 7),
                  Text(hm(lang, 'sub'), style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.5, color: colors.text2)),
                ],
              ),
            ),
            if (services.isNotEmpty)
              SizedBox(
                height: 310,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _page,
                      itemCount: services.length,
                      onPageChanged: (value) => setState(() => _pageIndex = value),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: _ServiceCard(colors: colors, service: service, lang: lang, onTap: () => _open(service)),
                        );
                      },
                    ),
                    Positioned(left: 6, top: 135, child: _Arrow(colors: colors, icon: Icons.chevron_left, enabled: _pageIndex > 0, onTap: () => _page.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut))),
                    Positioned(right: 6, top: 135, child: _Arrow(colors: colors, icon: Icons.chevron_right, enabled: _pageIndex < services.length - 1, onTap: () => _page.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut))),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < services.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _pageIndex ? 22 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    decoration: BoxDecoration(color: i == _pageIndex ? colors.menta : colors.line, borderRadius: BorderRadius.circular(999)),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF8CA598),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x668CA598), blurRadius: 20, offset: Offset(0, 8))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservaScreen())),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('✨ ${hm(lang, 'book')}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16.5, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
            const TeamStrip(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                children: [
                  Text(hm(lang, 'closing'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, height: 1.4, color: colors.ink)),
                  const SizedBox(height: 2),
                  Text(hm(lang, 'closingSub'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, color: colors.text2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.colors, required this.service, required this.lang, required this.onTap});

  final _HomeLook colors;
  final ServiceOffer service;
  final AppLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final proposal = service.tipoServicio == 'fijo' || service.tipoServicio == 'repaso' || service.tipoServicio == 'eventos';
    return Material(
      color: colors.line,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 310,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _photo(service),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0014100C), Color(0x2614100C), Color(0xB814100C)],
                    stops: [0.34, 0.58, 0.98],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title(lang, service), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, height: 1.08, color: Colors.white)),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xEBFFFFFF), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 14, color: colors.ink),
                          const SizedBox(width: 5),
                          Text(hm(lang, proposal ? 'ask' : 'more'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, color: colors.ink)),
                        ],
                      ),
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

  Widget _photo(ServiceOffer service) {
    final asset = _photos[service.tipoServicio];
    if (asset != null) return Image.asset(asset, fit: BoxFit.cover);
    final image = service.image;
    if (image == null || image.isEmpty) return ColoredBox(color: colors.menta);
    return Image.network(image, fit: BoxFit.cover, errorBuilder: (context, error, stack) => ColoredBox(color: colors.menta));
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.colors, required this.icon, required this.enabled, required this.onTap});

  final _HomeLook colors;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.32,
      child: Material(
        color: colors.arrow,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 40, height: 40, child: Icon(icon, color: Colors.white)),
        ),
      ),
    );
  }
}

class _ServiceSheet extends StatelessWidget {
  const _ServiceSheet({required this.service, required this.colors});

  final ServiceOffer service;
  final _HomeLook colors;

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).lang;
    final priced = service.tipoServicio == 'ocasional' || service.tipoServicio == 'emergencia';
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        child: Material(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: colors.line, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(13)),
                    child: Icon(_icon(service.tipoServicio), color: colors.menta, size: 24),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title(lang, service), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, height: 1.1, color: colors.ink)),
                        const SizedBox(height: 2),
                        Text(priced ? hm(lang, 'fromHour', {'n': _plain(_rate(service, 1))}) : hm(lang, 'custom'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: colors.brun)),
                      ],
                    ),
                  ),
                  Material(
                    color: colors.menta15,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: SizedBox(width: 34, height: 34, child: Icon(Icons.close, size: 18, color: colors.ink)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(_description(lang, service), style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.6, color: colors.text)),
              const SizedBox(height: 16),
              if (priced) ...[
                _RateTable(colors: colors, lang: lang, service: service),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(colors: colors, label: hm(lang, 'tagMin'), filled: true),
                    _Tag(colors: colors, label: hm(lang, service.tipoServicio == 'emergencia' ? 'tagNight' : 'tagEach'), filled: false),
                  ],
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, height: 1.5, color: colors.text2),
                    children: [
                      TextSpan(text: hm(lang, 'igiBold'), style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink)),
                      TextSpan(text: hm(lang, 'igiRest')),
                    ],
                  ),
                ),
              ] else if (service.tipoServicio == 'fijo') ...[
                _Module(colors: colors, title: hm(lang, 'agency'), body: hm(lang, 'agencyBody')),
                _Module(colors: colors, title: hm(lang, 'teamMod'), body: hm(lang, 'teamModBody')),
                const SizedBox(height: 8),
                Text(hm(lang, 'fixCtaLine'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.55, color: colors.text)),
                const SizedBox(height: 14),
                _SheetButton(colors: colors, label: '${hm(lang, 'fixCta')}  ✨', onTap: () => _go(context, FixFormScreen(service: service))),
              ] else if (service.tipoServicio == 'repaso') ...[
                Text(hm(lang, 'extraCtaLine'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.55, color: colors.text)),
                const SizedBox(height: 14),
                _SheetButton(colors: colors, label: '${hm(lang, 'extraCta')}  🎨', onTap: () => _go(context, ExtraFormScreen(service: service))),
              ] else ...[
                Text(hm(lang, 'eventCtaLine'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.55, color: colors.text)),
                const SizedBox(height: 14),
                _SheetButton(colors: colors, label: '${hm(lang, 'eventCta')}  ✨', onTap: () => _go(context, EventFormScreen(service: service))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }
}

class _RateTable extends StatelessWidget {
  const _RateTable({required this.colors, required this.lang, required this.service});

  final _HomeLook colors;
  final AppLang lang;
  final ServiceOffer service;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.line)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
          children: [
            TableRow(
              decoration: BoxDecoration(color: colors.menta15),
              children: [
                _cell(hm(lang, 'kids'), colors, header: true),
                _cell('€/h', colors, header: true, align: TextAlign.right),
              ],
            ),
            for (var n = 1; n <= 5; n++)
              TableRow(
                decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.line))),
                children: [
                  _cell(n == 1 ? hm(lang, 'oneChild') : hm(lang, 'manyChildren', {'n': '$n'}), colors),
                  _cell(_euro(lang, _rate(service, n)), colors, align: TextAlign.right, strong: true),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, _HomeLook colors, {bool header = false, TextAlign align = TextAlign.left, bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontFamily: 'Nunito', fontWeight: header || strong ? FontWeight.w800 : FontWeight.w600, fontSize: header ? 12 : 14.5, color: colors.ink),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.colors, required this.label, required this.filled});

  final _HomeLook colors;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? colors.menta15 : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: filled ? null : Border.all(color: colors.line),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, color: colors.text)),
    );
  }
}

class _Module extends StatelessWidget {
  const _Module({required this.colors, required this.title, required this.body});

  final _HomeLook colors;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14.5, color: colors.ink)),
          const SizedBox(height: 3),
          Text(body, style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, height: 1.5, color: colors.text)),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({required this.colors, required this.label, required this.onTap});

  final _HomeLook colors;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.menta,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: colors.menta.withValues(alpha: 0.55), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink)),
          ),
        ),
      ),
    );
  }
}

String _title(AppLang lang, ServiceOffer service) {
  switch (service.tipoServicio) {
    case 'ocasional':
      return rt(lang, 'svcOcasional');
    case 'emergencia':
      return rt(lang, 'svcUrgencia');
    case 'eventos':
      return rt(lang, 'svcEvent');
    case 'fijo':
      return rt(lang, 'svcFix');
    case 'repaso':
      return rt(lang, 'svcExtra');
    default:
      return service.nombre.isNotEmpty ? service.nombre : service.tipoServicio;
  }
}

String _description(AppLang lang, ServiceOffer service) {
  switch (service.tipoServicio) {
    case 'ocasional':
      return hm(lang, 'descOcasional');
    case 'emergencia':
      return hm(lang, 'descUrgent');
    case 'eventos':
      return hm(lang, 'descEvent');
    case 'fijo':
      return hm(lang, 'descFix');
    case 'repaso':
      return hm(lang, 'descExtra');
    default:
      return service.descripcion;
  }
}

IconData _icon(String tipo) {
  switch (tipo) {
    case 'emergencia':
      return Icons.error_outline;
    case 'eventos':
      return Icons.auto_awesome_outlined;
    case 'fijo':
      return Icons.calendar_month_outlined;
    case 'repaso':
      return Icons.menu_book_outlined;
    default:
      return Icons.schedule;
  }
}

double _rate(ServiceOffer service, int children) {
  final key = children < 1 ? 1 : (children > 5 ? 5 : children);
  final mapped = service.tarifasPorNinosConIGI[key] ?? service.tarifasPorNinos[key];
  if (mapped != null) return mapped;
  const ocasional = <double>[0, 25, 28, 32, 38, 45];
  const urgent = <double>[0, 35, 40, 50, 60, 70];
  if (service.tipoServicio == 'emergencia') return urgent[key];
  return ocasional[key];
}

String _plain(double value) => value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(0);

String _euro(AppLang lang, double value) {
  final raw = value.toStringAsFixed(2);
  return '${lang == AppLang.en ? raw : raw.replaceAll('.', ',')} €';
}

class _HomeLook {
  const _HomeLook({
    required this.bg,
    required this.card,
    required this.menta,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
    required this.brun,
    required this.menta15,
    required this.arrow,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color brun;
  final Color menta15;
  final Color arrow;

  static const light = _HomeLook(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    brun: Color(0xFFA98E7B),
    menta15: Color(0x26B3CFC4),
    arrow: Color(0xFF9CAF9F),
  );

  static const dark = _HomeLook(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    brun: Color(0xFFA98E7B),
    menta15: Color(0x1FB3CFC4),
    arrow: Color(0xFF9CAF9F),
  );

  static _HomeLook of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

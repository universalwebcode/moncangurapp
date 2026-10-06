import 'package:flutter/material.dart';

import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'booking_detail_screen.dart';
import 'extra_form_screen.dart';
import 'fix_form_screen.dart';
import 'menu_screen.dart';
import 'reserva_screen.dart';
import 'team_cangur_screen.dart';

class FatherScreen extends StatefulWidget {
  const FatherScreen({super.key});

  @override
  State<FatherScreen> createState() => _FatherScreenState();
}

class _FatherScreenState extends State<FatherScreen> {
  int _index = 0;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = AppScope.of(context);
      state.refreshServices();
      state.refreshCanguros();
      state.refreshBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _HomeColors.of(context);
    if (_selected >= state.services.length) _selected = 0;
    final pages = [
      _ServicesTab(
        colors: colors,
        selected: state.services.isEmpty ? 0 : _selected,
        onSelect: (value) => setState(() => _selected = value),
      ),
      _BookingsTab(colors: colors),
      MenuScreen(
        onOpenServices: () => setState(() => _index = 0),
        onOpenBookings: () => setState(() => _index = 1),
      ),
    ];
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colors.card,
          indicatorColor: colors.menta,
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.w700, fontSize: 12, color: colors.ink),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          backgroundColor: colors.card,
          indicatorColor: colors.menta,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            NavigationDestination(icon: Icon(Icons.child_care_outlined, color: colors.sageDark), label: state.tr('services')),
            NavigationDestination(icon: Icon(Icons.event_note_outlined, color: colors.sageDark), label: state.tr('bookings')),
            NavigationDestination(icon: Icon(Icons.menu_rounded, color: colors.sageDark), label: state.tr('menu')),
          ],
        ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.colors, required this.selected, required this.onSelect});

  final _HomeColors colors;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;
    final services = state.services;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user == null ? state.tr('welcome') : user.nombre,
                    style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 26, height: 1.15, color: colors.ink),
                  ),
                ),
                _LangPills(colors: colors, lang: state.lang, onLang: state.setLang),
              ],
            ),
            const SizedBox(height: 18),
            Text(state.tr('ourServices'), style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 22, color: colors.ink)),
            const SizedBox(height: 4),
            Text(state.tr('serviceTypes'), style: TextStyle(fontSize: 14.5, color: colors.muted)),
            const SizedBox(height: 14),
            SizedBox(
              height: 248,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _ServiceSlide(
                    colors: colors,
                    service: service,
                    title: service.nombre.isNotEmpty && service.nombre != service.tipoServicio
                        ? service.nombre
                        : serviceName(state.lang, service.tipoServicio),
                    selected: index == selected,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            _BookButton(
              colors: colors,
              label: state.tr('bookNow'),
              onPressed: services.isEmpty
                  ? null
                  : () {
                      final service = services[selected];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            switch (service.tipoServicio) {
                              case 'fijo':
                                return FixFormScreen(service: service);
                              case 'repaso':
                                return ExtraFormScreen(service: service);
                              default:
                                return ReservaScreen(initialServiceId: service.id);
                            }
                          },
                        ),
                      );
                    },
            ),
            const SizedBox(height: 28),
            const TeamStrip(),
          ],
        ),
      ),
    );
  }
}

class _ServiceSlide extends StatelessWidget {
  const _ServiceSlide({
    required this.colors,
    required this.service,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final _HomeColors colors;
  final ServiceOffer service;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = service.image;
    return SizedBox(
      width: 210,
      child: Material(
        color: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: selected ? colors.sage : colors.line, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 132,
                width: double.infinity,
                child: image == null
                    ? ColoredBox(color: colors.menta, child: const Center(child: Text('🧸', style: TextStyle(fontSize: 32))))
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => ColoredBox(color: colors.menta, child: const Center(child: Text('🧸', style: TextStyle(fontSize: 32)))),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 16, height: 1.15, color: colors.ink)),
                    const SizedBox(height: 4),
                    Text(service.descripcion, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.35, color: colors.muted)),
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

class _BookButton extends StatelessWidget {
  const _BookButton({required this.colors, required this.label, required this.onPressed});

  final _HomeColors colors;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.sage,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _LangPills extends StatelessWidget {
  const _LangPills({required this.colors, required this.lang, required this.onLang});

  final _HomeColors colors;
  final AppLang lang;
  final ValueChanged<AppLang> onLang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          for (final value in AppLang.values)
            GestureDetector(
              onTap: () => onLang(value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: lang == value ? colors.menta : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  value.name.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: lang == value ? colors.sageDark : colors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.bookingsForCurrent();
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          children: [
            Text(state.tr('bookings'), style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 26, color: colors.ink)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              _SoftCard(colors: colors, child: Text(state.tr('emptyBookings'), style: TextStyle(color: colors.muted)))
            else
              for (final booking in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BookingCard(colors: colors, booking: booking),
                ),
          ],
        ),
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.colors, required this.child});

  final _HomeColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line, width: 1.5),
      ),
      child: child,
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.colors, required this.booking});

  final _HomeColors colors;
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final when = booking.horaInicio.isEmpty
        ? state.tr('schedulePending')
        : '${formatDate(booking.fecha)} · ${booking.horaInicio}–${booking.horaFin}';
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking))),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.line, width: 1.5),
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceName(state.lang, booking.tipoServicio),
                  style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.w700, fontSize: 16, color: colors.ink),
                ),
              ),
              Text(statusLabel(state, booking), style: TextStyle(color: statusColor(booking), fontWeight: FontWeight.w800)),
              Icon(Icons.chevron_right, color: colors.muted, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(when),
          if (booking.numeroNinos > 0) Text('${state.tr('nanniesLabel')}: ${booking.numeroNinos}'),
          Text(booking.canguroNombre == null ? state.tr('noAssigned') : '${state.tr('assigned')}: ${booking.canguroNombre}'),
          if (booking.total != null) Text('${state.tr('total')}: ${money(booking.total!)}'),
          if (booking.notas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(booking.notas, style: TextStyle(color: colors.muted)),
            ),
          if ((booking.estadoPago == 'pagada' || booking.estadoPago == 'pagado') && booking.canguroId != null)
            TextButton(onPressed: () => _review(context), child: Text(state.tr('sendReview'))),
        ],
          ),
        ),
      ),
    );
  }

  Future<void> _review(BuildContext context) async {
    final state = AppScope.of(context);
    var puntualidad = 5;
    var trato = 5;
    var profesionalismo = 5;
    final comment = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            Widget stars(String label, int value, ValueChanged<int> onChanged) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: () => setLocal(() => onChanged(i)),
                          icon: Icon(i <= value ? Icons.star : Icons.star_border, color: colors.sage),
                        ),
                    ],
                  ),
                ],
              );
            }

            return AlertDialog(
              title: Text(state.tr('generalRating')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    stars(state.tr('punctuality'), puntualidad, (v) => puntualidad = v),
                    stars(state.tr('treatment'), trato, (v) => trato = v),
                    stars(state.tr('professionalism'), profesionalismo, (v) => profesionalismo = v),
                    TextField(controller: comment, decoration: InputDecoration(labelText: state.tr('comment'))),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(state.tr('cancel'))),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(state.tr('sendReview'))),
              ],
            );
          },
        );
      },
    );
    if (saved == true && context.mounted) {
      state.addReview(
        booking: booking,
        puntualidad: puntualidad,
        trato: trato,
        profesionalismo: profesionalismo,
        comentario: comment.text,
      );
    }
    comment.dispose();
  }
}

class _HomeColors {
  const _HomeColors({
    required this.bg,
    required this.card,
    required this.sage,
    required this.sageDark,
    required this.menta,
    required this.ink,
    required this.muted,
    required this.line,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color sage;
  final Color sageDark;
  final Color menta;
  final Color ink;
  final Color muted;
  final Color line;
  final Color shadow;

  static const light = _HomeColors(
    bg: Color(0xFFF2EFE7),
    card: Color(0xFFFCFBF7),
    sage: Color(0xFF8CA598),
    sageDark: Color(0xFF6E8B7E),
    menta: Color(0xFFB3CFC4),
    ink: Color(0xFF3B403B),
    muted: Color(0xFF6C726B),
    line: Color(0xFFE2DDD1),
    shadow: Color(0x296E8B7E),
  );

  static const dark = _HomeColors(
    bg: Color(0xFF20241F),
    card: Color(0xFF282D26),
    sage: Color(0xFF8CA598),
    sageDark: Color(0xFFB3CFC4),
    menta: Color(0xFFB3CFC4),
    ink: Color(0xFFEDEBE2),
    muted: Color(0xFFAAB0A5),
    line: Color(0xFF3A3F37),
    shadow: Color(0x66000000),
  );

  static _HomeColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

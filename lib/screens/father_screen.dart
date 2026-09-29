import 'package:flutter/material.dart';

import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';
import 'account_screen.dart';
import 'booking_screen.dart';
import 'request_screen.dart';

class FatherScreen extends StatefulWidget {
  const FatherScreen({super.key});

  @override
  State<FatherScreen> createState() => _FatherScreenState();
}

class _FatherScreenState extends State<FatherScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pages = [
      _ServicesTab(onOpen: _openService),
      const _BookingsTab(),
      const AccountScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.child_care_outlined), label: state.tr('services')),
          NavigationDestination(icon: const Icon(Icons.event_note_outlined), label: state.tr('bookings')),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: state.tr('profile')),
        ],
      ),
    );
  }

  void _openService(ServiceOffer service) {
    final page = service.isQuote ? RequestScreen(service: service) : BookingScreen(service: service);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.onOpen});

  final ValueChanged<ServiceOffer> onOpen;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;
    return PageWidth(
      maxWidth: 880,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user == null ? state.tr('welcome') : user.nombre,
                  style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 28),
                ),
              ),
              const LanguageMenu(),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: Image.asset('assets/images/FamiliaMC.png', height: 210, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(state.tr('ourServices'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 4),
          Text(state.tr('serviceTypes'), style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 640;
              final cards = [
                for (final service in state.services)
                  _ServiceCard(service: service, onTap: () => onOpen(service)),
              ];
              if (!wide) {
                return Column(
                  children: [
                    for (final card in cards) Padding(padding: const EdgeInsets.only(bottom: 10), child: card),
                  ],
                );
              }
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final card in cards) SizedBox(width: (constraints.maxWidth - 10) / 2, child: card),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final ServiceOffer service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final price = service.tarifaConIGI;
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceName(state.lang, service.tipoServicio),
            style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(service.descripcion, style: const TextStyle(height: 1.35)),
          if (price != null && price > 0) ...[
            const SizedBox(height: 8),
            Text('${state.tr('estimated')}: ${money(price)} / h', style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onTap,
            child: Text(service.isQuote ? state.tr('send') : state.tr('find')),
          ),
        ],
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.bookingsForCurrent();
    return PageWidth(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(state.tr('bookings'), style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            SurfaceCard(child: Text(state.tr('emptyBookings')))
          else
            for (final booking in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BookingCard(booking: booking),
              ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final when = booking.horaInicio.isEmpty
        ? state.tr('schedulePending')
        : '${formatDate(booking.fecha)} · ${booking.horaInicio}–${booking.horaFin}';
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceName(state.lang, booking.tipoServicio),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              Text(statusLabel(state, booking), style: TextStyle(color: statusColor(booking), fontWeight: FontWeight.w800)),
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
              child: Text(booking.notas, style: const TextStyle(color: AppColors.textSecondary)),
            ),
          if (booking.estadoPago == 'pagada' && booking.canguroId != null)
            TextButton(onPressed: () => _review(context), child: Text(state.tr('sendReview'))),
        ],
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
                          icon: Icon(i <= value ? Icons.star : Icons.star_border, color: AppColors.brown),
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

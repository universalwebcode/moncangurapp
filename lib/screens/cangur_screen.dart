import 'package:flutter/material.dart';

import '../domain/availability.dart';
import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';
import 'account_screen.dart';

class CangurScreen extends StatefulWidget {
  const CangurScreen({super.key});

  @override
  State<CangurScreen> createState() => _CangurScreenState();
}

class _CangurScreenState extends State<CangurScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            _CangurHome(),
            _CangurBookings(),
            AccountScreen(cangur: true),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.badge_outlined), label: state.tr('profile')),
          NavigationDestination(icon: const Icon(Icons.event_available_outlined), label: state.tr('bookings')),
          NavigationDestination(icon: const Icon(Icons.manage_accounts_outlined), label: state.tr('accountInfo')),
        ],
      ),
    );
  }
}

class _CangurHome extends StatelessWidget {
  const _CangurHome();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final profile = state.user == null ? null : state.profileFor(state.user!.id);
    if (profile == null) {
      return PageWidth(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(state.tr('noPro'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () {}, child: Text(state.tr('createPro'))),
          ],
        ),
      );
    }
    final hasServices = profile.servicios.isNotEmpty;
    return PageWidth(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              Expanded(child: Text(profile.nombre, style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30))),
              const LanguageMenu(),
            ],
          ),
          Text(state.tr('updateInfo'), style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SurfaceCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(state.tr('activeProfile'), style: const TextStyle(fontWeight: FontWeight.w800)),
              value: profile.activo,
              onChanged: (value) {
                profile.activo = value;
                state.saveCangur(profile);
              },
            ),
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.tr('servicesYouOffer'), style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(state.tr('mustMark'), style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final tipo in serviceTypeKeys)
                      FilterChip(
                        label: Text(serviceName(state.lang, tipo)),
                        selected: profile.servicios.contains(tipo),
                        onSelected: (selected) {
                          if (selected) {
                            profile.servicios = [...profile.servicios, tipo];
                          } else {
                            profile.servicios = profile.servicios.where((s) => s != tipo).toList();
                          }
                          state.saveCangur(profile);
                        },
                      ),
                  ],
                ),
                if (!hasServices)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(state.tr('mustMark'), style: const TextStyle(color: AppColors.danger)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.tr('weekly'), style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final day in weekDays)
                  _DayRow(profile: profile, day: day),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.descripcionPersonal),
                const SizedBox(height: 6),
                Text('${profile.idiomas.join(' · ')} · ${money(profile.tarifaPorHora)} / h'),
                if (profile.certificaciones.isNotEmpty) Text(profile.certificaciones.join(', ')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.profile, required this.day});

  final CangurProfile profile;
  final String day;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final slot = profile.week[day]!;
    final band = slot.franjas.isEmpty ? const TimeBand('09:00', '17:00') : slot.franjas.first;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(dayName(state.lang, day)),
      subtitle: Text(slot.disponible ? '${band.inicio}–${band.fin}' : state.tr('unavailable')),
      trailing: Switch(
        value: slot.disponible,
        onChanged: (value) {
          slot.disponible = value;
          state.saveCangur(profile);
        },
      ),
    );
  }
}

class _CangurBookings extends StatelessWidget {
  const _CangurBookings();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.bookingsForCurrent();
    return PageWidth(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(state.tr('bookings'), style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            SurfaceCard(child: Text(state.tr('emptyBookings')))
          else
            for (final booking in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceName(state.lang, booking.tipoServicio), style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('${booking.padreNombre} · ${formatDate(booking.fecha)}'),
                      if (booking.horaInicio.isNotEmpty) Text('${booking.horaInicio}–${booking.horaFin}'),
                      Text('${state.tr('nanniesLabel')}: ${booking.numeroNinos}'),
                      Text(statusLabel(state, booking), style: TextStyle(color: statusColor(booking), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

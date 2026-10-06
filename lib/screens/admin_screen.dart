import 'package:flutter/material.dart';

import '../domain/availability.dart';
import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';
import 'account_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _index = 0;
  String _query = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).refreshBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageWidth(
          maxWidth: 960,
          child: IndexedStack(
            index: _index,
            children: [
              _overview(state),
              _canguros(state),
              _bookings(state),
              const AccountScreen(admin: true),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.insights_outlined), label: state.tr('totalBookings')),
          NavigationDestination(icon: const Icon(Icons.groups_outlined), label: state.tr('manage')),
          NavigationDestination(icon: const Icon(Icons.assignment_outlined), label: state.tr('bookings')),
          NavigationDestination(icon: const Icon(Icons.admin_panel_settings_outlined), label: state.tr('profile')),
        ],
      ),
    );
  }

  Widget _overview(AppState state) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: Text(state.tr('manage'), style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30))),
            const LanguageMenu(),
          ],
        ),
        const SizedBox(height: 6),
        Text(state.tr('manageHint')),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Stat(label: state.tr('totalCanguros'), value: '${state.canguros.length}'),
            _Stat(label: state.tr('totalBookings'), value: '${state.bookings.length}'),
          ],
        ),
        const SizedBox(height: 12),
        Text(state.tr('history'), style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(state.tr('supervise')),
      ],
    );
  }

  Widget _canguros(AppState state) {
    final q = _query.trim().toLowerCase();
    final list = state.canguros.where((p) {
      if (q.isEmpty) return true;
      return p.nombre.toLowerCase().contains(q) || p.email.toLowerCase().contains(q);
    }).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(state.tr('manage'), style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 28)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(labelText: state.tr('search'), prefixIcon: const Icon(Icons.search)),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Text(state.tr('noBookingsFilter'))
        else
          for (final profile in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(profile.email.isEmpty ? state.tr('noEmail') : profile.email),
                    Text(profile.servicios.map((s) => serviceName(state.lang, s)).join(' · ')),
                    Text(profile.activo ? state.tr('available') : state.tr('unavailable')),
                    Text(profile.idiomas.join(', ')),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _bookings(AppState state) {
    final items = state.bookings.where((b) => _filter == 'all' || b.estadoPago == _filter || b.estado == _filter).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(state.tr('bookings'), style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 28)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final key in ['all', 'pendiente', 'pagada', 'fallido', 'presupuesto'])
              ChoiceChip(
                label: Text(key == 'all' ? state.tr('filterAll') : key),
                selected: _filter == key,
                onSelected: (_) => setState(() => _filter = key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(state.tr('noBookingsFilter'))
        else
          for (final booking in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${serviceName(state.lang, booking.tipoServicio)} · ${booking.padreNombre}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(booking.horaInicio.isEmpty ? state.tr('schedulePending') : '${formatDate(booking.fecha)} ${booking.horaInicio}–${booking.horaFin}'),
                    Text(booking.canguroNombre == null ? state.tr('noAssigned') : '${state.tr('assigned')}: ${booking.canguroNombre}'),
                    Text(statusLabel(state, booking), style: TextStyle(color: statusColor(booking), fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _Assign(booking: booking),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 36)),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _Assign extends StatelessWidget {
  const _Assign({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final options = state.canguros.where((profile) {
      if (booking.horaInicio.isEmpty) return profile.activo && offersService(profile.servicios, booking.tipoServicio);
      return cangurMatches(
        profile: profile,
        tipoServicio: booking.tipoServicio,
        date: booking.fecha,
        start: booking.horaInicio,
        end: booking.horaFin,
      );
    }).toList();
    if (options.isEmpty) return Text(state.tr('noneForBooking'));
    return DropdownButton<String>(
      isExpanded: true,
      hint: Text(state.tr('selectAvailable')),
      value: options.any((p) => p.userId == booking.canguroId) ? booking.canguroId : null,
      items: [
        for (final profile in options)
          DropdownMenuItem(value: profile.userId, child: Text(profile.nombre)),
      ],
      onChanged: (id) {
        if (id != null) state.assignCangur(booking.id, id);
      },
    );
  }
}

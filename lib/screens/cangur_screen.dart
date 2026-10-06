import 'package:flutter/material.dart';

import '../domain/availability.dart';
import '../l10n/app_copy.dart';
import '../l10n/cangur_copy.dart';
import '../l10n/reserva_copy.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/mc_widgets.dart';
import 'booking_detail_screen.dart';

class CangurScreen extends StatefulWidget {
  const CangurScreen({super.key});

  @override
  State<CangurScreen> createState() => _CangurScreenState();
}

class _CangurScreenState extends State<CangurScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = AppScope.of(context);
      state.refreshCanguros();
      state.refreshBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _CangurColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(child: IndexedStack(index: _index, children: const [_AgendaTab(), _ProfileTab()])),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colors.card,
          indicatorColor: colors.menta,
          labelTextStyle: WidgetStateProperty.all(TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.ink)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          backgroundColor: colors.card,
          indicatorColor: colors.menta,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined, color: colors.mentaD), label: cg(state.lang, 'agenda')),
            NavigationDestination(icon: Icon(Icons.person_outline, color: colors.mentaD), label: state.tr('profile')),
          ],
        ),
      ),
    );
  }
}

enum _Filter { all, pending, done }

class _AgendaTab extends StatefulWidget {
  const _AgendaTab();

  @override
  State<_AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<_AgendaTab> {
  _Filter _filter = _Filter.all;
  late DateTime _month;
  late DateTime _selected;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _month = DateTime(today.year, today.month);
    _selected = today;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Booking> _visible(AppState state) {
    final items = state.bookingsForCurrent();
    switch (_filter) {
      case _Filter.all:
        return items;
      case _Filter.pending:
        return items.where((booking) => !_completed(booking)).toList();
      case _Filter.done:
        return items.where(_completed).toList();
    }
  }

  bool _completed(Booking booking) {
    if (booking.estado == 'completada') return true;
    final day = DateUtils.dateOnly(booking.fecha);
    return day.isBefore(DateUtils.dateOnly(DateTime.now())) && booking.estado != 'pendiente' && booking.estado != 'presupuesto';
  }

  List<Booking> _onDay(List<Booking> items, DateTime day) {
    final date = DateUtils.dateOnly(day);
    return items.where((booking) => DateUtils.dateOnly(booking.fecha) == date).toList();
  }

  void _jump(DateTime day) {
    final date = DateUtils.dateOnly(day);
    setState(() {
      _selected = date;
      _month = DateTime(date.year, date.month);
      _search.text = formatDate(date);
    });
  }

  void _searchDate() {
    final parts = _search.text.trim().split(RegExp(r'[./-]'));
    if (parts.length < 3) return;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null || month < 1 || month > 12 || day < 1 || day > 31) return;
    _jump(DateTime(year < 100 ? 2000 + year : year, month, day));
  }

  void _upcoming(List<Booking> items) {
    final today = DateUtils.dateOnly(DateTime.now());
    final future = items.map((booking) => DateUtils.dateOnly(booking.fecha)).where((day) => !day.isBefore(today)).toList()..sort();
    _jump(future.isEmpty ? today : future.first);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _CangurColors.of(context);
    final profile = state.user == null ? null : state.profileFor(state.user!.id);
    final visible = _visible(state);
    final dayItems = _onDay(visible, _selected);
    final shownMonth = reservaMonths[lang.index][_month.month - 1];
    final selectedMonth = reservaMonths[lang.index][_selected.month - 1];
    final weekday = dayName(lang, dayKey(_selected)).toLowerCase();
    final count = dayItems.isEmpty
        ? cg(lang, 'manyBookings', {'n': '0'})
        : dayItems.length == 1
        ? cg(lang, 'oneBooking')
        : cg(lang, 'manyBookings', {'n': '${dayItems.length}'});
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(child: Text(cg(lang, 'myAgenda'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, color: colors.ink))),
                _LangPills(colors: colors, lang: lang, onLang: state.setLang),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(colors, cg(lang, 'all'), _filter == _Filter.all, () => setState(() => _filter = _Filter.all)),
                _pill(colors, cg(lang, 'pending'), _filter == _Filter.pending, () => setState(() => _filter = _Filter.pending)),
                _pill(colors, cg(lang, 'done'), _filter == _Filter.done, () => setState(() => _filter = _Filter.done)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onSubmitted: (_) => _searchDate(),
                    style: TextStyle(fontFamily: 'Nunito', color: colors.ink),
                    decoration: InputDecoration(
                      hintText: cg(lang, 'searchDate'),
                      prefixIcon: Icon(Icons.search, color: colors.mentaD),
                      filled: true,
                      fillColor: colors.card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: colors.line)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: colors.mentaD, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _pill(colors, cg(lang, 'upcoming'), false, () => _upcoming(visible)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: Icon(Icons.chevron_left, color: colors.ink)),
                Expanded(
                  child: Text('$shownMonth ${_month.year}', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.mentaD)),
                ),
                IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: Icon(Icons.chevron_right, color: colors.ink)),
              ],
            ),
            Row(
              children: [
                for (final label in reservaDow[lang.index])
                  Expanded(child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, color: colors.mentaD))),
              ],
            ),
            const SizedBox(height: 6),
            _MonthGrid(
              colors: colors,
              month: _month,
              selected: _selected,
              profile: profile,
              bookings: visible,
              onSelect: (day) => setState(() => _selected = day),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _legend(colors.base, cg(lang, 'baseHours')),
                _legend(colors.changed, cg(lang, 'changed')),
                _legend(colors.closed, state.tr('unavailable')),
                _legend(colors.mentaD, cg(lang, 'bookingDot')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('$weekday, ${_selected.day} $selectedMonth', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.line)),
                  child: Text(count, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.mentaD)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dayItems.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Column(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 42, color: colors.menta),
                    const SizedBox(height: 8),
                    Text(cg(lang, 'noDay'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: colors.mentaD)),
                  ],
                ),
              )
            else
              for (final booking in dayItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking))),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.line, width: 1.5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(serviceName(lang, booking.tipoServicio), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink)),
                            const SizedBox(height: 2),
                            Text('${booking.padreNombre} · ${booking.horaInicio}–${booking.horaFin}', style: TextStyle(fontFamily: 'Nunito', color: colors.text)),
                            Text(statusLabel(state, booking), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: statusColor(booking))),
                          ],
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

  Widget _pill(_CangurColors colors, String label, bool on, VoidCallback tap) {
    return Material(
      color: on ? colors.menta : colors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? colors.mentaD : colors.line, width: 1.5)),
          child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13, color: on ? const Color(0xFF2C3A33) : colors.text2)),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.colors,
    required this.month,
    required this.selected,
    required this.profile,
    required this.bookings,
    required this.onSelect,
  });

  final _CangurColors colors;
  final DateTime month;
  final DateTime selected;
  final CangurProfile? profile;
  final List<Booking> bookings;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final offset = (first.weekday + 6) % 7;
    final cells = offset + days;
    final rows = (cells / 7).ceil();
    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(child: _cell(row * 7 + col - offset)),
            ],
          ),
      ],
    );
  }

  Widget _cell(int dayNumber) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    if (dayNumber < 1 || dayNumber > days) return const SizedBox(height: 42);
    final day = DateTime(month.year, month.month, dayNumber);
    final picked = DateUtils.isSameDay(day, selected);
    final tone = _tone(day);
    final booked = bookings.any((booking) => DateUtils.isSameDay(booking.fecha, day));
    return InkWell(
      onTap: () => onSelect(day),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: picked ? colors.menta : Colors.transparent, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '$dayNumber',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: picked ? const Color(0xFF2C3A33) : tone),
              ),
            ),
            Container(width: 5, height: 5, decoration: BoxDecoration(color: booked ? colors.mentaD : Colors.transparent, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  Color _tone(DateTime day) {
    final iso = isoDate(day);
    final exception = profile?.exceptions.where((item) => item.fecha == iso);
    if (exception != null && exception.isNotEmpty) {
      return exception.first.disponible ? colors.changed : colors.closed;
    }
    final slot = profile?.week[dayKey(day)];
    if (slot == null || !slot.disponible) return colors.closed;
    return colors.base;
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _name = TextEditingController();
  final _about = TextEditingController();
  final _years = TextEditingController();
  final _skill = TextEditingController();
  final _cert = TextEditingController();
  bool _active = true;
  bool _applied = false;
  bool _saving = false;
  String? _note;
  List<String> _services = [];
  List<String> _skills = [];
  List<String> _certs = [];
  Map<String, DayAvailability> _week = {
    for (final day in weekDays)
      day: DayAvailability(
        disponible: const {'lunes', 'martes', 'miercoles', 'jueves', 'viernes'}.contains(day),
        franjas: [const TimeBand('09:00', '17:00')],
      ),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_applied) return;
    final state = AppScope.of(context);
    final profile = state.user == null ? null : state.profileFor(state.user!.id);
    if (profile == null) {
      if (_name.text.isEmpty) _name.text = state.user?.nombre ?? '';
      return;
    }
    _applied = true;
    _name.text = profile.nombre;
    _about.text = profile.descripcionPersonal;
    _years.text = '${profile.aniosExperiencia}';
    _active = profile.activo;
    _services = [...profile.servicios];
    _skills = [...profile.habilidades];
    _certs = [...profile.certificaciones];
    _week = {
      for (final day in weekDays)
        day: DayAvailability(
          disponible: profile.week[day]?.disponible ?? false,
          franjas: [for (final band in profile.week[day]?.franjas ?? const <TimeBand>[]) TimeBand(band.inicio, band.fin)],
        ),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    _years.dispose();
    _skill.dispose();
    _cert.dispose();
    super.dispose();
  }

  Future<void> _pickBand(String day, int index, bool start) async {
    final band = _week[day]!.franjas[index];
    final picked = await pickTime(context, start ? band.inicio : band.fin);
    if (picked == null) return;
    setState(() {
      final next = TimeBand(start ? picked : band.inicio, start ? band.fin : picked);
      _week[day]!.franjas[index] = next;
    });
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    final account = state.user;
    if (account == null || _saving) return;
    final current = state.profileFor(account.id);
    setState(() {
      _saving = true;
      _note = null;
    });
    final profile = CangurProfile(
      userId: account.id,
      nombre: _name.text.trim().isEmpty ? account.nombre : _name.text.trim(),
      email: current?.email ?? account.email,
      descripcionPersonal: _about.text.trim(),
      tarifaPorHora: current?.tarifaPorHora ?? 0,
      servicios: _services,
      certificaciones: _certs,
      idiomas: current?.idiomas ?? const [],
      week: _week,
      activo: _active,
      aniosExperiencia: int.tryParse(_years.text.trim()) ?? 0,
      photoUrl: current?.photoUrl,
      slug: current?.slug ?? '',
      rol: current?.rol ?? '',
      badge: current?.badge ?? '',
      color: current?.color ?? 0xFF8CA598,
      qui: current?.qui ?? '',
      trayectoria: current?.trayectoria ?? '',
      agrada: current?.agrada ?? '',
      puntFort: current?.puntFort ?? '',
      habilidades: _skills,
      exceptions: current?.exceptions ?? const [],
    );
    final error = await state.saveCangurProfile(profile);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _note = error == null ? cg(state.lang, 'saved') : state.tr(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _CangurColors.of(context);
    final photo = state.profileFor(state.user?.id ?? '')?.photoUrl;
    const offered = ['repaso', 'ocasional', 'emergencia', 'fijo', 'eventos'];
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(state.tr('editPro'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 22, color: colors.ink)),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: SizedBox(
                          width: 92,
                          height: 92,
                          child: photo == null || photo.isEmpty
                              ? ColoredBox(color: colors.menta, child: Icon(Icons.person, size: 42, color: colors.ink))
                              : Image.network(photo, fit: BoxFit.cover, errorBuilder: (context, error, stack) => ColoredBox(color: colors.menta, child: Icon(Icons.person, size: 42, color: colors.ink))),
                        ),
                      ),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Material(
                          color: colors.menta,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () => setState(() => _note = cg(lang, 'photoSoon')),
                            customBorder: const CircleBorder(),
                            child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.photo_camera_outlined, size: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(cg(lang, 'tapPhoto'), style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(cg(lang, 'yourName'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.mentaD)),
            const SizedBox(height: 6),
            _box(colors, child: TextField(controller: _name, style: TextStyle(fontFamily: 'Nunito', color: colors.ink), decoration: const InputDecoration(border: InputBorder.none, isDense: true))),
            const SizedBox(height: 12),
            _box(
              colors,
              child: Row(
                children: [
                  Icon(Icons.work_outline, color: colors.mentaD),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.tr('activeProfile'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.ink))),
                  Switch(value: _active, activeThumbColor: colors.mentaD, onChanged: (value) => setState(() => _active = value)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(state.tr('servicesYouOffer'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.mentaD)),
            const SizedBox(height: 4),
            Text(state.tr('mustMark'), style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in offered)
                  FilterChip(
                    label: Text(serviceName(lang, tipo), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
                    selected: _services.contains(tipo),
                    selectedColor: colors.menta,
                    checkmarkColor: const Color(0xFF2C3A33),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _services = [..._services, tipo];
                      } else {
                        _services = _services.where((item) => item != tipo).toList();
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(cg(lang, 'proInfo'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.mentaD)),
            const SizedBox(height: 8),
            Text(cg(lang, 'about'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: colors.text2)),
            const SizedBox(height: 6),
            _box(colors, child: TextField(key: const Key('cangur-about'), controller: _about, minLines: 3, maxLines: 5, style: TextStyle(fontFamily: 'Nunito', color: colors.ink), decoration: const InputDecoration(border: InputBorder.none))),
            const SizedBox(height: 12),
            Text(cg(lang, 'years'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: colors.text2)),
            const SizedBox(height: 6),
            _box(colors, child: TextField(controller: _years, keyboardType: TextInputType.number, style: TextStyle(fontFamily: 'Nunito', color: colors.ink), decoration: const InputDecoration(border: InputBorder.none, isDense: true))),
            const SizedBox(height: 16),
            Text(cg(lang, 'skills'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.mentaD)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _box(colors, child: TextField(controller: _skill, style: TextStyle(fontFamily: 'Nunito', color: colors.ink), decoration: InputDecoration(hintText: cg(lang, 'newSkill'), border: InputBorder.none, isDense: true)))),
                const SizedBox(width: 8),
                _addButton(colors, cg(lang, 'add'), () {
                  final value = _skill.text.trim();
                  if (value.isEmpty || _skills.contains(value)) return;
                  setState(() {
                    _skills = [..._skills, value];
                    _skill.clear();
                  });
                }),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in _skills)
                  InputChip(
                    label: Text(skill, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
                    onDeleted: () => setState(() => _skills = _skills.where((item) => item != skill).toList()),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(cg(lang, 'certs'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.mentaD)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _box(colors, child: TextField(controller: _cert, style: TextStyle(fontFamily: 'Nunito', color: colors.ink), decoration: InputDecoration(hintText: cg(lang, 'newCert'), border: InputBorder.none, isDense: true)))),
                const SizedBox(width: 8),
                _addButton(colors, cg(lang, 'add'), () {
                  final value = _cert.text.trim();
                  if (value.isEmpty || _certs.contains(value)) return;
                  setState(() {
                    _certs = [..._certs, value];
                    _cert.clear();
                  });
                }),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cert in _certs)
                  InputChip(
                    label: Text(cert, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
                    onDeleted: () => setState(() => _certs = _certs.where((item) => item != cert).toList()),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(state.tr('weekly'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.mentaD)),
            const SizedBox(height: 8),
            for (final day in weekDays) _dayEditor(colors, lang, day),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(color: colors.mentaD, borderRadius: BorderRadius.circular(16)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _saving ? null : _save,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(cg(lang, 'save'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ),
            if (_note != null) ...[
              const SizedBox(height: 10),
              Text(_note!, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: colors.mentaD)),
            ],
            const SizedBox(height: 18),
            TextButton(
              onPressed: () {
                state.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              child: Text(state.tr('signOut'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.closed)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayEditor(_CangurColors colors, AppLang lang, String day) {
    final slot = _week[day]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(dayName(lang, day), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.ink))),
              Switch(value: slot.disponible, activeThumbColor: colors.mentaD, onChanged: (value) => setState(() => slot.disponible = value)),
            ],
          ),
          if (slot.disponible)
            for (var i = 0; i < slot.franjas.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: _timeBox(colors, slot.franjas[i].inicio, () => _pickBand(day, i, true))),
                    const SizedBox(width: 8),
                    Expanded(child: _timeBox(colors, slot.franjas[i].fin, () => _pickBand(day, i, false))),
                    IconButton(
                      onPressed: () => setState(() => slot.franjas.removeAt(i)),
                      icon: Icon(Icons.delete_outline, color: colors.closed),
                    ),
                  ],
                ),
              ),
          if (slot.disponible)
            TextButton.icon(
              onPressed: () => setState(() => slot.franjas.add(const TimeBand('09:00', '17:00'))),
              icon: Icon(Icons.add, color: colors.mentaD),
              label: Text(cg(lang, 'addBand'), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.mentaD)),
            ),
        ],
      ),
    );
  }

  Widget _timeBox(_CangurColors colors, String value, VoidCallback onTap) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.brun.withValues(alpha: 0.6), width: 1.5)),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 18, color: colors.brun),
              const SizedBox(width: 8),
              Text(value, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: colors.ink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(_CangurColors colors, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.line, width: 1.5)),
      child: child,
    );
  }

  Widget _addButton(_CangurColors colors, String label, VoidCallback onTap) {
    return Material(
      color: colors.mentaD,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Text(label, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ),
    );
  }
}

class _LangPills extends StatelessWidget {
  const _LangPills({required this.colors, required this.lang, required this.onLang});

  final _CangurColors colors;
  final AppLang lang;
  final ValueChanged<AppLang> onLang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in AppLang.values)
            GestureDetector(
              onTap: () => onLang(value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(color: lang == value ? colors.menta : Colors.transparent, borderRadius: BorderRadius.circular(999)),
                child: Text(value.name.toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w800, color: lang == value ? const Color(0xFF2C3A33) : colors.text2)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CangurColors {
  const _CangurColors({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
    required this.brun,
    required this.base,
    required this.changed,
    required this.closed,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color mentaD;
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color brun;
  final Color base;
  final Color changed;
  final Color closed;

  static const light = _CangurColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF4F4A45),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    brun: Color(0xFFA98E7B),
    base: Color(0xFF3E6B4F),
    changed: Color(0xFFC08457),
    closed: Color(0xFFC0705F),
  );

  static const dark = _CangurColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFCFC9C0),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    brun: Color(0xFFA98E7B),
    base: Color(0xFFB7D7C3),
    changed: Color(0xFFE0B089),
    closed: Color(0xFFE0A396),
  );

  static _CangurColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

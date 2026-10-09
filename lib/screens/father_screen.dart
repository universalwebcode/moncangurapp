import 'package:flutter/material.dart';

import '../widgets/mc_widgets.dart';
import 'father_bookings.dart';
import 'father_home.dart';
import 'menu_screen.dart';

class FatherScreen extends StatefulWidget {
  const FatherScreen({super.key});

  @override
  State<FatherScreen> createState() => _FatherScreenState();
}

class _FatherScreenState extends State<FatherScreen> {
  int _index = 0;
  int _bookingPane = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = AppScope.of(context);
      state.refreshServices();
      state.refreshCanguros();
      state.refreshBookings();
      state.refreshReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _HomeColors.of(context);
    final pages = [
      FatherServicesTab(onOpenMenu: () => setState(() => _index = 2)),
      FatherBookingsTab(
        pane: _bookingPane,
        onBack: () => setState(() => _index = 0),
      ),
      MenuScreen(
        onOpenServices: () => setState(() => _index = 0),
        onOpenBookings: () => setState(() {
          _bookingPane = 0;
          _index = 1;
        }),
        onOpenHistory: () => setState(() {
          _bookingPane = 1;
          _index = 1;
        }),
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
            TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: colors.ink),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          backgroundColor: colors.card,
          indicatorColor: colors.menta,
          onDestinationSelected: (value) => setState(() {
            if (value == 1) _bookingPane = 0;
            _index = value;
          }),
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
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    sage: Color(0xFF8CA598),
    sageDark: Color(0xFF9CAF9F),
    menta: Color(0xFFB3CFC4),
    ink: Color(0xFF1A1A1A),
    muted: Color(0xFF6B6560),
    line: Color(0x14000000),
    shadow: Color(0x0D000000),
  );

  static const dark = _HomeColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    sage: Color(0xFF8CA598),
    sageDark: Color(0xFFB3CFC4),
    menta: Color(0xFFB3CFC4),
    ink: Color(0xFFF7F3EE),
    muted: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    shadow: Color(0x66000000),
  );

  static _HomeColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

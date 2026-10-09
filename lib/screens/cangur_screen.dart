import 'package:flutter/material.dart';

import '../l10n/cangur_copy.dart';
import '../widgets/mc_widgets.dart';
import 'cangur_availability_screen.dart';
import 'cangur_bookings_screen.dart';
import 'cangur_home.dart';
import 'cangur_menu_screen.dart';
import 'cangur_profile_tab.dart';

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

  void _openAvailability() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CangurAvailabilityScreen()));
  }

  void _openBookings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CangurBookingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = _CangurColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            CangurHomeTab(
              onOpenBookings: _openBookings,
              onOpenAvailability: _openAvailability,
              onOpenMenu: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CangurMenuScreen(
                      onOpenProfile: () {
                        Navigator.pop(context);
                        setState(() => _index = 1);
                      },
                      onOpenBookings: _openBookings,
                      onOpenAvailability: _openAvailability,
                    ),
                  ),
                );
              },
            ),
            CangurProfileTab(onBack: () => setState(() => _index = 0)),
          ],
        ),
      ),
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
            NavigationDestination(icon: Icon(Icons.home_outlined, color: colors.mentaD), label: cg(state.lang, 'home')),
            NavigationDestination(icon: Icon(Icons.person_outline, color: colors.mentaD), label: state.tr('profile')),
          ],
        ),
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
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color mentaD;
  final Color ink;

  static const light = _CangurColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    ink: Color(0xFF1A1A1A),
  );

  static const dark = _CangurColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    ink: Color(0xFFF7F3EE),
  );

  static _CangurColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}

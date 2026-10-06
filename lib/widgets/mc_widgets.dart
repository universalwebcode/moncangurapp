import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({required AppState state, required super.child, super.key}) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({required this.title, this.subtitle, this.trailing, super.key});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: const [BoxShadow(color: Color(0x3374461F), blurRadius: 28, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Image.asset('assets/images/cangurLogin.png', height: 92),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'CyGroteskKey',
              color: Colors.white,
              fontSize: 28,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Text('◎  Mon Cangur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          if (trailing != null) ...[const SizedBox(height: 12), trailing!],
        ],
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({required this.child, this.padding = const EdgeInsets.all(18), super.key});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.12)),
        boxShadow: const [BoxShadow(color: Color(0x0F1F1F1F), blurRadius: 20, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PopupMenuButton<AppLang>(
      initialValue: state.lang,
      onSelected: state.setLang,
      tooltip: state.tr('language'),
      itemBuilder: (context) => [
        for (final lang in AppLang.values)
          PopupMenuItem(value: lang, child: Text(lang.name.toUpperCase())),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          state.lang.name.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w800, color: light ? Colors.white : AppColors.brown),
        ),
      ),
    );
  }
}

class PageWidth extends StatelessWidget {
  const PageWidth({required this.child, this.maxWidth = 520, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

String money(double value) => '${value.toStringAsFixed(2)} €';

String formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

Future<String?> pickTime(BuildContext context, String current) async {
  final parts = current.split(':');
  final initial = TimeOfDay(
    hour: int.tryParse(parts.first) ?? 9,
    minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
  );
  final picked = await showTimePicker(
    context: context,
    initialTime: initial,
    initialEntryMode: TimePickerEntryMode.input,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
  if (picked == null) return null;
  final h = picked.hour.toString().padLeft(2, '0');
  final m = picked.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String statusLabel(AppState state, Booking booking) {
  switch (booking.estadoPago) {
    case 'pagada':
    case 'pagado':
      return state.tr('paid');
    case 'fallido':
      return state.tr('failed');
    default:
      break;
  }
  if (booking.estado == 'presupuesto') return state.tr('quote');
  if (booking.estado == 'confirmada') return state.tr('confirmed');
  return state.tr('pending');
}

Color statusColor(Booking booking) {
  if (booking.estadoPago == 'pagada' || booking.estadoPago == 'pagado') return AppColors.success;
  if (booking.estadoPago == 'fallido') return AppColors.danger;
  if (booking.estado == 'presupuesto') return AppColors.teal;
  return AppColors.brown;
}

import '../models/models.dart';

/// Day keys recovered from `b7A` (DateTime weekday, Monday = 1).
const weekDays = [
  'lunes',
  'martes',
  'miercoles',
  'jueves',
  'viernes',
  'sabado',
  'domingo',
];

String dayKey(DateTime date) => weekDays[date.weekday - 1];

String isoDate(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

int? minutesOf(String hhmm) {
  final parts = hhmm.trim().split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}

/// `bgr`: the requested interval must sit entirely inside one franja,
/// and the end must be strictly after the start.
/// Argument order in the minified build is (end, bands, start).
bool intervalCovered(String start, String end, List<TimeBand> bands) {
  final endMin = minutesOf(end);
  final startMin = minutesOf(start);
  if (endMin == null || startMin == null) return false;
  if (endMin <= startMin) return false;
  for (final band in bands) {
    final bandStart = minutesOf(band.inicio);
    final bandEnd = minutesOf(band.fin);
    if (bandStart == null || bandEnd == null) continue;
    if (bandStart <= startMin && bandEnd >= endMin) return true;
  }
  return false;
}

double? hoursBetween(String start, String end) {
  final endMin = minutesOf(end);
  final startMin = minutesOf(start);
  if (endMin == null || startMin == null || endMin <= startMin) return null;
  return (endMin - startMin) / 60;
}

/// `agU`: fold a service label onto ocasional / emergencia / repaso / fijo,
/// otherwise keep the lowercased text (eventos stays eventos).
String? normalizeService(String raw) {
  final n = raw.trim().toLowerCase();
  if (n.isEmpty) return null;
  const known = ['repaso', 'ocasional', 'emergencia', 'fijo'];
  for (final key in known) {
    if (n == key || n.contains(key)) return key;
  }
  return n;
}

/// `bf8`: a caregiver offers the requested service when the labels contain
/// each other or normalize to the same key.
bool offersService(List<String> offered, String requested) {
  final wanted = requested.trim().toLowerCase();
  if (wanted.isEmpty) return false;
  for (final item in offered) {
    final q = item.trim().toLowerCase();
    if (q.isEmpty) continue;
    if (q == wanted || q.contains(wanted) || wanted.contains(q)) return true;
    final a = normalizeService(q);
    final b = normalizeService(wanted);
    if (a != null && b != null && a == b) return true;
  }
  return false;
}

/// `b3s`: an exception for that date replaces the weekly row.
/// A day counts only when `disponible` is true and it has franjas.
List<TimeBand>? bandsOn(CangurProfile profile, DateTime date) {
  final dateKey = isoDate(date);
  for (final exception in profile.exceptions) {
    if (exception.fecha != dateKey) continue;
    if (!exception.disponible || exception.franjas.isEmpty) return null;
    return exception.franjas;
  }
  final day = profile.week[dayKey(date)];
  if (day == null || !day.disponible || day.franjas.isEmpty) return null;
  return day.franjas;
}

bool cangurMatches({
  required CangurProfile profile,
  required String tipoServicio,
  required DateTime date,
  required String start,
  required String end,
}) {
  if (!profile.activo) return false;
  if (!offersService(profile.servicios, tipoServicio)) return false;
  final bands = bandsOn(profile, date);
  if (bands == null) return false;
  return intervalCovered(start, end, bands);
}

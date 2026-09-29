import '../models/models.dart';

/// Pricing recovered from the compiled web build.
///
/// Client hourly (`GK`): child-count map with IGI, else flat `tarifaConIGI`,
/// else child-count map without IGI, else `tarifaBase`. Child count is clamped
/// to 1–12.
///
/// Caregiver hourly (`aCD`): child-count map without IGI, else the client rate
/// divided by `1 + igi/100` when `igi` is between 0 and 100.
///
/// The booking summary shows caregiver rate as "tarifa por hora", the
/// difference as "comisión de servicio" (the IGI gap) and the client rate
/// times hours as the total.
class Pricing {
  static int clampChildren(int children) => children.clamp(1, 12);

  static double clientHourly(ServiceOffer service, int children) {
    final n = clampChildren(children);
    final withIgi = service.tarifasPorNinosConIGI[n];
    if (withIgi != null) return withIgi;
    if (service.tarifaConIGI != null) return service.tarifaConIGI!;
    final net = service.tarifasPorNinos[n];
    if (net != null) return net;
    return service.tarifaBase;
  }

  static double caregiverHourly(ServiceOffer service, int children) {
    final n = clampChildren(children);
    final explicit = service.tarifasPorNinos[n];
    if (explicit != null) return explicit;
    final client = clientHourly(service, n);
    final igi = service.igi;
    if (igi > 0 && igi < 100) return client / (1 + igi / 100);
    return client;
  }

  static PriceBreakdown quote({
    required ServiceOffer service,
    required int children,
    required double hours,
  }) {
    final client = clientHourly(service, children);
    final caregiver = caregiverHourly(service, children);
    return PriceBreakdown(
      hourlyCaregiver: caregiver,
      hourlyClient: client,
      hours: hours,
      subtotal: caregiver * hours,
      fee: (client - caregiver) * hours,
      total: client * hours,
    );
  }
}

class PriceBreakdown {
  const PriceBreakdown({
    required this.hourlyCaregiver,
    required this.hourlyClient,
    required this.hours,
    required this.subtotal,
    required this.fee,
    required this.total,
  });

  final double hourlyCaregiver;
  final double hourlyClient;
  final double hours;
  final double subtotal;
  final double fee;
  final double total;
}

/// Recovered from `aq6`: thresholds on the number of children.
String caregiverNeedKey(int children) {
  if (children <= 2) return 'oneCaregiver';
  if (children <= 4) return 'maybeMore';
  if (children <= 12) return 'mediumGroup';
  return 'largeGroup';
}

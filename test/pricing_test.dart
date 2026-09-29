import 'package:cangur_app/domain/availability.dart';
import 'package:cangur_app/domain/pricing.dart';
import 'package:cangur_app/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = ServiceOffer(
    id: 'ocasional',
    nombre: 'Ocasional',
    descripcion: '',
    tipoServicio: 'ocasional',
    igi: 4.5,
    tarifaBase: 18,
    tarifaConIGI: 18.81,
  );

  test('client rate prefers tarifaConIGI and caregiver rate removes IGI', () {
    expect(Pricing.clientHourly(service, 2), 18.81);
    expect(Pricing.caregiverHourly(service, 2), closeTo(18.81 / 1.045, 0.001));
    final quote = Pricing.quote(service: service, children: 2, hours: 3);
    expect(quote.total, closeTo(18.81 * 3, 0.001));
    expect(quote.fee, closeTo(quote.total - quote.subtotal, 0.001));
  });

  test('per-child maps override the flat rates and children clamp to 1–12', () {
    const mapped = ServiceOffer(
      id: 'x',
      nombre: 'x',
      descripcion: '',
      tipoServicio: 'ocasional',
      igi: 4.5,
      tarifaBase: 10,
      tarifaConIGI: 20,
      tarifasPorNinos: {2: 15},
      tarifasPorNinosConIGI: {2: 22},
    );
    expect(Pricing.clientHourly(mapped, 2), 22);
    expect(Pricing.caregiverHourly(mapped, 2), 15);
    expect(Pricing.clientHourly(mapped, 99), Pricing.clientHourly(mapped, 12));
  });

  test('a franja covers the request only when the end is after the start', () {
    const bands = [TimeBand('09:00', '17:00')];
    expect(intervalCovered('16:00', '19:00', bands), isFalse);
    expect(intervalCovered('10:00', '13:00', bands), isTrue);
    expect(intervalCovered('18:00', '16:00', bands), isFalse);
  });

  test('service labels fold onto the recovered keys', () {
    expect(normalizeService('Ocasional'), 'ocasional');
    expect(normalizeService('para eventos'), 'para eventos');
    expect(offersService(['eventos'], 'para eventos'), isTrue);
    expect(offersService(['repaso'], 'Repaso escolar'), isTrue);
    expect(offersService(['ocasional'], 'emergencia'), isFalse);
  });
}

import 'package:cangur_app/main.dart';
import 'package:cangur_app/models/models.dart';
import 'package:cangur_app/screens/event_form_screen.dart';
import 'package:cangur_app/screens/extra_form_screen.dart';
import 'package:cangur_app/screens/fix_form_screen.dart';
import 'package:cangur_app/state/app_state.dart';
import 'package:cangur_app/widgets/mc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entrance follows the role, login and signup design', (tester) async {
    await tester.pumpWidget(CangurApp(state: AppState()));
    expect(find.text('Benvingut/da a Mon Cangur'), findsOneWidget);
    expect(find.text('CA'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Mon Cangur'), findsOneWidget);
    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();
    expect(find.text('Soc pare o mare'), findsOneWidget);
    expect(find.text('Soc cangur'), findsOneWidget);

    await tester.tap(find.text('Soc pare o mare'));
    await tester.pumpAndSettle();
    expect(find.text('Que bé tornar-te a veure'), findsOneWidget);
    expect(find.text('CA'), findsOneWidget);
    expect(find.text('ES'), findsOneWidget);
    await tester.tap(find.text('ES'));
    await tester.pumpAndSettle();
    expect(find.text('Qué bien volver a verte'), findsOneWidget);
    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();
    expect(find.text('Continua amb Google'), findsOneWidget);

    await tester.ensureVisible(find.text("Crea'n un"));
    await tester.tap(find.text("Crea'n un"));
    await tester.pumpAndSettle();
    expect(find.text('Crea el teu compte'), findsOneWidget);
    expect(find.text('FR'), findsOneWidget);
    await tester.tap(find.text('FR'));
    await tester.pumpAndSettle();
    expect(find.text('Créer votre compte'), findsOneWidget);
    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();
    expect(find.text('Repeteix la contrasenya'), findsWidgets);

    await tester.ensureVisible(find.text('Entra'));
    await tester.tap(find.text('Entra'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'familia@moncangur.ad');
    await tester.enterText(find.byType(TextField).at(1), 'demo1234');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('ELS NOSTRES SERVEIS'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('✨ Reservar un servei'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('✨ Reservar un servei'));
    await tester.pumpAndSettle();
    expect(find.text('Quin servei necessites?'), findsOneWidget);
    expect(find.text('Servei Ocasional'), findsWidgets);
    await tester.tap(find.text('Servei Ocasional').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    expect(find.text('Quantes criatures?'), findsOneWidget);
  });

  testWidgets('a father without a profile completes the setup form', (tester) async {
    final state = AppState();
    state.user = AppUser(
      id: 'familia',
      nombre: 'Marta',
      email: 'familia@moncangur.ad',
      password: '',
      role: UserRole.father,
      perfilCompleto: false,
    );
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    expect(find.text('Hola! Comencem 👋'), findsOneWidget);
    expect(find.text('Pas 1 de 4'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('On viviu?'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Els teus peques 🌱'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear el meu perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil creat!'), findsOneWidget);
    expect(state.user!.perfilCompleto, isFalse);

    await tester.tap(find.text("Entrar a l'app →"));
    await tester.pumpAndSettle();
    expect(state.user!.perfilCompleto, isTrue);
    expect(find.text('ELS NOSTRES SERVEIS'), findsOneWidget);
  });

  testWidgets('time picker uses 24-hour entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(onPressed: () => pickTime(context, '10:00'), child: const Text('open'));
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);
    expect(find.text('10'), findsWidgets);
    expect(find.text('00'), findsWidgets);
  });

  testWidgets('servei fix form sends a quote request', (tester) async {
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    final service = state.services.firstWhere((item) => item.tipoServicio == 'fijo');
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(home: FixFormScreen(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pas 1 de 8 · Dates del servei'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continuar →')).onPressed, isNull);

    await tester.tap(find.text('Selecciona una data').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    expect(find.text('Pas 2 de 8 · Dies i hores'), findsOneWidget);

    await tester.tap(find.text('Dilluns'));
    await tester.tap(find.text('Dimecres'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Pas 3 de 8 · Suport'), findsOneWidget);
    await tester.tap(find.text('Cura'));
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('1 infant'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Marta Riba'), findsOneWidget);
    expect(find.text('familia@moncangur.ad'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Et contactarem en 2–3 dies'), findsOneWidget);
    await tester.tap(find.text('Enviar sol·licitud'));
    await tester.pumpAndSettle();

    expect(find.text('Rebut!'), findsOneWidget);
    expect(state.quotes, hasLength(1));
    expect(state.bookings.first.estado, 'presupuesto');
    expect(state.bookings.first.tipoServicio, 'fijo');
    expect(state.bookings.first.notas, contains('Dilluns'));
  });

  testWidgets('extraescolar form sends a quote request', (tester) async {
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    final service = state.services.firstWhere((item) => item.tipoServicio == 'repaso');
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(home: ExtraFormScreen(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pas 1 de 8 · Activitat'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continuar →')).onPressed, isNull);

    await tester.tap(find.text('Anglès'));
    await tester.tap(find.text('Escacs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Pas 2 de 8 · Dies'), findsOneWidget);
    await tester.ensureVisible(find.text('Dimarts'));
    await tester.tap(find.text('Dimarts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Pas 3 de 8 · Horari'), findsOneWidget);
    expect(find.text('Des de'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('1 infant'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Carrer de la Unió, Andorra la Vella'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Marta Riba'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Et contactarem en 2–3 dies'), findsOneWidget);
    await tester.tap(find.text('Enviar sol·licitud'));
    await tester.pumpAndSettle();

    expect(find.text('Sol·licitud rebuda!'), findsOneWidget);
    expect(state.quotes, hasLength(1));
    expect(state.bookings.first.estado, 'presupuesto');
    expect(state.bookings.first.tipoServicio, 'repaso');
    expect(state.bookings.first.horaInicio, '17:00');
    expect(state.bookings.first.direccionServicio, 'Carrer de la Unió, Andorra la Vella');
    expect(state.bookings.first.notas, contains('Anglès'));
  });

  testWidgets('events form sends a quote request', (tester) async {
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    final service = state.services.firstWhere((item) => item.tipoServicio == 'eventos');
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(home: EventFormScreen(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("PAS 1 DE 8 · TIPUS D'ESDEVENIMENT"), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continuar →')).onPressed, isNull);

    await tester.tap(find.text('Aniversari infantil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('PAS 2 DE 8 · DATA I HORARI'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continuar →')).onPressed, isNull);
    await tester.tap(find.byKey(const Key('event-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('PAS 3 DE 8 · INFANTS'), findsOneWidget);
    await tester.tap(find.text('+').first);
    await tester.pumpAndSettle();
    expect(find.text('1 prof · 50 €/h'), findsWidgets);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Pinta cares 🎨'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Carrer de la Unió, Andorra la Vella'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Marta Riba'), findsOneWidget);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Et prepararem un pressupost en 2–3 dies'), findsOneWidget);
    await tester.tap(find.text('Enviar sol·licitud'));
    await tester.pumpAndSettle();

    expect(find.text('Sol·licitud rebuda!'), findsOneWidget);
    expect(state.bookings.first.estado, 'presupuesto');
    expect(state.bookings.first.tipoServicio, 'eventos');
    expect(state.bookings.first.horaInicio, '17:00');
    expect(state.bookings.first.horaFin, '20:00');
    expect(state.bookings.first.numeroNinos, 1);
    expect(state.bookings.first.notas, contains('Aniversari infantil'));
  });

  testWidgets('family menu opens services, bookings and profile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    expect(find.text('EL MEU COMPTE'), findsOneWidget);
    expect(find.text('Marta Riba'), findsOneWidget);
    expect(find.text('AVIAT'), findsWidgets);

    await tester.tap(find.text('El meu perfil'));
    await tester.pumpAndSettle();
    expect(find.text('DADES DE LA FAMÍLIA'), findsOneWidget);
    expect(find.text('Desar canvis'), findsOneWidget);
    await tester.tap(find.text('+ Afegir infant'));
    await tester.pumpAndSettle();
    expect(find.text('Nou infant'), findsOneWidget);
    await tester.tap(find.text('Desar canvis'));
    await tester.pumpAndSettle();
    final infants = state.user!.perfil['infants'];
    expect(infants, isA<List>().having((list) => list.length, 'length', 1));

    await tester.tap(find.byIcon(Icons.chevron_left).hitTestable());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Tancar sessió'), 400);
    await tester.tap(find.text('Termes i condicions'));
    await tester.pumpAndSettle();
    expect(find.text("Termes i condicions d'ús"), findsOneWidget);
    expect(find.textContaining('F-370532-N'), findsOneWidget);
    expect(find.text('Política de privacitat'), findsOneWidget);
    expect(find.text('Política de cancel·lació'), findsOneWidget);
  });

  testWidgets('the infants screen saves extra details about a child', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Infants'));
    await tester.pumpAndSettle();

    expect(find.text('Els meus infants'), findsOneWidget);
    await tester.tap(find.text('Afegir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Pol');
    await tester.tap(find.text('Curiós/a'));
    await tester.tap(find.text('Sí'));
    await tester.ensureVisible(find.text('Desar canvis'));
    await tester.tap(find.text('Desar canvis'));
    await tester.pumpAndSettle();

    expect(find.text('Canvis desats ✓'), findsOneWidget);
    final infants = state.user!.perfil['infants'] as List;
    expect(infants, hasLength(1));
    final kid = infants.first as Map;
    expect(kid['nombre'], 'Pol');
    expect(kid['caracter'], contains('curious'));
    expect(kid['migdiada'], 0);
  });

  testWidgets('a booking opens its details', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    state.bookings.add(
      Booking(
        id: 'r1',
        padreId: 'familia',
        padreNombre: 'Marta Riba',
        tipoServicio: 'ocasional',
        fecha: DateTime(2026, 10, 8),
        horaInicio: '16:00',
        horaFin: '19:00',
        numeroNinos: 2,
        direccionServicio: 'Carrer de la Unió, Andorra la Vella',
        canguroNombre: 'Júlia',
        notas: 'Portar berenar',
        total: 84,
      ),
    );
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reserves'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Servei Ocasional'));
    await tester.pumpAndSettle();

    expect(find.text('Detall de la reserva'), findsOneWidget);
    expect(find.text('Júlia'), findsWidgets);
    expect(find.text('Carrer de la Unió, Andorra la Vella'), findsOneWidget);
    expect(find.text('16:00 – 19:00'), findsOneWidget);
    expect(find.text('Portar berenar'), findsOneWidget);
    expect(find.text('84.00 €'), findsOneWidget);
    expect(find.text('Pagar'), findsOneWidget);
    await tester.tap(find.text('Pagar'));
    await tester.pumpAndSettle();
    expect(find.text('El navegador ha bloquejat la finestra de pagament.'), findsOneWidget);
  });

  testWidgets('a completed booking can be reviewed from history', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    state.bookings.add(
      Booking(
        id: 'done-1',
        padreId: 'familia',
        padreNombre: 'Marta Riba',
        tipoServicio: 'ocasional',
        fecha: DateTime(2026, 9, 20),
        horaInicio: '16:00',
        horaFin: '20:00',
        numeroNinos: 2,
        direccionServicio: 'Carrer de la Unió',
        canguroId: 'anna',
        canguroNombre: 'Anna',
        estado: 'completada',
        total: 112,
      ),
    );
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reserves'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Encara no tens reserves actives'), findsOneWidget);
    await tester.tap(find.textContaining('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('112,00 €'), findsOneWidget);
    await tester.tap(find.text('Deixar la meva valoració'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-star-5')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('review-text')), 'La Carla va ser encantadora');
    await tester.tap(find.text('Enviar valoració'));
    await tester.pumpAndSettle();

    expect(find.text('Valoració enviada a Mon Cangur ✓'), findsOneWidget);
    expect(state.reviews, hasLength(1));
    expect(state.reviews.single.stars, 5);
    expect(state.reviews.single.comentario, 'La Carla va ser encantadora');
    expect(find.textContaining('La Carla va ser encantadora'), findsOneWidget);
  });

  testWidgets('the home screen opens a cangur profile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    expect(find.text('EL NOSTRE EQUIP'), findsOneWidget);
    await tester.tap(find.text('Servei Ocasional'));
    await tester.pumpAndSettle();
    expect(find.text('25,00 €'), findsWidgets);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Júlia Lima'));
    await tester.tap(find.text('Júlia Lima'));
    await tester.pumpAndSettle();
    expect(find.text('La nostra cangur'), findsOneWidget);
    expect(find.text('Júlia Lima'), findsWidgets);
    expect(find.text('Fundadora'), findsOneWidget);
    expect(find.text('Qui és'), findsOneWidget);
    expect(find.text('Reservar un servei'), findsOneWidget);
  });

  testWidgets('a cangur sees the agenda and can save the professional profile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'cangur@moncangur.ad');
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/cangur');
    await tester.pumpAndSettle();

    expect(find.text('Hola, Laia 👋'), findsOneWidget);
    expect(find.text('CA'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Laia 👋'), findsOneWidget);
    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();
    expect(find.text('Sol·licituds pendents'), findsOneWidget);
    expect(find.textContaining('No tens sol·licituds pendents'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('CANGUR'), findsOneWidget);
    expect(find.text('LA MEVA FEINA'), findsOneWidget);
    expect(find.text('Xat amb pares'), findsOneWidget);
    await tester.tap(find.text('Xat amb pares'));
    await tester.pumpAndSettle();
    expect(find.text('CONVERSES'), findsOneWidget);
    expect(find.text('Mon Cangur'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left).hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Les meves reserves'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Properes'), findsOneWidget);
    expect(find.textContaining('Historial'), findsOneWidget);
    expect(find.textContaining('No tens reserves confirmades'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left).hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left).hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('El meu perfil'), findsOneWidget);
    expect(find.text('Laia Serra'), findsWidgets);
    expect(find.text('DADES'), findsOneWidget);
    expect(find.text('LA MEVA PRESENTACIÓ'), findsOneWidget);
    expect(find.text('GALERIA DE FOTOS'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('cangur-qui')), 'Nova descripció');
    await tester.pump();
    await tester.tap(find.text('Desar canvis'));
    await tester.pump();

    expect(find.text('Canvis desats ✓'), findsOneWidget);
    expect(state.profileFor('laia')!.qui, 'Nova descripció');
    expect(state.profileFor('laia')!.descripcionPersonal, 'Nova descripció');
    expect(state.profileFor('laia')!.servicios, contains('ocasional'));
    expect(state.profileFor('laia')!.idiomas, contains('Català'));

    await tester.tap(find.byIcon(Icons.chevron_left).hitTestable());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Editar la meva disponibilitat'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Editar la meva disponibilitat'));
    await tester.pumpAndSettle();
    expect(find.text('Aplica a tot el mes'), findsOneWidget);
    expect(find.text('Desar la disponibilitat'), findsOneWidget);
    expect(find.text('EL MEU CALENDARI'), findsOneWidget);
    expect(state.profileFor('laia')!.week['lunes']!.disponible, isTrue);
  });

  testWidgets('a cangur accepts a pending request from home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'cangur@moncangur.ad');
    final booking = Booking(
      id: 'req1',
      padreId: 'familia',
      padreNombre: 'Família Soler',
      tipoServicio: 'emergencia',
      fecha: DateTime.now(),
      horaInicio: '20:00',
      horaFin: '23:00',
      numeroNinos: 1,
      direccionServicio: 'Carrer Major, Encamp',
      canguroId: 'laia',
      canguroNombre: 'Laia Serra',
      total: 45,
    );
    state.bookings.add(booking);
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/cangur');
    await tester.pumpAndSettle();

    expect(find.text("Servei d'Urgència"), findsOneWidget);
    expect(find.text('Encamp'), findsOneWidget);
    expect(find.text('45,00 €'), findsOneWidget);
    await tester.tap(find.text('Acceptar'));
    await tester.pumpAndSettle();

    expect(find.text('Reserva acceptada ✓'), findsOneWidget);
    expect(find.textContaining('Acceptada'), findsOneWidget);
    expect(booking.estado, 'confirmada');
  });

  testWidgets('a cangur with an incomplete profile submits the welcome form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = AppUser(
      id: 'nova',
      nombre: 'Anna',
      email: 'anna.nova@moncangur.ad',
      password: '',
      role: UserRole.cangur,
      perfilCompleto: false,
    );
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/cangur');
    await tester.pumpAndSettle();

    expect(find.text('Crea el teu perfil de cangur'), findsOneWidget);
    expect(find.text('PAS 1 DE 7 · BENVINGUDA'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('cangur-rol')), "Mestra d'educació infantil");
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Quins idiomes parles?'), findsOneWidget);
    await tester.tap(find.text('Català'));
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cangur-qui')), 'a' * 120);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cangur-work')), 'b' * 80);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cangur-likes')), 'c' * 60);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cangur-strength')), 'd' * 50);
    await tester.tap(find.text('Continuar →'));
    await tester.pumpAndSettle();

    expect(find.text('Tot a punt!'), findsOneWidget);
    await tester.tap(find.text('Enviar perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil creat!'), findsOneWidget);
    expect(state.user!.perfilCompleto, isFalse);
    expect(state.profileFor('nova')!.rol, "Mestra d'educació infantil");
    expect(state.profileFor('nova')!.idiomas, contains('Català'));
    expect(state.profileFor('nova')!.qui.length, 120);

    await tester.tap(find.text("Entrar a l'app →"));
    await tester.pumpAndSettle();
    expect(state.user!.perfilCompleto, isTrue);
    expect(find.text('Hola, Anna 👋'), findsOneWidget);
  });

  testWidgets('a father chats with the cangur from a booking', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    state.bookings.add(
      Booking(
        id: 'r-chat',
        padreId: 'familia',
        padreNombre: 'Marta Riba',
        tipoServicio: 'ocasional',
        fecha: DateTime(2026, 10, 10),
        horaInicio: '16:00',
        horaFin: '19:00',
        numeroNinos: 1,
        direccionServicio: 'Carrer de la Unió',
        canguroId: 'laia',
        canguroNombre: 'Laia Serra',
      ),
    );
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Xat amb la meva cangur'), 300);
    await tester.tap(find.text('Xat amb la meva cangur'));
    await tester.pumpAndSettle();

    expect(find.text('Laia Serra'), findsOneWidget);
    expect(find.text('Comença la conversa'), findsOneWidget);
    await tester.tap(find.text('Laia Serra'));
    await tester.pumpAndSettle();

    expect(find.text('Fotos només per a la família'), findsOneWidget);
    expect(find.textContaining('la teva cangur'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('chat-input')), 'Hola Laia');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('Hola Laia'), findsOneWidget);
    expect(state.messagesFor('r-chat'), hasLength(1));
    expect(state.messagesFor('r-chat').single.remitenteId, 'familia');
    expect(state.chatPreviews['r-chat']?.ultimoMensaje, 'Hola Laia');
  });

  testWidgets('admin home shows totals and upcoming bookings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'admin@moncangur.ad');
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    Booking sample(String id, String family, String tipo, DateTime fecha) {
      return Booking(
        id: id,
        padreId: 'familia',
        padreNombre: family,
        tipoServicio: tipo,
        fecha: fecha,
        horaInicio: '10:00',
        horaFin: '12:00',
        numeroNinos: 1,
        direccionServicio: 'Encamp',
        canguroId: 'laia',
        canguroNombre: 'Laia Serra',
        estado: 'pendiente',
        total: 48,
      );
    }

    state.bookings.addAll([
      sample('a', 'Marta Riba', 'eventos', day.add(const Duration(days: 1))),
      sample('soon', 'Marta Riba', 'ocasional', day.add(const Duration(days: 2))),
      sample('c', 'Marta Riba', 'emergencia', day.add(const Duration(days: 3))),
      sample('d', 'Marta Riba', 'repaso', day.add(const Duration(days: 4))),
      sample('e', 'Família Cinc', 'fijo', day.add(const Duration(days: 5))),
      sample('later', 'Família Sisena', 'fijo', day.add(const Duration(days: 20))),
      sample('old', 'Marta Riba', 'emergencia', day.subtract(const Duration(days: 3))),
    ]);
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/admin');
    await tester.pumpAndSettle();

    expect(find.text('Total cangurs'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Total reserves'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Properes'), findsOneWidget);
    expect(find.text('Servei Ocasional'), findsOneWidget);
    expect(find.text('Família Cinc'), findsOneWidget);
    expect(find.text('Família Sisena'), findsNothing);
    expect(find.text('Marta Riba'), findsWidgets);
    expect(find.text('Laia Serra'), findsWidgets);
    expect(find.text('Tancar sessió'), findsNothing);
    expect(find.text('Inici'), findsOneWidget);
    expect(find.text('Reserves'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Tancar sessió'), findsOneWidget);
    expect(find.text('ADMIN'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Tancar sessió'), findsNothing);
    await tester.tap(find.text('Reserves'));
    await tester.pumpAndSettle();
    expect(find.text('Les meves reserves'), findsOneWidget);
    expect(find.textContaining('Properes (7)'), findsOneWidget);
    expect(find.textContaining('Historial (0)'), findsOneWidget);
    expect(find.text('Xat família i cangur'), findsWidgets);
    await tester.tap(find.text('Xat família i cangur').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat-input')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left).hitTestable());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Família Sisena'), 400);
    expect(find.text('Família Sisena'), findsOneWidget);
    await tester.tap(find.text('Inici'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Total nannies'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Occasional service'), findsOneWidget);
  });
}

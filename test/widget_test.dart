import 'package:cangur_app/main.dart';
import 'package:cangur_app/models/models.dart';
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
    expect(find.text('Els nostres serveis'), findsOneWidget);

    await tester.ensureVisible(find.text('Reservar'));
    await tester.tap(find.text('Reservar'));
    await tester.pumpAndSettle();
    expect(find.text('Quin servei necessites?'), findsOneWidget);
    expect(find.text('Servei Ocasional'), findsOneWidget);

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
    expect(find.text('Els nostres serveis'), findsOneWidget);
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
    await tester.tap(find.text('Ocasional'));
    await tester.pumpAndSettle();

    expect(find.text('Detall de la reserva'), findsOneWidget);
    expect(find.text('Júlia'), findsOneWidget);
    expect(find.text('Carrer de la Unió, Andorra la Vella'), findsOneWidget);
    expect(find.text('16:00 – 19:00'), findsOneWidget);
    expect(find.text('Portar berenar'), findsOneWidget);
    expect(find.text('84.00 €'), findsOneWidget);
    expect(find.text('Pagar'), findsOneWidget);
    await tester.tap(find.text('Pagar'));
    await tester.pumpAndSettle();
    expect(find.text('El navegador ha bloquejat la finestra de pagament.'), findsOneWidget);
  });

  testWidgets('the home screen opens a cangur profile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = AppState();
    state.user = state.users.firstWhere((user) => user.email == 'familia@moncangur.ad');
    await tester.pumpWidget(CangurApp(state: state));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/father');
    await tester.pumpAndSettle();

    expect(find.text('LES NOSTRES CANGURS'), findsOneWidget);
    await tester.tap(find.text('Júlia'));
    await tester.pumpAndSettle();
    expect(find.text('La nostra cangur'), findsOneWidget);
    expect(find.text('Júlia Lima'), findsOneWidget);
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

    expect(find.text('La meva agenda'), findsOneWidget);
    expect(find.text('Totes'), findsOneWidget);
    expect(find.text('Pendents'), findsOneWidget);
    expect(find.text('Completades'), findsOneWidget);
    expect(find.text('No hi ha reserves per a aquest dia'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Editar perfil professional'), findsOneWidget);
    expect(find.text('Laia Serra'), findsOneWidget);
    expect(find.text('Primers auxilis'), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const Key('cangur-about')), 400, scrollable: find.byType(Scrollable).last);
    await tester.enterText(find.byKey(const Key('cangur-about')), 'Nova descripció');
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Desar canvis'), 300, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Desar canvis'));
    await tester.pumpAndSettle();

    expect(find.text('Canvis desats'), findsOneWidget);
    expect(state.profileFor('laia')!.descripcionPersonal, 'Nova descripció');
    expect(state.profileFor('laia')!.servicios, contains('ocasional'));
  });
}

import 'package:flutter/foundation.dart';

import '../domain/availability.dart';
import '../domain/pricing.dart';
import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../services/account_gateway.dart';

class AppState extends ChangeNotifier {
  AppState({this.accounts}) {
    _seed();
  }

  final AccountGateway? accounts;

  AppLang lang = AppLang.ca;
  AppUser? user;
  final List<AppUser> users = [];
  final List<ServiceOffer> services = [];
  final List<CangurProfile> canguros = [];
  final List<Booking> bookings = [];
  final List<Review> reviews = [];
  final List<QuoteRequest> quotes = [];
  String? banner;

  String tr(String key) => t(lang, key);

  void setLang(AppLang value) {
    lang = value;
    notifyListeners();
  }

  void flash(String message) {
    banner = message;
    notifyListeners();
  }

  void clearBanner() {
    banner = null;
    notifyListeners();
  }

  Future<AppUser?> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (!_validEmail(normalized)) {
      flash(tr('emailInvalidShort'));
      return null;
    }
    final gateway = accounts;
    if (gateway == null) {
      for (final account in users) {
        if (account.email == normalized && account.password == password) {
          user = account;
          banner = null;
          notifyListeners();
          return account;
        }
      }
      flash(tr('wrongCredentials'));
      return null;
    }
    try {
      final account = await gateway.signIn(email: normalized, password: password);
      user = account;
      banner = null;
      notifyListeners();
      return account;
    } on AccountFailure catch (error) {
      flash(tr(error.code));
      return null;
    }
  }

  Future<String?> signUp({
    required String nombre,
    required String email,
    required String password,
    required String confirm,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!_validEmail(normalized)) return tr('invalidEmail');
    if (password.length < 6) return tr('weakPassword');
    if (password != confirm) return tr('mismatch');
    final gateway = accounts;
    if (gateway == null) {
      if (users.any((u) => u.email == normalized)) return tr('emailTaken');
      users.add(
        AppUser(
          id: 'u${users.length + 1}',
          nombre: nombre.trim().isEmpty ? normalized : nombre.trim(),
          email: normalized,
          password: password,
          role: UserRole.father,
        ),
      );
      return null;
    }
    try {
      await gateway.register(email: normalized, password: password, idioma: lang.name);
      return null;
    } on AccountFailure catch (error) {
      return tr(error.code);
    }
  }

  Future<String?> resetPassword(String email) async {
    final normalized = email.trim().toLowerCase();
    if (!_validEmail(normalized)) return tr('invalidEmail');
    final gateway = accounts;
    if (gateway == null) return null;
    try {
      await gateway.resetPassword(normalized);
      return null;
    } on AccountFailure catch (error) {
      return tr(error.code);
    }
  }

  Future<String?> completeFatherProfile({
    required String displayName,
    required String telefono,
    required String direccion,
    required String idioma,
    required Map<String, Object?> perfil,
  }) async {
    final account = user;
    if (account == null) return tr('mustSignIn');
    final gateway = accounts;
    if (gateway != null) {
      try {
        await gateway.saveFatherProfile(
          uid: account.id,
          displayName: displayName,
          telefono: telefono,
          direccion: direccion,
          idioma: idioma,
          perfil: perfil,
        );
      } on AccountFailure catch (error) {
        return tr(error.code);
      }
    }
    if (displayName.isNotEmpty) account.nombre = displayName;
    account.telefono = telefono;
    account.direccion = direccion;
    account.perfil = Map<String, dynamic>.from(perfil);
    notifyListeners();
    return null;
  }

  Future<void> refreshServices() async {
    final gateway = accounts;
    if (gateway == null) return;
    try {
      final remote = await gateway.loadServices();
      if (remote.isEmpty) return;
      services
        ..clear()
        ..addAll(remote);
      notifyListeners();
    } on AccountFailure {
      return;
    }
  }

  Future<void> refreshCanguros() async {
    final gateway = accounts;
    if (gateway == null) return;
    try {
      final remote = await gateway.loadCanguros();
      canguros
        ..clear()
        ..addAll(remote);
      notifyListeners();
    } on AccountFailure {
      return;
    }
  }

  void signOut() {
    user = null;
    banner = null;
    notifyListeners();
    accounts?.signOut();
  }

  bool changePassword(String current, String next, String confirm) {
    final account = user;
    if (account == null) return false;
    if (current.isEmpty) {
      flash(tr('enterCurrent'));
      return false;
    }
    if (current != account.password) {
      flash(tr('wrongCredentials'));
      return false;
    }
    if (next.length < 6) {
      flash(tr('weakPassword'));
      return false;
    }
    if (next != confirm) {
      flash(tr('mismatch'));
      return false;
    }
    if (next == current) {
      flash(tr('passwordSame'));
      return false;
    }
    account.password = next;
    flash(tr('passwordChanged'));
    return true;
  }

  void updateAccount(AppUser edited) {
    notifyListeners();
  }

  List<CangurProfile> findCanguros({
    required String tipo,
    required DateTime date,
    required String start,
    required String end,
  }) {
    return canguros.where((profile) {
      return cangurMatches(
        profile: profile,
        tipoServicio: tipo,
        date: date,
        start: start,
        end: end,
      );
    }).toList();
  }

  Future<Booking?> placeReserva({
    required ServiceOffer service,
    required DateTime date,
    required String start,
    required String end,
    required int children,
    required String address,
    required CangurProfile cangur,
    double? total,
    String? caregiverNames,
    String notes = '',
  }) async {
    final account = user;
    if (account == null) return null;
    final hours = hoursBetween(start, end);
    if (hours == null) return null;
    final price = Pricing.quote(service: service, children: children, hours: hours);
    final amount = total ?? price.total;
    String? remoteId;
    final gateway = accounts;
    if (gateway != null) {
      remoteId = await gateway.saveReserva(
        padreId: account.id,
        padreNombre: account.nombre,
        tipoServicio: service.tipoServicio,
        fecha: date,
        horaInicio: start,
        horaFin: end,
        numeroNinos: children,
        direccion: address,
        canguroId: cangur.userId,
        canguroNombre: caregiverNames ?? cangur.nombre,
        total: amount,
        servicioId: service.id,
        duracionHoras: hours,
        notas: notes,
      );
    }
    return createBooking(
      id: remoteId,
      service: service,
      date: date,
      start: start,
      end: end,
      children: children,
      address: address,
      cangur: cangur,
      total: amount,
      caregiverNames: caregiverNames,
      notes: notes,
    );
  }

  Booking? createBooking({
    String? id,
    required ServiceOffer service,
    required DateTime date,
    required String start,
    required String end,
    required int children,
    required String address,
    required CangurProfile cangur,
    double? total,
    String? caregiverNames,
    String notes = '',
    bool paid = false,
  }) {
    final account = user;
    if (account == null) return null;
    final hours = hoursBetween(start, end);
    if (hours == null) return null;
    final price = Pricing.quote(service: service, children: children, hours: hours);
    final booking = Booking(
      id: id ?? 'r${bookings.length + 1}',
      padreId: account.id,
      padreNombre: account.nombre,
      tipoServicio: service.tipoServicio,
      fecha: DateTime(date.year, date.month, date.day),
      horaInicio: start,
      horaFin: end,
      numeroNinos: children,
      direccionServicio: address.trim(),
      canguroId: cangur.userId,
      canguroNombre: caregiverNames ?? cangur.nombre,
      estado: paid ? 'confirmada' : 'pendiente',
      estadoPago: paid ? 'pagada' : 'pendiente',
      notas: notes,
      total: total ?? price.total,
    );
    bookings.insert(0, booking);
    notifyListeners();
    return booking;
  }

  void setPayment(String bookingId, bool success) {
    final booking = _booking(bookingId);
    if (booking == null) {
      flash(tr('bookingNotFound'));
      return;
    }
    booking.estadoPago = success ? 'pagada' : 'fallido';
    notifyListeners();
  }

  QuoteRequest? submitQuote({required String tipo, required String resumen}) {
    final account = user;
    if (account == null) {
      flash(tr('mustSignIn'));
      return null;
    }
    final quote = QuoteRequest(
      id: 'q${quotes.length + 1}',
      padreId: account.id,
      tipo: tipo,
      resumen: resumen,
      createdAt: DateTime.now(),
    );
    quotes.insert(0, quote);
    final booking = Booking(
      id: 'r${bookings.length + 1}',
      padreId: account.id,
      padreNombre: account.nombre,
      tipoServicio: tipo,
      fecha: DateTime.now(),
      horaInicio: '',
      horaFin: '',
      numeroNinos: 0,
      direccionServicio: '',
      estado: 'presupuesto',
      estadoPago: 'pendiente',
      notas: resumen,
    );
    bookings.insert(0, booking);
    notifyListeners();
    return quote;
  }

  Future<bool> submitFixRequest({
    required ServiceOffer service,
    required DateTime startDate,
    required String start,
    required String end,
    required int children,
    required String resumen,
    String direccion = '',
  }) async {
    final account = user;
    if (account == null) {
      flash(tr('mustSignIn'));
      return false;
    }
    final hours = hoursBetween(start, end) ?? 0;
    final place = direccion.trim().isEmpty ? account.direccion : direccion.trim();
    String? remoteId;
    final gateway = accounts;
    if (gateway != null) {
      try {
        remoteId = await gateway.saveReserva(
          padreId: account.id,
          padreNombre: account.nombre,
          tipoServicio: service.tipoServicio,
          fecha: startDate,
          horaInicio: start,
          horaFin: end,
          numeroNinos: children,
          direccion: place,
          canguroId: '',
          canguroNombre: '',
          total: 0,
          servicioId: service.id,
          duracionHoras: hours,
          notas: resumen,
          estado: 'presupuesto',
        );
      } on AccountFailure catch (error) {
        flash(tr(error.code));
        return false;
      }
    }
    final quote = QuoteRequest(
      id: remoteId ?? 'q${quotes.length + 1}',
      padreId: account.id,
      tipo: service.tipoServicio,
      resumen: resumen,
      createdAt: DateTime.now(),
    );
    quotes.insert(0, quote);
    bookings.insert(
      0,
      Booking(
        id: remoteId ?? 'r${bookings.length + 1}',
        padreId: account.id,
        padreNombre: account.nombre,
        tipoServicio: service.tipoServicio,
        fecha: DateTime(startDate.year, startDate.month, startDate.day),
        horaInicio: start,
        horaFin: end,
        numeroNinos: children,
        direccionServicio: place,
        estado: 'presupuesto',
        estadoPago: 'pendiente',
        notas: resumen,
      ),
    );
    notifyListeners();
    return true;
  }

  void assignCangur(String bookingId, String canguroId) {
    final booking = _booking(bookingId);
    CangurProfile? profile;
    for (final item in canguros) {
      if (item.userId == canguroId) profile = item;
    }
    if (booking == null || profile == null) {
      flash(tr('noneForBooking'));
      return;
    }
    booking.canguroId = profile.userId;
    booking.canguroNombre = profile.nombre;
    if (booking.estado == 'pendiente' || booking.estado == 'presupuesto') {
      booking.estado = 'confirmada';
    }
    flash(tr('assignedOk'));
  }

  void saveCangur(CangurProfile profile) {
    notifyListeners();
  }

  void addReview({
    required Booking booking,
    required int puntualidad,
    required int trato,
    required int profesionalismo,
    required String comentario,
  }) {
    final account = user;
    if (account == null || booking.canguroId == null) return;
    reviews.removeWhere((r) => r.reservaId == booking.id && r.padreId == account.id);
    reviews.add(
      Review(
        id: 'v${reviews.length + 1}',
        padreId: account.id,
        canguroId: booking.canguroId!,
        reservaId: booking.id,
        puntualidad: puntualidad,
        trato: trato,
        profesionalismo: profesionalismo,
        comentario: comentario.trim(),
      ),
    );
    notifyListeners();
  }

  List<Review> reviewsFor(String canguroId) {
    return reviews.where((r) => r.canguroId == canguroId).toList();
  }

  List<Booking> bookingsForCurrent() {
    final account = user;
    if (account == null) return [];
    switch (account.role) {
      case UserRole.father:
        return bookings.where((b) => b.padreId == account.id).toList();
      case UserRole.cangur:
        return bookings.where((b) => b.canguroId == account.id).toList();
      case UserRole.admin:
        return bookings;
    }
  }

  CangurProfile? profileFor(String userId) {
    for (final profile in canguros) {
      if (profile.userId == userId) return profile;
    }
    return null;
  }

  Booking? _booking(String id) {
    for (final booking in bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  bool _validEmail(String email) {
    return email.contains('@') && email.contains('.') && !email.startsWith('@');
  }

  void _seed() {
    users.addAll([
      AppUser(
        id: 'admin',
        nombre: 'Admin Mon Cangur',
        email: 'admin@moncangur.ad',
        password: 'demo1234',
        role: UserRole.admin,
      ),
      AppUser(
        id: 'familia',
        nombre: 'Marta Riba',
        email: 'familia@moncangur.ad',
        password: 'demo1234',
        role: UserRole.father,
        telefono: '+376 600 100',
        direccion: 'Carrer de la Unió, Andorra la Vella',
        idiomasCanguro: ['Català', 'Castellà'],
        contactoEmergenciaNombre: 'Pere Riba',
        contactoEmergenciaTelefono: '+376 600 101',
      ),
      AppUser(
        id: 'laia',
        nombre: 'Laia Serra',
        email: 'cangur@moncangur.ad',
        password: 'demo1234',
        role: UserRole.cangur,
        telefono: '+376 600 200',
      ),
      AppUser(
        id: 'marc',
        nombre: 'Marc Vidal',
        email: 'marc@moncangur.ad',
        password: 'demo1234',
        role: UserRole.cangur,
      ),
      AppUser(
        id: 'anna',
        nombre: 'Anna Costa',
        email: 'anna@moncangur.ad',
        password: 'demo1234',
        role: UserRole.cangur,
      ),
    ]);

    ServiceOffer priced({
      required String id,
      required String tipo,
      required String descripcion,
      required double net,
      bool phone = false,
    }) {
      final gross = double.parse((net * 1.045).toStringAsFixed(2));
      return ServiceOffer(
        id: id,
        nombre: tipo,
        descripcion: descripcion,
        tipoServicio: tipo,
        igi: 4.5,
        tarifaBase: net,
        tarifaConIGI: gross,
        gestionTelefonica: phone,
      );
    }

    services.addAll([
      priced(
        id: 'ocasional',
        tipo: 'ocasional',
        descripcion: 'Cura puntual a casa, per hores.',
        net: 18,
      ),
      priced(
        id: 'emergencia',
        tipo: 'emergencia',
        descripcion: 'Cobertura urgent quan la família ho necessita el mateix dia.',
        net: 24,
        phone: true,
      ),
      priced(
        id: 'repaso',
        tipo: 'repaso',
        descripcion: 'Acompanyament i repàs després de l\'escola.',
        net: 20,
      ),
      const ServiceOffer(
        id: 'fijo',
        nombre: 'fijo',
        descripcion: 'Servei recurrent, amb pressupost personalitzat.',
        tipoServicio: 'fijo',
        igi: 4.5,
        tarifaBase: 0,
        requiereAprobacion: true,
        requiereFormulario: true,
      ),
      const ServiceOffer(
        id: 'eventos',
        nombre: 'eventos',
        descripcion:
            'Suport professional durant celebracions. El pressupost es confirma per WhatsApp o correu.',
        tipoServicio: 'eventos',
        igi: 4.5,
        tarifaBase: 0,
        requiereAprobacion: true,
        requiereFormulario: true,
        gestionTelefonica: true,
      ),
    ]);

    DayAvailability open(String start, String end) => DayAvailability(
      disponible: true,
      franjas: [TimeBand(start, end)],
    );
    DayAvailability closed() => DayAvailability(disponible: false, franjas: [const TimeBand('09:00', '17:00')]);

    Map<String, DayAvailability> week({
      required String start,
      required String end,
      Set<String> days = const {'lunes', 'martes', 'miercoles', 'jueves', 'viernes'},
    }) {
      return {
        for (final day in weekDays) day: days.contains(day) ? open(start, end) : closed(),
      };
    }

    canguros.addAll([
      CangurProfile(
        userId: 'laia',
        nombre: 'Laia Serra',
        email: 'cangur@moncangur.ad',
        descripcionPersonal: 'Mestra d\'anglès. Primers auxilis i experiència amb nadons i infants.',
        tarifaPorHora: 18,
        servicios: ['ocasional', 'emergencia'],
        certificaciones: ['Primers auxilis'],
        idiomas: ['Català', 'Castellà', 'Anglès'],
        aniosExperiencia: 6,
        week: week(start: '09:00', end: '19:00'),
      ),
      CangurProfile(
        userId: 'marc',
        nombre: 'Marc Vidal',
        email: 'marc@moncangur.ad',
        descripcionPersonal: 'Repàs de primària i ESO, en català i francès.',
        tarifaPorHora: 20,
        servicios: ['repaso', 'ocasional'],
        certificaciones: ['Primers auxilis'],
        idiomas: ['Català', 'Francès'],
        aniosExperiencia: 4,
        week: week(start: '15:00', end: '20:00'),
      ),
      CangurProfile(
        userId: 'anna',
        nombre: 'Anna Costa',
        email: 'anna@moncangur.ad',
        descripcionPersonal: 'Esdeveniments familiars i servei fix de tarda.',
        tarifaPorHora: 22,
        servicios: ['eventos', 'fijo', 'ocasional'],
        certificaciones: ['Primers auxilis'],
        idiomas: ['Català', 'Castellà', 'Francès', 'Anglès'],
        aniosExperiencia: 8,
        week: week(
          start: '10:00',
          end: '22:00',
          days: {'viernes', 'sabado', 'domingo'},
        ),
      ),
    ]);
  }
}

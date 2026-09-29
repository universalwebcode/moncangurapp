enum AppLang { ca, es, en, fr }

enum UserRole { admin, cangur, father }

/// Routes recovered from the compiled app: /login, /signup, /admin, /cangur, /father.
/// Role index used at login: 0 admin, 1 cangur, 2 father.
UserRole roleFromIndex(int index) {
  switch (index) {
    case 0:
      return UserRole.admin;
    case 1:
      return UserRole.cangur;
    default:
      return UserRole.father;
  }
}

String routeForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.cangur:
      return '/cangur';
    case UserRole.father:
      return '/father';
  }
}

class TimeBand {
  const TimeBand(this.inicio, this.fin);
  final String inicio;
  final String fin;
}

class DayAvailability {
  DayAvailability({required this.disponible, required this.franjas});
  bool disponible;
  List<TimeBand> franjas;
}

class AvailabilityException {
  AvailabilityException({
    required this.fecha,
    required this.disponible,
    required this.franjas,
  });
  final String fecha;
  bool disponible;
  List<TimeBand> franjas;
}

class AppUser {
  AppUser({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.role,
    this.telefono = '',
    this.direccion = '',
    this.idiomasCanguro = const [],
    this.contactoEmergenciaNombre = '',
    this.contactoEmergenciaTelefono = '',
  });

  final String id;
  String nombre;
  final String email;
  String password;
  final UserRole role;
  String telefono;
  String direccion;
  List<String> idiomasCanguro;
  String contactoEmergenciaNombre;
  String contactoEmergenciaTelefono;
}

class ServiceOffer {
  const ServiceOffer({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipoServicio,
    required this.igi,
    required this.tarifaBase,
    this.tarifaConIGI,
    this.tarifasPorNinos = const {},
    this.tarifasPorNinosConIGI = const {},
    this.gestionTelefonica = false,
    this.requiereAprobacion = false,
    this.requiereFormulario = false,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String tipoServicio;
  final double igi;
  final double tarifaBase;
  final double? tarifaConIGI;
  final Map<int, double> tarifasPorNinos;
  final Map<int, double> tarifasPorNinosConIGI;
  final bool gestionTelefonica;
  final bool requiereAprobacion;
  final bool requiereFormulario;

  bool get isQuote => requiereFormulario;
}

class CangurProfile {
  CangurProfile({
    required this.userId,
    required this.nombre,
    required this.email,
    required this.descripcionPersonal,
    required this.tarifaPorHora,
    required this.servicios,
    required this.certificaciones,
    required this.idiomas,
    required this.week,
    this.activo = true,
    this.aniosExperiencia = 0,
    List<AvailabilityException>? exceptions,
  }) : exceptions = exceptions ?? [];

  final String userId;
  String nombre;
  final String email;
  String descripcionPersonal;
  double tarifaPorHora;
  List<String> servicios;
  List<String> certificaciones;
  List<String> idiomas;
  Map<String, DayAvailability> week;
  bool activo;
  int aniosExperiencia;
  List<AvailabilityException> exceptions;
}

class Booking {
  Booking({
    required this.id,
    required this.padreId,
    required this.padreNombre,
    required this.tipoServicio,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.numeroNinos,
    required this.direccionServicio,
    this.canguroId,
    this.canguroNombre,
    this.estado = 'pendiente',
    this.estadoPago = 'pendiente',
    this.notas = '',
    this.total,
  });

  final String id;
  final String padreId;
  final String padreNombre;
  final String tipoServicio;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final int numeroNinos;
  final String direccionServicio;
  String? canguroId;
  String? canguroNombre;
  String estado;
  String estadoPago;
  String notas;
  double? total;
}

class Review {
  Review({
    required this.id,
    required this.padreId,
    required this.canguroId,
    required this.reservaId,
    required this.puntualidad,
    required this.trato,
    required this.profesionalismo,
    required this.comentario,
  });

  final String id;
  final String padreId;
  final String canguroId;
  final String reservaId;
  final int puntualidad;
  final int trato;
  final int profesionalismo;
  final String comentario;

  double get rating => (puntualidad + trato + profesionalismo) / 3;
}

class QuoteRequest {
  QuoteRequest({
    required this.id,
    required this.padreId,
    required this.tipo,
    required this.resumen,
    required this.createdAt,
  });

  final String id;
  final String padreId;
  final String tipo;
  final String resumen;
  final DateTime createdAt;
}

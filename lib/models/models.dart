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
  const TimeBand(this.inicio, this.fin, {this.torn});
  final String inicio;
  final String fin;
  final String? torn;
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
    this.perfilCompleto = true,
    Map<String, dynamic>? perfil,
  }) : perfil = perfil ?? {};

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
  bool perfilCompleto;
  Map<String, dynamic> perfil;
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
    this.image,
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
  final String? image;

  bool get isQuote => requiereFormulario;
}

ServiceOffer serviceFromMap(String id, Map<String, dynamic> data) {
  Map<int, double> rates(Object? raw) {
    if (raw is! Map) return {};
    final parsed = <int, double>{};
    for (final entry in raw.entries) {
      final children = int.tryParse(entry.key.toString());
      final amount = entry.value is num ? (entry.value as num).toDouble() : double.tryParse('${entry.value}');
      if (children != null && amount != null) parsed[children] = amount;
    }
    return parsed;
  }

  double number(Object? raw) => raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0;

  return ServiceOffer(
    id: data['id'] is String ? data['id'] as String : id,
    nombre: data['nombre'] is String ? data['nombre'] as String : id,
    descripcion: data['descripcion'] is String ? data['descripcion'] as String : '',
    tipoServicio: data['tipoServicio'] is String ? data['tipoServicio'] as String : id,
    igi: number(data['igi'] ?? 4.5),
    tarifaBase: number(data['tarifaBase']),
    tarifaConIGI: data['tarifaConIGI'] == null ? null : number(data['tarifaConIGI']),
    tarifasPorNinos: rates(data['tarifasPorNinos']),
    tarifasPorNinosConIGI: rates(data['tarifasPorNinosConIGI']),
    gestionTelefonica: data['gestionTelefonica'] == true,
    requiereAprobacion: data['requiereAprobacion'] == true,
    requiereFormulario: data['requiereFormulario'] == true,
    image: data['image'] is String && (data['image'] as String).isNotEmpty ? data['image'] as String : null,
  );
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
    this.photoUrl,
    this.slug = '',
    this.rol = '',
    this.badge = '',
    this.color = 0xFF8CA598,
    this.qui = '',
    this.trayectoria = '',
    this.agrada = '',
    this.puntFort = '',
    List<String>? habilidades,
    List<String>? fotos,
    List<AvailabilityException>? exceptions,
  }) : habilidades = habilidades ?? [],
       fotos = fotos ?? [],
       exceptions = exceptions ?? [];

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
  final String? photoUrl;
  final String slug;
  final String rol;
  final String badge;
  final int color;
  final String qui;
  final String trayectoria;
  final String agrada;
  final String puntFort;
  List<String> habilidades;
  List<String> fotos;
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

class ChatPreview {
  ChatPreview({
    required this.reservaId,
    required this.chatId,
    this.ultimoMensaje = '',
    this.ultimoMensajeFecha,
  });

  final String reservaId;
  final String chatId;
  final String ultimoMensaje;
  DateTime? ultimoMensajeFecha;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.remitenteId,
    required this.fecha,
    this.texto = '',
    this.imageUrl = '',
    this.tipo = 'text',
    List<String>? vistoPor,
  }) : vistoPor = vistoPor ?? [];

  final String id;
  final String remitenteId;
  final DateTime fecha;
  final String texto;
  final String imageUrl;
  final String tipo;
  final List<String> vistoPor;
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
    this.compartir = false,
  });

  final String id;
  final String padreId;
  final String canguroId;
  final String reservaId;
  final int puntualidad;
  final int trato;
  final int profesionalismo;
  final String comentario;
  final bool compartir;

  double get rating => (puntualidad + trato + profesionalismo) / 3;

  int get stars {
    final rounded = rating.round();
    if (rounded < 1) return 1;
    if (rounded > 5) return 5;
    return rounded;
  }
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

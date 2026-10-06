import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/availability.dart';
import '../models/models.dart';

class AccountFailure implements Exception {
  const AccountFailure(this.code);
  final String code;
}

abstract class AccountGateway {
  Future<AppUser> signIn({required String email, required String password});
  Future<void> register({required String email, required String password, required String idioma});
  Future<void> resetPassword(String email);
  Future<void> saveFatherProfile({
    required String uid,
    required String displayName,
    required String telefono,
    required String direccion,
    required String idioma,
    required Map<String, Object?> perfil,
  });
  Future<List<ServiceOffer>> loadServices();
  Future<List<CangurProfile>> loadCanguros();
  Future<String> saveReserva({
    required String padreId,
    required String padreNombre,
    required String tipoServicio,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required int numeroNinos,
    required String direccion,
    required String canguroId,
    required String canguroNombre,
    required double total,
    required String servicioId,
    required double duracionHoras,
    required String notas,
    String estado = 'pendiente',
  });
  Future<void> signOut();
}

class FirebaseAccountGateway implements AccountGateway {
  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;
      if (uid == null) throw const AccountFailure('wrongCredentials');
      final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = snap.data();
      if (!snap.exists || data == null) {
        await FirebaseAuth.instance.signOut();
        throw const AccountFailure('profileMissing');
      }
      if (data['activo'] == false) {
        await FirebaseAuth.instance.signOut();
        throw const AccountFailure('accountInactive');
      }
      return appUserFromFirestore(uid, data, email);
    } on AccountFailure {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(authFailureCode(error.code));
    } on FirebaseException catch (error) {
      throw AccountFailure(error.code == 'permission-denied' ? 'rulesDenied' : 'networkError');
    }
  }

  @override
  Future<void> register({required String email, required String password, required String idioma}) async {
    UserCredential cred;
    try {
      cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(authFailureCode(error.code));
    }
    final uid = cred.user?.uid;
    if (uid == null) throw const AccountFailure('networkError');
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'activo': true,
        'created_time': FieldValue.serverTimestamp(),
        'email': email,
        'idiomaPreferido': idioma,
        'notificacionesActivas': true,
        'perfilCompleto': false,
        'photo_url': '',
        'role': 'father',
        'uid': uid,
      });
    } on FirebaseException catch (error) {
      await cred.user?.delete();
      throw AccountFailure(error.code == 'permission-denied' ? 'rulesDenied' : 'networkError');
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(authFailureCode(error.code));
    }
  }

  @override
  Future<void> saveFatherProfile({
    required String uid,
    required String displayName,
    required String telefono,
    required String direccion,
    required String idioma,
    required Map<String, Object?> perfil,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'perfilCompleto': true,
        'display_name': displayName,
        'telefono': telefono,
        'direccion': direccion,
        'idiomaPreferido': idioma,
        'perfil': _withoutNulls(perfil),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw AccountFailure(error.code == 'permission-denied' ? 'rulesDenied' : 'networkError');
    }
  }

  @override
  Future<String> saveReserva({
    required String padreId,
    required String padreNombre,
    required String tipoServicio,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required int numeroNinos,
    required String direccion,
    required String canguroId,
    required String canguroNombre,
    required double total,
    required String servicioId,
    required double duracionHoras,
    required String notas,
    String estado = 'pendiente',
  }) async {
    try {
      final ref = FirebaseFirestore.instance.collection('reservas').doc();
      final day = DateTime(fecha.year, fecha.month, fecha.day);
      await ref.set({
        'id': ref.id,
        'padreId': padreId,
        'padreNombre': padreNombre,
        'canguroId': canguroId,
        'canguroNombre': canguroNombre,
        'servicioId': servicioId,
        'tipoServicio': tipoServicio,
        'numeroNinos': numeroNinos,
        'duracionHoras': duracionHoras,
        'estado': estado,
        'estadoPago': 'pendiente',
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaServicio': Timestamp.fromDate(day),
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'direccionServicio': direccion,
        'total': total,
        'totalPagado': total,
        'notas': notas,
        'created_time': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } on FirebaseException catch (error) {
      throw AccountFailure(error.code == 'permission-denied' ? 'rulesDenied' : 'networkError');
    }
  }

  @override
  Future<List<ServiceOffer>> loadServices() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('servicios').get();
      final offers = <ServiceOffer>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['activo'] == false) continue;
        offers.add(serviceFromMap(doc.id, data));
      }
      return offers;
    } on FirebaseException catch (error) {
      throw AccountFailure(error.code == 'permission-denied' ? 'rulesDenied' : 'networkError');
    }
  }

  @override
  Future<List<CangurProfile>> loadCanguros() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final profiles = await firestore.collection('perfiles_canguro').get();
      final exceptions = await _exceptionDocs(firestore);
      final byUser = <String, List<AvailabilityException>>{};
      for (final doc in exceptions) {
        final parsed = _exceptionFromMap(doc.data());
        if (parsed == null) continue;
        byUser.putIfAbsent(parsed.$1, () => []).add(parsed.$2);
      }

      final ids = <String>[];
      for (final doc in profiles.docs) {
        if (_profileClosed(doc.data())) continue;
        ids.add(_profileUserId(doc.id, doc.data()));
      }
      final users = await _usersById(firestore, ids);

      final carers = <CangurProfile>[];
      for (final doc in profiles.docs) {
        final data = doc.data();
        if (_profileClosed(data)) continue;
        final uid = _profileUserId(doc.id, data);
        final user = users[uid];
        final role = user?['role'];
        if (role is String && role != 'cangur' && role != 'canguro') continue;
        carers.add(_cangurFromFirestore(uid, data, user, byUser[uid] ?? const []));
      }
      return carers;
    } on FirebaseException catch (error) {
      throw AccountFailure(error.code == 'permission-denied' ? 'rulesDenied' : 'networkError');
    }
  }

  @override
  Future<void> signOut() => FirebaseAuth.instance.signOut();
}

Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _exceptionDocs(FirebaseFirestore firestore) async {
  try {
    final snap = await firestore.collection('excepciones_disponibilidad').get();
    return snap.docs;
  } on FirebaseException {
    return const [];
  }
}

Future<Map<String, Map<String, dynamic>>> _usersById(FirebaseFirestore firestore, List<String> ids) async {
  final unique = ids.toSet();
  final out = <String, Map<String, dynamic>>{};
  await Future.wait(unique.map((id) async {
    try {
      final snap = await firestore.collection('users').doc(id).get();
      final data = snap.data();
      if (data != null) out[id] = data;
    } on FirebaseException {
      return;
    }
  }));
  return out;
}

bool _profileClosed(Map<String, dynamic> data) => data['active'] == false || data['activo'] == false;

String _profileUserId(String docId, Map<String, dynamic> data) {
  final stored = data['userId'];
  if (stored is String && stored.trim().isNotEmpty) return stored.trim();
  return docId;
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return [];
  return [for (final item in raw) if (item is String && item.trim().isNotEmpty) item.trim()];
}

List<TimeBand> _bands(Object? raw) {
  if (raw is! List) return [];
  final bands = <TimeBand>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final start = item['inicio'];
    final end = item['fin'];
    if (start is String && end is String && start.isNotEmpty && end.isNotEmpty) {
      bands.add(TimeBand(start, end));
    }
  }
  return bands;
}

Map<String, DayAvailability> _weekFrom(Object? raw) {
  final source = raw is Map ? raw : const {};
  return {
    for (final day in weekDays)
      day: DayAvailability(
        disponible: source[day] is Map && source[day]['disponible'] == true,
        franjas: source[day] is Map ? _bands(source[day]['franjas']) : const [],
      ),
  };
}

(String, AvailabilityException)? _exceptionFromMap(Map<String, dynamic> data) {
  final uid = data['userId'];
  if (uid is! String || uid.isEmpty) return null;
  final fecha = data['fecha'];
  String? iso;
  if (fecha is Timestamp) {
    iso = isoDate(fecha.toDate());
  } else if (fecha is String && fecha.length >= 10) {
    iso = fecha.substring(0, 10);
  }
  if (iso == null) return null;
  return (uid, AvailabilityException(fecha: iso, disponible: data['disponible'] == true, franjas: _bands(data['franjas'])));
}

CangurProfile _cangurFromFirestore(
  String uid,
  Map<String, dynamic> data,
  Map<String, dynamic>? user,
  List<AvailabilityException> exceptions,
) {
  final display = user?['display_name'] ?? user?['nombre'];
  final email = user?['email'];
  final photo = user?['photo_url'] ?? user?['photoUrl'];
  final languages = _stringList(data['idiomas']);
  final skills = _stringList(data['habilidades']);
  final years = data['experienciaAnos'] ?? data['aniosExperiencia'];
  final rate = data['tarifaPorHora'];
  return CangurProfile(
    userId: uid,
    nombre: display is String && display.trim().isNotEmpty ? display.trim() : 'Cangur',
    email: email is String ? email.trim() : '',
    descripcionPersonal: data['descripcionPersonal'] is String ? data['descripcionPersonal'] as String : '',
    tarifaPorHora: rate is num ? rate.toDouble() : double.tryParse('$rate') ?? 0,
    servicios: _stringList(data['servicios']),
    certificaciones: _stringList(data['certificaciones']),
    idiomas: languages.isEmpty ? skills : languages,
    week: _weekFrom(data['disponibilidad']),
    activo: data['active'] != false && data['activo'] != false,
    aniosExperiencia: years is num ? years.toInt() : int.tryParse('$years') ?? 0,
    photoUrl: photo is String && photo.trim().isNotEmpty ? photo.trim() : null,
    exceptions: exceptions,
  );
}

String authFailureCode(String code) {
  switch (code) {
    case 'invalid-email':
      return 'invalidEmail';
    case 'email-already-in-use':
      return 'emailTaken';
    case 'weak-password':
      return 'weakPassword';
    case 'user-disabled':
      return 'accountInactive';
    case 'operation-not-allowed':
      return 'authDisabled';
    case 'network-request-failed':
      return 'networkError';
    case 'too-many-requests':
      return 'tooManyAttempts';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'wrongCredentials';
    default:
      return 'wrongCredentials';
  }
}

AppUser appUserFromFirestore(String uid, Map<String, dynamic> data, String email) {
  final storedEmail = data['email'];
  final resolvedEmail = storedEmail is String && storedEmail.contains('@') ? storedEmail.trim().toLowerCase() : email;
  final nombre = data['display_name'] ?? data['nombre'];
  final display = nombre is String && nombre.trim().isNotEmpty ? nombre.trim() : _localPart(resolvedEmail);
  return AppUser(
    id: uid,
    nombre: display,
    email: resolvedEmail,
    password: '',
    role: roleFromValue(data['role']),
    telefono: data['telefono'] is String ? data['telefono'] as String : '',
    direccion: data['direccion'] is String ? data['direccion'] as String : '',
    perfilCompleto: data['perfilCompleto'] == true,
    perfil: data['perfil'] is Map ? Map<String, dynamic>.from(data['perfil'] as Map) : null,
  );
}

Map<String, Object?> _withoutNulls(Map<String, Object?> source) {
  final cleaned = <String, Object?>{};
  for (final entry in source.entries) {
    final value = entry.value;
    if (value == null) continue;
    if (value is Map<String, Object?>) {
      cleaned[entry.key] = _withoutNulls(value);
    } else if (value is List) {
      cleaned[entry.key] = [
        for (final item in value)
          if (item is Map<String, Object?>) _withoutNulls(item) else item,
      ];
    } else {
      cleaned[entry.key] = value;
    }
  }
  return cleaned;
}

String _localPart(String email) {
  final at = email.indexOf('@');
  return at > 0 ? email.substring(0, at) : email;
}

UserRole roleFromValue(Object? value) {
  if (value is num) return roleFromIndex(value.toInt());
  switch (value?.toString().toLowerCase()) {
    case 'admin':
    case '0':
      return UserRole.admin;
    case 'cangur':
    case 'canguro':
    case '1':
      return UserRole.cangur;
    default:
      return UserRole.father;
  }
}

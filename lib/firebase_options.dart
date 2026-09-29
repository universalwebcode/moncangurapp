/// Client config recovered from the public web bundle at moncangur.web.app.
///
/// These values are the Firebase *web* options already shipped in main.dart.js.
/// This reconstruction does not initialize Firebase and does not read or write
/// the production project. Wire them up only when you are ready to reconnect
/// Auth, Firestore and Storage yourself.
class RecoveredFirebaseOptions {
  static const apiKey = 'AIzaSyCfoslyNEHX0rnNVhxAzSPZ0TmS3cbqn_U';
  static const appId = '1:922984930491:web:868fcf23a210b30a6f1d9e';
  static const messagingSenderId = '922984930491';
  static const projectId = 'moncangur';
  static const authDomain = 'moncangur.firebaseapp.com';
  static const storageBucket = 'moncangur.firebasestorage.app';
}

/// Firestore collections and fields named in the compiled client.
const recoveredCollections = <String, List<String>>{
  'users': [
    'nombre',
    'email',
    'role',
    'telefono',
    'direccion',
    'idiomasCanguro',
    'contactoEmergencia',
  ],
  'servicios': [
    'nombre',
    'descripcion',
    'image',
    'tipoServicio',
    'igi',
    'tarifaBase',
    'tarifaConIGI',
    'tarifasPorNinos',
    'tarifasPorNinosConIGI',
    'gestionTelefonica',
    'requiereAprobacion',
    'requiereFormulario',
  ],
  'perfiles_canguro': [
    'userId',
    'active',
    'disponible',
    'disponibilidad',
    'descripcionPersonal',
    'tarifaPorHora',
    'servicios',
    'certificaciones',
    'idiomas',
  ],
  'perfiles_padre': ['userId', 'idiomasCanguro', 'contactoEmergencia'],
  'reservas': [
    'padreId',
    'canguroId',
    'fechaServicio',
    'horaInicio',
    'horaFin',
    'numeroNinos',
    'direccionServicio',
    'tipoServicio',
    'estado',
    'estadoPago',
    'urlRedsys',
  ],
  'disponibilidad': ['userId', 'franjas', 'disponible'],
  'excepciones_disponibilidad': ['userId', 'fecha', 'disponible', 'franjas'],
  'reviews': [
    'padreId',
    'canguroId',
    'reservaId',
    'rating',
    'comentario',
    'puntualidad',
    'trato',
    'profesionalismo',
  ],
};

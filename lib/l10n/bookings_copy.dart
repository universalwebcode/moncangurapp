import '../models/models.dart';

const _rows = <String, List<String>>{
  'actuals': ['Actuals', 'Actuales', 'Current', 'En cours'],
  'history': ['Historial', 'Historial', 'History', 'Historique'],
  'date': ['Data', 'Fecha', 'Date', 'Date'],
  'schedule': ['Horari', 'Horario', 'Time', 'Horaire'],
  'cangur': ['Cangur', 'Canguro', 'Nanny', 'Nounou'],
  'price': ['Preu', 'Precio', 'Price', 'Prix'],
  'oneChild': ['1 infant', '1 niño', '1 child', '1 enfant'],
  'manyChildren': ['{n} infants', '{n} niños', '{n} children', '{n} enfants'],
  'hours': ['{n} h', '{n} h', '{n} h', '{n} h'],
  'unassigned': ['Sense assignar', 'Sin asignar', 'Not assigned', 'Non assignée'],
  'completed': ['Completada', 'Completada', 'Completed', 'Terminée'],
  'leaveReview': [
    'Deixar la meva valoració',
    'Dejar mi valoración',
    'Leave my review',
    'Laisser mon avis',
  ],
  'yourReview': ['La teva valoració', 'Tu valoración', 'Your review', 'Ton avis'],
  'howWas': ['Com ha anat?', '¿Cómo ha ido?', 'How did it go?', 'Comment ça s’est passé ?'],
  'howHelp': [
    'La teva opinió ens ajuda a cuidar millor.',
    'Tu opinión nos ayuda a cuidar mejor.',
    'Your feedback helps us take better care.',
    'Ton avis nous aide à mieux prendre soin.',
  ],
  'rateWith': [
    'Valora el servei amb {name} · {date}.',
    'Valora el servicio con {name} · {date}.',
    'Rate the service with {name} · {date}.',
    'Évalue le service avec {name} · {date}.',
  ],
  'experience': [
    "Explica'ns la teva experiència",
    'Cuéntanos tu experiencia',
    'Tell us about your experience',
    'Raconte-nous ton expérience',
  ],
  'experienceHint': [
    "Com s'ha sentit la teva família? Què ha anat bé? Alguna cosa a millorar?",
    '¿Cómo se ha sentido tu familia? ¿Qué ha ido bien? ¿Algo a mejorar?',
    'How did your family feel? What went well? Anything to improve?',
    'Comment ta famille s’est-elle sentie ? Qu’est-ce qui s’est bien passé ? Quelque chose à améliorer ?',
  ],
  'share': [
    'Autoritzo a **compartir la meva valoració** al perfil de la cangur (opcional).',
    'Autorizo **compartir mi valoración** en el perfil de la canguro (opcional).',
    'I allow **sharing my review** on the nanny’s profile (optional).',
    'J’autorise à **partager mon avis** sur le profil de la nounou (facultatif).',
  ],
  'send': ['Enviar valoració', 'Enviar valoración', 'Send review', 'Envoyer l’avis'],
  'intern': [
    "La teva valoració s'envia **directament a l'equip de Mon Cangur** per correu. Nosaltres decidim si es publica al perfil de la cangur.",
    'Tu valoración se envía **directamente al equipo de Mon Cangur** por correo. Nosotros decidimos si se publica en el perfil de la canguro.',
    'Your review is sent **directly to the Mon Cangur team** by email. We decide whether it is published on the nanny’s profile.',
    'Ton avis est envoyé **directement à l’équipe de Mon Cangur** par e-mail. Nous décidons s’il est publié sur le profil de la nounou.',
  ],
  'sent': [
    'Valoració enviada a Mon Cangur ✓',
    'Valoración enviada a Mon Cangur ✓',
    'Review sent to Mon Cangur ✓',
    'Avis envoyé à Mon Cangur ✓',
  ],
  'emptyActuals': [
    'Encara no tens reserves actives.\nQuan en facis una, apareixerà aquí.',
    'Aún no tienes reservas activas.\nCuando hagas una, aparecerá aquí.',
    'You have no active bookings yet.\nWhen you make one, it will show up here.',
    'Tu n’as pas encore de réservation active.\nQuand tu en feras une, elle apparaîtra ici.',
  ],
  'emptyHistory': [
    'Aquí veuràs les reserves ja completades.',
    'Aquí verás las reservas ya completadas.',
    'Completed bookings will show up here.',
    'Les réservations terminées apparaîtront ici.',
  ],
  'noUpcoming': [
    'No hi ha reserves properes ara mateix.',
    'No hay reservas próximas ahora mismo.',
    'There are no upcoming bookings right now.',
    'Il n’y a pas de réservation à venir pour le moment.',
  ],
};

const _weekdays = <List<String>>[
  ['dl', 'dt', 'dc', 'dj', 'dv', 'ds', 'dg'],
  ['lu', 'ma', 'mi', 'ju', 'vi', 'sá', 'do'],
  ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su'],
  ['lu', 'ma', 'me', 'je', 've', 'sa', 'di'],
];

const _months = <List<String>>[
  ['gener', 'febrer', 'març', 'abril', 'maig', 'juny', 'juliol', 'agost', 'setembre', 'octubre', 'novembre', 'desembre'],
  ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'],
  ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'],
];

String bk(AppLang lang, String key) {
  final row = _rows[key];
  if (row == null || row.length != 4) return key;
  return row[lang.index];
}

String bookingDate(AppLang lang, DateTime date) {
  final weekday = _weekdays[lang.index][date.weekday - 1];
  final month = _months[lang.index][date.month - 1];
  return '$weekday ${date.day} $month ${date.year}';
}

String bookingServiceTitle(AppLang lang, String tipo) {
  const titles = <String, List<String>>{
    'ocasional': ['Servei Ocasional', 'Servicio ocasional', 'Occasional service', 'Service occasionnel'],
    'emergencia': ["Servei d'Urgència", 'Servicio de urgencia', 'Urgent service', "Service d'urgence"],
    'eventos': ["Servei d'Esdeveniments", 'Servicio de eventos', 'Events service', 'Service événements'],
    'fijo': ['Servei Fix', 'Servicio fijo', 'Regular service', 'Service régulier'],
    'repaso': ['Servei Extraescolar', 'Servicio extraescolar', 'After-school service', 'Service extrascolaire'],
  };
  return titles[tipo]?[lang.index] ?? tipo;
}

String bookingEmoji(String tipo) {
  switch (tipo) {
    case 'ocasional':
      return '🌙';
    case 'emergencia':
      return '⚡';
    case 'eventos':
      return '✨';
    case 'repaso':
      return '🎨';
    default:
      return '🌿';
  }
}

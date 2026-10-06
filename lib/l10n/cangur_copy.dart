import '../models/models.dart';

const _rows = <String, List<String>>{
  'team': ['Les nostres cangurs', 'Nuestras cangurs', 'Our nannies', 'Nos nounous'],
  'title': ['La nostra cangur', 'Nuestra cangur', 'Our nanny', 'Notre nounou'],
  'qui': ['Qui és', 'Quién es', 'Who she is', 'Qui est-elle'],
  'work': ['On ha treballat abans', 'Dónde ha trabajado', 'Where she has worked', 'Où elle a travaillé'],
  'likes': ['Què li agrada fer amb els nens', 'Qué le gusta hacer con los niños', 'What she likes to do with the children', 'Ce qu’elle aime faire avec les enfants'],
  'strength': ['El seu punt fort', 'Su punto fuerte', 'Her strength', 'Son point fort'],
  'others': ['Altres cangurs', 'Otras cangurs', 'Other nannies', 'Autres nounous'],
  'book': ['Reservar un servei', 'Reservar un servicio', 'Book a service', 'Réserver un service'],
  'founder': ['Fundadora', 'Fundadora', 'Founder', 'Fondatrice'],
  'agenda': ['Agenda', 'Agenda', 'Agenda', 'Agenda'],
  'myAgenda': ['La meva agenda', 'Mi agenda', 'My agenda', 'Mon agenda'],
  'all': ['Totes', 'Todas', 'All', 'Toutes'],
  'pending': ['Pendents', 'Pendientes', 'Pending', 'En attente'],
  'done': ['Completades', 'Completadas', 'Completed', 'Terminées'],
  'searchDate': ['Cercar data: dd/mm/aaaa', 'Buscar fecha: dd/mm/aaaa', 'Find a date: dd/mm/yyyy', 'Chercher une date : jj/mm/aaaa'],
  'upcoming': ['Pròximes', 'Próximas', 'Upcoming', 'Prochaines'],
  'baseHours': ['Horari base', 'Horario base', 'Base hours', 'Horaire de base'],
  'changed': ['Modificat', 'Modificado', 'Changed', 'Modifié'],
  'bookingDot': ['Reserva', 'Reserva', 'Booking', 'Réservation'],
  'noDay': ['No hi ha reserves per a aquest dia', 'No hay reservas para este día', 'No bookings for this day', 'Aucune réservation pour ce jour'],
  'oneBooking': ['1 reserva', '1 reserva', '1 booking', '1 réservation'],
  'manyBookings': ['{n} reserves', '{n} reservas', '{n} bookings', '{n} réservations'],
  'yourName': ['El teu nom', 'Tu nombre', 'Your name', 'Ton nom'],
  'tapPhoto': ['Toca la foto per canviar-la', 'Toca la foto para cambiarla', 'Tap the photo to change it', 'Touche la photo pour la changer'],
  'proInfo': ['Informació professional', 'Información profesional', 'Professional information', 'Informations professionnelles'],
  'about': ['Descripció personal', 'Descripción personal', 'Personal description', 'Description personnelle'],
  'years': ['Anys d\'experiència', 'Años de experiencia', 'Years of experience', 'Années d\'expérience'],
  'skills': ['Habilitats', 'Habilidades', 'Skills', 'Compétences'],
  'newSkill': ['Nova habilitat', 'Nueva habilidad', 'New skill', 'Nouvelle compétence'],
  'certs': ['Certificacions', 'Certificaciones', 'Certifications', 'Certifications'],
  'newCert': ['Nova certificació', 'Nueva certificación', 'New certification', 'Nouvelle certification'],
  'add': ['Afegir', 'Agregar', 'Add', 'Ajouter'],
  'addBand': ['Afegir franja horària', 'Agregar franja horaria', 'Add a time band', 'Ajouter un créneau'],
  'save': ['Desar canvis', 'Guardar cambios', 'Save changes', 'Enregistrer'],
  'saved': ['Canvis desats', 'Cambios guardados', 'Changes saved', 'Modifications enregistrées'],
  'photoSoon': [
    'La foto es canvia des del compte de Firebase quan l\'emmagatzematge estigui actiu.',
    'La foto se cambia desde la cuenta de Firebase cuando el almacenamiento esté activo.',
    'The photo can be changed once Firebase Storage is enabled.',
    'La photo se change une fois Firebase Storage activé.',
  ],
};

String ct(AppLang lang, String key) => cg(lang, key);

String cg(AppLang lang, String key, [Map<String, String> vars = const {}]) {
  final row = _rows[key];
  var text = (row == null || row.length != 4) ? key : row[lang.index];
  for (final entry in vars.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value);
  }
  return text;
}

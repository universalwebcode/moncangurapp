import '../models/models.dart';

const _rows = <String, List<String>>{
  'eyebrow': ['Pas {n} de 8 · {label}', 'Paso {n} de 8 · {label}', 'Step {n} of 8 · {label}', 'Étape {n} sur 8 · {label}'],
  's1': ['Activitat', 'Actividad', 'Activity', 'Activité'],
  's2': ['Dies', 'Días', 'Days', 'Jours'],
  's3': ['Horari', 'Horario', 'Schedule', 'Horaire'],
  's4': ['Infants', 'Niños', 'Children', 'Enfants'],
  's5': ['Observacions', 'Observaciones', 'Notes', 'Observations'],
  's6': ['On', 'Dónde', 'Where', 'Où'],
  's7': ['Les teves dades', 'Tus datos', 'Your details', 'Tes coordonnées'],
  's8': ['Gairebé fet', 'Casi listo', 'Almost done', 'Presque fini'],
  'h1': ['Què vols que aprengui o faci?', '¿Qué quieres que aprenda o haga?', 'What should they learn or do?', 'Que veux-tu qu’il apprenne ou fasse ?'],
  'sub1': [
    'Tria una o més activitats. El nostre extraescolar és a mida.',
    'Elige una o más actividades. Nuestro extraescolar es a medida.',
    'Choose one or more activities. Our after-school service is tailored.',
    'Choisis une ou plusieurs activités. Notre extrascolaire est sur mesure.',
  ],
  'h2': ['Quins dies us van bé?', '¿Qué días os van bien?', 'Which days work for you?', 'Quels jours vous conviennent ?'],
  'sub2': [
    "L'extraescolar és fix, així que tindrà un dia fix cada setmana.",
    'El extraescolar es fijo, así que tendrá un día fijo cada semana.',
    'The after-school service is regular, so it will be the same day each week.',
    'L’extrascolaire est régulier, donc ce sera un jour fixe chaque semaine.',
  ],
  'h3': ['En quina franja horària?', '¿En qué franja horaria?', 'Which time slot?', 'Sur quel créneau horaire ?'],
  'sub3': [
    "Indica l'horari que preferiu per a les sessions.",
    'Indica el horario que preferís para las sesiones.',
    'Choose the hours you prefer for the sessions.',
    'Indique l’horaire que vous préférez pour les séances.',
  ],
  'from': ['Des de', 'Desde', 'From', 'De'],
  'until': ['Fins a', 'Hasta', 'Until', 'Jusqu’à'],
  'h4': ['Quants infants i quines edats?', '¿Cuántos niños y qué edades?', 'How many children and what ages?', 'Combien d’enfants et quels âges ?'],
  'sub4': [
    'Ens ajuda a buscar la persona adequada per a cada edat.',
    'Nos ayuda a buscar la persona adecuada para cada edad.',
    'This helps us find the right person for each age.',
    'Cela nous aide à trouver la bonne personne pour chaque âge.',
  ],
  'infant': ['{n} infant', '{n} niño', '{n} child', '{n} enfant'],
  'infants': ['{n} infants', '{n} niños', '{n} children', '{n} enfants'],
  'age': ['Edat infant {n}', 'Edad niño {n}', 'Age of child {n}', 'Âge enfant {n}'],
  'years': ['Anys', 'Años', 'Years', 'Ans'],
  'h5': ['Alguna cosa més que hàgim de saber?', '¿Algo más que debamos saber?', 'Anything else we should know?', 'Autre chose à savoir ?'],
  'sub5': [
    'Nivell, objectius, preferències, necessitats especials... el que vulguis.',
    'Nivel, objetivos, preferencias, necesidades especiales... lo que quieras.',
    'Level, goals, preferences, special needs... whatever you want to add.',
    'Niveau, objectifs, préférences, besoins particuliers... ce que tu veux.',
  ],
  'notesHint': ['Escriu aquí les observacions (opcional)', 'Escribe aquí las observaciones (opcional)', 'Write your notes here (optional)', 'Écris tes observations ici (facultatif)'],
  'h6': ['On es fa el servei?', '¿Dónde se hace el servicio?', 'Where does the service take place?', 'Où se déroule le service ?'],
  'sub6': ['Confirma l\'adreça de les sessions.', 'Confirma la dirección de las sesiones.', 'Confirm the address for the sessions.', 'Confirme l’adresse des séances.'],
  'addrProfile': ['Adreça del perfil', 'Dirección del perfil', 'Profile address', 'Adresse du profil'],
  'addrOther': ['Una altra adreça', 'Otra dirección', 'Another address', 'Une autre adresse'],
  'addrOtherSub': ['Indica on vols les sessions.', 'Indica dónde quieres las sesiones.', 'Say where you want the sessions.', 'Indique où tu veux les séances.'],
  'addrHint': ['Carrer, número, parròquia', 'Calle, número, parroquia', 'Street, number, parish', 'Rue, numéro, paroisse'],
  'h7': ['Com et contactem?', '¿Cómo te contactamos?', 'How do we contact you?', 'Comment te contacter ?'],
  'fromProfile': ['Del teu perfil · pots editar-ho si cal', 'De tu perfil · puedes editarlo si hace falta', 'From your profile · you can edit it if needed', 'Depuis ton profil · tu peux le modifier si besoin'],
  'name': ['El teu nom', 'Tu nombre', 'Your name', 'Ton nom'],
  'phone': ['Telèfon', 'Teléfono', 'Phone', 'Téléphone'],
  'email': ['Correu', 'Correo', 'Email', 'E-mail'],
  'h8': ['Ho tenim!', '¡Lo tenemos!', 'We’ve got it!', 'C’est noté !'],
  'sub8': ['Revisa-ho i envia la sol·licitud.', 'Revísala y envía la solicitud.', 'Check it and send the request.', 'Vérifie et envoie la demande.'],
  'replyTitle': ['Et contactarem en 2–3 dies', 'Te contactaremos en 2–3 días', 'We will contact you in 2–3 days', 'Nous te contactons sous 2–3 jours'],
  'replyBody': [
    "Analitzarem la teva sol·licitud i buscarem un professional del nostre equip que encaixi amb la disponibilitat i els requisits de la teva família. En un termini de 2–3 dies et contactarem per l'app, tant si hem trobat la persona adequada com si continuem buscant. No et quedaràs sense resposta.",
    'Analizaremos tu solicitud y buscaremos un profesional de nuestro equipo que encaje con la disponibilidad y los requisitos de tu familia. En un plazo de 2–3 días te contactaremos por la app, tanto si hemos encontrado a la persona adecuada como si seguimos buscando. No te quedarás sin respuesta.',
    'We will review your request and look for someone on our team who fits your family’s availability and needs. Within 2–3 days we will contact you in the app, whether we have found the right person or we are still looking. You will get an answer.',
    'Nous étudierons ta demande et chercherons un professionnel de notre équipe qui corresponde à la disponibilité et aux besoins de ta famille. Sous 2–3 jours nous te contactons dans l’app, que nous ayons trouvé la bonne personne ou que nous cherchions encore. Tu auras une réponse.',
  ],
  'continue': ['Continuar →', 'Continuar →', 'Continue →', 'Continuer →'],
  'back': ['← Enrere', '← Atrás', '← Back', '← Retour'],
  'send': ['Enviar sol·licitud', 'Enviar solicitud', 'Send request', 'Envoyer la demande'],
  'doneTitle': ['Sol·licitud rebuda!', '¡Solicitud recibida!', 'Request received!', 'Demande reçue !'],
  'doneBody': [
    'Buscarem el professional adequat i et contactarem en 2–3 dies, amb notícies o per dir-te que seguim buscant. Gràcies per confiar en Mon Cangur.',
    'Buscaremos al profesional adecuado y te contactaremos en 2–3 días, con noticias o para decirte que seguimos buscando. Gracias por confiar en Mon Cangur.',
    'We will look for the right professional and contact you in 2–3 days, with news or to say we are still looking. Thank you for trusting Mon Cangur.',
    'Nous chercherons le bon professionnel et te contacterons sous 2–3 jours, avec des nouvelles ou pour te dire que nous cherchons encore. Merci de faire confiance à Mon Cangur.',
  ],
  'home': ["Tornar a l'inici", 'Volver al inicio', 'Back to home', 'Retour à l’accueil'],
  'en': ['Anglès', 'Inglés', 'English', 'Anglais'],
  'fr': ['Francès', 'Francés', 'French', 'Français'],
  'ca': ['Català', 'Catalán', 'Catalan', 'Catalan'],
  'es': ['Castellà', 'Castellano', 'Spanish', 'Espagnol'],
  'pt': ['Portuguès', 'Portugués', 'Portuguese', 'Portugais'],
  'music': ['Música', 'Música', 'Music', 'Musique'],
  'school': ['Repàs escolar', 'Repaso escolar', 'School tutoring', 'Soutien scolaire'],
  'yoga': ['Ioga infantil', 'Yoga infantil', 'Kids’ yoga', 'Yoga enfants'],
  'chess': ['Escacs', 'Ajedrez', 'Chess', 'Échecs'],
  'crafts': ['Manualitats', 'Manualidades', 'Crafts', 'Bricolage'],
  'dl': ['Dilluns', 'Lunes', 'Monday', 'Lundi'],
  'dt': ['Dimarts', 'Martes', 'Tuesday', 'Mardi'],
  'dc': ['Dimecres', 'Miércoles', 'Wednesday', 'Mercredi'],
  'dj': ['Dijous', 'Jueves', 'Thursday', 'Jeudi'],
  'dv': ['Divendres', 'Viernes', 'Friday', 'Vendredi'],
  'ds': ['Dissabte', 'Sábado', 'Saturday', 'Samedi'],
  'dg': ['Diumenge', 'Domingo', 'Sunday', 'Dimanche'],
};

const extraActivities = ['en', 'fr', 'ca', 'es', 'pt', 'music', 'school', 'yoga', 'chess', 'crafts'];
const extraDays = ['dl', 'dt', 'dc', 'dj', 'dv', 'ds', 'dg'];

const extraSlots = <String>[
  '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
  '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
  '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30',
  '19:00', '19:30', '20:00', '20:30', '21:00',
];

String ex(AppLang lang, String key, [Map<String, String> vars = const {}]) {
  final row = _rows[key];
  var text = (row == null || row.length != 4) ? key : row[lang.index];
  for (final entry in vars.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value);
  }
  return text;
}

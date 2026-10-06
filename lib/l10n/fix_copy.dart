import '../models/models.dart';

const _rows = <String, List<String>>{
  'title': ['Servei Fix', 'Servicio fijo', 'Regular service', 'Service régulier'],
  'eyebrow': ['Pas {n} de 8 · {label}', 'Paso {n} de 8 · {label}', 'Step {n} of 8 · {label}', 'Étape {n} sur 8 · {label}'],
  's1': ['Dates del servei', 'Fechas del servicio', 'Service dates', 'Dates du service'],
  's2': ['Dies i hores', 'Días y horas', 'Days and hours', 'Jours et heures'],
  's3': ['Suport', 'Apoyo', 'Support', 'Soutien'],
  's4': ['Infants', 'Niños', 'Children', 'Enfants'],
  's5': ['Requisits', 'Requisitos', 'Requirements', 'Exigences'],
  's6': ['Observacions', 'Observaciones', 'Notes', 'Observations'],
  's7': ['Les teves dades', 'Tus datos', 'Your details', 'Tes coordonnées'],
  's8': ['Gairebé fet', 'Casi listo', 'Almost done', 'Presque fini'],
  'h1': ['Quan necessiteu que comenci el servei?', '¿Cuándo necesitáis que empiece el servicio?', 'When do you need the service to start?', 'Quand le service doit-il commencer ?'],
  'sub1': [
    "Indica la data d'inici. Afegeix la data de fi prevista o marca l'opció indefinida.",
    'Indica la fecha de inicio. Añade la fecha de fin prevista o marca la opción indefinida.',
    'Choose the start date. Add an expected end date or mark it as open-ended.',
    'Indique la date de début. Ajoute la date de fin prévue ou marque l’option sans fin.',
  ],
  'start': ["Data d'inici *", 'Fecha de inicio *', 'Start date *', 'Date de début *'],
  'end': ['Data de fi prevista', 'Fecha de fin prevista', 'Expected end date', 'Date de fin prévue'],
  'pickDate': ['Selecciona una data', 'Selecciona una fecha', 'Choose a date', 'Choisis une date'],
  'indef': ['Indefinit / sense data de fi', 'Indefinido / sin fecha de fin', 'Open-ended / no end date', 'Sans date de fin'],
  'indefSub': [
    "La persona s'integra a la família sense límit de temps.",
    'La persona se integra en la familia sin límite de tiempo.',
    'The person joins the family with no time limit.',
    'La personne rejoint la famille sans limite de temps.',
  ],
  'h2': ['Quins dies i quantes hores al dia?', '¿Qué días y cuántas horas al día?', 'Which days and how many hours a day?', 'Quels jours et combien d’heures par jour ?'],
  'sub2': ['Selecciona els dies i l\'horari diari.', 'Selecciona los días y el horario diario.', 'Choose the days and the daily hours.', 'Choisis les jours et l’horaire quotidien.'],
  'days': ['Dies de la setmana *', 'Días de la semana *', 'Days of the week *', 'Jours de la semaine *'],
  'slot': ['Franja horària *', 'Franja horaria *', 'Time slot *', 'Créneau horaire *'],
  'startHour': ["Hora d'inici", 'Hora de inicio', 'Start time', 'Heure de début'],
  'endHour': ['Hora de fi', 'Hora de fin', 'End time', 'Heure de fin'],
  'h3': ['Què necessiteu del servei?', '¿Qué necesitáis del servicio?', 'What do you need from the service?', 'De quoi avez-vous besoin ?'],
  'sub3': ['Tria el que us encaixi. Pots triar-ne més d\'un.', 'Elige lo que os encaje. Puedes elegir más de uno.', 'Choose what fits. You can pick more than one.', 'Choisis ce qui convient. Tu peux en choisir plusieurs.'],
  'extraNote': [
    'Busques idiomes o reforç educatiu? El Servei Fix és per tenir una cangur fixa. Per a idiomes, repàs o activitats concretes, el que necessites és el nostre Servei Extraescolar.',
    '¿Buscas idiomas o refuerzo educativo? El servicio fijo es para tener una canguro fija. Para idiomas, repaso o actividades concretas, lo que necesitas es nuestro servicio extraescolar.',
    'Looking for languages or tutoring? The regular service is for a regular nanny. For languages, tutoring or specific activities, you need our after-school service.',
    'Tu cherches des langues ou du soutien scolaire ? Le service régulier est pour une nounou fixe. Pour les langues, le soutien ou des activités précises, il te faut notre service extrascolaire.',
  ],
  'h4': ['Quants infants i quines edats?', '¿Cuántos niños y qué edades?', 'How many children and what ages?', 'Combien d’enfants et quels âges ?'],
  'sub4': [
    "Ho necessitem per buscar un perfil adequat a l'edat i les necessitats de cada infant.",
    'Lo necesitamos para buscar un perfil adecuado a la edad y las necesidades de cada niño.',
    'We need this to find a profile that fits each child’s age and needs.',
    'Nous en avons besoin pour trouver un profil adapté à l’âge et aux besoins de chaque enfant.',
  ],
  'infant': ['{n} infant', '{n} niño', '{n} child', '{n} enfant'],
  'infants': ['{n} infants', '{n} niños', '{n} children', '{n} enfants'],
  'age': ['Edat infant {n}', 'Edad niño {n}', 'Age of child {n}', 'Âge enfant {n}'],
  'years': ['Anys', 'Años', 'Years', 'Ans'],
  'h5': ['Quins requisits ha de tenir la persona?', '¿Qué requisitos debe tener la persona?', 'What should the person be able to offer?', 'Quelles exigences pour la personne ?'],
  'sub5': ['Selecciona els que apliquin o afegeix-los al camp de sota.', 'Selecciona los que apliquen o añádelos en el campo de abajo.', 'Select the ones that apply or add them below.', 'Sélectionne celles qui s’appliquent ou ajoute-les ci-dessous.'],
  'otherReq': ['Altres requisits', 'Otros requisitos', 'Other requirements', 'Autres exigences'],
  'otherHint': ['Ex: cotxe propi, necessitats especials...', 'Ej.: coche propio, necesidades especiales...', 'E.g. own car, special needs...', 'Ex. : voiture, besoins particuliers...'],
  'h6': ['Alguna cosa més que hàgim de saber?', '¿Algo más que debamos saber?', 'Anything else we should know?', 'Autre chose à savoir ?'],
  'sub6': ["Al·lèrgies, necessitats especials, rutines... el que vulguis explicar-nos.", 'Alergias, necesidades especiales, rutinas... lo que quieras contarnos.', 'Allergies, special needs, routines... anything you want to tell us.', 'Allergies, besoins particuliers, routines... ce que tu veux nous dire.'],
  'notesHint': ['Escriu aquí les observacions (opcional)', 'Escribe aquí las observaciones (opcional)', 'Write your notes here (optional)', 'Écris tes observations ici (facultatif)'],
  'h7': ['Com et contactem?', '¿Cómo te contactamos?', 'How do we contact you?', 'Comment te contacter ?'],
  'fromProfile': ['Del teu perfil · pots editar-ho si cal', 'De tu perfil · puedes editarlo si hace falta', 'From your profile · you can edit it if needed', 'Depuis ton profil · tu peux le modifier si besoin'],
  'name': ['El teu nom', 'Tu nombre', 'Your name', 'Ton nom'],
  'phone': ['Telèfon', 'Teléfono', 'Phone', 'Téléphone'],
  'email': ['Correu', 'Correo', 'Email', 'E-mail'],
  'h8': ['Tot a punt!', '¡Todo listo!', 'All set!', 'Tout est prêt !'],
  'sub8': ['Revisa que estigui tot correcte i envia la sol·licitud.', 'Revisa que todo esté correcto y envía la solicitud.', 'Check that everything is right and send the request.', 'Vérifie que tout est correct et envoie la demande.'],
  'replyTitle': ['Et contactarem en 2–3 dies', 'Te contactaremos en 2–3 días', 'We will contact you in 2–3 days', 'Nous te contactons sous 2–3 jours'],
  'replyBody': [
    "Analitzarem la teva sol·licitud i et prepararem una proposta personalitzada per a la teva família. En un termini de 2–3 dies et contactarem per l'app, tant si tenim la persona adequada com si continuem buscant. No et quedaràs sense resposta.",
    'Analizaremos tu solicitud y te prepararemos una propuesta personalizada para tu familia. En un plazo de 2–3 días te contactaremos por la app, tanto si tenemos a la persona adecuada como si seguimos buscando. No te quedarás sin respuesta.',
    'We will review your request and prepare a personalised proposal for your family. Within 2–3 days we will contact you in the app, whether we have the right person or we are still looking. You will get an answer.',
    'Nous étudierons ta demande et préparerons une proposition personnalisée pour ta famille. Sous 2–3 jours nous te contactons dans l’app, que nous ayons la bonne personne ou que nous cherchions encore. Tu auras une réponse.',
  ],
  'continue': ['Continuar →', 'Continuar →', 'Continue →', 'Continuer →'],
  'back': ['← Enrere', '← Atrás', '← Back', '← Retour'],
  'send': ['Enviar sol·licitud', 'Enviar solicitud', 'Send request', 'Envoyer la demande'],
  'doneTitle': ['Rebut!', '¡Recibido!', 'Received!', 'Bien reçu !'],
  'doneBody': [
    "Preparem la teva proposta personalitzada i te la fem arribar aquí, a l'app. T'avisarem amb una notificació quan estigui llesta.",
    'Preparamos tu propuesta personalizada y te la hacemos llegar aquí, en la app. Te avisaremos con una notificación cuando esté lista.',
    'We are preparing your personalised proposal and will send it here, in the app. We will notify you when it is ready.',
    'Nous préparons ta proposition personnalisée et te l’enverrons ici, dans l’app. Tu recevras une notification quand elle sera prête.',
  ],
  'home': ["Tornar a l'inici", 'Volver al inicio', 'Back to home', 'Retour à l’accueil'],
  'dl': ['Dilluns', 'Lunes', 'Monday', 'Lundi'],
  'dt': ['Dimarts', 'Martes', 'Tuesday', 'Mardi'],
  'dc': ['Dimecres', 'Miércoles', 'Wednesday', 'Mercredi'],
  'dj': ['Dijous', 'Jueves', 'Thursday', 'Jeudi'],
  'dv': ['Divendres', 'Viernes', 'Friday', 'Vendredi'],
  'ds': ['Dissabte', 'Sábado', 'Saturday', 'Samedi'],
  'dg': ['Diumenge', 'Domingo', 'Sunday', 'Dimanche'],
  'flex': ['Flexible', 'Flexible', 'Flexible', 'Flexible'],
  'care': ['Cura', 'Cuidado', 'Care', 'Garde'],
  'school': ["Recollides a l'escola", 'Recogidas en la escuela', 'School pick-ups', 'Sorties d’école'],
  'crafts': ['Activitats i manualitats', 'Actividades y manualidades', 'Activities and crafts', 'Activités et bricolage'],
  'routines': ['Rutines', 'Rutinas', 'Routines', 'Routines'],
  'babies': ['Experiència amb nadons', 'Experiencia con bebés', 'Experience with babies', 'Expérience avec les bébés'],
  'education': ['Formació en educació', 'Formación en educación', 'Education training', 'Formation en éducation'],
  'health': ['Formació en salut', 'Formación en salud', 'Health training', 'Formation en santé'],
  'firstAid': ['Primers auxilis', 'Primeros auxilios', 'First aid', 'Premiers secours'],
  'drive': ['Carnet de conduir', 'Carné de conducir', 'Driving licence', 'Permis de conduire'],
  'cook': ['Cuinar', 'Cocinar', 'Cooking', 'Cuisine'],
};

const fixDays = ['dl', 'dt', 'dc', 'dj', 'dv', 'ds', 'dg', 'flex'];
const fixSupport = ['care', 'school', 'crafts', 'routines'];
const fixNeeds = ['babies', 'education', 'health', 'firstAid', 'drive', 'cook'];

String fx(AppLang lang, String key, [Map<String, String> vars = const {}]) {
  final row = _rows[key];
  var text = (row == null || row.length != 4) ? key : row[lang.index];
  for (final entry in vars.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value);
  }
  return text;
}

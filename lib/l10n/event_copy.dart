import '../models/models.dart';

const _rows = <String, List<String>>{
  'eyebrow': ['Pas {n} de 8 · {label}', 'Paso {n} de 8 · {label}', 'Step {n} of 8 · {label}', 'Étape {n} sur 8 · {label}'],
  's1': ["Tipus d'esdeveniment", 'Tipo de evento', 'Event type', "Type d'événement"],
  's2': ['Data i horari', 'Fecha y horario', 'Date and time', 'Date et horaire'],
  's3': ['Infants', 'Niños', 'Children', 'Enfants'],
  's4': ['Activitats i extres', 'Actividades y extras', 'Activities and extras', 'Activités et extras'],
  's5': ['Observacions', 'Observaciones', 'Notes', 'Observations'],
  's6': ['On', 'Dónde', 'Where', 'Où'],
  's7': ['Les teves dades', 'Tus datos', 'Your details', 'Tes coordonnées'],
  's8': ['Gairebé fet', 'Casi listo', 'Almost done', 'Presque fini'],
  'h1': ['Quin esdeveniment voleu celebrar?', '¿Qué evento queréis celebrar?', 'Which event do you want to celebrate?', 'Quel événement voulez-vous fêter ?'],
  'sub1': [
    "Tria el que més s'hi acosti. Després ens expliques els detalls.",
    'Elige el que más se acerque. Después nos cuentas los detalles.',
    'Choose the closest match. You can tell us the details next.',
    'Choisis ce qui s’en rapproche le plus. Tu nous expliqueras les détails ensuite.',
  ],
  'birthday': ['Aniversari infantil', 'Cumpleaños infantil', 'Children’s birthday', 'Anniversaire d’enfant'],
  'baptism': ['Bateig', 'Bautizo', 'Christening', 'Baptême'],
  'communion': ['Comunió', 'Comunión', 'Communion', 'Communion'],
  'wedding': ['Casament', 'Boda', 'Wedding', 'Mariage'],
  'private': ['Celebració privada', 'Celebración privada', 'Private celebration', 'Célébration privée'],
  'corporate': ['Esdeveniment corporatiu', 'Evento corporativo', 'Corporate event', 'Événement d’entreprise'],
  'other': ['Altre', 'Otro', 'Other', 'Autre'],
  'h2': ['Quan serà?', '¿Cuándo será?', 'When will it be?', 'Quand aura-t-il lieu ?'],
  'sub2': [
    'Indica el dia i la franja en què necessiteu les professionals.',
    'Indica el día y la franja en la que necesitáis a las profesionales.',
    'Choose the day and the hours when you need the professionals.',
    'Indique le jour et le créneau où vous avez besoin des professionnelles.',
  ],
  'date': ["Data de l'esdeveniment *", 'Fecha del evento *', 'Event date *', "Date de l'événement *"],
  'pickDate': ['Tria el dia', 'Elige el día', 'Choose the day', 'Choisis le jour'],
  'slot': ['Franja horària *', 'Franja horaria *', 'Time slot *', 'Créneau horaire *'],
  'from': ['Des de', 'Desde', 'From', 'De'],
  'until': ['Fins a', 'Hasta', 'Until', 'Jusqu’à'],
  'nightNote': [
    'Es poden aplicar recàrrecs per a serveis a partir de les 22 h i en dies festius.',
    'Se pueden aplicar recargos para servicios a partir de las 22 h y en días festivos.',
    'Surcharges may apply for services from 22:00 and on public holidays.',
    'Des majorations peuvent s’appliquer à partir de 22 h et les jours fériés.',
  ],
  'h3': ['Quants infants hi haurà?', '¿Cuántos niños habrá?', 'How many children will there be?', 'Combien d’enfants y aura-t-il ?'],
  'sub3': [
    'Separem per edats perquè cada grup té les seves pròpies professionals.',
    'Separamos por edades porque cada grupo tiene sus propias profesionales.',
    'We split by age because each group has its own professionals.',
    'Nous séparons par âge parce que chaque groupe a ses propres professionnelles.',
  ],
  'babies': ['Nadons 👶', 'Bebés 👶', 'Babies 👶', 'Bébés 👶'],
  'babiesSub': ['De 6 mesos a 3 anys', 'De 6 meses a 3 años', 'From 6 months to 3 years', 'De 6 mois à 3 ans'],
  'kids': ['Nens 🧒', 'Niños 🧒', 'Children 🧒', 'Enfants 🧒'],
  'kidsSub': ['A partir de 3 anys', 'A partir de 3 años', 'From 3 years', 'À partir de 3 ans'],
  'none': ['—', '—', '—', '—'],
  't1': ['1 prof · 50 €/h', '1 prof · 50 €/h', '1 carer · 50 €/h', '1 prof · 50 €/h'],
  't2': ['2 prof · 90 €/h', '2 prof · 90 €/h', '2 carers · 90 €/h', '2 prof · 90 €/h'],
  't3': ['3 prof · 120 €/h', '3 prof · 120 €/h', '3 carers · 120 €/h', '3 prof · 120 €/h'],
  'countNote': [
    "El dia de l'esdeveniment fem un recompte d'infants. Per cada infant addicional no comunicat prèviament s'aplica un recàrrec de 10 €.",
    'El día del evento hacemos un recuento de niños. Por cada niño adicional no comunicado antes se aplica un recargo de 10 €.',
    'On the day of the event we count the children. Each extra child not told to us in advance adds a 10 € charge.',
    'Le jour de l’événement nous comptons les enfants. Chaque enfant supplémentaire non signalé à l’avance entraîne un supplément de 10 €.',
  ],
  'h4': ['Voleu afegir alguna activitat?', '¿Queréis añadir alguna actividad?', 'Would you like to add an activity?', 'Voulez-vous ajouter une activité ?'],
  'sub4': [
    'Opcional. Cada activitat la fa una professional dedicada, a part de la cura.',
    'Opcional. Cada actividad la hace una profesional dedicada, además del cuidado.',
    'Optional. Each activity is run by a dedicated professional, in addition to the care.',
    'Facultatif. Chaque activité est animée par une professionnelle dédiée, en plus de la garde.',
  ],
  'activitiesLabel': ['Activitats · 40 €/h cadascuna', 'Actividades · 40 €/h cada una', 'Activities · 40 €/h each', 'Activités · 40 €/h chacune'],
  'paint': ['Pinta cares 🎨', 'Pinta caras 🎨', 'Face painting 🎨', 'Maquillage 🎨'],
  'paintSub': ['Una professional pinta la cara dels nens durant la festa.', 'Una profesional pinta la cara de los niños durante la fiesta.', 'A professional paints the children’s faces during the party.', 'Une professionnelle maquille les enfants pendant la fête.'],
  'karaoke': ['Karaoke 🎤', 'Karaoke 🎤', 'Karaoke 🎤', 'Karaoké 🎤'],
  'karaokeSub': ['Cançons i micro per animar la celebració.', 'Canciones y micro para animar la celebración.', 'Songs and a microphone to liven up the celebration.', 'Chansons et micro pour animer la fête.'],
  'zumba': ['Zumba infantil 💃', 'Zumba infantil 💃', 'Kids’ zumba 💃', 'Zumba enfants 💃'],
  'zumbaSub': ['Balls i moviment guiats per als més petits.', 'Bailes y movimiento guiados para los más pequeños.', 'Guided dancing and movement for the little ones.', 'Danses et mouvement guidés pour les plus petits.'],
  'perHour': ['40 €/h', '40 €/h', '40 €/h', '40 €/h'],
  'decoLabel': ['Decoració', 'Decoración', 'Decoration', 'Décoration'],
  'deco': ["Decoració de l'espai infantil 🎈", 'Decoración del espacio infantil 🎈', 'Decorating the children’s space 🎈', 'Décoration de l’espace enfants 🎈'],
  'decoSub': ['Ens expliqueu com la voleu i us preparem una proposta.', 'Nos explicáis cómo la queréis y os preparamos una propuesta.', 'Tell us how you want it and we will prepare a proposal.', 'Vous nous expliquez comment vous la voulez et nous préparons une proposition.'],
  'decoPrice': ['des de 150 €', 'desde 150 €', 'from 150 €', 'dès 150 €'],
  'decoNote': [
    "La decoració és un complement del servei de cangur i cal sol·licitar-la amb un mínim de 3 setmanes d'antelació.",
    'La decoración es un complemento del servicio de cangur y hay que solicitarla con un mínimo de 3 semanas de antelación.',
    'Decoration is an add-on to the childcare service and must be requested at least 3 weeks in advance.',
    'La décoration est un complément du service de garde et doit être demandée au moins 3 semaines à l’avance.',
  ],
  'h5': ['Alguna cosa més que hàgim de saber?', '¿Algo más que debamos saber?', 'Anything else we should know?', 'Autre chose à savoir ?'],
  'sub5': [
    'Temàtica, al·lèrgies, necessitats especials, horaris concrets... el que vulguis.',
    'Temática, alergias, necesidades especiales, horarios concretos... lo que quieras.',
    'Theme, allergies, special needs, specific times... whatever you want to add.',
    'Thème, allergies, besoins particuliers, horaires précis... ce que tu veux.',
  ],
  'notesHint': ['Escriu aquí les observacions (opcional)', 'Escribe aquí las observaciones (opcional)', 'Write your notes here (optional)', 'Écris tes observations ici (facultatif)'],
  'h6': ["On es fa l'esdeveniment?", '¿Dónde se hace el evento?', 'Where does the event take place?', 'Où a lieu l’événement ?'],
  'sub6': ["Confirma l'adreça o indica'n una altra.", 'Confirma la dirección o indica otra.', 'Confirm the address or enter another one.', 'Confirme l’adresse ou indiquez-en une autre.'],
  'addrProfile': ['Adreça del perfil', 'Dirección del perfil', 'Profile address', 'Adresse du profil'],
  'addrOther': ['Una altra adreça', 'Otra dirección', 'Another address', 'Une autre adresse'],
  'addrOtherSub': ["Indica on es fa l'esdeveniment.", 'Indica dónde se hace el evento.', 'Say where the event takes place.', 'Indique où a lieu l’événement.'],
  'addrHint': ['Carrer, número, parròquia / nom del local', 'Calle, número, parroquia / nombre del local', 'Street, number, parish / venue name', 'Rue, numéro, paroisse / nom du lieu'],
  'h7': ['Com et contactem?', '¿Cómo te contactamos?', 'How do we contact you?', 'Comment te contacter ?'],
  'fromProfile': ['Del teu perfil · pots editar-ho si cal', 'De tu perfil · puedes editarlo si hace falta', 'From your profile · you can edit it if needed', 'Depuis ton profil · tu peux le modifier si besoin'],
  'name': ['El teu nom', 'Tu nombre', 'Your name', 'Ton nom'],
  'phone': ['Telèfon', 'Teléfono', 'Phone', 'Téléphone'],
  'email': ['Correu', 'Correo', 'Email', 'E-mail'],
  'h8': ['Ho tenim!', '¡Lo tenemos!', 'We’ve got it!', 'C’est noté !'],
  'sub8': [
    "Revisa-ho i envia la sol·licitud. T'enviarem un pressupost a mida.",
    'Revísala y envía la solicitud. Te enviaremos un presupuesto a medida.',
    'Check it and send the request. We will send you a tailored quote.',
    'Vérifie et envoie la demande. Nous t’enverrons un devis sur mesure.',
  ],
  'replyTitle': ['Et prepararem un pressupost en 2–3 dies', 'Te prepararemos un presupuesto en 2–3 días', 'We will prepare a quote in 2–3 days', 'Nous préparerons un devis sous 2–3 jours'],
  'replyBody': [
    "Analitzarem la teva sol·licitud i et prepararem una proposta i un pressupost personalitzats per al teu esdeveniment. En un termini de 2–3 dies et contactarem per l'app amb tots els detalls. No et quedaràs sense resposta.",
    'Analizaremos tu solicitud y te prepararemos una propuesta y un presupuesto personalizados para tu evento. En un plazo de 2–3 días te contactaremos por la app con todos los detalles. No te quedarás sin respuesta.',
    'We will review your request and prepare a personal proposal and quote for your event. Within 2–3 days we will contact you in the app with all the details. You will get an answer.',
    'Nous étudierons ta demande et préparerons une proposition et un devis personnalisés pour ton événement. Sous 2–3 jours nous te contactons dans l’app avec tous les détails. Tu auras une réponse.',
  ],
  'continue': ['Continuar →', 'Continuar →', 'Continue →', 'Continuer →'],
  'back': ['← Enrere', '← Atrás', '← Back', '← Retour'],
  'send': ['Enviar sol·licitud', 'Enviar solicitud', 'Send request', 'Envoyer la demande'],
  'doneTitle': ['Sol·licitud rebuda!', '¡Solicitud recibida!', 'Request received!', 'Demande reçue !'],
  'doneBody': [
    "Prepararem la proposta i el pressupost del teu esdeveniment i te'ls farem arribar aquí, a l'app, en 2–3 dies. Gràcies per confiar en Mon Cangur.",
    'Prepararemos la propuesta y el presupuesto de tu evento y te los haremos llegar aquí, en la app, en 2–3 días. Gracias por confiar en Mon Cangur.',
    'We will prepare the proposal and quote for your event and send them here, in the app, within 2–3 days. Thank you for trusting Mon Cangur.',
    'Nous préparerons la proposition et le devis de ton événement et nous te les enverrons ici, dans l’app, sous 2–3 jours. Merci de faire confiance à Mon Cangur.',
  ],
  'home': ["Tornar a l'inici", 'Volver al inicio', 'Back to home', 'Retour à l’accueil'],
};

const eventTypes = ['birthday', 'baptism', 'communion', 'wedding', 'private', 'corporate', 'other'];
const eventActivities = ['paint', 'karaoke', 'zumba'];

final eventSlots = <String>[
  for (var hour = 8; hour <= 24; hour++) ...[
    '${hour.toString().padLeft(2, '0')}:00',
    if (hour < 24) '${hour.toString().padLeft(2, '0')}:30',
  ],
];

String ev(AppLang lang, String key, [Map<String, String> vars = const {}]) {
  final row = _rows[key];
  var text = (row == null || row.length != 4) ? key : row[lang.index];
  for (final entry in vars.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value);
  }
  return text;
}

String babyTariff(AppLang lang, int count) {
  if (count <= 0) return ev(lang, 'none');
  if (count <= 2) return ev(lang, 't1');
  if (count <= 6) return ev(lang, 't2');
  return ev(lang, 't3');
}

String childTariff(AppLang lang, int count) {
  if (count <= 0) return ev(lang, 'none');
  if (count <= 7) return ev(lang, 't1');
  if (count <= 14) return ev(lang, 't2');
  return ev(lang, 't3');
}

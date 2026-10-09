import '../models/models.dart';

const _rows = <String, List<String>>{
  'place': ['Cura infantil · Andorra', 'Cuidado infantil · Andorra', 'Childcare · Andorra', 'Garde d’enfants · Andorre'],
  'eyebrow': ['Els nostres serveis', 'Nuestros servicios', 'Our services', 'Nos services'],
  'title': ['5 serveis per a cada família', '5 servicios para cada familia', '5 services for every family', '5 services pour chaque famille'],
  'sub': [
    'Llisca de costat i toca un servei per veure la tarifa.',
    'Desliza y toca un servicio para ver la tarifa.',
    'Swipe sideways and tap a service to see the rate.',
    'Fais glisser et touche un service pour voir le tarif.',
  ],
  'more': ['Més detalls', 'Más detalles', 'More details', 'Plus de détails'],
  'ask': ['Demanar proposta', 'Pedir propuesta', 'Request a proposal', 'Demander une proposition'],
  'book': ['Reservar un servei', 'Reservar un servicio', 'Book a service', 'Réserver un service'],
  'teamEyebrow': ['El nostre equip', 'Nuestro equipo', 'Our team', 'Notre équipe'],
  'teamTitle': ['Coneix les nostres cangurs', 'Conoce a nuestras cangurs', 'Meet our nannies', 'Découvre nos nounous'],
  'teamSub': [
    'Aquestes són les professionals de Mon Cangur. Per reservar, prem «Reservar un servei» i tria servei, dia i hora: et mostrarem qui està lliure.',
    'Estas son las profesionales de Mon Cangur. Para reservar, pulsa «Reservar un servicio» y elige servicio, día y hora: te mostraremos quién está libre.',
    'These are the Mon Cangur professionals. To book, tap “Book a service” and choose the service, day and time: we will show who is free.',
    'Voici les professionnelles de Mon Cangur. Pour réserver, appuie sur « Réserver un service » et choisis le service, le jour et l’heure : nous te montrerons qui est libre.',
  ],
  'strength': ['Punt fort', 'Punto fuerte', 'Strength', 'Point fort'],
  'see': ['Veure perfil', 'Ver perfil', 'View profile', 'Voir le profil'],
  'closing': [
    'Darrere de cada professional, hi ha un equip que cuida.',
    'Detrás de cada profesional, hay un equipo que cuida.',
    'Behind every professional, there is a team that cares.',
    'Derrière chaque professionnelle, il y a une équipe qui prend soin.',
  ],
  'closingSub': [
    'Estem aquí per quan ens necessitis.',
    'Estamos aquí para cuando nos necesites.',
    'We are here whenever you need us.',
    'Nous sommes là quand tu as besoin de nous.',
  ],
  'fromHour': ['des de {n} €/h', 'desde {n} €/h', 'from {n} €/h', 'dès {n} €/h'],
  'custom': ['Proposta personalitzada', 'Propuesta personalizada', 'Personal proposal', 'Proposition personnalisée'],
  'kids': ['Nens', 'Niños', 'Children', 'Enfants'],
  'oneChild': ['1 nen', '1 niño', '1 child', '1 enfant'],
  'manyChildren': ['{n} nens', '{n} niños', '{n} children', '{n} enfants'],
  'tagMin': ['Mínim 2 h', 'Mínimo 2 h', 'Minimum 2 h', 'Minimum 2 h'],
  'tagEach': ['Cada reserva és independent', 'Cada reserva es independiente', 'Each booking stands alone', 'Chaque réservation est indépendante'],
  'tagNight': [
    'Nocturn (22–8 h): exclusiu Fix o Repàs actiu',
    'Nocturno (22–8 h): exclusivo Fijo o Repaso activo',
    'Night (22–8 h): only with an active regular or after-school plan',
    'Nuit (22–8 h) : réservé au Fixe ou au Soutien actif',
  ],
  'igiBold': ['Preus finals (IGI 4,5% inclòs).', 'Precios finales (IGI 4,5% incluido).', 'Final prices (4.5% IGI included).', 'Prix finaux (IGI 4,5 % inclus).'],
  'igiRest': [
    ' Suplements: nocturn +5 €/h · festiu +12 €/h · nit de festiu +17 €/h.',
    ' Suplementos: nocturno +5 €/h · festivo +12 €/h · noche de festivo +17 €/h.',
    ' Supplements: night +5 €/h · holiday +12 €/h · holiday night +17 €/h.',
    ' Suppléments : nuit +5 €/h · férié +12 €/h · nuit de férié +17 €/h.',
  ],
  'descOcasional': [
    'Per quan ho necessites, el dia que ho necessites. Per a una tarda concreta, una nit especial o una reunió que ja tens al calendari. Sense compromisos.',
    'Para cuando lo necesitas, el día que lo necesitas. Una tarde concreta, una noche especial o una reunión que ya tienes en el calendario. Sin compromisos.',
    'For when you need it, on the day you need it. A specific afternoon, a special evening or a meeting already in the calendar. No commitment.',
    'Pour quand tu en as besoin, le jour où tu en as besoin. Un après-midi précis, une soirée spéciale ou une réunion déjà au calendrier. Sans engagement.',
  ],
  'descUrgent': [
    'Suport immediat quan menys t\'ho esperes. Una reunió d\'última hora o un peque que s\'ha despertat malalt: reserves amb menys de 24 h d\'antelació.',
    'Apoyo inmediato cuando menos te lo esperas. Una reunión de última hora o un peque que se ha despertado enfermo: reservas con menos de 24 h de antelación.',
    'Immediate support when you least expect it. A last-minute meeting or a child who woke up ill: you book with less than 24 hours\' notice.',
    'Un soutien immédiat quand tu t’y attends le moins. Une réunion de dernière minute ou un enfant réveillé malade : tu réserves avec moins de 24 h d’avance.',
  ],
  'descEvent': [
    'Perquè els nens s\'ho passin bé i els adults també. Aniversaris, batejos, casaments i esdeveniments corporatius: ens encarreguem de l\'entreteniment i la cura.',
    'Para que los niños lo pasen bien y los adultos también. Cumpleaños, bautizos, bodas y eventos de empresa: nos encargamos del entretenimiento y el cuidado.',
    'So the children have a good time, and the adults do too. Birthdays, christenings, weddings and company events: we take care of the entertainment and the care.',
    'Pour que les enfants passent un bon moment, et les adultes aussi. Anniversaires, baptêmes, mariages et événements d’entreprise : nous nous occupons de l’animation et de la garde.',
  ],
  'descFix': [
    'La mateixa persona, cada setmana. Una professional de referència que coneix els teus fills, les seves rutines i necessitats, per crear un vincle real de confiança.',
    'La misma persona, cada semana. Una profesional de referencia que conoce a tus hijos, sus rutinas y necesidades, para crear un vínculo real de confianza.',
    'The same person, every week. A regular professional who knows your children, their routines and needs, and builds a real bond of trust.',
    'La même personne, chaque semaine. Une professionnelle de référence qui connaît tes enfants, leurs routines et leurs besoins, pour créer un vrai lien de confiance.',
  ],
  'descExtra': [
    'Idiomes, música, repàs escolar, ioga infantil, escacs o manualitats: un extraescolar a mida, amb el nostre equip i la nostra cura, un dia fix cada setmana.',
    'Idiomas, música, repaso escolar, yoga infantil, ajedrez o manualidades: un extraescolar a medida, con nuestro equipo y nuestro cuidado, un día fijo cada semana.',
    'Languages, music, school support, children’s yoga, chess or crafts: a tailored after-school activity, with our team and our care, on a fixed day each week.',
    'Langues, musique, soutien scolaire, yoga pour enfants, échecs ou travaux manuels : un extrascolaire sur mesure, avec notre équipe et notre attention, un jour fixe chaque semaine.',
  ],
  'agency': ['Agència i Gestió', 'Agencia y gestión', 'Agency and management', 'Agence et gestion'],
  'agencyBody': [
    'Seleccionem i et presentem el perfil que millor encaixa amb la teva família, i t\'acompanyem en la selecció i la contractació.',
    'Seleccionamos y te presentamos el perfil que mejor encaja con tu familia, y te acompañamos en la selección y la contratación.',
    'We select and introduce the profile that fits your family best, and we stay with you through the choice and the hiring.',
    'Nous sélectionnons et te présentons le profil qui convient le mieux à ta famille, et nous t’accompagnons dans le choix et l’embauche.',
  ],
  'teamMod': ['Mon Cangur Team', 'Mon Cangur Team', 'Mon Cangur Team', 'Mon Cangur Team'],
  'teamModBody': [
    'La professional forma part del nostre equip. Nosaltres gestionem contractes, nòmines i assegurança, i tens accés exclusiu al Servei d\'Urgència.',
    'La profesional forma parte de nuestro equipo. Nosotros gestionamos contratos, nóminas y seguro, y tienes acceso exclusivo al Servicio de urgencia.',
    'The professional is part of our team. We handle contracts, payroll and insurance, and you get exclusive access to the urgent service.',
    'La professionnelle fait partie de notre équipe. Nous gérons les contrats, la paie et l’assurance, et tu as un accès exclusif au service d’urgence.',
  ],
  'fixCtaLine': [
    'Comença amb un formulari de menys de 5 minuts i et preparem una proposta personalitzada per a la teva família.',
    'Empieza con un formulario de menos de 5 minutos y te preparamos una propuesta personalizada para tu familia.',
    'Start with a form that takes less than 5 minutes and we will prepare a personal proposal for your family.',
    'Commence par un formulaire de moins de 5 minutes et nous préparons une proposition personnalisée pour ta famille.',
  ],
  'fixCta': ['Començar el formulari', 'Empezar el formulario', 'Start the form', 'Commencer le formulaire'],
  'extraCtaLine': [
    'Digues-nos què vols que aprengui el teu fill o filla i buscarem el professional del nostre equip que encaixi amb la vostra disponibilitat. Et contactem en 2–3 dies.',
    'Dinos qué quieres que aprenda tu hijo o hija y buscaremos al profesional de nuestro equipo que encaje con vuestra disponibilidad. Te contactamos en 2–3 días.',
    'Tell us what you want your child to learn and we will look for the professional on our team who fits your availability. We contact you in 2–3 days.',
    'Dis-nous ce que tu veux que ton enfant apprenne et nous chercherons la professionnelle de notre équipe qui correspond à vos disponibilités. Nous te contactons sous 2–3 jours.',
  ],
  'extraCta': ['Demanar el meu extraescolar', 'Pedir mi extraescolar', 'Request my after-school activity', 'Demander mon extrascolaire'],
  'eventCtaLine': [
    'Explica\'ns com és el teu esdeveniment (tipus, data, nombre d\'infants i extres) i et preparem una proposta i un pressupost a mida. Et contactem en 2–3 dies.',
    'Cuéntanos cómo es tu evento (tipo, fecha, número de niños y extras) y te preparamos una propuesta y un presupuesto a medida. Te contactamos en 2–3 días.',
    'Tell us about your event (type, date, number of children and extras) and we will prepare a tailored proposal and quote. We contact you in 2–3 days.',
    'Explique-nous ton événement (type, date, nombre d’enfants et extras) et nous préparons une proposition et un devis sur mesure. Nous te contactons sous 2–3 jours.',
  ],
  'eventCta': ['Demanar proposta d\'esdeveniment', 'Pedir propuesta de evento', 'Request an event proposal', 'Demander une proposition d’événement'],
};

String hm(AppLang lang, String key, [Map<String, String> vars = const {}]) {
  final row = _rows[key];
  var text = (row == null || row.length != 4) ? key : row[lang.index];
  for (final entry in vars.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value);
  }
  return text;
}

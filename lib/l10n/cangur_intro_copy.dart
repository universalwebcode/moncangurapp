import '../models/models.dart';

const _rows = <String, List<String>>{
  'step': ['Pas {n} de 7 · {label}', 'Paso {n} de 7 · {label}', 'Step {n} of 7 · {label}', 'Étape {n} sur 7 · {label}'],
  'welcome': ['Benvinguda', 'Bienvenida', 'Welcome', 'Bienvenue'],
  'languages': ['Idiomes', 'Idiomas', 'Languages', 'Langues'],
  'who': ['Qui ets', 'Quién eres', 'Who you are', 'Qui tu es'],
  'experience': ['Experiència', 'Experiencia', 'Experience', 'Expérience'],
  'withKids': ['Amb els nens', 'Con los niños', 'With the children', 'Avec les enfants'],
  'strength': ['El teu punt fort', 'Tu punto fuerte', 'Your strength', 'Ton point fort'],
  'almost': ['Gairebé fet', 'Casi listo', 'Almost done', 'Presque fini'],
  'title1': ['Crea el teu perfil de cangur', 'Crea tu perfil de canguro', 'Create your nanny profile', 'Crée ton profil de nounou'],
  'sub1': [
    'Aquest perfil és el que veuran les famílies. Explica\'t amb naturalitat: volem que et coneguin de veritat. 🌿',
    'Este perfil es el que verán las familias. Explícate con naturalidad: queremos que te conozcan de verdad. 🌿',
    'Families will see this profile. Write naturally: we want them to really get to know you. 🌿',
    'Les familles verront ce profil. Présente-toi naturellement : nous voulons qu’elles te connaissent vraiment. 🌿',
  ],
  'addPhoto': ['Afegir foto', 'Añadir foto', 'Add photo', 'Ajouter une photo'],
  'changePhoto': ['Canviar foto', 'Cambiar foto', 'Change photo', 'Changer la photo'],
  'photoHint': [
    'Una foto propera i amable ajuda molt.',
    'Una foto cercana y amable ayuda mucho.',
    'A warm, friendly photo helps a lot.',
    'Une photo proche et bienveillante aide beaucoup.',
  ],
  'photoBig': [
    'La foto és massa gran. En pots triar una de més petita.',
    'La foto es demasiado grande. Elige una más pequeña.',
    'The photo is too large. Choose a smaller one.',
    'La photo est trop grande. Choisis-en une plus petite.',
  ],
  'name': ['El teu nom', 'Tu nombre', 'Your name', 'Ton nom'],
  'role': ['La teva professió o formació', 'Tu profesión o formación', 'Your profession or training', 'Ta profession ou formation'],
  'roleHint': ["Ex: Mestra d'educació infantil", 'Ej: Maestra de educación infantil', 'E.g. Early years teacher', 'Ex. : Enseignante en petite enfance'],
  'langTitle': ['Quins idiomes parles?', '¿Qué idiomas hablas?', 'Which languages do you speak?', 'Quelles langues parles-tu ?'],
  'langSub': [
    'Tria tots els que puguis fer servir amb els infants.',
    'Elige todos los que puedas usar con los niños.',
    'Choose every language you can use with the children.',
    'Choisis toutes celles que tu peux utiliser avec les enfants.',
  ],
  'whoTitle': ["Explica'ns qui ets", 'Cuéntanos quién eres', 'Tell us who you are', 'Dis-nous qui tu es'],
  'whoGuide': [
    'Parla de tu i de la teva manera de cuidar. **Com ets amb els nens?** Per què t\'agrada aquesta feina? Què et fa especial?',
    'Habla de ti y de tu manera de cuidar. **¿Cómo eres con los niños?** ¿Por qué te gusta este trabajo? ¿Qué te hace especial?',
    'Talk about yourself and how you care. **What are you like with children?** Why do you like this work? What makes you special?',
    'Parle de toi et de ta façon de prendre soin. **Comment es-tu avec les enfants ?** Pourquoi aimes-tu ce travail ? Qu’est-ce qui te rend spéciale ?',
  ],
  'whoHint': [
    'Ex: Soc una persona tranquil·la i afectuosa, m\'adapto a cada nen...',
    'Ej: Soy una persona tranquila y cariñosa, me adapto a cada niño...',
    'E.g. I am calm and affectionate, and I adapt to each child...',
    'Ex. : Je suis une personne calme et affectueuse, je m’adapte à chaque enfant...',
  ],
  'workTitle': ['On has treballat abans?', '¿Dónde has trabajado antes?', 'Where have you worked before?', 'Où as-tu travaillé avant ?'],
  'workGuide': [
    'Escoles bressol, famílies, acadèmies, casals... **amb quines edats** i durant **quant de temps**.',
    'Escuelas infantiles, familias, academias, casales... **con qué edades** y durante **cuánto tiempo**.',
    'Nurseries, families, academies, holiday clubs... **which ages** and for **how long**.',
    'Crèches, familles, académies, centres de loisirs... **avec quels âges** et pendant **combien de temps**.',
  ],
  'workHint': [
    'Ex: He treballat 3 anys en una escola bressol amb nens de 0 a 3 anys...',
    'Ej: He trabajado 3 años en una escuela infantil con niños de 0 a 3 años...',
    'E.g. I worked for 3 years in a nursery with children from 0 to 3...',
    'Ex. : J’ai travaillé 3 ans dans une crèche avec des enfants de 0 à 3 ans...',
  ],
  'likesTitle': ["Què t'agrada fer amb els nens?", '¿Qué te gusta hacer con los niños?', 'What do you like doing with children?', 'Qu’aimes-tu faire avec les enfants ?'],
  'likesGuide': [
    'Jocs, manualitats, música, sortides, contes... **allò que més gaudeixes** compartint amb ells.',
    'Juegos, manualidades, música, salidas, cuentos... **lo que más disfrutas** compartiendo con ellos.',
    'Games, crafts, music, outings, stories... **what you enjoy most** sharing with them.',
    'Jeux, bricolage, musique, sorties, histoires... **ce que tu aimes le plus** partager avec eux.',
  ],
  'likesHint': [
    "Ex: M'encanta la música i les manualitats sensorials...",
    'Ej: Me encanta la música y las manualidades sensoriales...',
    'E.g. I love music and sensory crafts...',
    'Ex. : J’adore la musique et les activités sensorielles...',
  ],
  'strengthTitle': ['Quin és el teu punt fort?', '¿Cuál es tu punto fuerte?', 'What is your strength?', 'Quel est ton point fort ?'],
  'strengthGuide': [
    "Allò que et defineix com a cangur: **paciència, flexibilitat, creativitat, afecte...** Explica-ho en una frase o dues.",
    'Lo que te define como canguro: **paciencia, flexibilidad, creatividad, cariño...** Explícalo en una o dos frases.',
    'What defines you as a nanny: **patience, flexibility, creativity, warmth...** Say it in a sentence or two.',
    'Ce qui te définit comme nounou : **patience, souplesse, créativité, affection...** Dis-le en une ou deux phrases.',
  ],
  'strengthHint': [
    "Ex: La flexibilitat i l'afecte: connecto de seguida amb els infants.",
    'Ej: La flexibilidad y el cariño: conecto enseguida con los niños.',
    'E.g. Flexibility and warmth: I connect with children straight away.',
    'Ex. : La souplesse et l’affection : je crée tout de suite le lien avec les enfants.',
  ],
  'readyTitle': ['Tot a punt!', '¡Todo listo!', 'All set!', 'Tout est prêt !'],
  'readySub': [
    "Revisarem el teu perfil i, un cop validat, les famílies el podran veure quan reservin. Ja podràs posar la teva disponibilitat des de l'app.",
    'Revisaremos tu perfil y, una vez validado, las familias podrán verlo al reservar. Ya podrás poner tu disponibilidad desde la app.',
    'We will review your profile and, once it is approved, families can see it when they book. You can set your availability in the app.',
    'Nous relirons ton profil et, une fois validé, les familles pourront le voir en réservant. Tu pourras indiquer tes disponibilités dans l’app.',
  ],
  'readyGuide': [
    'Podràs **editar el teu perfil** i afegir més fotos quan vulguis des de **El meu perfil**.',
    'Podrás **editar tu perfil** y añadir más fotos cuando quieras desde **Mi perfil**.',
    'You can **edit your profile** and add more photos whenever you want from **My profile**.',
    'Tu pourras **modifier ton profil** et ajouter d’autres photos quand tu veux depuis **Mon profil**.',
  ],
  'back': ['← Enrere', '← Atrás', '← Back', '← Retour'],
  'next': ['Continuar →', 'Continuar →', 'Continue →', 'Continuer →'],
  'send': ['Enviar perfil', 'Enviar perfil', 'Send profile', 'Envoyer le profil'],
  'count': ['{n} / {max} caràcters', '{n} / {max} caracteres', '{n} / {max} characters', '{n} / {max} caractères'],
  'missing': ['{n} · et falten {left} per al mínim', '{n} · te faltan {left} para el mínimo', '{n} · {left} more to reach the minimum', '{n} · encore {left} pour le minimum'],
  'limit': ['mín. {min} · màx. {max}', 'mín. {min} · máx. {max}', 'min. {min} · max. {max}', 'min. {min} · max. {max}'],
  'doneTitle': ['Perfil creat!', '¡Perfil creado!', 'Profile created!', 'Profil créé !'],
  'doneBody': [
    "Gràcies, {name}. El revisem i t'avisem quan estigui actiu. Benvingut/da a l'equip de Mon Cangur!",
    'Gracias, {name}. Lo revisamos y te avisamos cuando esté activo. ¡Bienvenido/a al equipo de Mon Cangur!',
    'Thank you, {name}. We will review it and tell you when it is active. Welcome to the Mon Cangur team!',
    'Merci, {name}. Nous le relisons et nous t’avertissons quand il sera actif. Bienvenue dans l’équipe de Mon Cangur !',
  ],
  'enter': ["Entrar a l'app →", 'Entrar en la app →', 'Enter the app →', 'Entrer dans l’app →'],
};

const introLanguages = ['Català', 'Castellà', 'Anglès', 'Francès', 'Portuguès', 'Alemany', 'Italià'];

String ci(AppLang lang, String key) {
  final row = _rows[key];
  if (row == null || row.length != 4) return key;
  return row[lang.index];
}

String introStep(AppLang lang, int step, String label) {
  return ci(lang, 'step').replaceAll('{n}', '$step').replaceAll('{label}', label);
}

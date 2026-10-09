import '../models/models.dart';

const _rows = <String, List<String>>{
  'intro': [
    'Aquí pots afegir tot el que ajudi la cangur a cuidar millor cada infant: com és, les seves rutines, què li agrada i les seves necessitats. Com més ens expliquis, millor serà la cura.',
    'Aquí puedes añadir todo lo que ayude a la cangur a cuidar mejor a cada niño: cómo es, sus rutinas, qué le gusta y sus necesidades. Cuanto más nos cuentes, mejor será el cuidado.',
    'Here you can add everything that helps the nanny care for each child: who they are, their routines, what they like and what they need. The more you tell us, the better the care.',
    'Ici tu peux ajouter tout ce qui aide la nounou à mieux s’occuper de chaque enfant : son caractère, ses routines, ce qu’il aime et ses besoins. Plus tu nous en dis, mieux ce sera.',
  ],
  'add': ['Afegir', 'Añadir', 'Add', 'Ajouter'],
  'photoData': ['Foto i dades', 'Foto y datos', 'Photo and details', 'Photo et données'],
  'addPhoto': ['Afegir foto', 'Añadir foto', 'Add photo', 'Ajouter une photo'],
  'changePhoto': ['Canviar foto', 'Cambiar foto', 'Change photo', 'Changer la photo'],
  'photoHint': ["Opcional · només per a l'equip de Mon Cangur", 'Opcional · solo para el equipo de Mon Cangur', 'Optional · only for the Mon Cangur team', 'Facultatif · uniquement pour l’équipe Mon Cangur'],
  'photoSoon': [
    'La foto es podrà afegir des del navegador. Si no s\'obre el selector, desa la resta de dades igualment.',
    'La foto se puede añadir desde el navegador. Si no se abre el selector, guarda el resto de datos igualmente.',
    'The photo can be added from the browser. If the picker does not open, you can still save the other details.',
    'La photo s’ajoute depuis le navigateur. Si le sélecteur ne s’ouvre pas, tu peux quand même enregistrer le reste.',
  ],
  'name': ['Nom', 'Nombre', 'Name', 'Nom'],
  'birth': ['Data de naixement', 'Fecha de nacimiento', 'Date of birth', 'Date de naissance'],
  'pickDate': ['Tria el dia', 'Elige el día', 'Choose the day', 'Choisis le jour'],
  'school': ['Escola / guarderia', 'Escuela / guardería', 'School / nursery', 'École / crèche'],
  'schoolHint': ['Nom del centre (opcional)', 'Nombre del centro (opcional)', 'Name of the centre (optional)', 'Nom du centre (facultatif)'],
  'who': ['Com és', 'Cómo es', 'Who they are', 'Comment il est'],
  'traits': ['Caràcter', 'Carácter', 'Character', 'Caractère'],
  'calm': ['Tranquil/a', 'Tranquilo/a', 'Calm', 'Calme'],
  'energetic': ['Enèrgic/a', 'Enérgico/a', 'Energetic', 'Énergique'],
  'shy': ['Tímid/a', 'Tímido/a', 'Shy', 'Timide'],
  'outgoing': ['Extravertit/da', 'Extravertido/a', 'Outgoing', 'Extraverti·e'],
  'sensitive': ['Sensible', 'Sensible', 'Sensitive', 'Sensible'],
  'curious': ['Curiós/a', 'Curioso/a', 'Curious', 'Curieux/curieuse'],
  'independent': ['Independent', 'Independiente', 'Independent', 'Indépendant·e'],
  'about': ["Explica'ns com és", 'Cuéntanos cómo es', 'Tell us what they are like', 'Dis-nous comment il est'],
  'aboutHint': [
    'Ex: li costa una mica separar-se al principi, però es relaxa de seguida amb jocs tranquils...',
    'Ej: le cuesta un poco separarse al principio, pero se relaja enseguida con juegos tranquilos...',
    'E.g. separating is a little hard at first, but they settle quickly with quiet games...',
    'Ex. : la séparation est un peu difficile au début, mais il se détend vite avec des jeux calmes...',
  ],
  'routines': ['Rutines', 'Rutinas', 'Routines', 'Routines'],
  'nap': ['Fa migdiada?', '¿Duerme la siesta?', 'Do they nap?', 'Fait-il la sieste ?'],
  'yes': ['Sí', 'Sí', 'Yes', 'Oui'],
  'no': ['No', 'No', 'No', 'Non'],
  'sometimes': ['A vegades', 'A veces', 'Sometimes', 'Parfois'],
  'bedtime': ['Hora de dormir', 'Hora de dormir', 'Bedtime', 'Heure du coucher'],
  'meals': ['Hora dels àpats', 'Hora de las comidas', 'Meal times', 'Heure des repas'],
  'mealsHint': ['Ex: 13 h i 20 h', 'Ej: 13 h y 20 h', 'E.g. 13:00 and 20:00', 'Ex. : 13 h et 20 h'],
  'habits': ['Hàbits i rutines a tenir en compte', 'Hábitos y rutinas a tener en cuenta', 'Habits and routines to keep in mind', 'Habitudes et routines à prendre en compte'],
  'habitsHint': [
    'Ex: abans de dormir li llegim un conte; necessita el seu peluix; sopa d\'hora...',
    'Ej: antes de dormir le leemos un cuento; necesita su peluche; cena pronto...',
    'E.g. we read a story before bed; they need their soft toy; dinner is early...',
    'Ex. : avant de dormir on lui lit une histoire ; il a besoin de sa peluche ; il dîne tôt...',
  ],
  'health': ['Salut i cura', 'Salud y cuidado', 'Health and care', 'Santé et soins'],
  'allergies': ['Al·lèrgies o intoleràncies', 'Alergias o intolerancias', 'Allergies or intolerances', 'Allergies ou intolérances'],
  'allergiesHint': ['Ex: fruits secs (opcional)', 'Ej: frutos secos (opcional)', 'E.g. nuts (optional)', 'Ex. : fruits à coque (facultatif)'],
  'medicine': ['Medicació', 'Medicación', 'Medication', 'Médicaments'],
  'medicineHint': ['Ex: cap / inhalador si tus (opcional)', 'Ej: ninguna / inhalador si tose (opcional)', 'E.g. none / inhaler if they cough (optional)', 'Ex. : aucun / inhalateur s’il tousse (facultatif)'],
  'needs': ['Necessitats especials', 'Necesidades especiales', 'Special needs', 'Besoins particuliers'],
  'needsHint': ['Qualsevol cosa important per a la seva cura (opcional)', 'Cualquier cosa importante para su cuidado (opcional)', 'Anything important for their care (optional)', 'Tout ce qui compte pour en prendre soin (facultatif)'],
  'prefs': ['Preferències', 'Preferencias', 'Preferences', 'Préférences'],
  'likes': ['Què li agrada', 'Qué le gusta', 'What they like', 'Ce qu’il aime'],
  'likesHint': ['Jocs, activitats, contes, cançons preferides...', 'Juegos, actividades, cuentos, canciones preferidas...', 'Games, activities, stories, favourite songs...', 'Jeux, activités, histoires, chansons préférées...'],
  'fears': ["Pors o coses que l'espanten", 'Miedos o cosas que le asustan', 'Fears or things that scare them', 'Peurs ou choses qui lui font peur'],
  'fearsHint': ['Ex: la foscor, els gossos (opcional)', 'Ej: la oscuridad, los perros (opcional)', 'E.g. the dark, dogs (optional)', 'Ex. : le noir, les chiens (facultatif)'],
  'soothe': ['Com es calma', 'Cómo se calma', 'How they calm down', 'Comment il se calme'],
  'sootheHint': ['Ex: música suau, abraçades (opcional)', 'Ej: música suave, abrazos (opcional)', 'E.g. soft music, hugs (optional)', 'Ex. : musique douce, câlins (facultatif)'],
};

const kidTraits = ['calm', 'energetic', 'shy', 'outgoing', 'sensitive', 'curious', 'independent'];
const kidColors = [0xFF6E82A6, 0xFF8CA598, 0xFFA98E7B, 0xFF9487B3, 0xFFC08457];

String kd(AppLang lang, String key) {
  final row = _rows[key];
  return (row == null || row.length != 4) ? key : row[lang.index];
}

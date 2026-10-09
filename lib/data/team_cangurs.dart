import '../models/models.dart';

class TeamStory {
  const TeamStory({
    required this.slug,
    required this.nombre,
    required this.color,
    required this.rol,
    required this.idiomas,
    required this.qui,
    required this.trayectoria,
    required this.agrada,
    required this.puntFort,
    this.badge = '',
    this.experienciaAnos = 0,
    this.userId,
    this.photoUrl,
  });

  final String slug;
  final String nombre;
  final int color;
  final String rol;
  final List<String> idiomas;
  final String qui;
  final String trayectoria;
  final String agrada;
  final String puntFort;
  final String badge;
  final int experienciaAnos;
  final String? userId;
  final String? photoUrl;

  String get firstName => nombre.split(' ').first;

  TeamStory link(CangurProfile profile) {
    return TeamStory(
      slug: slug,
      nombre: nombre,
      color: color,
      rol: profile.rol.isNotEmpty ? profile.rol : rol,
      idiomas: profile.idiomas.isNotEmpty ? profile.idiomas : idiomas,
      qui: profile.qui.isNotEmpty ? profile.qui : qui,
      trayectoria: profile.trayectoria.isNotEmpty ? profile.trayectoria : trayectoria,
      agrada: profile.agrada.isNotEmpty ? profile.agrada : agrada,
      puntFort: profile.puntFort.isNotEmpty ? profile.puntFort : puntFort,
      badge: profile.badge.isNotEmpty ? profile.badge : badge,
      experienciaAnos: profile.aniosExperiencia > 0 ? profile.aniosExperiencia : experienciaAnos,
      userId: profile.userId,
      photoUrl: profile.photoUrl,
    );
  }
}

const teamStories = <TeamStory>[
  TeamStory(
    slug: 'anna',
    nombre: 'Anna',
    color: 0xFF6E82A6,
    rol: "Mestra d'educació infantil · 8 anys en escola bressol",
    idiomas: ['Català', 'Castellà', 'Anglès', 'Francès'],
    experienciaAnos: 8,
    qui:
        "És mestra d'educació infantil i primària, amb experiència amb infants de 4 mesos a 12 anys. Des de petita li ha agradat passar temps amb els més menuts, i fa 8 anys que treballa en escola bressol. És una persona implicada, flexible i molt afectuosa, que s'adapta a les necessitats de cada nen i sap detectar quan necessiten una activitat o un moment de relax i mimos.",
    trayectoria:
        "Té experiència en escola bressol i ha fet classes d'anglès en una acadèmia. També acumula 4-5 anys com a cangur en famílies particulars, normalment vinculades a l'entorn escolar.",
    agrada:
        "És una persona molt musical i la música és el seu fil conductor. Gaudeix especialment de les activitats i manualitats d'experimentació i sensorials, i també d'explicar contes als infants.",
    puntFort: "La flexibilitat i l'afecte. Connecta amb els infants de manera ràpida i natural, adaptant-se sempre a cada situació.",
  ),
  TeamStory(
    slug: 'carla',
    nombre: 'Carla',
    color: 0xFFA98E7B,
    rol: 'Batxillerat social · futura Educació Social',
    idiomas: ['Català', 'Castellà', 'Portuguès'],
    experienciaAnos: 1,
    qui:
        "Acaba de finalitzar el batxillerat en la modalitat social i té previst estudiar Educació Social. Sempre li ha agradat estar amb els més petits i té molta facilitat per fer que tant ells com ella gaudeixin del temps junts. La seva prioritat és que els infants se sentin en un espai segur i de confiança.",
    trayectoria:
        "El darrer estiu va treballar en una llar d'infants amb nens i nenes d'entre 3 i 7 anys, acompanyant-los en les excursions, el dia a dia i les rutines. Una experiència que li va confirmar la seva vocació d'acompanyar els més petits.",
    agrada:
        "Les activitats on els infants tenen llibertat per pensar, imaginar i crear. El dibuix, el seu hobby preferit des de petita, és una de les activitats que més comparteix amb ells.",
    puntFort: 'Saber posar límits quan cal sense perdre mai la confiança ni el vincle. Aconsegueix que els infants se sentin còmodes i confiats.',
  ),
  TeamStory(
    slug: 'julia',
    nombre: 'Júlia Lima',
    color: 0xFF8CA598,
    badge: 'Fundadora',
    rol: 'Psicòloga i educadora · +4 anys amb infants a Andorra',
    idiomas: ['Català', 'Castellà', 'Anglès', 'Portuguès'],
    experienciaAnos: 4,
    qui:
        "Ha estudiat psicologia i és educadora de vocació. Porta més de quatre anys treballant amb infants a Andorra i és la persona que va crear Mon Cangur per donar resposta a una necessitat real: famílies sense xarxa de suport que necessiten algú de confiança. Connecta amb els nens des de la calma i la proximitat, és tranquil·la i molt atenta.",
    trayectoria:
        "Ha treballat més de 4 anys com a professora d'anglès per a infants petits, tant en acadèmies com en guarderies a Andorra. Ha gestionat grups d'infants de 0 a 12 anys en entorns educatius i de cura, amb famílies expatriades i locals.",
    agrada:
        "Li agrada molt cantar i posar música; creu que és una manera bonica d'ajudar a retenir coneixement i, alhora, de desconnectar i gaudir amb els nens. És una apassionada de les manualitats i li encanten els jocs lúdics.",
    puntFort:
        "La seva proactivitat i capacitat d'adaptació. La seva creativitat i la connexió amb els infants li permeten crear un entorn de confiança tant per als més petits com per a les seves famílies.",
  ),
  TeamStory(
    slug: 'noha',
    nombre: 'Noha',
    color: 0xFF9487B3,
    rol: 'Educadora infantil · 2 anys en escola bressol',
    idiomas: ['Català', 'Castellà', 'Anglès', 'Francès'],
    experienciaAnos: 2,
    qui:
        "És educadora infantil per passió, una professió que exerceix amb il·lusió cada dia. Li encanten els infants i gaudeix acompanyant-los en el seu creixement, respectant els seus ritmes i les seves emocions. És una persona propera, empàtica i creativa, que sap combinar el joc, l'aprenentatge i l'afecte en cada moment.",
    trayectoria:
        'Ha treballat durant dos anys en escoles bressol, on va posar en pràctica tot el que va aprendre durant la seva formació. També ha treballat com a cangur acompanyant els infants amb els deures i reforçant idiomes.',
    agrada:
        "Li encanta proposar activitats variades: des de l'experimentació sensorial i les manualitats fins a la psicomotricitat. Gaudeix especialment del ioga infantil, que combina amb contes i música, i també d'organitzar sortides a l'aire lliure.",
    puntFort:
        "La versatilitat i l'empatia. Sap llegir les necessitats de cada infant i oferir-li allò que més li convé en cada moment, connectant amb ells de manera ràpida i autèntica.",
  ),
  TeamStory(
    slug: 'paula',
    nombre: 'Paula',
    color: 0xFFC08457,
    rol: 'Fisioterapeuta i professora de ioga · +15 anys amb infants',
    idiomas: ['Castellà', 'Anglès', 'Francès', 'Català'],
    experienciaAnos: 15,
    qui:
        "És fisioterapeuta i professora de ioga i Pilates, amb una llarga trajectòria acompanyant infants. Li agrada molt estar amb els nens perquè gaudeix jugant amb ells i ajudant-los a descobrir i desenvolupar les seves habilitats. És responsable, afectuosa, dinàmica i pacient, i sap crear un ambient de confiança i seguretat.",
    trayectoria:
        "Fa més de 15 anys que treballa amb infants, principalment com a instructora d'esquí en clubs i escoles d'esquí, acompanyant nens de diferents edats. També té formació i experiència com a fisioterapeuta i professora de ioga i Pilates.",
    agrada:
        "Les activitats a l'aire lliure, el joc de moviment i la psicomotricitat, així com dibuixar, fer manualitats i escoltar música. Adapta sempre les propostes a l'edat i als interessos de cada infant.",
    puntFort:
        "La capacitat d'adaptar-se a cada infant i crear un vincle de confiança. La seva formació com a fisioterapeuta i professora de ioga li aporta eines valuoses per entendre i acompanyar el desenvolupament i el benestar dels nens.",
  ),
];

const _demoIds = {'laia', 'marc', 'anna'};

String foldName(String value) {
  const from = 'àáäâèéëêìíïîòóöôùúüûñç';
  const to = 'aaaaeeeeiiiioooouuuunc';
  final buffer = StringBuffer();
  for (final char in value.toLowerCase().trim().split('')) {
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

bool samePerson(String remoteName, TeamStory story) {
  final remote = foldName(remoteName);
  final full = foldName(story.nombre);
  if (remote.isEmpty) return false;
  if (remote == full) return true;
  return remote.split(' ').first == full.split(' ').first;
}

TeamStory? storyFor(CangurProfile profile) {
  if (_demoIds.contains(profile.userId)) return null;
  for (final story in teamStories) {
    if (profile.slug == story.slug || samePerson(profile.nombre, story)) return story;
  }
  return null;
}

List<TeamStory> showcaseTeam(List<CangurProfile> remote) {
  final used = <String>{};
  final people = <TeamStory>[];
  for (final story in teamStories) {
    CangurProfile? match;
    for (final profile in remote) {
      if (_demoIds.contains(profile.userId)) continue;
      final linked = storyFor(profile);
      if (linked?.slug == story.slug) {
        match = profile;
        break;
      }
    }
    if (match != null) used.add(match.userId);
    people.add(match == null ? story : story.link(match));
  }
  const extras = [0xFF6E82A6, 0xFFA98E7B, 0xFF8CA598, 0xFF9487B3, 0xFFC08457];
  var index = 0;
  for (final profile in remote) {
    if (used.contains(profile.userId) || _demoIds.contains(profile.userId)) continue;
    people.add(
      TeamStory(
        slug: profile.slug.isNotEmpty ? profile.slug : profile.userId,
        nombre: profile.nombre,
        color: profile.color == 0xFF8CA598 && profile.qui.isEmpty ? extras[index % extras.length] : profile.color,
        rol: profile.rol,
        idiomas: profile.idiomas,
        qui: profile.qui.isNotEmpty ? profile.qui : profile.descripcionPersonal,
        trayectoria: profile.trayectoria,
        agrada: profile.agrada,
        puntFort: profile.puntFort,
        badge: profile.badge,
        experienciaAnos: profile.aniosExperiencia,
        userId: profile.userId,
        photoUrl: profile.photoUrl,
      ),
    );
    index++;
  }
  return people;
}

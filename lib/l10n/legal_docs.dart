import '../models/models.dart';

part 'legal_es.dart';
part 'legal_en.dart';
part 'legal_fr.dart';

enum LegalSection { terms, privacy, cancel }

class LegalDoc {
  const LegalDoc({required this.title, required this.updated, required this.blocks, this.footer});

  final String title;
  final String updated;
  final List<LegalBlock> blocks;
  final String? footer;
}

class LegalBlock {
  const LegalBlock.heading(this.text, {this.small = false}) : kind = 'h', items = const [], rows = const [];
  const LegalBlock.paragraph(this.text) : kind = 'p', small = false, items = const [], rows = const [];
  const LegalBlock.list(this.items) : kind = 'l', text = '', small = false, rows = const [];
  const LegalBlock.facts(this.rows) : kind = 'f', text = '', small = false, items = const [];

  final String kind;
  final String text;
  final bool small;
  final List<String> items;
  final List<(String, String)> rows;
}

LegalDoc legalDocument(LegalSection section, [AppLang lang = AppLang.ca]) {
  switch (lang) {
    case AppLang.es:
      return legalEs(section);
    case AppLang.en:
      return legalEn(section);
    case AppLang.fr:
      return legalFr(section);
    case AppLang.ca:
      return _catalan(section);
  }
}

LegalDoc _catalan(LegalSection section) {
  switch (section) {
    case LegalSection.terms:
      return _terms;
    case LegalSection.privacy:
      return _privacy;
    case LegalSection.cancel:
      return _cancel;
  }
}

const _terms = LegalDoc(
  title: "Termes i condicions d'ús",
  updated: 'Mon Cangur · moncangur.ad i aplicació mòbil',
  blocks: [
    LegalBlock.heading('1. Condicions generals d\'ús'),
    LegalBlock.paragraph(
      "Aquestes Condicions s'apliquen al lloc web de Mon Cangur (moncangur.ad) i a l'aplicació mòbil associada (la Plataforma). L'accés i l'ús de la Plataforma, el registre d'un compte i/o la contractació de serveis impliquen l'acceptació d'aquestes Condicions, la Política de Privacitat i la Política de Cookies. Mon Cangur es reserva el dret de modificar aquestes Condicions; la versió vigent serà la publicada a la Plataforma.",
    ),
    LegalBlock.heading('2. Informació legal i dades del titular'),
    LegalBlock.facts([
      ('Titular', 'Lima Terra, Júlia'),
      ('Nom comercial', 'Mon Cangur'),
      ('NRT', 'F-370532-N'),
      ('Domicili', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('Correu', 'infomoncangur@gmail.com'),
      ('Telèfon', '+376 620 991'),
    ]),
    LegalBlock.heading('3. Definicions'),
    LegalBlock.list([
      '**Plataforma:** el web moncangur.ad i l\'app de Mon Cangur.',
      '**Usuari:** tota persona que accedeixi o utilitzi la Plataforma.',
      '**Client:** l\'Usuari que sol·licita o contracta un servei.',
      '**Cangur:** personal cuidador empleat per Mon Cangur amb accés a la Plataforma.',
      '**Servei:** el servei de cura infantil a domicili prestat per Mon Cangur.',
      '**Reserva:** sol·licitud confirmada d\'un Servei formalitzada a la Plataforma.',
    ]),
    LegalBlock.heading('4. Objecte'),
    LegalBlock.paragraph(
      'Mon Cangur presta i gestiona serveis de cura infantil a domicili a través de la Plataforma. Ofereix diferents modalitats: servei ocasional, servei per a esdeveniments, servei de reforç i acompanyament pedagògic, servei fix i servei d\'emergència. En els serveis ocasional, esdeveniments i reforç, la família selecciona el cangur segons la disponibilitat; en els serveis fix i d\'emergència, l\'assignació la fa Mon Cangur. Els serveis són prestats per Mon Cangur, no per tercers: no actua com a intermediari.',
    ),
    LegalBlock.heading('5. Accés, registre i compte'),
    LegalBlock.paragraph(
      "Per registrar-se cal ser major d'edat, omplir de manera veraç les dades obligatòries (nom, cognoms, correu i telèfon) i acceptar aquestes Condicions. L'accés es fa amb correu i contrasenya, personals i intransferibles. Mon Cangur pot suspendre o cancel·lar el compte en cas d'ús fraudulent, incompliment o informació falsa.",
    ),
    LegalBlock.heading('Perfil del Client i dels fills', small: true),
    LegalBlock.paragraph(
      "El Client ha de completar la informació necessària per al servei. No es poden fer reserves sense completar la informació obligatòria (inclosos els perfils dels fills). El Client pot modificar o eliminar el seu compte, sens perjudici de la conservació de dades per obligacions legals o contractuals.",
    ),
    LegalBlock.heading('6. Funcionament i contractació'),
    LegalBlock.paragraph(
      "El Client sol·licita el servei indicant tipus, data, franja horària i adreça. En ocasional, esdeveniments i reforç, filtra per dia i hora, tria cangur, confirma i paga. En fix, omple un formulari de necessitats i Mon Cangur proposa el cangur; en emergència, activa una notificació i Mon Cangur el contacta.",
    ),
    LegalBlock.heading('Durada, control horari i pagament', small: true),
    LegalBlock.paragraph(
      "Els serveis es contracten per blocs. El cangur registra l'hora de finalització; si s'excedeix l'horari, l'import s'ajusta. En esdeveniments amb més de 4 nens cal una segona cuidadora. El pagament es fa en el moment de la reserva via TPV; en el servei fix es pot habilitar domiciliació mensual.",
    ),
    LegalBlock.heading('Cancel·lacions i incidències', small: true),
    LegalBlock.paragraph(
      "Les cancel·lacions es regeixen per la Política de Cancel·lació. Els canvis d'hora o adreça requereixen anul·lar i tornar a reservar o contactar amb Atenció al Client. Si un cangur no pot prestar el servei, Mon Cangur proposa alternatives o reemborsa. Si el cangur arriba amb més de 30 min de retard per causa de Mon Cangur, el Client pot demanar un voucher de descompte.",
    ),
    LegalBlock.heading('Comunicacions i protecció de menors', small: true),
    LegalBlock.paragraph(
      "El contacte entre Client i cangur s'ha de fer a través de la Plataforma. Queda prohibida l'administració de medicació pel cangur i la difusió de continguts de menors fora de la Plataforma. El Client ha d'informar d'al·lèrgies, restriccions i necessitats especials. El Client configura l'ús d'imatges del menor (ús corporatiu sense mostrar la cara, només intercanvi pel xat, o cap imatge).",
    ),
    LegalBlock.heading('7. Reclamacions i incidències'),
    LegalBlock.paragraph(
      "Les reclamacions es presenten per escrit pels canals oficials (correu o WhatsApp d'empresa), amb data i franja del servei, adreça, nom del cangur, descripció dels fets i evidències si escau. En cas de no compareixença, s'ha de notificar dins de les 24 h. Mon Cangur respon en un màxim de 10 dies hàbils.",
    ),
    LegalBlock.heading('8. Tarifes, pagament i promocions'),
    LegalBlock.paragraph(
      "L'ús de la Plataforma és gratuït; la contractació implica el pagament de les tarifes, que es mostren abans de confirmar. Els reemborsaments es fan conforme a la Política de Cancel·lació, pel mateix mètode de pagament. Mon Cangur pot oferir codis promocionals i vouchers, personals i intransferibles.",
    ),
    LegalBlock.heading('9. Comunicacions i feedback'),
    LegalBlock.paragraph(
      'La Plataforma incorpora missatgeria interna entre Client i cangur, que no es pot fer servir per a spam ni continguts il·lícits. El Client pot deixar feedback després del servei, subjecte a revisió prèvia per Mon Cangur.',
    ),
    LegalBlock.heading("10. Baixa de l'Usuari"),
    LegalBlock.paragraph(
      "L'Usuari pot donar-se de baixa des de la Plataforma o sol·licitant-ho a infomoncangur@gmail.com o via WhatsApp d'empresa. La baixa no eximeix d'obligacions pendents.",
    ),
    LegalBlock.heading("11. Obligacions de l'Usuari"),
    LegalBlock.paragraph(
      "L'Usuari és responsable de l'ús adequat del compte i les seves credencials. Ha de facilitar informació veraç, completar els perfils dels fills, mantenir una comunicació respectuosa, no eludir la Plataforma i romandre localitzable durant el servei. El cangur ha d'utilitzar la Plataforma només per a finalitats professionals, mantenir la disponibilitat actualitzada, no consumir substàncies que afectin el servei i respectar les normes de protecció de menors.",
    ),
    LegalBlock.heading('12–14. Responsabilitat i estàndards'),
    LegalBlock.paragraph(
      "Mon Cangur fa esforços raonables per mantenir la Plataforma operativa, sense garantir un accés ininterromput. No és responsable d'incidències derivades d'informació falsa del Client, manca d'accés al servei, força major o acords fets fora de la Plataforma. Disposa d'una pòlissa d'assegurança de responsabilitat civil i d'un procés de selecció de cangurs basat en experiència, idoneïtat i formació (prioritzant primers auxilis).",
    ),
    LegalBlock.heading('15. Impostos i facturació'),
    LegalBlock.paragraph(
      "La facturació i les obligacions fiscals les gestiona Mon Cangur segons la normativa andorrana. Els preus s'expressen en euros i inclouen l'IGI aplicable. Mon Cangur emet factura o justificant quan el Client ho sol·licita.",
    ),
    LegalBlock.heading('16. Desistiment i fulls de reclamació'),
    LegalBlock.paragraph(
      "Atesa la naturalesa dels serveis (data i hora concretes), el dret de desistiment pot quedar limitat, aplicant-se la Política de Cancel·lació. Mon Cangur posa a disposició fulls oficials de reclamació, sol·licitables per escrit a infomoncangur@gmail.com.",
    ),
    LegalBlock.heading('17–22. Força major, propietat i jurisdicció'),
    LegalBlock.paragraph(
      "Cap part és responsable per força major. Mon Cangur és titular dels drets de propietat intel·lectual i industrial de la Plataforma i la marca. En cas de discrepància entre versions d'idioma, preval la versió en català. Aquestes Condicions es regeixen per la legislació del Principat d'Andorra.",
    ),
  ],
);

const _privacy = LegalDoc(
  title: 'Política de privacitat i protecció de dades',
  updated: 'Darrera actualització: 08/03/2026',
  blocks: [
    LegalBlock.heading('1. Responsable del tractament'),
    LegalBlock.facts([
      ('Responsable', 'Lima Terra, Júlia (Mon Cangur)'),
      ('NRT', 'F-370532-N'),
      ('Domicili', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('Correu', 'infomoncangur@gmail.com'),
      ('Telèfon / WhatsApp', '+376 620 991'),
    ]),
    LegalBlock.paragraph(
      'Mon Cangur tracta les dades personals dels usuaris del web i de l\'app per gestionar comptes, reserves i la prestació de serveis de cura infantil a domicili.',
    ),
    LegalBlock.heading('2. Normativa aplicable'),
    LegalBlock.paragraph(
      "S'aplica la normativa de protecció de dades vigent a Andorra, en particular la Llei 29/2021, qualificada de protecció de dades personals. Quan correspongui, es poden aplicar estàndards equivalents (per exemple, el RGPD de la UE).",
    ),
    LegalBlock.heading('3. Quines dades tractem'),
    LegalBlock.heading('Dades del Client', small: true),
    LegalBlock.paragraph(
      "Obligatòries: nom i cognoms, correu, telèfon, contrasenya i adreça principal. En reserves: adreça del servei, data, franja, tipus de servei i observacions. Opcional: foto de perfil i preferències. El canvi de correu pot requerir gestió manual i verificació d'identitat.",
    ),
    LegalBlock.heading('Dades dels fills / menors', small: true),
    LegalBlock.paragraph(
      "Aportades pel Client com a tutor legal. Obligatòries: nom complet, gènere, data de naixement, al·lèrgies i restriccions, i responsable secundari d'emergència (nom, parentiu, telèfon). Opcionals: necessitats especials, idiomes, observacions i foto. Poden incloure informació sensible (al·lèrgies, necessitats especials), tractada per a la seguretat i correcta prestació del servei.",
    ),
    LegalBlock.heading('Dades del cangur', small: true),
    LegalBlock.paragraph(
      'Dades identificatives i de contacte professionals, foto de perfil professional, disponibilitat i registres operatius. La documentació laboral es gestiona com a part de processos interns, no com a informació pública per als clients.',
    ),
    LegalBlock.heading('Comunicacions i suport', small: true),
    LegalBlock.paragraph(
      'Missatges del xat intern, sol·licituds a Atenció al Client i registres tècnics (logs) necessaris per a seguretat i funcionament.',
    ),
    LegalBlock.heading('4. Finalitats i base legal'),
    LegalBlock.list([
      'Crear i gestionar el compte — execució del contracte.',
      'Gestionar reserves i prestar el servei — execució del contracte.',
      'Seguretat i protecció del menor — contracte i interès legítim; dades sensibles amb consentiment del tutor quan escaigui.',
      'Facturació i obligacions legals — obligació legal / interès legítim.',
      'Comunicacions operatives — execució del contracte.',
      'Comunicacions comercials — només amb consentiment, revocable.',
    ]),
    LegalBlock.heading('5. Imatges i vídeos de menors'),
    LegalBlock.paragraph(
      'El Client tria una opció: **A)** ús corporatiu/publicitari sense mostrar la cara ni elements identificatius (revocable); **B)** només intercanvi pel xat intern amb els pares; **C)** prohibició total. Mon Cangur aplica aquesta preferència com a configuració de privacitat.',
    ),
    LegalBlock.heading('6. Amb qui compartim dades'),
    LegalBlock.paragraph(
      "Mon Cangur no ven dades. Les comparteix només quan cal: amb el cangur assignat (dades necessàries per al servei), amb proveïdors tecnològics (encarregats del tractament), amb el proveïdor de pagament (Redsys, per TPV), pels canals externs escollits per l'usuari (WhatsApp) i amb autoritats públiques quan hi hagi obligació legal.",
    ),
    LegalBlock.heading('7. Conservació'),
    LegalBlock.paragraph(
      "Les dades es conserven mentre el compte estigui actiu i, després, durant els terminis necessaris per a compliment legal i defensa davant reclamacions. Les comunicacions es poden conservar un termini raonable per a incidències i auditoria.",
    ),
    LegalBlock.heading("8. Drets de l'usuari"),
    LegalBlock.paragraph(
      "L'usuari pot exercir els drets d'accés, rectificació, supressió, oposició, limitació i portabilitat escrivint a infomoncangur@gmail.com. Mon Cangur pot demanar informació per verificar la identitat. Es pot reclamar davant l'autoritat de control competent a Andorra.",
    ),
    LegalBlock.heading('9–11. Seguretat, cookies i canvis'),
    LegalBlock.paragraph(
      'Mon Cangur aplica mesures tècniques i organitzatives raonables per protegir les dades, especialment les dels menors. El web pot usar cookies tècniques i analítiques (vegeu la Política de Cookies). Aquesta Política es pot actualitzar; la versió vigent estarà publicada a la Plataforma.',
    ),
  ],
);

const _cancel = LegalDoc(
  title: 'Política de cancel·lació',
  updated: 'Forma part integrant dels Termes i Condicions',
  footer: 'Document en revisió. Les condicions definitives es confirmaran d\'acord amb la normativa aplicable al Principat d\'Andorra.',
  blocks: [
    LegalBlock.heading('1. Disposicions generals'),
    LegalBlock.paragraph(
      "Aquesta Política regula les cancel·lacions, els canvis i les incidències de les reserves fetes a través de la Plataforma. Qualsevol cancel·lació o canvi s'ha de comunicar per escrit a través dels canals oficials (correu infomoncangur@gmail.com o WhatsApp d'empresa +376 620 991), identificant la reserva (família, data i horari).",
    ),
    LegalBlock.paragraph('Amb caràcter general, a tots els serveis s\'apliquen els criteris següents:'),
    LegalBlock.list([
      '**Força major** (desastres naturals, incidències greus de serveis bàsics o similars): la Família podrà escollir entre reprogramar el servei, subjecte a disponibilitat, o sol·licitar el reemborsament de les hores corresponents.',
      '**Retard o absència de la professional** per causa imputable a Mon Cangur (retard superior a 30 minuts o absència): Mon Cangur oferirà una professional substituta, la reprogramació o el reemborsament de la sessió afectada.',
      "**No presentació o impediment d'accés per part de la Família** (absència al domicili, manca d'accés o impossibilitat de contacte): el servei es cobrarà íntegrament i no donarà dret a reemborsament.",
    ]),
    LegalBlock.heading('2. Serveis puntuals'),
    LegalBlock.paragraph(
      "Per als serveis Ocasional, d'Esdeveniments i d'Urgència, que es paguen per avançat en el moment de la reserva, la cancel·lació dona dret a reemborsament en funció de l'antelació. En aquests serveis no cal reprogramar: la Família pot fer una nova reserva quan ho necessiti.",
    ),
    LegalBlock.heading('2.1. Servei Ocasional', small: true),
    LegalBlock.list([
      'Amb **24 hores o més** d\'antelació: reemborsament complet.',
      'Amb **menys de 24 hores** d\'antelació: es cobrarà el servei, sense reemborsament.',
    ]),
    LegalBlock.heading("2.2. Servei d'Esdeveniments", small: true),
    LegalBlock.paragraph("Atès que requereix més planificació i, sovint, més d'una professional:"),
    LegalBlock.list([
      'Amb **7 dies o més** d\'antelació: reemborsament complet.',
      'Entre **3 i 7 dies** d\'antelació: reemborsament del 50%.',
      'Amb **menys de 72 hores** d\'antelació: es cobrarà el servei, sense reemborsament.',
    ]),
    LegalBlock.heading("2.3. Servei d'Urgència", small: true),
    LegalBlock.paragraph("Pel seu caràcter immediat, s'aplica segons l'estat de la reserva:"),
    LegalBlock.list([
      '**Abans** que Mon Cangur confirmi la sol·licitud i assigni la professional: reemborsament complet.',
      'Un cop **confirmada i assignada** la professional: es cobrarà el servei, llevat de força major o causa imputable a Mon Cangur.',
    ]),
    LegalBlock.heading('3. Serveis continuats (Fix i Repàs)'),
    LegalBlock.paragraph('Per als serveis Fix i de Repàs, de caràcter recurrent, s\'apliquen les condicions següents.'),
    LegalBlock.heading('3.1. Comunicació', small: true),
    LegalBlock.paragraph(
      "Qualsevol cancel·lació o canvi del servei s'haurà de comunicar per escrit mitjançant un dels canals oficials (correu infomoncangur@gmail.com o WhatsApp d'empresa +376 620 991), identificant el servei (família, dia i horari).",
    ),
    LegalBlock.heading('3.2. Criteri en cas de cancel·lació', small: true),
    LegalBlock.list([
      '**a)** Amb 24 hores o més d\'antelació: la sessió es cobrarà igualment. La Família tindrà l\'opció de remarcar-la en una altra data, subjecte a disponibilitat.',
      '**b)** Amb menys de 24 hores d\'antelació: la sessió es cobrarà igualment i, en principi, no es podrà remarcar.',
      '**c)** Força major: la Família podrà escollir entre remarcar la sessió, subjecte a disponibilitat, o sol·licitar el reemborsament de la sessió o hores corresponents.',
    ]),
    LegalBlock.heading('3.3. Condicions per remarcar', small: true),
    LegalBlock.paragraph(
      "Les sessions a remarcar s'hauran de programar dins de 4 setmanes des de la data original, subjecte a disponibilitat i confirmació per escrit. Si no es troba data, la sessió es considerarà realitzada a efectes de cobrament (excepte força major amb reemborsament escollit).",
    ),
    LegalBlock.heading("3.4. No presentació o impediment d'accés per part de la Família", small: true),
    LegalBlock.paragraph(
      'Si el servei no es pot iniciar o prestar per causes imputables a la Família, la sessió es cobrarà igualment i es podrà remarcar subjecte a disponibilitat.',
    ),
    LegalBlock.heading('3.5. Retard o absència de la professional', small: true),
    LegalBlock.list([
      '**a)** Retard superior a 30 minuts per causes imputables a Mon Cangur: la Família podrà escollir entre remarcar la sessió o sol·licitar el reemborsament de la sessió afectada.',
      "**b)** Absència: Mon Cangur oferirà substitució per una altra professional de l'equip, remarcar la sessió, o el reemborsament de la sessió afectada.",
    ]),
    LegalBlock.heading('4. Reemborsaments'),
    LegalBlock.paragraph(
      'Els reemborsaments que corresponguin es faran, per norma general, pel mateix mètode de pagament utilitzat, conforme a aquesta Política i als Termes i Condicions.',
    ),
  ],
);

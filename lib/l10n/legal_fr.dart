part of 'legal_docs.dart';

LegalDoc legalFr(LegalSection section) {
  switch (section) {
    case LegalSection.terms:
      return _termsFr;
    case LegalSection.privacy:
      return _privacyFr;
    case LegalSection.cancel:
      return _cancelFr;
  }
}

const _termsFr = LegalDoc(
  title: "Conditions générales d'utilisation",
  updated: "Mon Cangur · moncangur.ad et l'application mobile",
  blocks: [
    LegalBlock.heading("1. Conditions générales d'utilisation"),
    LegalBlock.paragraph(
      "Les présentes Conditions s'appliquent au site web de Mon Cangur (moncangur.ad) et à l'application mobile associée (la Plateforme). L'accès et l'utilisation de la Plateforme, la création d'un compte et/ou la réservation de services impliquent l'acceptation des présentes Conditions, de la Politique de confidentialité et de la Politique de cookies. Mon Cangur se réserve le droit de modifier ces Conditions ; la version en vigueur est celle publiée sur la Plateforme.",
    ),
    LegalBlock.heading('2. Informations légales et données du titulaire'),
    LegalBlock.facts([
      ('Titulaire', 'Lima Terra, Júlia'),
      ('Nom commercial', 'Mon Cangur'),
      ('NRT', 'F-370532-N'),
      ('Adresse', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('E-mail', 'infomoncangur@gmail.com'),
      ('Téléphone', '+376 620 991'),
    ]),
    LegalBlock.heading('3. Définitions'),
    LegalBlock.list([
      '**Plateforme :** le site moncangur.ad et l\'application Mon Cangur.',
      '**Utilisateur :** toute personne qui accède à la Plateforme ou l\'utilise.',
      '**Client :** l\'Utilisateur qui demande ou réserve un service.',
      '**Cangur :** personnel de garde employé par Mon Cangur et ayant accès à la Plateforme.',
      '**Service :** le service de garde d\'enfants à domicile fourni par Mon Cangur.',
      '**Réservation :** demande confirmée d\'un Service formalisée sur la Plateforme.',
    ]),
    LegalBlock.heading('4. Objet'),
    LegalBlock.paragraph(
      "Mon Cangur fournit et gère des services de garde d'enfants à domicile par l'intermédiaire de la Plateforme. Plusieurs formules sont proposées : service occasionnel, service pour événements, soutien scolaire et accompagnement pédagogique, service régulier et service d'urgence. Pour les services occasionnel, événements et soutien, la famille choisit le cangur selon les disponibilités ; pour les services régulier et d'urgence, l'affectation est faite par Mon Cangur. Les services sont fournis par Mon Cangur, et non par des tiers : Mon Cangur n'agit pas comme intermédiaire.",
    ),
    LegalBlock.heading('5. Accès, inscription et compte'),
    LegalBlock.paragraph(
      "Pour s'inscrire, il faut être majeur, renseigner de façon exacte les données obligatoires (nom, prénom, e-mail et téléphone) et accepter les présentes Conditions. L'accès se fait par e-mail et mot de passe, personnels et incessibles. Mon Cangur peut suspendre ou clôturer le compte en cas d'usage frauduleux, de manquement ou d'informations fausses.",
    ),
    LegalBlock.heading('Profil du Client et des enfants', small: true),
    LegalBlock.paragraph(
      "Le Client doit compléter les informations nécessaires au service. Aucune réservation n'est possible tant que les informations obligatoires ne sont pas complètes, y compris les profils des enfants. Le Client peut modifier ou supprimer son compte, sans préjudice de la conservation des données imposée par des obligations légales ou contractuelles.",
    ),
    LegalBlock.heading('6. Fonctionnement et réservation'),
    LegalBlock.paragraph(
      "Le Client demande le service en indiquant le type, la date, le créneau horaire et l'adresse. Pour l'occasionnel, les événements et le soutien, il filtre par jour et par heure, choisit un cangur, confirme et paie. Pour le service régulier, il remplit un formulaire de besoins et Mon Cangur propose le cangur ; pour l'urgence, une notification est envoyée et Mon Cangur prend contact.",
    ),
    LegalBlock.heading('Durée, contrôle des horaires et paiement', small: true),
    LegalBlock.paragraph(
      "Les services sont réservés par blocs. Le cangur enregistre l'heure de fin ; si l'horaire prévu est dépassé, le montant est ajusté. Les événements de plus de 4 enfants nécessitent une deuxième professionnelle. Le paiement est effectué au moment de la réservation via le TPV ; pour le service régulier, un prélèvement mensuel peut être mis en place.",
    ),
    LegalBlock.heading('Annulations et incidents', small: true),
    LegalBlock.paragraph(
      "Les annulations sont régies par la Politique d'annulation. Un changement d'heure ou d'adresse exige d'annuler puis de réserver à nouveau, ou de contacter le Service client. Si un cangur ne peut pas assurer le service, Mon Cangur propose des solutions de remplacement ou un remboursement. Si le cangur arrive avec plus de 30 minutes de retard pour une cause imputable à Mon Cangur, le Client peut demander un bon de réduction.",
    ),
    LegalBlock.heading('Communications et protection des mineurs', small: true),
    LegalBlock.paragraph(
      "Le contact entre le Client et le cangur doit passer par la Plateforme. L'administration de médicaments par le cangur est interdite, de même que la diffusion de contenus concernant des mineurs en dehors de la Plateforme. Le Client doit signaler les allergies, restrictions et besoins particuliers. Le Client choisit l'usage des images du mineur : usage institutionnel sans montrer le visage, échange uniquement dans le chat, ou aucune image.",
    ),
    LegalBlock.heading('7. Réclamations et incidents'),
    LegalBlock.paragraph(
      "Les réclamations sont présentées par écrit via les canaux officiels (e-mail ou WhatsApp de l'entreprise), avec la date et le créneau du service, l'adresse, le nom du cangur, la description des faits et, le cas échéant, des preuves. En cas d'absence, il faut le signaler dans les 24 heures. Mon Cangur répond dans un délai maximum de 10 jours ouvrables.",
    ),
    LegalBlock.heading('8. Tarifs, paiement et promotions'),
    LegalBlock.paragraph(
      "L'utilisation de la Plateforme est gratuite ; la réservation implique le paiement des tarifs, affichés avant la confirmation. Les remboursements sont effectués conformément à la Politique d'annulation, par le même moyen de paiement. Mon Cangur peut proposer des codes promotionnels et des bons, personnels et incessibles.",
    ),
    LegalBlock.heading('9. Communications et avis'),
    LegalBlock.paragraph(
      "La Plateforme comprend une messagerie interne entre le Client et le cangur, qui ne peut pas servir au spam ni à des contenus illicites. Le Client peut laisser un avis après le service, sous réserve d'un examen préalable par Mon Cangur.",
    ),
    LegalBlock.heading("10. Clôture du compte de l'Utilisateur"),
    LegalBlock.paragraph(
      "L'Utilisateur peut clôturer son compte depuis la Plateforme ou en le demandant à infomoncangur@gmail.com ou via le WhatsApp de l'entreprise. La clôture ne dispense pas des obligations en cours.",
    ),
    LegalBlock.heading("11. Obligations de l'Utilisateur"),
    LegalBlock.paragraph(
      "L'Utilisateur est responsable de l'usage correct du compte et de ses identifiants. Il doit fournir des informations exactes, compléter les profils des enfants, communiquer de façon respectueuse, ne pas contourner la Plateforme et rester joignable pendant le service. Le cangur doit utiliser la Plateforme uniquement à des fins professionnelles, tenir sa disponibilité à jour, ne pas consommer de substances qui nuisent au service et respecter les règles de protection des mineurs.",
    ),
    LegalBlock.heading('12–14. Responsabilité et exigences'),
    LegalBlock.paragraph(
      "Mon Cangur fait des efforts raisonnables pour maintenir la Plateforme en fonctionnement, sans garantir un accès ininterrompu. Elle n'est pas responsable des incidents liés à des informations fausses du Client, à l'impossibilité d'accéder au service, à un cas de force majeure ou à des accords conclus en dehors de la Plateforme. Elle dispose d'une assurance de responsabilité civile et d'un processus de sélection des cangurs fondé sur l'expérience, l'aptitude et la formation, en privilégiant les premiers secours.",
    ),
    LegalBlock.heading('15. Impôts et facturation'),
    LegalBlock.paragraph(
      "La facturation et les obligations fiscales sont gérées par Mon Cangur selon la réglementation andorrane. Les prix sont exprimés en euros et incluent l'IGI applicable. Mon Cangur émet une facture ou un justificatif lorsque le Client le demande.",
    ),
    LegalBlock.heading('16. Rétractation et formulaires de réclamation'),
    LegalBlock.paragraph(
      "Compte tenu de la nature des services (date et heure précises), le droit de rétractation peut être limité et la Politique d'annulation s'applique. Mon Cangur met à disposition des formulaires officiels de réclamation, que l'on peut demander par écrit à infomoncangur@gmail.com.",
    ),
    LegalBlock.heading('17–22. Force majeure, propriété et juridiction'),
    LegalBlock.paragraph(
      "Aucune partie n'est responsable en cas de force majeure. Mon Cangur est titulaire des droits de propriété intellectuelle et industrielle sur la Plateforme et la marque. En cas de divergence entre les versions linguistiques, la version catalane prévaut. Les présentes Conditions sont régies par la législation de la Principauté d'Andorre.",
    ),
  ],
);

const _privacyFr = LegalDoc(
  title: 'Politique de confidentialité et de protection des données',
  updated: 'Dernière mise à jour : 08/03/2026',
  blocks: [
    LegalBlock.heading('1. Responsable du traitement'),
    LegalBlock.facts([
      ('Responsable', 'Lima Terra, Júlia (Mon Cangur)'),
      ('NRT', 'F-370532-N'),
      ('Adresse', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('E-mail', 'infomoncangur@gmail.com'),
      ('Téléphone / WhatsApp', '+376 620 991'),
    ]),
    LegalBlock.paragraph(
      "Mon Cangur traite les données personnelles des utilisateurs du site et de l'application afin de gérer les comptes, les réservations et la fourniture de services de garde d'enfants à domicile.",
    ),
    LegalBlock.heading('2. Réglementation applicable'),
    LegalBlock.paragraph(
      "La réglementation de protection des données en vigueur en Andorre s'applique, en particulier la Loi qualifiée 29/2021 relative à la protection des données personnelles. Le cas échéant, des standards équivalents peuvent s'appliquer, par exemple le RGPD de l'UE.",
    ),
    LegalBlock.heading('3. Quelles données nous traitons'),
    LegalBlock.heading('Données du Client', small: true),
    LegalBlock.paragraph(
      "Obligatoires : nom et prénom, e-mail, téléphone, mot de passe et adresse principale. Pour les réservations : adresse du service, date, créneau, type de service et observations. Facultatifs : photo de profil et préférences. Le changement d'e-mail peut nécessiter un traitement manuel et une vérification d'identité.",
    ),
    LegalBlock.heading('Données des enfants / mineurs', small: true),
    LegalBlock.paragraph(
      "Fournies par le Client en tant que tuteur légal. Obligatoires : nom complet, genre, date de naissance, allergies et restrictions, et responsable secondaire en cas d'urgence (nom, lien de parenté, téléphone). Facultatifs : besoins particuliers, langues, observations et photo. Elles peuvent comprendre des informations sensibles (allergies, besoins particuliers), traitées pour la sécurité et la bonne exécution du service.",
    ),
    LegalBlock.heading('Données du cangur', small: true),
    LegalBlock.paragraph(
      "Données d'identité et de contact professionnelles, photo de profil professionnelle, disponibilités et registres opérationnels. Les documents liés à l'emploi sont gérés dans le cadre de processus internes, et non comme une information publique destinée aux clients.",
    ),
    LegalBlock.heading('Communications et assistance', small: true),
    LegalBlock.paragraph(
      'Messages du chat interne, demandes au Service client et journaux techniques nécessaires à la sécurité et au fonctionnement.',
    ),
    LegalBlock.heading('4. Finalités et base juridique'),
    LegalBlock.list([
      'Créer et gérer le compte — exécution du contrat.',
      'Gérer les réservations et fournir le service — exécution du contrat.',
      "Sécurité et protection du mineur — contrat et intérêt légitime ; données sensibles avec le consentement du tuteur lorsque c'est requis.",
      'Facturation et obligations légales — obligation légale / intérêt légitime.',
      'Communications opérationnelles — exécution du contrat.',
      'Communications commerciales — uniquement avec consentement, révocable.',
    ]),
    LegalBlock.heading('5. Images et vidéos de mineurs'),
    LegalBlock.paragraph(
      "Le Client choisit une option : **A)** usage institutionnel ou publicitaire sans montrer le visage ni d'éléments identificatoires (révocable) ; **B)** échange uniquement dans le chat interne avec les parents ; **C)** interdiction totale. Mon Cangur applique ce choix comme paramètre de confidentialité.",
    ),
    LegalBlock.heading('6. Avec qui nous partageons les données'),
    LegalBlock.paragraph(
      "Mon Cangur ne vend pas de données. Elle ne les partage que lorsque c'est nécessaire : avec le cangur assigné (données utiles au service), avec des prestataires technologiques (sous-traitants), avec le prestataire de paiement (Redsys, pour le TPV), via les canaux externes choisis par l'utilisateur (WhatsApp) et avec les autorités publiques lorsqu'une obligation légale l'impose.",
    ),
    LegalBlock.heading('7. Conservation'),
    LegalBlock.paragraph(
      "Les données sont conservées tant que le compte est actif puis, ensuite, pendant les délais nécessaires au respect des obligations légales et à la défense en cas de réclamation. Les communications peuvent être conservées pendant un délai raisonnable pour les incidents et l'audit.",
    ),
    LegalBlock.heading("8. Droits de l'utilisateur"),
    LegalBlock.paragraph(
      "L'utilisateur peut exercer les droits d'accès, de rectification, d'effacement, d'opposition, de limitation et de portabilité en écrivant à infomoncangur@gmail.com. Mon Cangur peut demander des informations pour vérifier l'identité. Une réclamation peut être introduite auprès de l'autorité de contrôle compétente en Andorre.",
    ),
    LegalBlock.heading('9–11. Sécurité, cookies et modifications'),
    LegalBlock.paragraph(
      "Mon Cangur applique des mesures techniques et organisationnelles raisonnables pour protéger les données, en particulier celles des mineurs. Le site peut utiliser des cookies techniques et d'analyse (voir la Politique de cookies). La présente Politique peut être mise à jour ; la version en vigueur sera publiée sur la Plateforme.",
    ),
  ],
);

const _cancelFr = LegalDoc(
  title: "Politique d'annulation",
  updated: 'Fait partie intégrante des Conditions générales',
  footer: 'Document en cours de révision. Les conditions définitives seront confirmées conformément à la réglementation applicable dans la Principauté d\'Andorre.',
  blocks: [
    LegalBlock.heading('1. Dispositions générales'),
    LegalBlock.paragraph(
      "La présente Politique régit les annulations, les modifications et les incidents des réservations effectuées via la Plateforme. Toute annulation ou modification doit être communiquée par écrit par les canaux officiels (e-mail infomoncangur@gmail.com ou WhatsApp de l'entreprise +376 620 991), en identifiant la réservation (famille, date et horaire).",
    ),
    LegalBlock.paragraph("De façon générale, les critères suivants s'appliquent à tous les services :"),
    LegalBlock.list([
      "**Force majeure** (catastrophes naturelles, incidents graves affectant des services essentiels ou situations similaires) : la Famille pourra choisir de reprogrammer le service, sous réserve de disponibilité, ou demander le remboursement des heures correspondantes.",
      "**Retard ou absence de la professionnelle** pour une cause imputable à Mon Cangur (retard de plus de 30 minutes ou absence) : Mon Cangur proposera une professionnelle de remplacement, une reprogrammation ou le remboursement de la séance concernée.",
      "**Absence de la Famille ou empêchement d'accès** (personne absente au domicile, accès impossible ou impossibilité de contact) : le service est facturé intégralement et n'ouvre pas droit à remboursement.",
    ]),
    LegalBlock.heading('2. Services ponctuels'),
    LegalBlock.paragraph(
      "Pour les services Occasionnel, Événements et Urgence, payés d'avance au moment de la réservation, l'annulation ouvre droit à remboursement selon le préavis. Pour ces services, il n'est pas nécessaire de reprogrammer : la Famille peut effectuer une nouvelle réservation lorsqu'elle en a besoin.",
    ),
    LegalBlock.heading('2.1. Service occasionnel', small: true),
    LegalBlock.list([
      'Avec **24 heures ou plus** de préavis : remboursement intégral.',
      'Avec **moins de 24 heures** de préavis : le service est facturé, sans remboursement.',
    ]),
    LegalBlock.heading('2.2. Service Événements', small: true),
    LegalBlock.paragraph("Parce qu'il demande davantage de planification et, souvent, plus d'une professionnelle :"),
    LegalBlock.list([
      'Avec **7 jours ou plus** de préavis : remboursement intégral.',
      'Entre **3 et 7 jours** de préavis : remboursement de 50 %.',
      'Avec **moins de 72 heures** de préavis : le service est facturé, sans remboursement.',
    ]),
    LegalBlock.heading("2.3. Service d'urgence", small: true),
    LegalBlock.paragraph("En raison de son caractère immédiat, la règle dépend de l'état de la réservation :"),
    LegalBlock.list([
      '**Avant** que Mon Cangur confirme la demande et assigne la professionnelle : remboursement intégral.',
      'Une fois la professionnelle **confirmée et assignée** : le service est facturé, sauf force majeure ou cause imputable à Mon Cangur.',
    ]),
    LegalBlock.heading('3. Services continus (régulier et soutien)'),
    LegalBlock.paragraph('Pour les services régulier et de soutien, qui sont récurrents, les conditions suivantes s\'appliquent.'),
    LegalBlock.heading('3.1. Communication', small: true),
    LegalBlock.paragraph(
      "Toute annulation ou modification du service devra être communiquée par écrit par l'un des canaux officiels (e-mail infomoncangur@gmail.com ou WhatsApp de l'entreprise +376 620 991), en identifiant le service (famille, jour et horaire).",
    ),
    LegalBlock.heading("3.2. Règle en cas d'annulation", small: true),
    LegalBlock.list([
      "**a)** Avec 24 heures ou plus de préavis : la séance est facturée malgré tout. La Famille pourra la reporter à une autre date, sous réserve de disponibilité.",
      "**b)** Avec moins de 24 heures de préavis : la séance est facturée malgré tout et, en principe, ne pourra pas être reportée.",
      "**c)** Force majeure : la Famille pourra choisir de reporter la séance, sous réserve de disponibilité, ou demander le remboursement de la séance ou des heures correspondantes.",
    ]),
    LegalBlock.heading('3.3. Conditions de report', small: true),
    LegalBlock.paragraph(
      "Les séances à reporter devront être programmées dans les 4 semaines suivant la date d'origine, sous réserve de disponibilité et d'une confirmation écrite. Si aucune date n'est trouvée, la séance est considérée comme effectuée aux fins de facturation, sauf force majeure lorsque le remboursement a été choisi.",
    ),
    LegalBlock.heading("3.4. Absence de la Famille ou empêchement d'accès", small: true),
    LegalBlock.paragraph(
      "Si le service ne peut pas commencer ou être fourni pour une cause imputable à la Famille, la séance est facturée malgré tout et pourra être reportée sous réserve de disponibilité.",
    ),
    LegalBlock.heading('3.5. Retard ou absence de la professionnelle', small: true),
    LegalBlock.list([
      '**a)** Retard de plus de 30 minutes pour une cause imputable à Mon Cangur : la Famille pourra choisir de reporter la séance ou demander le remboursement de la séance concernée.',
      "**b)** Absence : Mon Cangur proposera un remplacement par une autre professionnelle de l'équipe, le report de la séance, ou le remboursement de la séance concernée.",
    ]),
    LegalBlock.heading('4. Remboursements'),
    LegalBlock.paragraph(
      "Les remboursements dus sont effectués, en règle générale, par le même moyen de paiement, conformément à la présente Politique et aux Conditions générales.",
    ),
  ],
);

import '../models/models.dart';

const _rows = <String, List<String>>{
  'empty': [
    'Encara no hi ha cap conversa',
    'Todavía no hay ninguna conversación',
    'There is no conversation yet',
    'Il n’y a pas encore de conversation',
  ],
  'emptySub': [
    'El xat s’obre amb la cangur d’una reserva que ja hagis fet.',
    'El chat se abre con la canguro de una reserva que ya hayas hecho.',
    'The chat opens with the nanny from a booking you have already made.',
    'La discussion s’ouvre avec la nounou d’une réservation déjà faite.',
  ],
  'emptySubCarer': [
    'El xat s’obre amb la família d’una reserva que ja tinguis.',
    'El chat se abre con la familia de una reserva que ya tengas.',
    'The chat opens with the family from a booking you already have.',
    'La discussion s’ouvre avec la famille d’une réservation que tu as déjà.',
  ],
  'privCarer': [
    'Conversa amb **la família** d’aquesta reserva. Per seguretat i qualitat del servei, l’equip de Mon Cangur també hi pot accedir.',
    'Conversación con **la familia** de esta reserva. Por seguridad y calidad del servicio, el equipo de Mon Cangur también puede acceder.',
    'Conversation with **the family** for this booking. For safety and service quality, the Mon Cangur team can also access it.',
    'Conversation avec **la famille** de cette réservation. Pour la sécurité et la qualité du service, l’équipe de Mon Cangur peut aussi y accéder.',
  ],
  'theFamily': ['La família', 'La familia', 'The family', 'La famille'],
  'xat': ['Xat', 'Chat', 'Chat', 'Discussion'],
  'openThread': ['Xat família i cangur', 'Chat familia y canguro', 'Family and nanny chat', 'Discussion famille et nounou'],
  'conversations': ['Converses', 'Conversaciones', 'Conversations', 'Discussions'],
  'inboxNote': [
    'Les converses amb les famílies són per a cada reserva. Per seguretat, l\'equip de Mon Cangur també hi pot accedir.',
    'Las conversaciones con las familias son para cada reserva. Por seguridad, el equipo de Mon Cangur también puede acceder.',
    'Conversations with families are for each booking. For safety, the Mon Cangur team can also access them.',
    'Les discussions avec les familles sont pour chaque réservation. Pour la sécurité, l’équipe de Mon Cangur peut aussi y accéder.',
  ],
  'team': ['Mon Cangur', 'Mon Cangur', 'Mon Cangur', 'Mon Cangur'],
  'equip': ['Equip', 'Equipo', 'Team', 'Équipe'],
  'teamStatus': [
    'Equip · atenció a la cangur',
    'Equipo · atención a la canguro',
    'Team · nanny support',
    'Équipe · aide à la nounou',
  ],
  'privTeam': [
    'Conversa **amb l\'equip** de Mon Cangur. Les famílies no hi tenen accés.',
    'Conversación **con el equipo** de Mon Cangur. Las familias no tienen acceso.',
    'Conversation **with the Mon Cangur team**. Families cannot access it.',
    'Conversation **avec l’équipe** de Mon Cangur. Les familles n’y ont pas accès.',
  ],
  'reservaStatus': ['Reserva {when}', 'Reserva {when}', 'Booking {when}', 'Réservation {when}'],
  'start': [
    'Comença la conversa',
    'Empieza la conversación',
    'Start the conversation',
    'Commencer la discussion',
  ],
  'yourCangur': ['La teva cangur', 'Tu canguro', 'Your nanny', 'Ta nounou'],
  'priv': [
    'Conversa entre tu i **la teva cangur** per a la reserva activa. Per seguretat i qualitat del servei, l’equip de Mon Cangur també hi pot accedir.',
    'Conversación entre tú y **tu canguro** para la reserva activa. Por seguridad y calidad del servicio, el equipo de Mon Cangur también puede acceder.',
    'Conversation between you and **your nanny** for the active booking. For safety and service quality, the Mon Cangur team can also access it.',
    'Conversation entre toi et **ta nounou** pour la réservation active. Pour la sécurité et la qualité du service, l’équipe de Mon Cangur peut aussi y accéder.',
  ],
  'today': ['Avui', 'Hoy', 'Today', 'Aujourd’hui'],
  'placeholder': ['Escriu un missatge...', 'Escribe un mensaje...', 'Write a message...', 'Écris un message...'],
  'permGreenH': [
    'Fotos permeses · liberades',
    'Fotos permitidas · liberadas',
    'Photos allowed · released',
    'Photos autorisées · libérées',
  ],
  'permGreenD': [
    'Podeu compartir fotos en aquest xat. La família autoritza que Mon Cangur les faci servir per a comunicació i màrqueting, sempre sense identificar l’infant.',
    'Podéis compartir fotos en este chat. La familia autoriza que Mon Cangur las use para comunicación y marketing, siempre sin identificar al niño.',
    'You can share photos in this chat. The family allows Mon Cangur to use them for communication and marketing, always without identifying the child.',
    'Vous pouvez partager des photos dans cette discussion. La famille autorise Mon Cangur à les utiliser pour la communication et le marketing, toujours sans identifier l’enfant.',
  ],
  'permYellowH': [
    'Fotos només per a la família',
    'Fotos solo para la familia',
    'Photos for the family only',
    'Photos uniquement pour la famille',
  ],
  'permYellowD': [
    'Podeu compartir fotos en aquest xat, però només per a la família. Mon Cangur no les farà servir per a res més.',
    'Podéis compartir fotos en este chat, pero solo para la familia. Mon Cangur no las usará para nada más.',
    'You can share photos in this chat, but only for the family. Mon Cangur will not use them for anything else.',
    'Vous pouvez partager des photos dans cette discussion, mais seulement pour la famille. Mon Cangur ne les utilisera pour rien d’autre.',
  ],
  'permRedH': ['Sense fotos', 'Sin fotos', 'No photos', 'Sans photos'],
  'permRedD': [
    'En aquest xat no es poden fer ni compartir fotos de l’infant.',
    'En este chat no se pueden hacer ni compartir fotos del niño.',
    'Photos of the child cannot be taken or shared in this chat.',
    'Dans cette discussion, aucune photo de l’enfant ne peut être prise ni partagée.',
  ],
  'photoBig': [
    'La foto és massa gran per enviar-la.',
    'La foto es demasiado grande para enviarla.',
    'The photo is too large to send.',
    'La photo est trop grande pour être envoyée.',
  ],
};

String cx(AppLang lang, String key) {
  final row = _rows[key];
  if (row == null || row.length != 4) return key;
  return row[lang.index];
}

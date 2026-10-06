import '../models/models.dart';

const _rows = <String, List<String>>{
  'title': ['Menú', 'Menú', 'Menu', 'Menu'],
  'account': ['El meu compte', 'Mi cuenta', 'My account', 'Mon compte'],
  'profile': ['El meu perfil', 'Mi perfil', 'My profile', 'Mon profil'],
  'kids': ['Infants', 'Niños', 'Children', 'Enfants'],
  'bookings': ['Reserves', 'Reservas', 'Bookings', 'Réservations'],
  'myBookings': ['Les meves reserves', 'Mis reservas', 'My bookings', 'Mes réservations'],
  'history': ['Historial i estats', 'Historial y estados', 'History and status', 'Historique et états'],
  'comms': ['Comunicació', 'Comunicación', 'Communication', 'Communication'],
  'chat': ['Xat amb la meva cangur', 'Chat con mi canguro', 'Chat with my nanny', 'Discussion avec ma nounou'],
  'help': ['Ajuda i atenció al client', 'Ayuda y atención al cliente', 'Help and support', 'Aide et service client'],
  'services': ['Serveis', 'Servicios', 'Services', 'Services'],
  'ourServices': ['Els nostres serveis', 'Nuestros servicios', 'Our services', 'Nos services'],
  'legal': ['Legal', 'Legal', 'Legal', 'Mentions'],
  'terms': ['Termes i condicions', 'Términos y condiciones', 'Terms and conditions', 'Conditions générales'],
  'privacy': ['Política de privacitat', 'Política de privacidad', 'Privacy policy', 'Politique de confidentialité'],
  'cancel': ['Política de cancel·lació', 'Política de cancelación', 'Cancellation policy', 'Politique d’annulation'],
  'soon': ['Aviat', 'Pronto', 'Soon', 'Bientôt'],
  'detail': ['Detall de la reserva', 'Detalle de la reserva', 'Booking details', 'Détail de la réservation'],
  'status': ['Estat', 'Estado', 'Status', 'État'],
  'payment': ['Pagament', 'Pago', 'Payment', 'Paiement'],
  'family': ['Família', 'Familia', 'Family', 'Famille'],
  'notes': ['Notes', 'Notas', 'Notes', 'Notes'],
  'pay': ['Pagar', 'Pagar', 'Pay', 'Payer'],
  'termsBody': [
    'En usar Mon Cangur acceptes les condicions del servei. La reserva queda confirmada quan l\'equip l\'accepta. Per a qualsevol dubte, escriu a info@moncangur.ad.',
    'Al usar Mon Cangur aceptas las condiciones del servicio. La reserva queda confirmada cuando el equipo la acepta. Para cualquier duda, escribe a info@moncangur.ad.',
    'By using Mon Cangur you accept the service conditions. A booking is confirmed when the team accepts it. For any question, write to info@moncangur.ad.',
    'En utilisant Mon Cangur, tu acceptes les conditions du service. La réservation est confirmée lorsque l’équipe l’accepte. Pour toute question, écris à info@moncangur.ad.',
  ],
  'privacyBody': [
    'Fem servir les dades del perfil i de les reserves per prestar el servei. Per exercir els teus drets, escriu a info@moncangur.ad.',
    'Usamos los datos del perfil y de las reservas para prestar el servicio. Para ejercer tus derechos, escribe a info@moncangur.ad.',
    'We use profile and booking details to provide the service. To exercise your rights, write to info@moncangur.ad.',
    'Nous utilisons les données du profil et des réservations pour fournir le service. Pour exercer tes droits, écris à info@moncangur.ad.',
  ],
  'cancelBody': [
    'Les condicions de cancel·lació es confirmen amb cada reserva. Per a un canvi, escriu a info@moncangur.ad.',
    'Las condiciones de cancelación se confirman con cada reserva. Para un cambio, escribe a info@moncangur.ad.',
    'Cancellation conditions are confirmed with each booking. For a change, write to info@moncangur.ad.',
    'Les conditions d’annulation sont confirmées avec chaque réservation. Pour un changement, écris à info@moncangur.ad.',
  ],
};

String mn(AppLang lang, String key) {
  final row = _rows[key];
  if (row == null || row.length != 4) return key;
  return row[lang.index];
}

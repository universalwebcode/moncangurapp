part of 'legal_docs.dart';

LegalDoc legalEs(LegalSection section) {
  switch (section) {
    case LegalSection.terms:
      return _termsEs;
    case LegalSection.privacy:
      return _privacyEs;
    case LegalSection.cancel:
      return _cancelEs;
  }
}

const _termsEs = LegalDoc(
  title: 'Términos y condiciones de uso',
  updated: 'Mon Cangur · moncangur.ad y aplicación móvil',
  blocks: [
    LegalBlock.heading('1. Condiciones generales de uso'),
    LegalBlock.paragraph(
      'Estas Condiciones se aplican al sitio web de Mon Cangur (moncangur.ad) y a la aplicación móvil asociada (la Plataforma). El acceso y el uso de la Plataforma, el registro de una cuenta y/o la contratación de servicios implican la aceptación de estas Condiciones, la Política de Privacidad y la Política de Cookies. Mon Cangur se reserva el derecho de modificar estas Condiciones; la versión vigente será la publicada en la Plataforma.',
    ),
    LegalBlock.heading('2. Información legal y datos del titular'),
    LegalBlock.facts([
      ('Titular', 'Lima Terra, Júlia'),
      ('Nombre comercial', 'Mon Cangur'),
      ('NRT', 'F-370532-N'),
      ('Domicilio', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('Correo', 'infomoncangur@gmail.com'),
      ('Teléfono', '+376 620 991'),
    ]),
    LegalBlock.heading('3. Definiciones'),
    LegalBlock.list([
      '**Plataforma:** el web moncangur.ad y la app de Mon Cangur.',
      '**Usuario:** toda persona que acceda o utilice la Plataforma.',
      '**Cliente:** el Usuario que solicita o contrata un servicio.',
      '**Cangur:** personal cuidador empleado por Mon Cangur con acceso a la Plataforma.',
      '**Servicio:** el servicio de cuidado infantil a domicilio prestado por Mon Cangur.',
      '**Reserva:** solicitud confirmada de un Servicio formalizada en la Plataforma.',
    ]),
    LegalBlock.heading('4. Objeto'),
    LegalBlock.paragraph(
      'Mon Cangur presta y gestiona servicios de cuidado infantil a domicilio a través de la Plataforma. Ofrece distintas modalidades: servicio ocasional, servicio para eventos, servicio de refuerzo y acompañamiento pedagógico, servicio fijo y servicio de urgencia. En los servicios ocasional, eventos y refuerzo, la familia selecciona al cangur según la disponibilidad; en los servicios fijo y de urgencia, la asignación la hace Mon Cangur. Los servicios los presta Mon Cangur, no terceros: no actúa como intermediario.',
    ),
    LegalBlock.heading('5. Acceso, registro y cuenta'),
    LegalBlock.paragraph(
      'Para registrarse hay que ser mayor de edad, completar de forma veraz los datos obligatorios (nombre, apellidos, correo y teléfono) y aceptar estas Condiciones. El acceso se hace con correo y contraseña, personales e intransferibles. Mon Cangur puede suspender o cancelar la cuenta en caso de uso fraudulento, incumplimiento o información falsa.',
    ),
    LegalBlock.heading('Perfil del Cliente y de los hijos', small: true),
    LegalBlock.paragraph(
      'El Cliente debe completar la información necesaria para el servicio. No se pueden hacer reservas sin completar la información obligatoria (incluidos los perfiles de los hijos). El Cliente puede modificar o eliminar su cuenta, sin perjuicio de la conservación de datos por obligaciones legales o contractuales.',
    ),
    LegalBlock.heading('6. Funcionamiento y contratación'),
    LegalBlock.paragraph(
      'El Cliente solicita el servicio indicando tipo, fecha, franja horaria y dirección. En ocasional, eventos y refuerzo, filtra por día y hora, elige cangur, confirma y paga. En fijo, rellena un formulario de necesidades y Mon Cangur propone el cangur; en urgencia, activa una notificación y Mon Cangur contacta con él.',
    ),
    LegalBlock.heading('Duración, control horario y pago', small: true),
    LegalBlock.paragraph(
      'Los servicios se contratan por bloques. El cangur registra la hora de finalización; si se excede el horario, el importe se ajusta. En eventos con más de 4 niños hace falta una segunda cuidadora. El pago se hace en el momento de la reserva a través de TPV; en el servicio fijo se puede habilitar la domiciliación mensual.',
    ),
    LegalBlock.heading('Cancelaciones e incidencias', small: true),
    LegalBlock.paragraph(
      'Las cancelaciones se rigen por la Política de Cancelación. Los cambios de hora o dirección requieren anular y volver a reservar o contactar con Atención al Cliente. Si un cangur no puede prestar el servicio, Mon Cangur propone alternativas o reembolsa. Si el cangur llega con más de 30 min de retraso por causa de Mon Cangur, el Cliente puede pedir un vale de descuento.',
    ),
    LegalBlock.heading('Comunicaciones y protección de menores', small: true),
    LegalBlock.paragraph(
      'El contacto entre Cliente y cangur debe hacerse a través de la Plataforma. Queda prohibida la administración de medicación por el cangur y la difusión de contenidos de menores fuera de la Plataforma. El Cliente debe informar de alergias, restricciones y necesidades especiales. El Cliente configura el uso de imágenes del menor (uso corporativo sin mostrar la cara, solo intercambio por el chat, o ninguna imagen).',
    ),
    LegalBlock.heading('7. Reclamaciones e incidencias'),
    LegalBlock.paragraph(
      'Las reclamaciones se presentan por escrito por los canales oficiales (correo o WhatsApp de empresa), con fecha y franja del servicio, dirección, nombre del cangur, descripción de los hechos y evidencias si procede. En caso de incomparecencia, se debe notificar en un plazo de 24 h. Mon Cangur responde en un máximo de 10 días hábiles.',
    ),
    LegalBlock.heading('8. Tarifas, pago y promociones'),
    LegalBlock.paragraph(
      'El uso de la Plataforma es gratuito; la contratación implica el pago de las tarifas, que se muestran antes de confirmar. Los reembolsos se hacen conforme a la Política de Cancelación, por el mismo método de pago. Mon Cangur puede ofrecer códigos promocionales y vales, personales e intransferibles.',
    ),
    LegalBlock.heading('9. Comunicaciones y comentarios'),
    LegalBlock.paragraph(
      'La Plataforma incorpora mensajería interna entre Cliente y cangur, que no se puede usar para spam ni contenidos ilícitos. El Cliente puede dejar comentarios después del servicio, sujetos a revisión previa por Mon Cangur.',
    ),
    LegalBlock.heading('10. Baja del Usuario'),
    LegalBlock.paragraph(
      'El Usuario puede darse de baja desde la Plataforma o solicitándolo a infomoncangur@gmail.com o por el WhatsApp de empresa. La baja no exime de las obligaciones pendientes.',
    ),
    LegalBlock.heading('11. Obligaciones del Usuario'),
    LegalBlock.paragraph(
      'El Usuario es responsable del uso adecuado de la cuenta y de sus credenciales. Debe facilitar información veraz, completar los perfiles de los hijos, mantener una comunicación respetuosa, no eludir la Plataforma y permanecer localizable durante el servicio. El cangur debe utilizar la Plataforma solo con fines profesionales, mantener la disponibilidad actualizada, no consumir sustancias que afecten al servicio y respetar las normas de protección de menores.',
    ),
    LegalBlock.heading('12–14. Responsabilidad y estándares'),
    LegalBlock.paragraph(
      'Mon Cangur hace esfuerzos razonables para mantener la Plataforma operativa, sin garantizar un acceso ininterrumpido. No es responsable de incidencias derivadas de información falsa del Cliente, falta de acceso al servicio, fuerza mayor o acuerdos hechos fuera de la Plataforma. Dispone de una póliza de seguro de responsabilidad civil y de un proceso de selección de cangurs basado en experiencia, idoneidad y formación (priorizando primeros auxilios).',
    ),
    LegalBlock.heading('15. Impuestos y facturación'),
    LegalBlock.paragraph(
      'La facturación y las obligaciones fiscales las gestiona Mon Cangur según la normativa andorrana. Los precios se expresan en euros e incluyen el IGI aplicable. Mon Cangur emite factura o justificante cuando el Cliente lo solicita.',
    ),
    LegalBlock.heading('16. Desistimiento y hojas de reclamación'),
    LegalBlock.paragraph(
      'Dada la naturaleza de los servicios (fecha y hora concretas), el derecho de desistimiento puede quedar limitado y se aplica la Política de Cancelación. Mon Cangur pone a disposición hojas oficiales de reclamación, que se pueden solicitar por escrito a infomoncangur@gmail.com.',
    ),
    LegalBlock.heading('17–22. Fuerza mayor, propiedad y jurisdicción'),
    LegalBlock.paragraph(
      'Ninguna parte es responsable por fuerza mayor. Mon Cangur es titular de los derechos de propiedad intelectual e industrial de la Plataforma y de la marca. En caso de discrepancia entre versiones de idioma, prevalece la versión en catalán. Estas Condiciones se rigen por la legislación del Principado de Andorra.',
    ),
  ],
);

const _privacyEs = LegalDoc(
  title: 'Política de privacidad y protección de datos',
  updated: 'Última actualización: 08/03/2026',
  blocks: [
    LegalBlock.heading('1. Responsable del tratamiento'),
    LegalBlock.facts([
      ('Responsable', 'Lima Terra, Júlia (Mon Cangur)'),
      ('NRT', 'F-370532-N'),
      ('Domicilio', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('Correo', 'infomoncangur@gmail.com'),
      ('Teléfono / WhatsApp', '+376 620 991'),
    ]),
    LegalBlock.paragraph(
      'Mon Cangur trata los datos personales de los usuarios del web y de la app para gestionar cuentas, reservas y la prestación de servicios de cuidado infantil a domicilio.',
    ),
    LegalBlock.heading('2. Normativa aplicable'),
    LegalBlock.paragraph(
      'Se aplica la normativa de protección de datos vigente en Andorra, en particular la Ley 29/2021, cualificada de protección de datos personales. Cuando corresponda, se pueden aplicar estándares equivalentes (por ejemplo, el RGPD de la UE).',
    ),
    LegalBlock.heading('3. Qué datos tratamos'),
    LegalBlock.heading('Datos del Cliente', small: true),
    LegalBlock.paragraph(
      'Obligatorios: nombre y apellidos, correo, teléfono, contraseña y dirección principal. En las reservas: dirección del servicio, fecha, franja, tipo de servicio y observaciones. Opcional: foto de perfil y preferencias. El cambio de correo puede requerir gestión manual y verificación de identidad.',
    ),
    LegalBlock.heading('Datos de los hijos / menores', small: true),
    LegalBlock.paragraph(
      'Aportados por el Cliente como tutor legal. Obligatorios: nombre completo, género, fecha de nacimiento, alergias y restricciones, y responsable secundario de emergencia (nombre, parentesco, teléfono). Opcionales: necesidades especiales, idiomas, observaciones y foto. Pueden incluir información sensible (alergias, necesidades especiales), tratada para la seguridad y la correcta prestación del servicio.',
    ),
    LegalBlock.heading('Datos del cangur', small: true),
    LegalBlock.paragraph(
      'Datos identificativos y de contacto profesionales, foto de perfil profesional, disponibilidad y registros operativos. La documentación laboral se gestiona como parte de procesos internos, no como información pública para los clientes.',
    ),
    LegalBlock.heading('Comunicaciones y soporte', small: true),
    LegalBlock.paragraph(
      'Mensajes del chat interno, solicitudes a Atención al Cliente y registros técnicos (logs) necesarios para la seguridad y el funcionamiento.',
    ),
    LegalBlock.heading('4. Finalidades y base legal'),
    LegalBlock.list([
      'Crear y gestionar la cuenta — ejecución del contrato.',
      'Gestionar reservas y prestar el servicio — ejecución del contrato.',
      'Seguridad y protección del menor — contrato e interés legítimo; datos sensibles con el consentimiento del tutor cuando proceda.',
      'Facturación y obligaciones legales — obligación legal / interés legítimo.',
      'Comunicaciones operativas — ejecución del contrato.',
      'Comunicaciones comerciales — solo con consentimiento, revocable.',
    ]),
    LegalBlock.heading('5. Imágenes y vídeos de menores'),
    LegalBlock.paragraph(
      'El Cliente elige una opción: **A)** uso corporativo/publicitario sin mostrar la cara ni elementos identificativos (revocable); **B)** solo intercambio por el chat interno con los padres; **C)** prohibición total. Mon Cangur aplica esta preferencia como configuración de privacidad.',
    ),
    LegalBlock.heading('6. Con quién compartimos datos'),
    LegalBlock.paragraph(
      'Mon Cangur no vende datos. Los comparte solo cuando es necesario: con el cangur asignado (datos necesarios para el servicio), con proveedores tecnológicos (encargados del tratamiento), con el proveedor de pago (Redsys, para el TPV), por los canales externos elegidos por el usuario (WhatsApp) y con autoridades públicas cuando exista una obligación legal.',
    ),
    LegalBlock.heading('7. Conservación'),
    LegalBlock.paragraph(
      'Los datos se conservan mientras la cuenta esté activa y, después, durante los plazos necesarios para el cumplimiento legal y la defensa frente a reclamaciones. Las comunicaciones se pueden conservar un plazo razonable para incidencias y auditoría.',
    ),
    LegalBlock.heading('8. Derechos del usuario'),
    LegalBlock.paragraph(
      'El usuario puede ejercer los derechos de acceso, rectificación, supresión, oposición, limitación y portabilidad escribiendo a infomoncangur@gmail.com. Mon Cangur puede pedir información para verificar la identidad. Se puede reclamar ante la autoridad de control competente en Andorra.',
    ),
    LegalBlock.heading('9–11. Seguridad, cookies y cambios'),
    LegalBlock.paragraph(
      'Mon Cangur aplica medidas técnicas y organizativas razonables para proteger los datos, especialmente los de los menores. El web puede usar cookies técnicas y analíticas (véase la Política de Cookies). Esta Política se puede actualizar; la versión vigente estará publicada en la Plataforma.',
    ),
  ],
);

const _cancelEs = LegalDoc(
  title: 'Política de cancelación',
  updated: 'Forma parte integrante de los Términos y Condiciones',
  footer: 'Documento en revisión. Las condiciones definitivas se confirmarán de acuerdo con la normativa aplicable en el Principado de Andorra.',
  blocks: [
    LegalBlock.heading('1. Disposiciones generales'),
    LegalBlock.paragraph(
      'Esta Política regula las cancelaciones, los cambios y las incidencias de las reservas hechas a través de la Plataforma. Cualquier cancelación o cambio se debe comunicar por escrito a través de los canales oficiales (correo infomoncangur@gmail.com o WhatsApp de empresa +376 620 991), identificando la reserva (familia, fecha y horario).',
    ),
    LegalBlock.paragraph('Con carácter general, a todos los servicios se aplican los criterios siguientes:'),
    LegalBlock.list([
      '**Fuerza mayor** (desastres naturales, incidencias graves de servicios básicos o similares): la Familia podrá elegir entre reprogramar el servicio, sujeto a disponibilidad, o solicitar el reembolso de las horas correspondientes.',
      '**Retraso o ausencia de la profesional** por causa imputable a Mon Cangur (retraso superior a 30 minutos o ausencia): Mon Cangur ofrecerá una profesional sustituta, la reprogramación o el reembolso de la sesión afectada.',
      '**No presentación o impedimento de acceso por parte de la Familia** (ausencia en el domicilio, falta de acceso o imposibilidad de contacto): el servicio se cobrará íntegramente y no dará derecho a reembolso.',
    ]),
    LegalBlock.heading('2. Servicios puntuales'),
    LegalBlock.paragraph(
      'Para los servicios Ocasional, de Eventos y de Urgencia, que se pagan por adelantado en el momento de la reserva, la cancelación da derecho a reembolso en función de la antelación. En estos servicios no hace falta reprogramar: la Familia puede hacer una nueva reserva cuando lo necesite.',
    ),
    LegalBlock.heading('2.1. Servicio Ocasional', small: true),
    LegalBlock.list([
      'Con **24 horas o más** de antelación: reembolso completo.',
      'Con **menos de 24 horas** de antelación: se cobrará el servicio, sin reembolso.',
    ]),
    LegalBlock.heading('2.2. Servicio de Eventos', small: true),
    LegalBlock.paragraph('Dado que requiere más planificación y, a menudo, más de una profesional:'),
    LegalBlock.list([
      'Con **7 días o más** de antelación: reembolso completo.',
      'Entre **3 y 7 días** de antelación: reembolso del 50%.',
      'Con **menos de 72 horas** de antelación: se cobrará el servicio, sin reembolso.',
    ]),
    LegalBlock.heading('2.3. Servicio de Urgencia', small: true),
    LegalBlock.paragraph('Por su carácter inmediato, se aplica según el estado de la reserva:'),
    LegalBlock.list([
      '**Antes** de que Mon Cangur confirme la solicitud y asigne a la profesional: reembolso completo.',
      'Una vez **confirmada y asignada** la profesional: se cobrará el servicio, salvo fuerza mayor o causa imputable a Mon Cangur.',
    ]),
    LegalBlock.heading('3. Servicios continuados (Fijo y Repaso)'),
    LegalBlock.paragraph('Para los servicios Fijo y de Repaso, de carácter recurrente, se aplican las condiciones siguientes.'),
    LegalBlock.heading('3.1. Comunicación', small: true),
    LegalBlock.paragraph(
      'Cualquier cancelación o cambio del servicio se deberá comunicar por escrito mediante uno de los canales oficiales (correo infomoncangur@gmail.com o WhatsApp de empresa +376 620 991), identificando el servicio (familia, día y horario).',
    ),
    LegalBlock.heading('3.2. Criterio en caso de cancelación', small: true),
    LegalBlock.list([
      '**a)** Con 24 horas o más de antelación: la sesión se cobrará igualmente. La Familia tendrá la opción de remarcarla en otra fecha, sujeta a disponibilidad.',
      '**b)** Con menos de 24 horas de antelación: la sesión se cobrará igualmente y, en principio, no se podrá remarcar.',
      '**c)** Fuerza mayor: la Familia podrá elegir entre remarcar la sesión, sujeta a disponibilidad, o solicitar el reembolso de la sesión o de las horas correspondientes.',
    ]),
    LegalBlock.heading('3.3. Condiciones para remarcar', small: true),
    LegalBlock.paragraph(
      'Las sesiones a remarcar se deberán programar en un plazo de 4 semanas desde la fecha original, sujetas a disponibilidad y confirmación por escrito. Si no se encuentra fecha, la sesión se considerará realizada a efectos de cobro (excepto fuerza mayor con reembolso elegido).',
    ),
    LegalBlock.heading('3.4. No presentación o impedimento de acceso por parte de la Familia', small: true),
    LegalBlock.paragraph(
      'Si el servicio no se puede iniciar o prestar por causas imputables a la Familia, la sesión se cobrará igualmente y se podrá remarcar sujeta a disponibilidad.',
    ),
    LegalBlock.heading('3.5. Retraso o ausencia de la profesional', small: true),
    LegalBlock.list([
      '**a)** Retraso superior a 30 minutos por causas imputables a Mon Cangur: la Familia podrá elegir entre remarcar la sesión o solicitar el reembolso de la sesión afectada.',
      '**b)** Ausencia: Mon Cangur ofrecerá sustitución por otra profesional del equipo, remarcar la sesión, o el reembolso de la sesión afectada.',
    ]),
    LegalBlock.heading('4. Reembolsos'),
    LegalBlock.paragraph(
      'Los reembolsos que correspondan se harán, por norma general, por el mismo método de pago utilizado, conforme a esta Política y a los Términos y Condiciones.',
    ),
  ],
);

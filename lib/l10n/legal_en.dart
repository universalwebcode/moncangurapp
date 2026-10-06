part of 'legal_docs.dart';

LegalDoc legalEn(LegalSection section) {
  switch (section) {
    case LegalSection.terms:
      return _termsEn;
    case LegalSection.privacy:
      return _privacyEn;
    case LegalSection.cancel:
      return _cancelEn;
  }
}

const _termsEn = LegalDoc(
  title: 'Terms and conditions of use',
  updated: 'Mon Cangur · moncangur.ad and the mobile app',
  blocks: [
    LegalBlock.heading('1. General conditions of use'),
    LegalBlock.paragraph(
      'These Conditions apply to the Mon Cangur website (moncangur.ad) and the associated mobile app (the Platform). Accessing and using the Platform, registering an account and/or booking services means accepting these Conditions, the Privacy Policy and the Cookie Policy. Mon Cangur may change these Conditions; the version in force is the one published on the Platform.',
    ),
    LegalBlock.heading('2. Legal information and details of the owner'),
    LegalBlock.facts([
      ('Owner', 'Lima Terra, Júlia'),
      ('Trade name', 'Mon Cangur'),
      ('NRT', 'F-370532-N'),
      ('Address', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('Email', 'infomoncangur@gmail.com'),
      ('Phone', '+376 620 991'),
    ]),
    LegalBlock.heading('3. Definitions'),
    LegalBlock.list([
      '**Platform:** the website moncangur.ad and the Mon Cangur app.',
      '**User:** any person who accesses or uses the Platform.',
      '**Client:** the User who requests or books a service.',
      '**Cangur:** care staff employed by Mon Cangur with access to the Platform.',
      '**Service:** the in-home childcare service provided by Mon Cangur.',
      '**Booking:** a confirmed request for a Service made on the Platform.',
    ]),
    LegalBlock.heading('4. Purpose'),
    LegalBlock.paragraph(
      'Mon Cangur provides and manages in-home childcare through the Platform. It offers several types: occasional care, events, tutoring and educational support, regular care, and emergency care. For occasional care, events and tutoring, the family chooses the cangur according to availability; for regular and emergency care, Mon Cangur assigns the cangur. The services are provided by Mon Cangur, not by third parties: it does not act as an intermediary.',
    ),
    LegalBlock.heading('5. Access, registration and account'),
    LegalBlock.paragraph(
      'To register, a person must be of legal age, complete the required details truthfully (first name, surname, email and phone) and accept these Conditions. Access is by email and password, which are personal and non-transferable. Mon Cangur may suspend or close the account in the event of fraudulent use, breach or false information.',
    ),
    LegalBlock.heading('Client profile and children', small: true),
    LegalBlock.paragraph(
      'The Client must complete the information needed for the service. Bookings cannot be made until the required information is complete, including the children\'s profiles. The Client may change or delete the account, without affecting the retention of data required by legal or contractual duties.',
    ),
    LegalBlock.heading('6. How booking works'),
    LegalBlock.paragraph(
      'The Client requests the service by stating the type, date, time slot and address. For occasional care, events and tutoring, the Client filters by day and time, chooses a cangur, confirms and pays. For regular care, the Client fills in a needs form and Mon Cangur proposes the cangur; for emergency care, a notification is sent and Mon Cangur makes contact.',
    ),
    LegalBlock.heading('Duration, timekeeping and payment', small: true),
    LegalBlock.paragraph(
      'Services are booked in blocks. The cangur records the end time; if the booked time is exceeded, the amount is adjusted. Events with more than 4 children require a second carer. Payment is taken when the booking is made, through the payment gateway; monthly direct debit may be enabled for regular care.',
    ),
    LegalBlock.heading('Cancellations and incidents', small: true),
    LegalBlock.paragraph(
      'Cancellations are governed by the Cancellation Policy. Changes of time or address require cancelling and booking again, or contacting Customer Care. If a cangur cannot provide the service, Mon Cangur offers alternatives or a refund. If the cangur arrives more than 30 minutes late for a reason attributable to Mon Cangur, the Client may request a discount voucher.',
    ),
    LegalBlock.heading('Communications and protection of children', small: true),
    LegalBlock.paragraph(
      'Contact between the Client and the cangur must take place through the Platform. The cangur may not administer medication, and content about children may not be shared outside the Platform. The Client must report allergies, restrictions and special needs. The Client sets how images of the child may be used: corporate use without showing the face, exchange in the chat only, or no images.',
    ),
    LegalBlock.heading('7. Complaints and incidents'),
    LegalBlock.paragraph(
      'Complaints are submitted in writing through the official channels (email or the company WhatsApp), with the date and time slot of the service, the address, the cangur\'s name, a description of what happened and evidence where relevant. A no-show must be reported within 24 hours. Mon Cangur replies within 10 working days.',
    ),
    LegalBlock.heading('8. Rates, payment and promotions'),
    LegalBlock.paragraph(
      'Use of the Platform is free; booking a service means paying the rates, which are shown before confirmation. Refunds are made under the Cancellation Policy, to the same payment method. Mon Cangur may offer promo codes and vouchers, which are personal and non-transferable.',
    ),
    LegalBlock.heading('9. Communications and feedback'),
    LegalBlock.paragraph(
      'The Platform includes internal messaging between the Client and the cangur. It may not be used for spam or unlawful content. The Client may leave feedback after the service, subject to prior review by Mon Cangur.',
    ),
    LegalBlock.heading('10. Closing an account'),
    LegalBlock.paragraph(
      'The User may close the account from the Platform, or by asking at infomoncangur@gmail.com or on the company WhatsApp. Closing the account does not release the User from outstanding obligations.',
    ),
    LegalBlock.heading('11. User obligations'),
    LegalBlock.paragraph(
      'The User is responsible for proper use of the account and its credentials. The User must provide truthful information, complete the children\'s profiles, communicate respectfully, not go around the Platform, and remain reachable during the service. The cangur must use the Platform only for professional purposes, keep availability up to date, not consume substances that affect the service, and follow the rules on the protection of children.',
    ),
    LegalBlock.heading('12–14. Liability and standards'),
    LegalBlock.paragraph(
      'Mon Cangur makes reasonable efforts to keep the Platform running, without guaranteeing uninterrupted access. It is not liable for incidents arising from false information from the Client, lack of access to the service, force majeure, or arrangements made outside the Platform. It holds a civil-liability insurance policy and selects cangurs on the basis of experience, suitability and training, with priority given to first aid.',
    ),
    LegalBlock.heading('15. Tax and invoicing'),
    LegalBlock.paragraph(
      'Invoicing and tax duties are handled by Mon Cangur under Andorran law. Prices are in euros and include the applicable IGI. Mon Cangur issues an invoice or receipt when the Client asks for one.',
    ),
    LegalBlock.heading('16. Withdrawal and complaint forms'),
    LegalBlock.paragraph(
      'Because the services are for a specific date and time, the right of withdrawal may be limited, and the Cancellation Policy applies. Mon Cangur provides official complaint forms, which can be requested in writing at infomoncangur@gmail.com.',
    ),
    LegalBlock.heading('17–22. Force majeure, ownership and jurisdiction'),
    LegalBlock.paragraph(
      'Neither party is liable for force majeure. Mon Cangur owns the intellectual and industrial property rights in the Platform and the brand. If language versions differ, the Catalan version prevails. These Conditions are governed by the law of the Principality of Andorra.',
    ),
  ],
);

const _privacyEn = LegalDoc(
  title: 'Privacy and data protection policy',
  updated: 'Last updated: 08/03/2026',
  blocks: [
    LegalBlock.heading('1. Data controller'),
    LegalBlock.facts([
      ('Controller', 'Lima Terra, Júlia (Mon Cangur)'),
      ('NRT', 'F-370532-N'),
      ('Address', 'Av. Joan Martí, 90, escala A 1-5, AD200, Encamp'),
      ('Email', 'infomoncangur@gmail.com'),
      ('Phone / WhatsApp', '+376 620 991'),
    ]),
    LegalBlock.paragraph(
      'Mon Cangur processes the personal data of website and app users in order to manage accounts, bookings and the provision of in-home childcare.',
    ),
    LegalBlock.heading('2. Applicable law'),
    LegalBlock.paragraph(
      'The data-protection law in force in Andorra applies, in particular Qualified Law 29/2021 on the protection of personal data. Where relevant, equivalent standards may also apply, such as the EU GDPR.',
    ),
    LegalBlock.heading('3. What data we process'),
    LegalBlock.heading('Client data', small: true),
    LegalBlock.paragraph(
      'Required: first name and surname, email, phone, password and main address. For bookings: service address, date, time slot, type of service and notes. Optional: profile photo and preferences. Changing the email may require manual handling and identity checks.',
    ),
    LegalBlock.heading('Data about children', small: true),
    LegalBlock.paragraph(
      'Provided by the Client as legal guardian. Required: full name, gender, date of birth, allergies and restrictions, and a secondary emergency contact (name, relationship, phone). Optional: special needs, languages, notes and a photo. This may include sensitive information (allergies, special needs), processed for the child\'s safety and so that the service can be provided properly.',
    ),
    LegalBlock.heading('Cangur data', small: true),
    LegalBlock.paragraph(
      'Professional identity and contact details, a professional profile photo, availability and operational records. Employment documents are handled as part of internal processes, not as information shown to clients.',
    ),
    LegalBlock.heading('Communications and support', small: true),
    LegalBlock.paragraph(
      'Internal chat messages, requests to Customer Care, and technical logs needed for security and operation.',
    ),
    LegalBlock.heading('4. Purposes and legal basis'),
    LegalBlock.list([
      'Creating and managing the account — performance of the contract.',
      'Managing bookings and providing the service — performance of the contract.',
      'Safety and protection of the child — contract and legitimate interest; sensitive data with the guardian\'s consent where required.',
      'Invoicing and legal duties — legal obligation / legitimate interest.',
      'Operational messages — performance of the contract.',
      'Marketing messages — only with consent, which can be withdrawn.',
    ]),
    LegalBlock.heading('5. Images and videos of children'),
    LegalBlock.paragraph(
      'The Client chooses one option: **A)** corporate or advertising use without showing the face or identifying features (this can be withdrawn); **B)** exchange only in the internal chat with the parents; **C)** no images at all. Mon Cangur applies this choice as a privacy setting.',
    ),
    LegalBlock.heading('6. Who we share data with'),
    LegalBlock.paragraph(
      'Mon Cangur does not sell data. It shares data only when needed: with the assigned cangur (the details required for the service), with technology providers (processors), with the payment provider (Redsys, for card payments), through external channels the user chooses (WhatsApp), and with public authorities when the law requires it.',
    ),
    LegalBlock.heading('7. Retention'),
    LegalBlock.paragraph(
      'Data is kept while the account is active and, afterwards, for as long as needed to meet legal duties and to defend claims. Communications may be kept for a reasonable period for incidents and audit.',
    ),
    LegalBlock.heading('8. User rights'),
    LegalBlock.paragraph(
      'The user may exercise the rights of access, rectification, erasure, objection, restriction and portability by writing to infomoncangur@gmail.com. Mon Cangur may ask for information to verify identity. A complaint may be made to the competent supervisory authority in Andorra.',
    ),
    LegalBlock.heading('9–11. Security, cookies and changes'),
    LegalBlock.paragraph(
      'Mon Cangur applies reasonable technical and organisational measures to protect data, especially children\'s data. The website may use technical and analytics cookies (see the Cookie Policy). This Policy may be updated; the version in force will be published on the Platform.',
    ),
  ],
);

const _cancelEn = LegalDoc(
  title: 'Cancellation policy',
  updated: 'Forms an integral part of the Terms and Conditions',
  footer: 'Document under review. The final conditions will be confirmed in accordance with the law applicable in the Principality of Andorra.',
  blocks: [
    LegalBlock.heading('1. General provisions'),
    LegalBlock.paragraph(
      'This Policy governs cancellations, changes and incidents for bookings made through the Platform. Any cancellation or change must be sent in writing through the official channels (email infomoncangur@gmail.com or company WhatsApp +376 620 991), identifying the booking (family, date and time).',
    ),
    LegalBlock.paragraph('As a general rule, the following applies to every service:'),
    LegalBlock.list([
      '**Force majeure** (natural disasters, serious failures of essential services, or similar events): the Family may choose to reschedule the service, subject to availability, or request a refund for the corresponding hours.',
      '**Late arrival or absence of the carer** for a reason attributable to Mon Cangur (more than 30 minutes late, or a no-show): Mon Cangur will offer a replacement carer, a new date, or a refund of the affected session.',
      '**The Family does not attend or prevents access** (nobody at the home, no access, or no way to make contact): the service is charged in full and no refund is due.',
    ]),
    LegalBlock.heading('2. One-off services'),
    LegalBlock.paragraph(
      'Occasional care, Events and Emergency care are paid in advance when the booking is made. A cancellation entitles the Family to a refund depending on how much notice is given. These services do not need to be rescheduled: the Family can make a new booking when needed.',
    ),
    LegalBlock.heading('2.1. Occasional care', small: true),
    LegalBlock.list([
      'With **24 hours\' notice or more**: full refund.',
      'With **less than 24 hours\' notice**: the service is charged, with no refund.',
    ]),
    LegalBlock.heading('2.2. Events', small: true),
    LegalBlock.paragraph('Because an event needs more planning and often more than one carer:'),
    LegalBlock.list([
      'With **7 days\' notice or more**: full refund.',
      'Between **3 and 7 days\' notice**: 50% refund.',
      'With **less than 72 hours\' notice**: the service is charged, with no refund.',
    ]),
    LegalBlock.heading('2.3. Emergency care', small: true),
    LegalBlock.paragraph('Because it is immediate, the rule depends on the status of the booking:'),
    LegalBlock.list([
      '**Before** Mon Cangur confirms the request and assigns the carer: full refund.',
      'Once the carer is **confirmed and assigned**: the service is charged, except in cases of force majeure or a cause attributable to Mon Cangur.',
    ]),
    LegalBlock.heading('3. Ongoing services (regular care and tutoring)'),
    LegalBlock.paragraph('The following applies to regular care and tutoring, which are recurring services.'),
    LegalBlock.heading('3.1. Notice', small: true),
    LegalBlock.paragraph(
      'Any cancellation or change must be sent in writing through one of the official channels (email infomoncangur@gmail.com or company WhatsApp +376 620 991), identifying the service (family, day and time).',
    ),
    LegalBlock.heading('3.2. Cancellation rules', small: true),
    LegalBlock.list([
      '**a)** With 24 hours\' notice or more: the session is still charged. The Family may move it to another date, subject to availability.',
      '**b)** With less than 24 hours\' notice: the session is still charged and, as a rule, cannot be moved.',
      '**c)** Force majeure: the Family may choose to move the session, subject to availability, or request a refund of the session or the corresponding hours.',
    ]),
    LegalBlock.heading('3.3. Moving a session', small: true),
    LegalBlock.paragraph(
      'A session that is moved must be booked within 4 weeks of the original date, subject to availability and written confirmation. If no date is found, the session is treated as delivered for payment purposes, except where force majeure applies and a refund was chosen.',
    ),
    LegalBlock.heading('3.4. The Family does not attend or prevents access', small: true),
    LegalBlock.paragraph(
      'If the service cannot start or be provided for a reason attributable to the Family, the session is still charged and may be moved subject to availability.',
    ),
    LegalBlock.heading('3.5. Late arrival or absence of the carer', small: true),
    LegalBlock.list([
      '**a)** More than 30 minutes late for a reason attributable to Mon Cangur: the Family may choose to move the session or request a refund of the affected session.',
      '**b)** Absence: Mon Cangur will offer a replacement from the team, a new date, or a refund of the affected session.',
    ]),
    LegalBlock.heading('4. Refunds'),
    LegalBlock.paragraph(
      'Refunds that are due are made, as a rule, to the same payment method, in line with this Policy and the Terms and Conditions.',
    ),
  ],
);

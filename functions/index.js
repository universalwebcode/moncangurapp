const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { buildPayment, verifyNotification, paymentAuthorised } = require('./redsys');

initializeApp();

const region = 'europe-southwest1';

function secret() {
  const value = process.env.REDSYS_SECRET || '';
  if (!value) throw new HttpsError('failed-precondition', 'missing-secret');
  return value;
}

function notifyUrl() {
  const project = process.env.GCLOUD_PROJECT || 'moncangur';
  return `https://${region}-${project}.cloudfunctions.net/redsysNotify`;
}

function allowedOrigin(origin) {
  let url;
  try {
    url = new URL(origin);
  } catch (error) {
    return false;
  }
  const host = url.hostname;
  if (host === 'localhost' || host === '127.0.0.1') return url.protocol === 'http:' || url.protocol === 'https:';
  if (host === 'moncangur.web.app' || host === 'moncangur.firebaseapp.com') return url.protocol === 'https:';
  return false;
}

function bizumPhone(raw) {
  if (typeof raw !== 'string') return '';
  const compact = raw.replace(/[\s.-]/g, '');
  if (/^\+\d{5,15}$/.test(compact)) return compact;
  if (/^376\d{6}$/.test(compact)) return `+${compact}`;
  return '';
}

function languageCode(lang) {
  switch (lang) {
    case 'es':
      return '001';
    case 'en':
      return '002';
    case 'fr':
      return '004';
    default:
      return '003';
  }
}

function newOrder() {
  const stamp = `${Date.now()}${Math.floor(Math.random() * 10)}`;
  return stamp.slice(-12);
}

function amountCents(total) {
  const cents = Math.round(Number(total) * 100);
  if (!Number.isFinite(cents) || cents < 1 || cents > 999999999999) return 0;
  return cents;
}

exports.createRedsysPayment = onCall({ region }, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'sign-in');
  const bookingId = request.data?.bookingId;
  const method = request.data?.method;
  const origin = request.data?.origin;
  if (typeof bookingId !== 'string' || !bookingId) throw new HttpsError('invalid-argument', 'booking');
  if (method !== 'bizum' && method !== 'card') throw new HttpsError('invalid-argument', 'method');
  if (typeof origin !== 'string' || !allowedOrigin(origin)) throw new HttpsError('invalid-argument', 'origin');

  const ref = getFirestore().collection('reservas').doc(bookingId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', 'booking');
  const data = snap.data() || {};
  if (data.padreId !== request.auth.uid) throw new HttpsError('permission-denied', 'owner');
  if (data.estadoPago === 'pagada') throw new HttpsError('failed-precondition', 'already-paid');
  const cents = amountCents(data.total);
  if (!cents) throw new HttpsError('failed-precondition', 'amount');

  const order = newOrder();
  const key = secret();
  const phone = method === 'bizum' ? bizumPhone(request.data?.phone) : '';
  const form = buildPayment({
    secret: key,
    order,
    amountCents: cents,
    fuc: process.env.REDSYS_FUC || '992244954',
    terminal: process.env.REDSYS_TERMINAL || '001',
    notifyUrl: notifyUrl(),
    urlOk: `${origin}/pago-ok.html?order=${order}`,
    urlKo: `${origin}/pago-ko.html?order=${order}`,
    method,
    phone,
    language: languageCode(request.data?.lang),
    bookingId,
    description: 'Reserva Mon Cangur',
  });

  await ref.set({
    redsysOrder: order,
    redsysAmount: String(cents),
    redsysMethod: method,
    estadoPago: 'pendiente',
    updated_time: FieldValue.serverTimestamp(),
  }, { merge: true });

  return {
    url: form.url,
    version: form.version,
    parameters: form.parameters,
    signature: form.signature,
    order,
  };
});

exports.redsysNotify = onRequest({ region }, async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('POST');
    return;
  }
  const body = req.body || {};
  const parameters = body.Ds_MerchantParameters || body.Ds_MerchantParameters;
  const signature = body.Ds_Signature;
  const key = process.env.REDSYS_SECRET || '';
  if (!parameters || !signature || !key) {
    res.status(400).send('bad-request');
    return;
  }
  let checked;
  try {
    checked = verifyNotification(parameters, signature, key);
  } catch (error) {
    res.status(400).send('bad-signature');
    return;
  }
  if (!checked.ok) {
    res.status(400).send('bad-signature');
    return;
  }
  const params = checked.params;
  const order = String(params.Ds_Order || '');
  const bookingId = String(params.Ds_MerchantData || '');
  const db = getFirestore();
  let ref = bookingId ? db.collection('reservas').doc(bookingId) : null;
  if (ref) {
    const snap = await ref.get();
    if (!snap.exists || snap.data()?.redsysOrder !== order) ref = null;
  }
  if (!ref) {
    const found = await db.collection('reservas').where('redsysOrder', '==', order).limit(1).get();
    if (!found.empty) ref = found.docs[0].ref;
  }
  if (!ref) {
    res.status(200).send('OK');
    return;
  }
  const snap = await ref.get();
  const storedAmount = String(snap.data()?.redsysAmount || '');
  const paid = paymentAuthorised(params) && storedAmount === String(params.Ds_Amount || '');
  await ref.set({
    estadoPago: paid ? 'pagada' : 'fallido',
    estado: paid ? 'confirmada' : 'pendiente',
    redsysResponse: String(params.Ds_Response || ''),
    redsysAuthCode: String(params.Ds_AuthorisationCode || ''),
    updated_time: FieldValue.serverTimestamp(),
  }, { merge: true });
  res.status(200).send('OK');
});

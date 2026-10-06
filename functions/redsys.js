const crypto = require('crypto');

const PRODUCTION_URL = 'https://sis.redsys.es/sis/realizarPago';

function zeroPad(buffer) {
  const extra = (8 - (buffer.length % 8)) % 8;
  if (extra === 0) return buffer;
  return Buffer.concat([buffer, Buffer.alloc(extra, 0)]);
}

function diversify(order, secret) {
  const key = Buffer.from(secret, 'base64');
  if (key.length !== 24) {
    throw new Error('bad-key');
  }
  const cipher = crypto.createCipheriv('des-ede3-cbc', key, Buffer.alloc(8, 0));
  cipher.setAutoPadding(false);
  const data = zeroPad(Buffer.from(String(order), 'utf8'));
  return Buffer.concat([cipher.update(data), cipher.final()]);
}

function sign(merchantParametersBase64, order, secret) {
  return crypto.createHmac('sha256', diversify(order, secret)).update(merchantParametersBase64).digest('base64');
}

function encodeParameters(params) {
  return Buffer.from(JSON.stringify(params), 'utf8').toString('base64');
}

function decodeParameters(merchantParametersBase64) {
  return JSON.parse(Buffer.from(merchantParametersBase64, 'base64').toString('utf8'));
}

function canonicalSignature(value) {
  let normalized = String(value).trim().replace(/-/g, '+').replace(/_/g, '/');
  const missing = normalized.length % 4;
  if (missing) normalized += '='.repeat(4 - missing);
  return Buffer.from(normalized, 'base64');
}

function signaturesMatch(expected, received) {
  const left = canonicalSignature(expected);
  const right = canonicalSignature(received);
  if (left.length === 0 || left.length !== right.length) return false;
  return crypto.timingSafeEqual(left, right);
}

function verifyNotification(merchantParametersBase64, signature, secret) {
  const params = decodeParameters(merchantParametersBase64);
  const order = params.Ds_Order || params.DS_ORDER || params.DS_MERCHANT_ORDER;
  if (!order || !signature) return { ok: false, params };
  const expected = sign(merchantParametersBase64, order, secret);
  return { ok: signaturesMatch(expected, signature), params };
}

function paymentAuthorised(params) {
  const code = Number.parseInt(params.Ds_Response, 10);
  return Number.isFinite(code) && code >= 0 && code <= 99;
}

function buildPayment({ secret, order, amountCents, fuc, terminal, notifyUrl, urlOk, urlKo, method, phone, language, bookingId, description }) {
  const params = {
    DS_MERCHANT_AMOUNT: String(amountCents),
    DS_MERCHANT_ORDER: order,
    DS_MERCHANT_MERCHANTCODE: fuc,
    DS_MERCHANT_CURRENCY: '978',
    DS_MERCHANT_TRANSACTIONTYPE: '0',
    DS_MERCHANT_TERMINAL: terminal,
    DS_MERCHANT_MERCHANTURL: notifyUrl,
    DS_MERCHANT_URLOK: urlOk,
    DS_MERCHANT_URLKO: urlKo,
    DS_MERCHANT_MERCHANTNAME: 'MON CANGUR VIRTUAL',
    DS_MERCHANT_PRODUCTDESCRIPTION: description,
    DS_MERCHANT_TITULAR: 'Mon Cangur',
    DS_MERCHANT_MERCHANTDATA: bookingId,
    DS_MERCHANT_CONSUMERLANGUAGE: language,
  };
  if (method === 'bizum') params.DS_MERCHANT_PAYMETHODS = 'z';
  if (phone) params.DS_MERCHANT_BIZUM_MOBILENUMBER = phone;
  const parameters = encodeParameters(params);
  return {
    url: process.env.REDSYS_URL || PRODUCTION_URL,
    version: 'HMAC_SHA256_V1',
    parameters,
    signature: sign(parameters, order, secret),
    order,
  };
}

module.exports = {
  PRODUCTION_URL,
  sign,
  encodeParameters,
  decodeParameters,
  verifyNotification,
  paymentAuthorised,
  buildPayment,
};

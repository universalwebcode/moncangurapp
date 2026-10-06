const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');
const { sign, encodeParameters, verifyNotification, paymentAuthorised, buildPayment } = require('./redsys');

const secret = crypto.randomBytes(24).toString('base64');

test('signature verifies the same parameters', () => {
  const parameters = encodeParameters({ DS_MERCHANT_ORDER: '123456789012', DS_MERCHANT_AMOUNT: '2500' });
  const signature = sign(parameters, '123456789012', secret);
  const checked = verifyNotification(parameters, signature, secret);
  assert.equal(checked.ok, true);
  assert.equal(checked.params.DS_MERCHANT_AMOUNT, '2500');
});

test('a changed payload fails verification', () => {
  const parameters = encodeParameters({ Ds_Order: '123456789012', Ds_Response: '0000', Ds_Amount: '2500' });
  const signature = sign(parameters, '123456789012', secret);
  const tampered = encodeParameters({ Ds_Order: '123456789012', Ds_Response: '0000', Ds_Amount: '1' });
  assert.equal(verifyNotification(tampered, signature, secret).ok, false);
});

test('authorised responses are 0 to 99', () => {
  assert.equal(paymentAuthorised({ Ds_Response: '0000' }), true);
  assert.equal(paymentAuthorised({ Ds_Response: '0099' }), true);
  assert.equal(paymentAuthorised({ Ds_Response: '0100' }), false);
  assert.equal(paymentAuthorised({ Ds_Response: '9998' }), false);
});

test('bizum request forces pay method z and card does not', () => {
  const common = {
    secret,
    order: '123456789012',
    amountCents: 2500,
    fuc: '992244954',
    terminal: '001',
    notifyUrl: 'https://example.test/notify',
    urlOk: 'https://example.test/pago-ok.html?order=123456789012',
    urlKo: 'https://example.test/pago-ko.html?order=123456789012',
    phone: '+376123456',
    language: '003',
    bookingId: 'abc',
    description: 'Reserva Mon Cangur',
  };
  const bizum = buildPayment({ ...common, method: 'bizum' });
  const card = buildPayment({ ...common, method: 'card' });
  const bizumParams = JSON.parse(Buffer.from(bizum.parameters, 'base64').toString('utf8'));
  const cardParams = JSON.parse(Buffer.from(card.parameters, 'base64').toString('utf8'));
  assert.equal(bizumParams.DS_MERCHANT_PAYMETHODS, 'z');
  assert.equal(bizumParams.DS_MERCHANT_TRANSACTIONTYPE, '0');
  assert.equal(bizumParams.DS_MERCHANT_BIZUM_MOBILENUMBER, '+376123456');
  assert.equal(cardParams.DS_MERCHANT_PAYMETHODS, undefined);
  assert.equal(verifyNotification(bizum.parameters, bizum.signature, secret).ok, true);
});

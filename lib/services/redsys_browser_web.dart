import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef RedsysMessage = void Function(bool ok, String order);

PaymentTab? openPaymentTab() {
  final opened = web.window.open('about:blank', 'moncangur_redsys', 'popup,width=460,height=720');
  if (opened == null) return null;
  return PaymentTab._(opened);
}

void submitRedsysForm({
  required String url,
  required String version,
  required String parameters,
  required String signature,
}) {
  final form = web.HTMLFormElement()
    ..method = 'POST'
    ..action = url
    ..target = 'moncangur_redsys';
  void field(String name, String value) {
    form.append(
      web.HTMLInputElement()
        ..type = 'hidden'
        ..name = name
        ..value = value,
    );
  }

  field('Ds_SignatureVersion', version);
  field('Ds_MerchantParameters', parameters);
  field('Ds_Signature', signature);
  web.document.body?.append(form);
  form.submit();
  form.remove();
}

String browserOrigin() => web.window.location.origin;

void listenForRedsys(RedsysMessage onMessage) {
  web.window.addEventListener(
    'message',
    (web.Event event) {
      if (!event.isA<web.MessageEvent>()) return;
      final data = (event as web.MessageEvent).data;
      if (data == null) return;
      final raw = data.dartify();
      final decoded = raw is String
          ? jsonDecode(raw)
          : raw;
      if (decoded is! Map || decoded['source'] != 'moncangur_redsys') return;
      final order = decoded['order'] is String ? decoded['order'] as String : '';
      onMessage(decoded['ok'] == true || decoded['success'] == true, order);
    }.toJS,
  );
}

class PaymentTab {
  PaymentTab._(this._window);

  final web.Window _window;

  void close() {
    _window.close();
  }

  void showMessage(String title, String body) {
    final html = '<!DOCTYPE html><html><head><meta charset="utf-8"><title>${_escape(title)}</title></head>'
        '<body style="margin:0;min-height:100vh;display:grid;place-items:center;background:#faf8f5;color:#1a1a1a;font-family:Nunito,system-ui,sans-serif">'
        '<main style="max-width:380px;padding:32px;text-align:center"><h1 style="font-size:22px">${_escape(title)}</h1>'
        '<p style="color:#6b6560;line-height:1.5">${_escape(body)}</p></main></body></html>';
    _window.document.open();
    _window.document.write(html.toJS);
    _window.document.close();
  }
}

String _escape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

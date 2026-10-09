import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<String?> pickChildPhoto() {
  final done = Completer<String?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*';
  input.onchange = ((web.Event event) {
    final file = input.files?.item(0);
    if (file == null) {
      if (!done.isCompleted) done.complete(null);
      return;
    }
    final reader = web.FileReader();
    reader.onloadend = ((web.Event event) {
      final result = reader.result;
      if (!done.isCompleted) done.complete(result == null ? null : (result as JSString).toDart);
    }).toJS;
    reader.readAsDataURL(file);
  }).toJS;
  input.click();
  return done.future;
}

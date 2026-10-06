typedef RedsysMessage = void Function(bool ok, String order);

PaymentTab? openPaymentTab() => null;

void submitRedsysForm({
  required String url,
  required String version,
  required String parameters,
  required String signature,
}) {}

void listenForRedsys(RedsysMessage onMessage) {}

String browserOrigin() => '';

class PaymentTab {
  void close() {}

  void showMessage(String title, String body) {}
}

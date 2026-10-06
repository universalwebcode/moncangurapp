import 'package:cloud_functions/cloud_functions.dart';

class RedsysForm {
  const RedsysForm({
    required this.url,
    required this.version,
    required this.parameters,
    required this.signature,
    required this.order,
  });

  final String url;
  final String version;
  final String parameters;
  final String signature;
  final String order;
}

class RedsysPayment {
  const RedsysPayment();

  Future<RedsysForm> create({
    required String bookingId,
    required int amountCents,
  }) async {
    final result = await FirebaseFunctions.instanceFor(region: 'us-central1').httpsCallable('crearPago').call({
      'idReserva': bookingId,
      'importeCentimos': amountCents,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    return RedsysForm(
      url: data['urlRedsys'] as String,
      version: data['Ds_SignatureVersion'] as String,
      parameters: data['Ds_MerchantParameters'] as String,
      signature: data['Ds_Signature'] as String,
      order: data['order'] is String ? data['order'] as String : '',
    );
  }
}

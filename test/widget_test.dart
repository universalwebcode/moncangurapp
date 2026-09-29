import 'package:cangur_app/main.dart';
import 'package:cangur_app/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login shows the recovered welcome line', (tester) async {
    await tester.pumpWidget(CangurApp(state: AppState()));
    expect(find.text('Benvingut a Mon Cangur!'), findsOneWidget);
    expect(find.text('familia@moncangur.ad'), findsWidgets);
  });
}

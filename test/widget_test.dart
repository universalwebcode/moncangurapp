import 'package:cangur_app/main.dart';
import 'package:cangur_app/state/app_state.dart';
import 'package:cangur_app/widgets/mc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login shows the recovered welcome line', (tester) async {
    await tester.pumpWidget(CangurApp(state: AppState()));
    expect(find.text('Benvingut a Mon Cangur!'), findsOneWidget);
    expect(find.text('familia@moncangur.ad'), findsWidgets);
  });

  testWidgets('time picker uses 24-hour entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(onPressed: () => pickTime(context, '10:00'), child: const Text('open'));
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);
    expect(find.text('10'), findsWidgets);
    expect(find.text('00'), findsWidgets);
  });
}

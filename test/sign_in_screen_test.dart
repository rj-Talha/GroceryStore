import 'package:daana/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows profile fields when creating a new account', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    await tester.tap(find.text('New here? Create account'));
    await tester.pumpAndSettle();

    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
  });
}

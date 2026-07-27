import 'package:flutter_test/flutter_test.dart';

import 'package:daana/screens/checkout_profile_utils.dart';

void main() {
  group('buildCheckoutProfileValues', () {
    test('prefers stored first and last name fields from Firestore', () {
      final values = buildCheckoutProfileValues(
        profileData: {
          'firstName': 'Ayesha',
          'lastName': 'Khan',
          'phone': '03123456789',
          'email': 'ayesha@example.com',
          'address': 'House 10, Gulberg',
          'location': 'Gulberg, Lahore',
        },
        displayName: 'Ayesha Khan',
        email: 'fallback@example.com',
      );

      expect(values['firstName'], 'Ayesha');
      expect(values['lastName'], 'Khan');
      expect(values['phone'], '03123456789');
      expect(values['email'], 'ayesha@example.com');
      expect(values['address'], 'House 10, Gulberg');
      expect(values['location'], 'Gulberg, Lahore');
    });

    test('falls back to display name when Firestore fields are missing', () {
      final values = buildCheckoutProfileValues(
        profileData: null,
        displayName: 'John Doe',
        email: 'john@example.com',
      );

      expect(values['firstName'], 'John');
      expect(values['lastName'], 'Doe');
      expect(values['email'], 'john@example.com');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import '../lib/screens/location_picker_utils.dart';

void main() {
  group('Pakistan location helpers', () {
    test('accepts a point inside Pakistan bounds', () {
      expect(isWithinPakistanBounds(30.3753, 69.3451), isTrue);
      expect(isWithinPakistanBounds(24.8607, 67.0011), isTrue);
    });

    test('rejects a point outside Pakistan bounds', () {
      expect(isWithinPakistanBounds(12.9716, 77.5946), isFalse);
      expect(isWithinPakistanBounds(40.7128, -74.0060), isFalse);
    });

    test('formats a selected location string with coordinates', () {
      final value = formatLocationSummary(
        latitude: 24.8607,
        longitude: 67.0011,
        displayName: 'Gulshan-e-Iqbal, Karachi',
      );

      expect(value, contains('Gulshan-e-Iqbal, Karachi'));
      expect(value, contains('24.8607'));
      expect(value, contains('67.0011'));
    });
  });
}

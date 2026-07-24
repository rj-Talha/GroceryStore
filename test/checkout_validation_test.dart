import 'package:daana/screens/checkout_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkout validation', () {
    test('accepts alphabetic names only', () {
      expect(validateAlphabeticName('John'), isNull);
      expect(validateAlphabeticName('Ali'), isNull);
      expect(validateAlphabeticName('John123'), 'Only letters are allowed');
      expect(validateAlphabeticName('John Doe'), 'Only letters are allowed');
    });

    test('validates card expiry month and year range', () {
      expect(validateExpiryDate('12/26'), isNull);
      expect(validateExpiryDate('01/32'), isNull);
      expect(validateExpiryDate('13/26'), 'Enter a valid month/year');
      expect(validateExpiryDate('12/25'), 'Enter a valid month/year');
      expect(validateExpiryDate('12/33'), 'Enter a valid month/year');
    });

    test('validates card number format and length', () {
      expect(validateCardNumber('1234-5678-9012-3456'), isNull);
      expect(validateCardNumber('1234567890123456'), isNull);
      expect(
        validateCardNumber('1234-5678-9012-345'),
        'Enter a valid card number',
      );
      expect(
        validateCardNumber('1234-5678-9012-34567'),
        'Enter a valid card number',
      );
    });
  });
}

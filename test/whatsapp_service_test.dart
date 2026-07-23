import 'package:flutter_test/flutter_test.dart';
import 'package:daana/services/whatsapp_service.dart';

void main() {
  group('WhatsAppService', () {
    test('builds a confirmation message with the customer name and total', () {
      final message = WhatsAppService.buildConfirmationMessage(
        customerName: 'Ali Khan',
        total: 1299.5,
      );

      expect(message, contains('Ali Khan'));
      expect(message, contains('1299.5'));
      expect(message, contains('Order confirmed'));
    });
  });
}

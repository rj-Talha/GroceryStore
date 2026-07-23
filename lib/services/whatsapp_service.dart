import 'dart:convert';
import 'package:http/http.dart' as http;

class WhatsAppSendResult {
  final bool success;
  final int? statusCode;
  final String body;
  final String? error;

  WhatsAppSendResult({
    required this.success,
    this.statusCode,
    required this.body,
    this.error,
  });
}

class WhatsAppService {
  static const String _defaultApiUrl = 'https://api.twilio.com/2010-04-01/Accounts';

  static String get accountSid =>
      const String.fromEnvironment('TWILIO_ACCOUNT_SID', defaultValue: '');
  static String get authToken =>
      const String.fromEnvironment('TWILIO_AUTH_TOKEN', defaultValue: '');
  static String get apiKey {
    final apiKey = const String.fromEnvironment('TWILIO_API_KEY', defaultValue: '');
    return apiKey.isNotEmpty ? apiKey : authToken;
  }

  static String get fromNumber =>
      const String.fromEnvironment('TWILIO_WHATSAPP_FROM', defaultValue: '');

  static String buildConfirmationMessage({
    required String customerName,
    required num total,
  }) {
    return 'Order confirmed for $customerName. Your order total is PKR $total. Thank you for shopping with Daana!';
  }

  static Future<WhatsAppSendResult> sendOrderConfirmation({
    required String phoneNumber,
    required String customerName,
    required num total,
    required String apiKey,
    required String accountSid,
    required String fromNumber,
  }) async {
    final normalizedPhone = _normalizePhone(phoneNumber);
    if (normalizedPhone == null || accountSid.isEmpty || apiKey.isEmpty || fromNumber.isEmpty) {
      return WhatsAppSendResult(
        success: false,
        statusCode: null,
        body: 'Missing or invalid Twilio credentials or phone number.',
        error: 'invalid_input',
      );
    }

    final message = buildConfirmationMessage(
      customerName: customerName,
      total: total,
    );

    final uri = Uri.parse('$_defaultApiUrl/$accountSid/Messages.json');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$apiKey'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': normalizedPhone,
          'From': fromNumber,
          'Body': message,
        },
      );

      final success = response.statusCode >= 200 && response.statusCode < 300;
      return WhatsAppSendResult(
        success: success,
        statusCode: response.statusCode,
        body: response.body,
        error: success ? null : 'http_error',
      );
    } catch (e) {
      return WhatsAppSendResult(
        success: false,
        statusCode: null,
        body: e.toString(),
        error: 'network_error',
      );
    }
  }

  static String? _normalizePhone(String phoneNumber) {
    final value = phoneNumber.trim();
    if (value.isEmpty) {
      return null;
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return null;
    }

    if (digits.startsWith('92')) {
      return 'whatsapp:+$digits';
    }

    if (digits.startsWith('0')) {
      return 'whatsapp:+92${digits.substring(1)}';
    }

    return 'whatsapp:+92$digits';
  }
}

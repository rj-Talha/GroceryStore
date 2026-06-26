import 'package:flutter_test/flutter_test.dart';

import 'package:daana/screens/admin_portal_screen.dart';

void main() {
  group('admin credential detection', () {
    test('matches the hard-coded admin credentials', () {
      expect(isAdminCredential('r.jtalha@gmail.com', 'admin123'), isTrue);
    });

    test('rejects other credentials', () {
      expect(isAdminCredential('someone@example.com', 'password'), isFalse);
      expect(isAdminCredential('r.jtalha@gmail.com', 'wrong'), isFalse);
    });
  });
}

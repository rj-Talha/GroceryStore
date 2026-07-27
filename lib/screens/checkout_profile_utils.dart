Map<String, String> buildCheckoutProfileValues({
  Map<String, dynamic>? profileData,
  String? displayName,
  String? email,
}) {
  final normalizedProfile = profileData ?? const <String, dynamic>{};
  final firstName = (normalizedProfile['firstName'] as String? ?? '').trim();
  final lastName = (normalizedProfile['lastName'] as String? ?? '').trim();
  final fullName = (displayName ?? '').trim();

  String parseFirstName() {
    if (firstName.isNotEmpty) {
      return firstName;
    }
    if (fullName.isEmpty) {
      return '';
    }
    final parts = fullName.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  String parseLastName() {
    if (lastName.isNotEmpty) {
      return lastName;
    }
    if (fullName.isEmpty) {
      return '';
    }
    final parts = fullName.split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return '';
    }
    return parts.sublist(1).join(' ');
  }

  return {
    'firstName': parseFirstName(),
    'lastName': parseLastName(),
    'phone': (normalizedProfile['phone'] as String? ?? '').trim(),
    'email': (normalizedProfile['email'] as String? ?? email ?? '').trim(),
    'address': (normalizedProfile['address'] as String? ?? '').trim(),
    'location': (normalizedProfile['location'] as String? ?? '').trim(),
  };
}

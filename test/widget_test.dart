import 'package:flutter_test/flutter_test.dart';

import 'package:somiti_app/core/utils/formatters.dart';
import 'package:somiti_app/shared/models/models.dart';

void main() {
  test('money formatter uses Bangla digits', () {
    final s = Formatters.money(1500);
    expect(s.contains('টাকা'), isTrue);
    expect(s.contains(RegExp('[০-৯]')), isTrue);
  });

  test('super admin is treated as a member-like user for counting', () {
    const user = AppUser(
      id: 'super-1',
      name: 'Super Admin',
      phone: '01700000000',
      role: UserRole.superAdmin,
    );

    expect(user.isMemberCountEligible, isTrue);
  });
}

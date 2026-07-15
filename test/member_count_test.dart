import 'package:flutter_test/flutter_test.dart';
import 'package:somiti_app/shared/models/models.dart';

void main() {
  group('member count eligibility', () {
    test('counts super admin as a member for dashboard totals', () {
      final users = <AppUser>[
        const AppUser(
          id: '1',
          name: 'Super Admin',
          phone: '01700000000',
          role: UserRole.superAdmin,
        ),
        const AppUser(
          id: '2',
          name: 'Member',
          phone: '01700000001',
          role: UserRole.member,
        ),
        const AppUser(
          id: '3',
          name: 'Collector',
          phone: '01700000002',
          role: UserRole.collector,
        ),
      ];

      expect(users.countMemberEligibleUsers(), 3);
    });
  });
}

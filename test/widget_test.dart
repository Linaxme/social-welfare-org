import 'package:flutter_test/flutter_test.dart';

import 'package:somiti_app/core/utils/formatters.dart';

void main() {
  test('money formatter uses Bangla digits', () {
    final s = Formatters.money(1500);
    expect(s.contains('টাকা'), isTrue);
    expect(s.contains(RegExp('[০-৯]')), isTrue);
  });
}

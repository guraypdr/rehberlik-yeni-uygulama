import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/shared/navigation/app_navigation.dart';

void main() {
  group('appDestinations', () {
    test('modül kimlikleri benzersizdir', () {
      final ids = appDestinations.map((item) => item.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('her modülün etiketi boş değildir', () {
      for (final destination in appDestinations) {
        expect(destination.label.trim(), isNotEmpty);
      }
    });

    test('initialDestinationId listede bulunur', () {
      expect(appDestinations.any((d) => d.id == initialDestinationId), isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/setup/presentation/setup_page.dart';

void main() {
  testWidgets('kurulumda psikolojik danışman bilgisi zorunlu ve önizlenir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith(() => _SessionNotifier())],
        child: const MaterialApp(home: SetupPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Ankara Ortaokulu',
    );
    await tester.tap(find.text('İleri →'));
    await tester.pumpAndSettle();
    expect(
      find.text('Psikolojik danışman adı ve soyadı zorunludur.'),
      findsNWidgets(2),
    );

    await tester.enterText(find.byKey(const Key('counselor_name')), 'Ayşe');
    await tester.enterText(
      find.byKey(const Key('counselor_surname')),
      'Yılmaz',
    );
    await tester.tap(find.text('Ortaokul'));
    await tester.tap(find.text('İleri →'));
    await tester.pumpAndSettle();

    expect(find.text('Psikolojik Danışman'), findsOneWidget);
    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('Ankara Ortaokulu'), findsOneWidget);
  });
}

class _SessionNotifier extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState();
}

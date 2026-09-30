import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/app/rehberlik_app.dart';
import 'package:rehberlik_app/shared/navigation/app_navigation.dart';

void main() {
  group('appDestinations', () {
    test('modül kimlikleri benzersizdir', () {
      final ids = appDestinations.map((item) => item.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('açılış modülü listede bulunur', () {
      expect(appDestinationById(initialDestinationId), isNotNull);
    });

    test('bilinmeyen kimlik için null döner', () {
      expect(appDestinationById('olmayan-modul'), isNull);
    });

    test('her modülün etiketi boş değildir', () {
      for (final destination in appDestinations) {
        expect(destination.label.trim(), isNotEmpty);
      }
    });
  });

  /// Test penceresini verilen boyuta ayarlar.
  Future<void> setWindowSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('açılışta Ana Sayfa seçilidir', (tester) async {
    await setWindowSize(tester, const Size(1400, 900));
    await tester.pumpWidget(const RehberlikApp());
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsWidgets);
    expect(find.text('Çalışma alanı hazırlanıyor'), findsOneWidget);
    expect(find.byKey(const Key('todo_input')), findsNothing);
  });

  testWidgets('menüden Yapılacaklar sayfasına geçilir', (tester) async {
    await setWindowSize(tester, const Size(1400, 900));
    await tester.pumpWidget(const RehberlikApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sidebar_item_todos')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('todo_input')), findsOneWidget);
    expect(find.text('Yapılacaklar'), findsWidgets);
  });

  testWidgets('görev eklenir, tamamlanır ve silinir', (tester) async {
    await setWindowSize(tester, const Size(1400, 900));
    await tester.pumpWidget(const RehberlikApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebar_item_todos')));
    await tester.pumpAndSettle();

    // Yeni görev ekleme.
    await tester.enterText(find.byKey(const Key('todo_input')), 'Yeni görev');
    await tester.tap(find.byKey(const Key('todo_add_button')));
    await tester.pumpAndSettle();

    expect(find.text('Yeni görev'), findsOneWidget);
    expect(find.text('3 açık görev • 1 tamamlandı'), findsOneWidget);

    // Tamamlama işaretleme.
    await tester.tap(find.byKey(const Key('todo_checkbox_sample_1')));
    await tester.pumpAndSettle();

    expect(find.text('2 açık görev • 2 tamamlandı'), findsOneWidget);

    // Silme.
    await tester.tap(find.byKey(const Key('todo_delete_sample_2')));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenci dosyalarını güncelle'), findsNothing);
  });

  testWidgets('sayfa değişince ekleme alanındaki metin korunur', (
    tester,
  ) async {
    await setWindowSize(tester, const Size(1400, 900));
    await tester.pumpWidget(const RehberlikApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebar_item_todos')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('todo_input')), 'Yarım kalan');
    await tester.pump();

    await tester.tap(find.byKey(const Key('sidebar_item_home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebar_item_todos')));
    await tester.pumpAndSettle();

    expect(find.text('Yarım kalan'), findsOneWidget);
  });

  testWidgets('dar pencerede menü ikon şeridine daralır', (tester) async {
    await setWindowSize(tester, const Size(900, 700));
    await tester.pumpWidget(const RehberlikApp());
    await tester.pumpAndSettle();

    final sidebar = tester.getSize(find.byKey(const Key('sidebar')));
    expect(sidebar.width, 68);
  });

  testWidgets('geniş pencerede menü etiketleri görünür', (tester) async {
    await setWindowSize(tester, const Size(1400, 900));
    await tester.pumpWidget(const RehberlikApp());
    await tester.pumpAndSettle();

    final sidebar = tester.getSize(find.byKey(const Key('sidebar')));
    expect(sidebar.width, 236);
    expect(find.text('Yapılacaklar'), findsOneWidget);
  });

  testWidgets('dar içerik alanında ekleme alanı dikey dizilir', (tester) async {
    // 600 px pencere: menü ikon şeridine düşer, içerik alanı daralır.
    await setWindowSize(tester, const Size(600, 700));
    await tester.pumpWidget(const RehberlikApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebar_item_todos')));
    await tester.pumpAndSettle();

    final input = tester.getTopLeft(find.byKey(const Key('todo_input')));
    final button = tester.getTopLeft(find.byKey(const Key('todo_add_button')));

    // Buton alanın altında olmalı (dikey dizilim).
    expect(button.dy, greaterThan(input.dy));
  });
}

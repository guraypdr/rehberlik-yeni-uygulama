import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/teachers/domain/teacher.dart';
import 'package:rehberlik_app/features/teachers/presentation/teachers_provider.dart';
import 'package:rehberlik_app/features/teachers/presentation/widgets/teacher_composer.dart';
import 'package:rehberlik_app/features/teachers/presentation/widgets/teacher_import_dialog.dart';

void main() {
  testWidgets('zorunlu alanları doğrular ve tüm öğretmen bilgilerini ekler', (
    tester,
  ) async {
    final notifier = _FakeTeachersNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [teachersProvider.overrideWith(() => notifier)],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: TeacherComposer())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('teacher_add_button')));
    await tester.pumpAndSettle();
    expect(find.text('Bu alan zorunludur'), findsNWidgets(3));
    expect(notifier.createdTeacher, isNull);

    await tester.enterText(find.byKey(const Key('teacher_name_input')), 'Ayşe');
    await tester.enterText(
      find.byKey(const Key('teacher_surname_input')),
      'Yılmaz',
    );
    await tester.enterText(
      find.byKey(const Key('teacher_branch_input')),
      'Türkçe',
    );
    await tester.enterText(
      find.byKey(const Key('teacher_email_input')),
      'ayse@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('teacher_phone_input')),
      '05551234567',
    );
    await tester.tap(find.byKey(const Key('teacher_add_button')));
    await tester.pumpAndSettle();

    expect(notifier.createdTeacher, isNotNull);
    expect(notifier.createdTeacher!.fullName, 'Ayşe Yılmaz');
    expect(notifier.createdTeacher!.branch, 'Türkçe');
    expect(notifier.createdTeacher!.email, 'ayse@example.com');
    expect(notifier.createdTeacher!.phone, '05551234567');
  });

  testWidgets('e-posta boş bırakılabilir ancak hatalıysa reddedilir', (
    tester,
  ) async {
    final notifier = _FakeTeachersNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [teachersProvider.overrideWith(() => notifier)],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: TeacherComposer())),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('teacher_name_input')), 'Ali');
    await tester.enterText(
      find.byKey(const Key('teacher_surname_input')),
      'Kaya',
    );
    await tester.enterText(
      find.byKey(const Key('teacher_branch_input')),
      'Matematik',
    );
    await tester.enterText(
      find.byKey(const Key('teacher_email_input')),
      'gecersiz',
    );
    await tester.tap(find.byKey(const Key('teacher_add_button')));
    await tester.pumpAndSettle();

    expect(find.text('Geçerli bir e-posta girin'), findsOneWidget);
    expect(notifier.createdTeacher, isNull);
  });

  testWidgets('Excel satırlarını önizleyip geçerli öğretmenleri toplu ekler', (
    tester,
  ) async {
    final notifier = _FakeTeachersNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [teachersProvider.overrideWith(() => notifier)],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: TeacherComposer())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('teacher_import_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('teacher_import_input')),
      'Adı\tSoyadı\tBranş\tE-posta\tCep telefonu\n'
      'Ayşe\tYılmaz\tTürkçe\tayse@example.com\t05551234567\n'
      'Mehmet\tKaya\tMatematik\t\t\n'
      'Eksik\t\tFen\tbad-email\t',
    );
    await tester.pumpAndSettle();

    expect(find.text('Önizleme (3 satır)'), findsOneWidget);
    expect(find.text('2 geçerli'), findsOneWidget);
    expect(find.text('1 hatalı'), findsOneWidget);

    await tester.tap(find.byKey(const Key('teacher_import_confirm')));
    await tester.pumpAndSettle();

    expect(notifier.importedTeachers, hasLength(2));
    expect(notifier.importedTeachers.first.email, 'ayse@example.com');
    expect(notifier.importedTeachers.last.email, isNull);
    expect(find.text('2 öğretmen eklendi.'), findsOneWidget);
    expect(find.byType(TeacherImportDialog), findsNothing);
  });
}

class _FakeTeachersNotifier extends TeachersNotifier {
  Teacher? createdTeacher;
  List<Teacher> importedTeachers = [];

  @override
  Future<List<Teacher>> build() async => [];

  @override
  Future<void> addTeacher({
    required String name,
    required String surname,
    required String branch,
    String? email,
    String? phone,
  }) async {
    createdTeacher = Teacher(
      id: 1,
      name: name,
      surname: surname,
      branch: branch,
      email: email,
      phone: phone,
    );
    state = AsyncValue.data([createdTeacher!]);
  }

  @override
  Future<int> addBatch(List<Teacher> teachers) async {
    importedTeachers = teachers;
    state = AsyncValue.data(teachers);
    return teachers.length;
  }
}

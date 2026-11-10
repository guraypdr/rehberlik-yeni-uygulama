import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/classes/data/school_risk_dao.dart';
import 'package:rehberlik_app/features/classes/domain/grade_level.dart';
import 'package:rehberlik_app/features/classes/domain/school_class.dart';
import 'package:rehberlik_app/features/classes/domain/student_risk_question.dart';
import 'package:rehberlik_app/features/classes/presentation/classes_provider.dart';
import 'package:rehberlik_app/features/classes/presentation/school_risk_map_page.dart';
import 'package:rehberlik_app/features/classes/presentation/school_risk_provider.dart';

void main() {
  testWidgets('sınıf adlarını solda ve her risk sorusunun sayısını gösterir', (
    tester,
  ) async {
    const schoolClass = SchoolClass(
      id: 3,
      gradeLevelId: 1,
      gradeLevelLabel: '9. Sınıf',
      branch: 'A',
    );
    final counts = {
      schoolClass.id: {
        for (final question in studentRiskQuestions) question.key: 0,
      }..['mother_low_education'] = 2,
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          classesProvider.overrideWith(() => _FakeClassesNotifier(schoolClass)),
          schoolRiskCountsProvider.overrideWith(
            () => _FakeSchoolRiskCountsNotifier(counts),
          ),
        ],
        child: const MaterialApp(home: SchoolRiskMapPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('9/A'), findsOneWidget);
    expect(find.byKey(const Key('print_school_risk_map')), findsOneWidget);
    expect(
      find.byKey(const Key('school_risk_horizontal_scroll')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Scrollbar>(
            find.byKey(const Key('school_risk_horizontal_scrollbar')),
          )
          .thumbVisibility,
      isTrue,
    );
    expect(
      tester
          .widget<Scrollbar>(
            find.byKey(const Key('school_risk_vertical_scrollbar')),
          )
          .thumbVisibility,
      isTrue,
    );
    expect(
      find.byKey(const Key('school_risk_count_3_mother_low_education')),
      findsOneWidget,
    );
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('A4 yatay genişliğinde risk sütunlarını ekrana sığdırır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1123, 794);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          classesProvider.overrideWith(
            () => _FakeClassesNotifier(
              const SchoolClass(
                id: 3,
                gradeLevelId: 1,
                gradeLevelLabel: '9. Sınıf',
                branch: 'A',
              ),
            ),
          ),
          schoolRiskCountsProvider.overrideWith(
            () => _FakeSchoolRiskCountsNotifier(const {}),
          ),
        ],
        child: const MaterialApp(home: SchoolRiskMapPage()),
      ),
    );
    await tester.pumpAndSettle();

    final horizontalScrollable = find.descendant(
      of: find.byKey(const Key('school_risk_horizontal_scroll')),
      matching: find.byType(Scrollable),
    );
    expect(
      tester
          .state<ScrollableState>(horizontalScrollable)
          .position
          .maxScrollExtent,
      0,
    );
  });
}

class _FakeClassesNotifier extends ClassesNotifier {
  _FakeClassesNotifier(SchoolClass schoolClass) : _schoolClass = schoolClass;

  final SchoolClass _schoolClass;

  @override
  Future<ClassesState> build() async => ClassesState(
    gradeLevels: [
      GradeLevel(
        id: _schoolClass.gradeLevelId,
        label: '9. Sınıf',
        sortOrder: 1,
      ),
    ],
    classes: [_schoolClass],
  );
}

class _FakeSchoolRiskCountsNotifier extends SchoolRiskCountsNotifier {
  _FakeSchoolRiskCountsNotifier(this.counts);

  final SchoolRiskCounts counts;

  @override
  Future<SchoolRiskCounts> build() async => counts;
}

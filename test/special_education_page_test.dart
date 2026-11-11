import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/special_education/domain/bep_meeting.dart';
import 'package:rehberlik_app/features/special_education/presentation/bep_meetings_provider.dart';
import 'package:rehberlik_app/features/special_education/presentation/special_education_page.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/student_profile_page.dart';
import 'package:rehberlik_app/features/teachers/domain/teacher.dart';
import 'package:rehberlik_app/features/teachers/presentation/teachers_provider.dart';

void main() {
  testWidgets('yalnız özel eğitim olarak işaretli öğrencileri listeler', (
    tester,
  ) async {
    const students = [
      Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Zeynep',
        surname: 'Kaya',
        createdAt: '2026-11-11',
        hasSpecialEducation: true,
        className: '9/A',
      ),
      Student(
        id: 2,
        classId: 2,
        number: '102',
        name: 'Ali',
        surname: 'Demir',
        createdAt: '2026-11-11',
        hasSpecialEducation: false,
        className: '9/A',
      ),
      Student(
        id: 3,
        classId: 3,
        number: '201',
        name: 'Ayşe',
        surname: 'Arı',
        createdAt: '2026-11-11',
        hasSpecialEducation: true,
        className: '10/B',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _StudentsNotifier(students)),
        ],
        child: const MaterialApp(home: Scaffold(body: SpecialEducationPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('special_education_students_table')),
      findsOneWidget,
    );
    expect(find.text('Ali Demir'), findsNothing);
    expect(find.text('Ayşe Arı'), findsOneWidget);
    expect(find.text('Zeynep Kaya'), findsOneWidget);

    await tester.tap(find.byKey(const Key('special_education_student_3')));
    await tester.pumpAndSettle();

    expect(find.byType(StudentProfilePage), findsOneWidget);
    expect(find.text('Özel Eğitim'), findsOneWidget);
  });

  testWidgets('özel eğitim öğrencisi yoksa boş durum mesajı gösterilir', (
    tester,
  ) async {
    const student = Student(
      id: 1,
      classId: 2,
      number: '101',
      name: 'Ali',
      surname: 'Demir',
      createdAt: '2026-11-11',
      hasSpecialEducation: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _StudentsNotifier([student])),
        ],
        child: const MaterialApp(home: Scaffold(body: SpecialEducationPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('special_education_empty')), findsOneWidget);
    expect(
      find.byKey(const Key('special_education_students_table')),
      findsNothing,
    );
  });

  testWidgets('BEP toplantısı için öğrenci, öğretmen ve gündem seçilir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const students = [
      Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Ayşe',
        surname: 'Kaya',
        createdAt: '2026-11-11',
        hasSpecialEducation: true,
        className: '9/A',
      ),
      Student(
        id: 2,
        classId: 2,
        number: '102',
        name: 'Ali',
        surname: 'Demir',
        createdAt: '2026-11-11',
        hasSpecialEducation: false,
        className: '9/A',
      ),
    ];
    const teachers = [
      Teacher(id: 5, name: 'Zeynep', surname: 'Arı', branch: 'Türkçe'),
      Teacher(id: 6, name: 'Mehmet', surname: 'Yılmaz', branch: 'Matematik'),
    ];
    final meetingsNotifier = _MeetingsNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _StudentsNotifier(students)),
          teachersProvider.overrideWith(() => _TeachersNotifier(teachers)),
          bepMeetingsProvider.overrideWith(() => meetingsNotifier),
        ],
        child: const MaterialApp(home: Scaffold(body: SpecialEducationPage())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_bep_meeting')));
    await tester.pumpAndSettle();
    expect(find.text('Ayşe Kaya'), findsNWidgets(2));
    expect(find.text('Ali Demir'), findsNothing);

    await tester.tap(find.byKey(const Key('bep_meeting_student_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bep_meeting_continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bep_meeting_teacher_5')), findsOneWidget);
    expect(find.byKey(const Key('bep_meeting_teacher_6')), findsOneWidget);
    await tester.tap(find.byKey(const Key('bep_meeting_teacher_5')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('bep_meeting_agenda_5')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('bep_meeting_details')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bep_meeting_agenda_5')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('bep_meeting_agenda_input')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('bep_meeting_details')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.byKey(const Key('bep_meeting_agenda_input')),
      'Ek gündem maddesi',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('bep_meeting_decision_0')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('bep_meeting_details')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('bep_meeting_decision_0')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('bep_meeting_decision_input')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('bep_meeting_details')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.byKey(const Key('bep_meeting_decision_input')),
      'Ek karar',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bep_meeting_save')));
    await tester.pumpAndSettle();

    expect(meetingsNotifier.studentId, 1);
    expect(meetingsNotifier.teacherIds, [5]);
    expect(meetingsNotifier.agendaItems, hasLength(6));
    expect(meetingsNotifier.agendaItems, contains('Ek gündem maddesi'));
    expect(meetingsNotifier.decisions, [
      bepMeetingDecisionItems[0],
      'Ek karar',
    ]);
    expect(
      meetingsNotifier.agendaItems,
      isNot(contains(bepMeetingAgendaItems[5])),
    );
  });

  testWidgets('toplantı numaralarını öğrenciye göre sayar ve toplantı siler', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final notifier = _MeetingsNotifier([
      _meeting(id: 1, studentId: 1, meetingDate: '2026-03-01'),
      _meeting(id: 2, studentId: 1, meetingDate: '2026-01-01'),
      _meeting(id: 3, studentId: 2, meetingDate: '2026-02-01'),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _StudentsNotifier([])),
          teachersProvider.overrideWith(() => _TeachersNotifier([])),
          bepMeetingsProvider.overrideWith(() => notifier),
        ],
        child: const MaterialApp(home: Scaffold(body: SpecialEducationPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2. Toplantı · Ayşe Kaya · 101'), findsOneWidget);
    expect(find.text('1. Toplantı · Ayşe Kaya · 101'), findsOneWidget);
    expect(find.text('1. Toplantı · Ali Demir · 102'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bep_meeting_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_bep_meeting_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete_bep_meeting_2')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bep_meeting_2')), findsNothing);
    expect(find.text('1. Toplantı · Ayşe Kaya · 101'), findsOneWidget);
  });
}

class _StudentsNotifier extends StudentsNotifier {
  _StudentsNotifier(this.students);

  final List<Student> students;

  @override
  Future<List<Student>> build() async => students;
}

class _TeachersNotifier extends TeachersNotifier {
  _TeachersNotifier(this.teachers);

  final List<Teacher> teachers;

  @override
  Future<List<Teacher>> build() async => teachers;
}

class _MeetingsNotifier extends BepMeetingsNotifier {
  _MeetingsNotifier([this.initialMeetings = const []]);

  final List<BepMeeting> initialMeetings;
  int? studentId;
  List<int> teacherIds = [];
  List<String> agendaItems = [];
  List<String> decisions = [];

  @override
  Future<List<BepMeeting>> build() async => initialMeetings;

  @override
  Future<void> deleteMeeting(int meetingId) async {
    state = AsyncValue.data(
      state.valueOrNull!.where((meeting) => meeting.id != meetingId).toList(),
    );
  }

  @override
  Future<void> addMeeting({
    required int studentId,
    required List<int> teacherIds,
    required String meetingDate,
    required List<String> agendaItems,
    required List<String> decisions,
  }) async {
    this.studentId = studentId;
    this.teacherIds = teacherIds;
    this.agendaItems = agendaItems;
    this.decisions = decisions;
    state = AsyncValue.data([
      BepMeeting(
        id: 1,
        studentId: studentId,
        studentName: 'Ayşe Kaya',
        studentNumber: '101',
        className: '9/A',
        meetingDate: meetingDate,
        agendaItems: agendaItems,
        decisions: decisions,
        teacherNames: ['Zeynep Arı'],
        createdAt: meetingDate,
      ),
    ]);
  }
}

BepMeeting _meeting({
  required int id,
  required int studentId,
  required String meetingDate,
}) => BepMeeting(
  id: id,
  studentId: studentId,
  studentName: studentId == 1 ? 'Ayşe Kaya' : 'Ali Demir',
  studentNumber: studentId == 1 ? '101' : '102',
  className: '9/A',
  meetingDate: meetingDate,
  agendaItems: [bepMeetingAgendaItems.first],
  decisions: const [],
  teacherNames: const ['Zeynep Arı'],
  createdAt: meetingDate,
);

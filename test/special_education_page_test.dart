import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/settings/domain/school_staff.dart';
import 'package:rehberlik_app/features/settings/presentation/school_staff_provider.dart';
import 'package:rehberlik_app/features/special_education/domain/bep_meeting.dart';
import 'package:rehberlik_app/features/special_education/domain/student_subject_need.dart';
import 'package:rehberlik_app/features/special_education/presentation/bep_meetings_provider.dart';
import 'package:rehberlik_app/features/special_education/presentation/special_education_page.dart';
import 'package:rehberlik_app/features/special_education/presentation/special_education_student_profile_page.dart';
import 'package:rehberlik_app/features/special_education/presentation/student_subject_needs_provider.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';
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

    expect(find.byType(SpecialEducationStudentProfilePage), findsOneWidget);
    expect(find.text('Özel Eğitim · Ayşe Arı'), findsOneWidget);
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

  testWidgets('öğrenci profilinden ders ihtiyaçları diyaloğu açılır', (
    tester,
  ) async {
    const student = Student(
      id: 21,
      classId: 2,
      number: '121',
      name: 'Ece',
      surname: 'Yıldız',
      createdAt: '2026-11-11',
      hasSpecialEducation: true,
      className: '9/A',
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

    final studentLink = find.byKey(const Key('special_education_student_21'));
    await tester.ensureVisible(studentLink);
    await tester.tap(studentLink);
    await tester.pumpAndSettle();

    expect(find.byType(SpecialEducationStudentProfilePage), findsOneWidget);

    final needsButton = find.byKey(const Key('student_subject_needs'));
    await tester.ensureVisible(needsButton);
    await tester.tap(needsButton);
    await tester.pumpAndSettle();

    expect(find.text('Ece Yıldız · Ders ihtiyaçları'), findsOneWidget);
    expect(find.text('Ders bulunmuyor'), findsOneWidget);
  });

  testWidgets(
    'öğrenci profilinden BEP toplantısı katılımcı ve gündemi kaydedilir',
    (tester) async {
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
          motherName: 'Fatma',
          motherSurname: 'Kaya',
          fatherName: 'Hasan',
          fatherSurname: 'Kaya',
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
            schoolStaffProvider.overrideWith(
              () => _SchoolStaffNotifier(const [
                SchoolStaff(
                  id: 7,
                  role: SchoolStaffRole.principal,
                  name: 'Ahmet',
                  surname: 'Yılmaz',
                ),
                SchoolStaff(
                  id: 8,
                  role: SchoolStaffRole.counselor,
                  name: 'Elif',
                  surname: 'Şahin',
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SpecialEducationPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('special_education_student_1')));
      await tester.pumpAndSettle();
      expect(find.byType(SpecialEducationStudentProfilePage), findsOneWidget);

      final addMeetingButton = find.byKey(const Key('add_student_bep_meeting'));
      await tester.ensureVisible(addMeetingButton);
      await tester.tap(addMeetingButton);
      await tester.pumpAndSettle();

      // 1. Adım: Tarih ve otomatik toplantı numarası.
      expect(find.byKey(const Key('bep_meeting_step_date')), findsOneWidget);
      expect(find.byKey(const Key('bep_meeting_number')), findsOneWidget);
      expect(find.text('Adım 1/5 · Tarih ve Toplantı No'), findsOneWidget);
      await tester.tap(find.byKey(const Key('bep_meeting_continue')));
      await tester.pumpAndSettle();

      // 2. Adım: Veli katılımı (anne ve baba).
      expect(
        find.byKey(const Key('bep_meeting_step_guardians')),
        findsOneWidget,
      );
      expect(find.text('Anne · Fatma Kaya'), findsOneWidget);
      expect(find.text('Baba · Hasan Kaya'), findsOneWidget);
      await tester.tap(find.byKey(const Key('bep_meeting_parent_mother')));
      await tester.pumpAndSettle();
      await _scrollToDialog(
        tester,
        'bep_meeting_step_guardians',
        'bep_meeting_staff_8',
      );
      expect(find.text('Okul Müdürü · Ahmet Yılmaz'), findsOneWidget);
      expect(find.text('Psikolojik Danışman · Elif Şahin'), findsOneWidget);
      await tester.tap(find.byKey(const Key('bep_meeting_staff_8')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bep_meeting_continue')));
      await tester.pumpAndSettle();

      // 3. Adım: Öğretmen seçimi.
      expect(find.byKey(const Key('bep_meeting_teacher_5')), findsOneWidget);
      expect(find.byKey(const Key('bep_meeting_teacher_6')), findsOneWidget);
      await tester.tap(find.byKey(const Key('bep_meeting_teacher_5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bep_meeting_continue')));
      await tester.pumpAndSettle();

      // 4. Adım: Gündem maddeleri.
      expect(find.byKey(const Key('bep_meeting_step_agenda')), findsOneWidget);
      await _scrollToDialog(
        tester,
        'bep_meeting_step_agenda',
        'bep_meeting_agenda_5',
      );
      await tester.tap(find.byKey(const Key('bep_meeting_agenda_5')));
      await tester.pumpAndSettle();
      await _scrollToDialog(
        tester,
        'bep_meeting_step_agenda',
        'bep_meeting_agenda_input',
      );
      await tester.enterText(
        find.byKey(const Key('bep_meeting_agenda_input')),
        'Ek gündem maddesi',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bep_meeting_continue')));
      await tester.pumpAndSettle();

      // 5. Adım: Alınan kararlar.
      expect(
        find.byKey(const Key('bep_meeting_step_decisions')),
        findsOneWidget,
      );
      await _scrollToDialog(
        tester,
        'bep_meeting_step_decisions',
        'bep_meeting_decision_0',
      );
      await tester.tap(find.byKey(const Key('bep_meeting_decision_0')));
      await tester.pumpAndSettle();
      await _scrollToDialog(
        tester,
        'bep_meeting_step_decisions',
        'bep_meeting_decision_input',
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
      expect(meetingsNotifier.parentAttendees, ['Fatma Kaya']);
      expect(meetingsNotifier.staffAttendees, ['Elif Şahin']);
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
    },
  );

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

  testWidgets('toplantı tutanağı için PDF önizlemesi açılır', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final notifier = _MeetingsNotifier([
      _meeting(id: 1, studentId: 1, meetingDate: '2026-11-11'),
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

    await tester.tap(find.byKey(const Key('bep_meeting_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preview_bep_meeting_1')));
    await tester.pump();

    expect(find.text('BEP Toplantı Tutanağı Önizleme'), findsOneWidget);
    expect(find.byKey(const Key('bep_meeting_pdf_preview')), findsOneWidget);
  });

  testWidgets('hazırlanmış BEP toplantısı mevcut değerleriyle düzenlenir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final notifier = _MeetingsNotifier([
      _meeting(
        id: 8,
        studentId: 1,
        meetingDate: '2026-03-15',
        teacherIds: [5],
        agendaItems: [bepMeetingAgendaItems.first, 'Ek gündem'],
        decisions: [bepMeetingDecisionItems.first, 'Ek karar'],
      ),
    ]);
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
    ];
    const teachers = [
      Teacher(id: 5, name: 'Zeynep', surname: 'Arı', branch: 'Türkçe'),
      Teacher(id: 6, name: 'Mehmet', surname: 'Yılmaz', branch: 'Matematik'),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _StudentsNotifier(students)),
          teachersProvider.overrideWith(() => _TeachersNotifier(teachers)),
          bepMeetingsProvider.overrideWith(() => notifier),
        ],
        child: const MaterialApp(home: Scaffold(body: SpecialEducationPage())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bep_meeting_8')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit_bep_meeting_8')));
    await tester.pumpAndSettle();

    expect(find.text('BEP Toplantısını Düzenle'), findsOneWidget);
    expect(find.text('Toplantı tarihi: 15.03.2026'), findsOneWidget);

    // 1. Adım (tarih) → 2. Adım (veli) → 3. Adım (öğretmenler).
    await tester.tap(find.byKey(const Key('bep_meeting_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bep_meeting_continue')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const Key('bep_meeting_teacher_5')),
          )
          .value,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('bep_meeting_teacher_6')));
    await tester.pumpAndSettle();

    // 3. Adım → 4. Adım (gündem) → 5. Adım (kararlar).
    await tester.tap(find.byKey(const Key('bep_meeting_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bep_meeting_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bep_meeting_save')));
    await tester.pumpAndSettle();

    expect(notifier.updatedMeetingId, 8);
    expect(notifier.teacherIds, [5, 6]);
    expect(notifier.meetingDate, '2026-03-15');
    expect(notifier.agendaItems, [bepMeetingAgendaItems.first, 'Ek gündem']);
    expect(notifier.decisions, [bepMeetingDecisionItems.first, 'Ek karar']);
  });

  testWidgets(
    'öğretmen adımında öğretmenin girdiği dersler ve saatleri görünür',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const student = Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Ayşe',
        surname: 'Kaya',
        createdAt: '2026-11-11',
        hasSpecialEducation: true,
        className: '9/A',
      );
      const teachers = [
        Teacher(id: 5, name: 'Zeynep', surname: 'Arı', branch: 'Türkçe'),
        Teacher(id: 6, name: 'Mehmet', surname: 'Yılmaz', branch: 'Matematik'),
      ];
      const subjects = [
        StudentSubjectNeed(
          studentId: 1,
          classSubjectId: 11,
          subjectName: 'Matematik',
          weeklyHours: 4,
          requiresSupportEducation: false,
          requiresBep: true,
          isExempt: false,
          teacherName: 'Mehmet Yılmaz',
        ),
        StudentSubjectNeed(
          studentId: 1,
          classSubjectId: 12,
          subjectName: 'Fizik',
          weeklyHours: 2,
          requiresSupportEducation: false,
          requiresBep: true,
          isExempt: false,
          teacherName: 'Mehmet Yılmaz',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(null),
            studentsProvider.overrideWith(() => _StudentsNotifier([student])),
            teachersProvider.overrideWith(() => _TeachersNotifier(teachers)),
            bepMeetingsProvider.overrideWith(() => _MeetingsNotifier()),
            studentSubjectNeedsProvider.overrideWith(
              () => _StudentSubjectNeedsNotifier(subjects),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SpecialEducationPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('special_education_student_1')));
      await tester.pumpAndSettle();

      final addMeetingButton = find.byKey(const Key('add_student_bep_meeting'));
      await tester.ensureVisible(addMeetingButton);
      await tester.tap(addMeetingButton);
      await tester.pumpAndSettle();

      // Tarih ve veli adımlarını geçip öğretmen adımına gel.
      await tester.tap(find.byKey(const Key('bep_meeting_continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bep_meeting_continue')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bep_meeting_teacher_5')), findsOneWidget);
      expect(find.byKey(const Key('bep_meeting_teacher_6')), findsOneWidget);
      expect(find.text('Matematik (4 saat), Fizik (2 saat)'), findsOneWidget);
      expect(find.text('Öğrencinin dersine girmiyor'), findsOneWidget);
    },
  );
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

class _StudentSubjectNeedsNotifier extends StudentSubjectNeedsNotifier {
  _StudentSubjectNeedsNotifier(this.subjects);

  final List<StudentSubjectNeed> subjects;

  @override
  Future<List<StudentSubjectNeed>> build(int studentId) async => subjects;
}

class _SchoolStaffNotifier extends SchoolStaffNotifier {
  _SchoolStaffNotifier(this.staff);

  final List<SchoolStaff> staff;

  @override
  Future<List<SchoolStaff>> build() async => staff;
}

class _MeetingsNotifier extends BepMeetingsNotifier {
  _MeetingsNotifier([this.initialMeetings = const []]);

  final List<BepMeeting> initialMeetings;
  int? studentId;
  List<int> teacherIds = [];
  List<String> agendaItems = [];
  List<String> decisions = [];
  List<String> parentAttendees = [];
  List<String> staffAttendees = [];
  int? updatedMeetingId;
  String? meetingDate;

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
    List<String> parentAttendees = const [],
    List<String> staffAttendees = const [],
  }) async {
    this.studentId = studentId;
    this.teacherIds = teacherIds;
    this.agendaItems = agendaItems;
    this.decisions = decisions;
    this.parentAttendees = parentAttendees;
    this.staffAttendees = staffAttendees;
    this.meetingDate = meetingDate;
    state = AsyncValue.data([
      BepMeeting(
        id: 1,
        studentId: studentId,
        studentName: 'Ayşe Kaya',
        studentNumber: '101',
        className: '9/A',
        studentBirthDate: '2010-01-02',
        studentGender: 'Kız',
        meetingDate: meetingDate,
        agendaItems: agendaItems,
        decisions: decisions,
        teacherIds: teacherIds,
        teacherNames: ['Zeynep Arı'],
        parentAttendees: parentAttendees,
        staffAttendees: staffAttendees,
        createdAt: meetingDate,
      ),
    ]);
  }

  @override
  Future<void> updateMeeting({
    required int meetingId,
    required int studentId,
    required List<int> teacherIds,
    required String meetingDate,
    required List<String> agendaItems,
    required List<String> decisions,
    List<String> parentAttendees = const [],
    List<String> staffAttendees = const [],
  }) async {
    updatedMeetingId = meetingId;
    this.studentId = studentId;
    this.teacherIds = teacherIds;
    this.meetingDate = meetingDate;
    this.agendaItems = agendaItems;
    this.decisions = decisions;
    this.parentAttendees = parentAttendees;
    this.staffAttendees = staffAttendees;
    state = AsyncValue.data([
      _meeting(
        id: meetingId,
        studentId: studentId,
        meetingDate: meetingDate,
        teacherIds: teacherIds,
        agendaItems: agendaItems,
        decisions: decisions,
        parentAttendees: parentAttendees,
        staffAttendees: staffAttendees,
      ),
    ]);
  }
}

BepMeeting _meeting({
  required int id,
  required int studentId,
  required String meetingDate,
  List<int> teacherIds = const [5],
  List<String>? agendaItems,
  List<String>? decisions,
  List<String> parentAttendees = const [],
  List<String> staffAttendees = const [],
}) => BepMeeting(
  id: id,
  studentId: studentId,
  studentName: studentId == 1 ? 'Ayşe Kaya' : 'Ali Demir',
  studentNumber: studentId == 1 ? '101' : '102',
  className: '9/A',
  studentBirthDate: '2010-01-02',
  studentGender: studentId == 1 ? 'Kız' : 'Erkek',
  meetingDate: meetingDate,
  agendaItems: agendaItems ?? [bepMeetingAgendaItems.first],
  decisions: decisions ?? const [],
  teacherIds: teacherIds,
  teacherNames: const ['Zeynep Arı'],
  parentAttendees: parentAttendees,
  staffAttendees: staffAttendees,
  createdAt: meetingDate,
);

/// Diyalog içindeki adım listesini hedefe kadar kaydırır.
Future<void> _scrollToDialog(
  WidgetTester tester,
  String listKey,
  String targetKey,
) async {
  await tester.scrollUntilVisible(
    find.byKey(Key(targetKey)),
    150,
    scrollable: find
        .descendant(
          of: find.byKey(Key(listKey)),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

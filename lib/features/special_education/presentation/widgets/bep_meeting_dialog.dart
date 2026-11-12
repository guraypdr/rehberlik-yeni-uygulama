import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../settings/domain/school_staff.dart';
import '../../../settings/presentation/school_staff_provider.dart';
import '../../../students/domain/student.dart';
import '../../../teachers/domain/teacher.dart';
import '../../domain/bep_meeting.dart';
import '../../domain/student_subject_need.dart';
import '../bep_meetings_provider.dart';
import '../student_subject_needs_provider.dart';

/// BEP toplantısı ekleme/düzenleme sihirbazı.
///
/// Adımlar: 1) Tarih ve toplantı no, 2) Veli katılımı, 3) Öğretmenler,
/// 4) Gündem maddeleri, 5) Alınan kararlar.
class BepMeetingDialog extends ConsumerStatefulWidget {
  const BepMeetingDialog({
    super.key,
    required this.students,
    required this.teachers,
    this.initialMeeting,
    this.initialStudentId,
  });

  final List<Student> students;
  final List<Teacher> teachers;
  final BepMeeting? initialMeeting;
  final int? initialStudentId;

  static Future<void> show(
    BuildContext context, {
    required List<Student> students,
    required List<Teacher> teachers,
    BepMeeting? initialMeeting,
    int? initialStudentId,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BepMeetingDialog(
      students: students,
      teachers: teachers,
      initialMeeting: initialMeeting,
      initialStudentId: initialStudentId,
    ),
  );

  @override
  ConsumerState<BepMeetingDialog> createState() => _BepMeetingDialogState();
}

class _BepMeetingDialogState extends ConsumerState<BepMeetingDialog> {
  static const List<String> _stepTitles = [
    'Tarih ve Toplantı No',
    'Veli Katılımı',
    'Öğretmenler',
    'Gündem Maddeleri',
    'Alınan Kararlar',
  ];

  int? _studentId;
  DateTime _meetingDate = DateTime.now();
  final Set<String> _selectedParents = {};
  final Set<String> _selectedStaff = {};
  final Set<int> _teacherIds = {};
  final List<String> _agendaItems = [...bepMeetingAgendaItems];
  final Set<String> _selectedAgendaItems = {...bepMeetingAgendaItems};
  final List<String> _decisionItems = [...bepMeetingDecisionItems];
  final Set<String> _selectedDecisions = {};
  final TextEditingController _agendaController = TextEditingController();
  final TextEditingController _decisionController = TextEditingController();
  int _step = 0;
  bool _saving = false;

  bool get _isEditing => widget.initialMeeting != null;

  Student? get _selectedStudent =>
      widget.students.where((student) => student.id == _studentId).firstOrNull;

  @override
  void initState() {
    super.initState();
    final meeting = widget.initialMeeting;
    if (meeting != null) {
      _studentId = meeting.studentId;
      _teacherIds.addAll(meeting.teacherIds);
      _selectedParents.addAll(meeting.parentAttendees);
      _selectedStaff.addAll(meeting.staffAttendees);
      _agendaItems.addAll(
        meeting.agendaItems.where((item) => !_agendaItems.contains(item)),
      );
      _selectedAgendaItems
        ..clear()
        ..addAll(meeting.agendaItems);
      _decisionItems.addAll(
        meeting.decisions.where((item) => !_decisionItems.contains(item)),
      );
      _selectedDecisions.addAll(meeting.decisions);
      _meetingDate = DateTime.tryParse(meeting.meetingDate) ?? DateTime.now();
    } else {
      _studentId = widget.initialStudentId ?? widget.students.firstOrNull?.id;
    }
  }

  @override
  void dispose() {
    _agendaController.dispose();
    _decisionController.dispose();
    super.dispose();
  }

  /// Öğrencinin mevcut toplantılarına göre otomatik toplantı numarası.
  int get _meetingNumber {
    final studentId = _studentId;
    if (studentId == null) return 1;
    final meetings =
        ref.watch(bepMeetingsProvider).valueOrNull ?? const <BepMeeting>[];
    final editingId = widget.initialMeeting?.id;
    final date = _formatIso(_meetingDate);
    final before = meetings.where((meeting) {
      if (meeting.studentId != studentId || meeting.id == editingId) {
        return false;
      }
      final comparison = meeting.meetingDate.compareTo(date);
      if (comparison != 0) return comparison < 0;
      return editingId == null || meeting.id < editingId;
    }).length;
    return before + 1;
  }

  List<({String key, String label, String name})> get _guardianOptions {
    final student = _selectedStudent;
    if (student == null) return const [];
    final options = <({String key, String label, String name})>[];
    final mother = _joinName(student.motherName, student.motherSurname);
    if (mother.isNotEmpty) {
      options.add((key: 'mother', label: 'Anne', name: mother));
    }
    final father = _joinName(student.fatherName, student.fatherSurname);
    if (father.isNotEmpty) {
      options.add((key: 'father', label: 'Baba', name: father));
    }
    // Daha önce kaydedilmiş ama listede görünmeyen veli adlarını koru.
    for (final name in _selectedParents) {
      if (!options.any((option) => option.name == name)) {
        options.add((key: 'extra_$name', label: 'Veli', name: name));
      }
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final studentId = _studentId;
    final studentSubjects = studentId == null
        ? const <StudentSubjectNeed>[]
        : ref.watch(studentSubjectNeedsProvider(studentId)).valueOrNull ??
              const <StudentSubjectNeed>[];

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isEditing ? 'BEP Toplantısını Düzenle' : 'BEP Toplantısı Oluştur',
          ),
          const SizedBox(height: 2),
          Text(
            'Adım ${_step + 1}/${_stepTitles.length} · ${_stepTitles[_step]}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
      content: SizedBox(
        width: (screenSize.width - 64).clamp(280.0, 680.0).toDouble(),
        height: (screenSize.height * 0.62).clamp(260.0, 620.0).toDouble(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: (_step + 1) / _stepTitles.length,
                minHeight: 5,
                backgroundColor: AppColors.surfaceMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _stepBody(studentSubjects)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        if (_step > 0)
          TextButton(
            key: const Key('bep_meeting_back'),
            onPressed: _saving ? null : () => setState(() => _step -= 1),
            child: const Text('Geri'),
          ),
        FilledButton.icon(
          key: Key(
            _step == _stepTitles.length - 1
                ? 'bep_meeting_save'
                : 'bep_meeting_continue',
          ),
          onPressed: _saving || !_canContinue
              ? null
              : _step == _stepTitles.length - 1
              ? _save
              : () => setState(() => _step += 1),
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _step == _stepTitles.length - 1
                      ? Icons.save_outlined
                      : Icons.arrow_forward,
                ),
          label: Text(
            _step == _stepTitles.length - 1
                ? (_isEditing ? 'Değişiklikleri Kaydet' : 'Toplantıyı Kaydet')
                : 'İleri',
          ),
        ),
      ],
    );
  }

  bool get _canContinue => switch (_step) {
    2 => _teacherIds.isNotEmpty,
    3 => _selectedAgendaItems.isNotEmpty,
    _ => true,
  };

  Widget _stepBody(List<StudentSubjectNeed> studentSubjects) => switch (_step) {
    0 => _dateStep(),
    1 => _guardianStep(),
    2 => _teacherStep(studentSubjects),
    3 => _agendaStep(),
    _ => _decisionStep(),
  };

  Widget _studentBanner() {
    final student = _selectedStudent;
    if (student == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${student.fullName} · ${student.number} · '
              '${student.displayClass}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateStep() => ListView(
    key: const Key('bep_meeting_step_date'),
    children: [
      _studentBanner(),
      const SizedBox(height: AppSpacing.lg),
      OutlinedButton.icon(
        key: const Key('bep_meeting_date'),
        onPressed: _pickDate,
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text('Toplantı tarihi: ${_formatDate(_meetingDate)}'),
      ),
      const SizedBox(height: AppSpacing.lg),
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.tag, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toplantı No',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$_meetingNumber',
                    key: const Key('bep_meeting_number'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Text(
              'Otomatik',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Toplantı numarası öğrencinin önceki toplantılarına göre otomatik '
        'hesaplanır.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
      ),
    ],
  );

  Widget _guardianStep() {
    final options = _guardianOptions;
    final staff =
        ref.watch(schoolStaffProvider).valueOrNull ?? const <SchoolStaff>[];

    return ListView(
      key: const Key('bep_meeting_step_guardians'),
      children: [
        Text(
          'Toplantıya katılan veliyi seçin. Anne ve baba birlikte veya tek '
          'başına seçilebilir.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (options.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Öğrencinin anne/baba bilgileri girilmemiş.',
              key: Key('bep_meeting_no_guardians'),
            ),
          )
        else
          for (final option in options)
            CheckboxListTile(
              key: Key('bep_meeting_parent_${option.key}'),
              contentPadding: EdgeInsets.zero,
              value: _selectedParents.contains(option.name),
              title: Text('${option.label} · ${option.name}'),
              onChanged: (selected) => _toggleParent(option.name, selected),
            ),
        const Divider(height: AppSpacing.xl),
        Text(
          'Toplantıya katılan idareci ve psikolojik danışmanı seçin. Bu kişiler '
          'Ayarlar sayfasındaki idari kadrodan gelir.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (staff.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Ayarlar sayfasından idareci veya psikolojik danışman ekleyebilirsiniz.',
              key: Key('bep_meeting_no_staff'),
            ),
          )
        else
          for (final member in staff)
            CheckboxListTile(
              key: Key('bep_meeting_staff_${member.id}'),
              contentPadding: EdgeInsets.zero,
              value: _selectedStaff.contains(member.fullName),
              title: Text('${member.role.label} · ${member.fullName}'),
              onChanged: (selected) => _toggleStaff(member.fullName, selected),
            ),
      ],
    );
  }

  Widget _teacherStep(List<StudentSubjectNeed> studentSubjects) {
    if (widget.teachers.isEmpty) {
      return const Center(child: Text('Okulda kayıtlı öğretmen bulunmuyor.'));
    }
    // Öğretmen adına göre öğrencinin hangi derslerine girdiğini grupla.
    final subjectsByTeacher = <String, List<StudentSubjectNeed>>{};
    for (final subject in studentSubjects) {
      final teacherName = subject.teacherName?.trim();
      if (teacherName == null || teacherName.isEmpty) continue;
      subjectsByTeacher.putIfAbsent(teacherName, () => []).add(subject);
    }

    return ListView(
      key: const Key('bep_meeting_step_teachers'),
      children: [
        Text(
          'Toplantıya katılan öğretmenleri seçin.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final teacher in widget.teachers)
          CheckboxListTile(
            key: Key('bep_meeting_teacher_${teacher.id}'),
            contentPadding: EdgeInsets.zero,
            value: _teacherIds.contains(teacher.id),
            title: Text(teacher.fullName),
            subtitle: Text(
              _teacherSubjectSummary(subjectsByTeacher[teacher.fullName]),
            ),
            onChanged: (selected) => setState(() {
              if (selected == true) {
                _teacherIds.add(teacher.id);
              } else {
                _teacherIds.remove(teacher.id);
              }
            }),
          ),
      ],
    );
  }

  /// Öğretmenin öğrenciye girdiği dersleri "Ders (N saat)" biçiminde özetler.
  String _teacherSubjectSummary(List<StudentSubjectNeed>? subjects) {
    if (subjects == null || subjects.isEmpty) {
      return 'Öğrencinin dersine girmiyor';
    }
    return subjects
        .map(
          (subject) => '${subject.subjectName} (${subject.weeklyHours} saat)',
        )
        .join(', ');
  }

  Widget _agendaStep() => ListView(
    key: const Key('bep_meeting_step_agenda'),
    children: [
      Text(
        'Görüşülecek gündem maddelerini seçin.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      for (var index = 0; index < _agendaItems.length; index++)
        CheckboxListTile(
          key: Key('bep_meeting_agenda_$index'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _selectedAgendaItems.contains(_agendaItems[index]),
          title: Text('${index + 1}. ${_agendaItems[index]}'),
          onChanged: (selected) => setState(() {
            if (selected == true) {
              _selectedAgendaItems.add(_agendaItems[index]);
            } else {
              _selectedAgendaItems.remove(_agendaItems[index]);
            }
          }),
        ),
      _itemInput(
        key: const Key('bep_meeting_agenda_input'),
        controller: _agendaController,
        hintText: 'Yeni gündem maddesi',
        onAdd: _addAgendaItem,
      ),
    ],
  );

  Widget _decisionStep() => ListView(
    key: const Key('bep_meeting_step_decisions'),
    children: [
      Text(
        'Toplantıda alınan kararları seçin.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      for (var index = 0; index < _decisionItems.length; index++)
        CheckboxListTile(
          key: Key('bep_meeting_decision_$index'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _selectedDecisions.contains(_decisionItems[index]),
          title: Text('${index + 1}. ${_decisionItems[index]}'),
          onChanged: (selected) => setState(() {
            if (selected == true) {
              _selectedDecisions.add(_decisionItems[index]);
            } else {
              _selectedDecisions.remove(_decisionItems[index]);
            }
          }),
        ),
      _itemInput(
        key: const Key('bep_meeting_decision_input'),
        controller: _decisionController,
        hintText: 'Yeni karar',
        onAdd: _addDecision,
      ),
    ],
  );

  Widget _itemInput({
    required Key key,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onAdd,
  }) => Row(
    children: [
      Expanded(
        child: TextField(
          key: key,
          controller: controller,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onAdd(),
          decoration: InputDecoration(hintText: hintText),
        ),
      ),
      IconButton(
        onPressed: onAdd,
        tooltip: 'Ekle',
        icon: const Icon(Icons.add_circle_outline),
      ),
    ],
  );

  void _toggleParent(String name, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedParents.add(name);
      } else {
        _selectedParents.remove(name);
      }
    });
  }

  void _toggleStaff(String name, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedStaff.add(name);
      } else {
        _selectedStaff.remove(name);
      }
    });
  }

  void _addAgendaItem() {
    final item = _agendaController.text.trim();
    if (item.isEmpty || _agendaItems.contains(item)) return;
    setState(() {
      _agendaItems.add(item);
      _selectedAgendaItems.add(item);
      _agendaController.clear();
    });
  }

  void _addDecision() {
    final item = _decisionController.text.trim();
    if (item.isEmpty || _decisionItems.contains(item)) return;
    setState(() {
      _decisionItems.add(item);
      _selectedDecisions.add(item);
      _decisionController.clear();
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _meetingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _meetingDate = selected);
  }

  Future<void> _save() async {
    final student = _selectedStudent;
    if (student == null) return;

    setState(() => _saving = true);
    try {
      final notifier = ref.read(bepMeetingsProvider.notifier);
      final teacherIds = _teacherIds.toList();
      final agendaItems = [
        for (final item in _agendaItems)
          if (_selectedAgendaItems.contains(item)) item,
      ];
      final decisions = [
        for (final item in _decisionItems)
          if (_selectedDecisions.contains(item)) item,
      ];
      final parentAttendees = _selectedParents.toList();
      final staffAttendees = _selectedStaff.toList();
      final meeting = widget.initialMeeting;
      if (meeting == null) {
        await notifier.addMeeting(
          studentId: student.id,
          teacherIds: teacherIds,
          meetingDate: _formatIso(_meetingDate),
          agendaItems: agendaItems,
          decisions: decisions,
          parentAttendees: parentAttendees,
          staffAttendees: staffAttendees,
        );
      } else {
        await notifier.updateMeeting(
          meetingId: meeting.id,
          studentId: student.id,
          teacherIds: teacherIds,
          meetingDate: _formatIso(_meetingDate),
          agendaItems: agendaItems,
          decisions: decisions,
          parentAttendees: parentAttendees,
          staffAttendees: staffAttendees,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('BEP toplantısı kaydedilemedi: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _joinName(String? name, String? surname) => [
    name,
    surname,
  ].where((value) => value?.trim().isNotEmpty ?? false).join(' ').trim();

  static String _formatIso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}

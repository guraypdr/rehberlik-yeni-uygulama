import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../students/domain/student.dart';
import '../../../teachers/domain/teacher.dart';
import '../../domain/bep_meeting.dart';
import '../bep_meetings_provider.dart';

class BepMeetingDialog extends ConsumerStatefulWidget {
  const BepMeetingDialog({
    super.key,
    required this.students,
    required this.teachers,
  });

  final List<Student> students;
  final List<Teacher> teachers;

  static Future<void> show(
    BuildContext context, {
    required List<Student> students,
    required List<Teacher> teachers,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BepMeetingDialog(students: students, teachers: teachers),
  );

  @override
  ConsumerState<BepMeetingDialog> createState() => _BepMeetingDialogState();
}

class _BepMeetingDialogState extends ConsumerState<BepMeetingDialog> {
  int? _studentId;
  final Set<int> _teacherIds = {};
  final List<String> _agendaItems = [...bepMeetingAgendaItems];
  final Set<String> _selectedAgendaItems = {...bepMeetingAgendaItems};
  final List<String> _decisionItems = [...bepMeetingDecisionItems];
  final Set<String> _selectedDecisions = {};
  final TextEditingController _agendaController = TextEditingController();
  final TextEditingController _decisionController = TextEditingController();
  DateTime _meetingDate = DateTime.now();
  int _step = 0;
  bool _saving = false;

  Student? get _selectedStudent =>
      widget.students.where((student) => student.id == _studentId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: Text(
        _step == 0
            ? 'BEP Toplantısı · Öğrenci Seçimi'
            : 'BEP Toplantısı · Katılımcılar ve Gündem',
      ),
      content: SizedBox(
        width: (screenSize.width - 64).clamp(280.0, 680.0).toDouble(),
        height: (screenSize.height * 0.62).clamp(260.0, 620.0).toDouble(),
        child: _step == 0 ? _studentSelection() : _meetingDetails(),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        if (_step == 1)
          TextButton(
            key: const Key('bep_meeting_back'),
            onPressed: _saving ? null : () => setState(() => _step = 0),
            child: const Text('Geri'),
          ),
        FilledButton.icon(
          key: Key(_step == 0 ? 'bep_meeting_continue' : 'bep_meeting_save'),
          onPressed: _saving || !_canContinue
              ? null
              : _step == 0
              ? () => setState(() => _step = 1)
              : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_step == 0 ? Icons.arrow_forward : Icons.save_outlined),
          label: Text(_step == 0 ? 'Devam Et' : 'Toplantıyı Kaydet'),
        ),
      ],
    );
  }

  bool get _canContinue => _step == 0
      ? _selectedStudent != null
      : _teacherIds.isNotEmpty && _selectedAgendaItems.isNotEmpty;

  Widget _studentSelection() {
    if (widget.students.isEmpty) {
      return const Center(
        child: Text('Özel eğitim öğrencisi olarak işaretlenmiş öğrenci yok.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Toplantı yapılacak öğrenciyi seçin.'),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            key: const Key('bep_meeting_student_list'),
            itemCount: widget.students.length,
            itemBuilder: (context, index) {
              final student = widget.students[index];
              return ListTile(
                key: Key('bep_meeting_student_${student.id}'),
                selected: _studentId == student.id,
                onTap: () => setState(() => _studentId = student.id),
                leading: Icon(
                  _studentId == student.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _studentId == student.id
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(student.fullName),
                subtitle: Text('${student.number} · ${student.displayClass}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _meetingDetails() => ListView(
    key: const Key('bep_meeting_details'),
    children: [
      if (_selectedStudent case final student?)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text(student.fullName),
          subtitle: Text('${student.number} · ${student.displayClass}'),
        ),
      const SizedBox(height: AppSpacing.sm),
      OutlinedButton.icon(
        key: const Key('bep_meeting_date'),
        onPressed: _pickDate,
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text('Toplantı tarihi: ${_formatDate(_meetingDate)}'),
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Katılan Öğretmenler (${_teacherIds.length} seçildi)',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      if (widget.teachers.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text('Okulda kayıtlı öğretmen bulunmuyor.'),
        )
      else
        for (final teacher in widget.teachers)
          CheckboxListTile(
            key: Key('bep_meeting_teacher_${teacher.id}'),
            contentPadding: EdgeInsets.zero,
            value: _teacherIds.contains(teacher.id),
            title: Text(teacher.fullName),
            subtitle: teacher.branch?.isNotEmpty == true
                ? Text(teacher.branch!)
                : null,
            onChanged: (selected) => setState(() {
              if (selected == true) {
                _teacherIds.add(teacher.id);
              } else {
                _teacherIds.remove(teacher.id);
              }
            }),
          ),
      const Divider(),
      Text(
        'Toplantı Gündemi',
        key: const Key('bep_meeting_agenda_heading'),
        style: Theme.of(context).textTheme.titleSmall,
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
      const SizedBox(height: AppSpacing.md),
      Text(
        'Alınan Kararlar',
        key: const Key('bep_meeting_decisions_heading'),
        style: Theme.of(context).textTheme.titleSmall,
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

  @override
  void dispose() {
    _agendaController.dispose();
    _decisionController.dispose();
    super.dispose();
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
    if (student == null || !_canContinue) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(bepMeetingsProvider.notifier)
          .addMeeting(
            studentId: student.id,
            teacherIds: _teacherIds.toList(),
            meetingDate:
                '${_meetingDate.year.toString().padLeft(4, '0')}-'
                '${_meetingDate.month.toString().padLeft(2, '0')}-'
                '${_meetingDate.day.toString().padLeft(2, '0')}',
            agendaItems: [
              for (final item in _agendaItems)
                if (_selectedAgendaItems.contains(item)) item,
            ],
            decisions: [
              for (final item in _decisionItems)
                if (_selectedDecisions.contains(item)) item,
            ],
          );
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

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}

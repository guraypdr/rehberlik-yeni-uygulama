import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../students/domain/student.dart';
import '../../students/presentation/students_provider.dart';
import '../data/student_risk_dao.dart';
import '../domain/school_class.dart';
import '../domain/student_risk_question.dart';
import 'student_risk_provider.dart';

class ClassRiskMapPage extends ConsumerStatefulWidget {
  const ClassRiskMapPage({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  ConsumerState<ClassRiskMapPage> createState() => _ClassRiskMapPageState();
}

class _ClassRiskMapPageState extends ConsumerState<ClassRiskMapPage> {
  int _questionIndex = 0;
  final Set<String> _savingCells = {};
  bool _isFinishing = false;

  StudentRiskQuestion get _question => studentRiskQuestions[_questionIndex];

  String _cellKey(int studentId) => '$studentId:${_question.key}';

  Future<void> _saveAnswer(int studentId, bool answer) async {
    final cellKey = _cellKey(studentId);
    setState(() => _savingCells.add(cellKey));
    try {
      await ref
          .read(studentRiskProvider(widget.schoolClass.id).notifier)
          .setAnswer(
            studentId: studentId,
            questionKey: _question.key,
            answer: answer,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cevap kaydedilemedi: $error')));
    } finally {
      if (mounted) setState(() => _savingCells.remove(cellKey));
    }
  }

  Future<void> _finishRiskMap() async {
    setState(() => _isFinishing = true);
    try {
      final database = ref.read(databaseProvider);
      if (database == null) {
        throw StateError('Açık bir veritabanı bulunamadı.');
      }
      await StudentRiskDao(
        database,
      ).markClassRiskMapCompleted(widget.schoolClass.id);
      ref.invalidate(classRiskMapCompletedProvider(widget.schoolClass.id));
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Risk haritası tamamlanamadı: $error')),
      );
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final answersAsync = ref.watch(studentRiskProvider(widget.schoolClass.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Sınıf Risk Haritası · ${widget.schoolClass.displayName}'),
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Öğrenciler yüklenemedi: $error')),
        data: (allStudents) {
          final students =
              allStudents
                  .where((student) => student.classId == widget.schoolClass.id)
                  .toList()
                ..sort((a, b) => a.number.compareTo(b.number));
          if (students.isEmpty) {
            return const Center(
              child: Text('Risk haritası için sınıfta öğrenci bulunmuyor.'),
            );
          }
          return answersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Risk cevapları yüklenemedi: $error')),
            data: (answers) => _buildQuestionView(students, answers),
          );
        },
      ),
    );
  }

  Widget _buildQuestionView(
    List<Student> students,
    StudentRiskAnswers answers,
  ) {
    final question = _question;
    final theme = Theme.of(context);
    final derivedAnswerCount = students
        .where((student) => question.answerFromStudent(student) == true)
        .length;

    return Center(
      child: ConstrainedBox(
        key: const Key('risk_map_form_container'),
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'SORU ${_questionIndex + 1} / ${studentRiskQuestions.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    question.fromStudentForm
                        ? Icons.sync_alt_rounded
                        : Icons.cloud_done_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      question.fromStudentForm
                          ? 'Öğrenci formundan'
                          : 'Otomatik kaydedilir',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: (_questionIndex + 1) / studentRiskQuestions.length,
                minHeight: 5,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          question.fromStudentForm
                              ? Icons.assignment_ind_outlined
                              : Icons.fact_check_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.label,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              question.fromStudentForm
                                  ? 'Öğrenci bilgi formundan alınır; '
                                        'değiştirmek için öğrenci formunu düzenleyin.'
                                  : 'Evet olan öğrencileri işaretleyin. '
                                        'Değişiklikler otomatik kaydedilir.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${students.length} öğrenci',
                      style: theme.textTheme.labelMedium,
                    ),
                    const Spacer(),
                    if (question.fromStudentForm)
                      Text(
                        '$derivedAnswerCount Evet',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.success,
                        ),
                      )
                    else
                      Text(
                        'İşaretleyerek Evet yapın',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    key: const Key('risk_map_student_list'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: students.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final answer =
                          question.answerFromStudent(student) ??
                          answers[student.id]?[question.key] ??
                          false;
                      return _studentAnswerRow(
                        student: student,
                        answers: answers,
                        question: question,
                        answer: answer,
                        theme: theme,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      key: const Key('risk_map_previous'),
                      onPressed: _questionIndex == 0
                          ? null
                          : () => setState(() => _questionIndex--),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Önceki'),
                    ),
                    const Spacer(),
                    if (_questionIndex < studentRiskQuestions.length - 1)
                      FilledButton.icon(
                        key: const Key('risk_map_next'),
                        onPressed: () => setState(() => _questionIndex++),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Sonraki Soru'),
                      )
                    else
                      FilledButton.icon(
                        key: const Key('risk_map_finish'),
                        onPressed: _savingCells.isEmpty && !_isFinishing
                            ? _finishRiskMap
                            : null,
                        icon: _isFinishing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: const Text('Kaydet ve Kapat'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentAnswerRow({
    required Student student,
    required StudentRiskAnswers answers,
    required StudentRiskQuestion question,
    required bool answer,
    required ThemeData theme,
  }) {
    final isDerived = question.fromStudentForm;
    final rowColor = answer
        ? AppColors.success.withValues(alpha: 0.06)
        : AppColors.transparent;

    return Container(
      key: Key('risk_student_${student.id}'),
      color: rowColor,
      constraints: const BoxConstraints(minHeight: 70),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              student.number,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  isDerived ? 'Öğrenci bilgi formu' : 'Sınıf risk haritası',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _answerCheckbox(
            student: student,
            answers: answers,
            question: question,
          ),
          SizedBox(
            width: 52,
            child: Text(
              answer ? 'Evet' : 'Hayır',
              style: theme.textTheme.labelMedium?.copyWith(
                color: answer ? AppColors.success : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerCheckbox({
    required Student student,
    required StudentRiskAnswers answers,
    required StudentRiskQuestion question,
  }) {
    final derivedAnswer = question.answerFromStudent(student);
    final answer = derivedAnswer ?? answers[student.id]?[question.key] ?? false;
    final cellKey = '${student.id}:${question.key}';
    final isSaving = _savingCells.contains(cellKey);

    return Tooltip(
      message: question.fromStudentForm
          ? 'Öğrenci bilgi formundan alınan cevap'
          : answer
          ? 'Evet'
          : 'Hayır',
      child: Checkbox(
        key: Key('risk_answer_${student.id}_${question.key}'),
        value: answer,
        tristate: false,
        onChanged: question.fromStudentForm || isSaving
            ? null
            : (value) {
                if (value != null) _saveAnswer(student.id, value);
              },
      ),
    );
  }
}

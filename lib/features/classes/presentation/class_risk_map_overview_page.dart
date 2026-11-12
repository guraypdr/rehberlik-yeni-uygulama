import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../students/domain/student.dart';
import '../../students/presentation/students_provider.dart';
import '../domain/school_class.dart';
import '../domain/student_risk_question.dart';
import 'class_risk_map_page.dart';
import 'student_risk_provider.dart';

class ClassRiskMapOverviewPage extends ConsumerStatefulWidget {
  const ClassRiskMapOverviewPage({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  ConsumerState<ClassRiskMapOverviewPage> createState() =>
      _ClassRiskMapOverviewPageState();
}

class _ClassRiskMapOverviewPageState
    extends ConsumerState<ClassRiskMapOverviewPage> {
  static const _numberColumnWidth = 48.0;
  static const _schoolNumberColumnWidth = 84.0;
  static const _nameColumnWidth = 188.0;
  static const _questionColumnWidth = 56.0;
  static const _headerHeight = 184.0;
  static const _rowHeight = 64.0;

  double get _studentColumnsWidth =>
      _numberColumnWidth + _schoolNumberColumnWidth + _nameColumnWidth;

  final _verticalScrollController = ScrollController();
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final answersAsync = ref.watch(studentRiskProvider(widget.schoolClass.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Sınıf Risk Haritası · ${widget.schoolClass.displayName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilledButton.icon(
              key: const Key('edit_class_risk_map'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ClassRiskMapPage(schoolClass: widget.schoolClass),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Düzenle'),
            ),
          ),
        ],
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
            data: (answers) => _buildOverview(context, students, answers),
          );
        },
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    List<Student> students,
    StudentRiskAnswers answers,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1800),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppCard(
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                key: const Key('class_risk_overview_vertical_scroll'),
                controller: _verticalScrollController,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _studentColumnsWidth,
                      child: Column(
                        children: [
                          _studentHeader(theme),
                          for (var index = 0; index < students.length; index++)
                            _studentRow(students[index], index, theme),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        notificationPredicate: (notification) =>
                            notification.depth == 0,
                        child: SingleChildScrollView(
                          key: const Key(
                            'class_risk_overview_horizontal_scroll',
                          ),
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width:
                                studentRiskQuestions.length *
                                _questionColumnWidth,
                            child: Column(
                              children: [
                                _questionHeader(theme),
                                for (
                                  var index = 0;
                                  index < students.length;
                                  index++
                                )
                                  _studentRiskRow(
                                    students[index],
                                    answers,
                                    index,
                                    theme,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentHeader(ThemeData theme) => SizedBox(
    height: _headerHeight,
    child: Row(
      children: [
        _headerCell('Sıra', _numberColumnWidth, theme),
        _headerCell('Okul No', _schoolNumberColumnWidth, theme),
        _headerCell('Ad Soyad', _nameColumnWidth, theme),
      ],
    ),
  );

  Widget _headerCell(String label, double width, ThemeData theme) => Container(
    width: width,
    height: _headerHeight,
    alignment: Alignment.bottomLeft,
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: const BoxDecoration(
      color: AppColors.surfaceMuted,
      border: Border(
        right: BorderSide(color: AppColors.border),
        bottom: BorderSide(color: AppColors.border),
      ),
    ),
    child: Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium,
    ),
  );

  Widget _studentRow(Student student, int index, ThemeData theme) => Container(
    height: _rowHeight,
    decoration: BoxDecoration(
      color: index.isEven ? AppColors.surface : AppColors.background,
      border: const Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        _studentCell('${index + 1}', _numberColumnWidth, theme, centered: true),
        _studentCell(student.number, _schoolNumberColumnWidth, theme),
        _studentCell(student.fullName, _nameColumnWidth, theme),
      ],
    ),
  );

  Widget _studentCell(
    String value,
    double width,
    ThemeData theme, {
    bool centered = false,
  }) => Container(
    width: width,
    height: _rowHeight,
    alignment: centered ? Alignment.center : Alignment.centerLeft,
    padding: EdgeInsets.symmetric(
      horizontal: centered ? AppSpacing.xs : AppSpacing.sm,
    ),
    decoration: const BoxDecoration(
      border: Border(right: BorderSide(color: AppColors.border)),
    ),
    child: Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: centered ? AppColors.textMuted : AppColors.textPrimary,
        fontWeight: centered ? FontWeight.w600 : null,
      ),
    ),
  );

  Widget _questionHeader(ThemeData theme) => SizedBox(
    height: _headerHeight,
    child: Row(
      children: [
        for (final question in studentRiskQuestions)
          Container(
            width: _questionColumnWidth,
            height: _headerHeight,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              border: Border(
                left: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  width: _headerHeight - AppSpacing.md,
                  child: Text(
                    question.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _studentRiskRow(
    Student student,
    StudentRiskAnswers answers,
    int index,
    ThemeData theme,
  ) {
    final questions = studentRiskQuestions;
    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: [
          for (final question in questions)
            _answerCell(
              question.answerFromStudent(student) ??
                  answers[student.id]?[question.key] ??
                  false,
              student.id,
              question.key,
              index,
              theme,
            ),
        ],
      ),
    );
  }

  Widget _answerCell(
    bool answer,
    int studentId,
    String questionKey,
    int index,
    ThemeData theme,
  ) => Container(
    key: Key('class_risk_view_${studentId}_$questionKey'),
    width: _questionColumnWidth,
    height: _rowHeight,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: index.isEven ? AppColors.surface : AppColors.background,
      border: const Border(
        left: BorderSide(color: AppColors.border),
        bottom: BorderSide(color: AppColors.border),
      ),
    ),
    child: Icon(
      answer ? Icons.check_circle_rounded : Icons.circle_outlined,
      size: 21,
      color: answer ? AppColors.success : AppColors.borderStrong,
    ),
  );
}

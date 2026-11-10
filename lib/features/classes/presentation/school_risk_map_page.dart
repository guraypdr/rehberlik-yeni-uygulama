import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_theme.dart';
import '../data/school_risk_dao.dart';
import '../data/school_risk_pdf.dart';
import '../domain/school_class.dart';
import '../domain/student_risk_question.dart';
import 'classes_provider.dart';
import 'school_risk_provider.dart';

class SchoolRiskMapPage extends ConsumerStatefulWidget {
  const SchoolRiskMapPage({super.key});

  @override
  ConsumerState<SchoolRiskMapPage> createState() => _SchoolRiskMapPageState();
}

class _SchoolRiskMapPageState extends ConsumerState<SchoolRiskMapPage> {
  static const _classColumnWidth = 150.0;
  static const _minimumQuestionColumnWidth = 24.0;
  static const _headerHeight = 184.0;
  static const _rowHeight = 72.0;
  static const _scrollbarWidth = 8.0;

  final _verticalScrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  bool _isPrinting = false;

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final classesAsync = ref.watch(classesProvider);
    final countsAsync = ref.watch(schoolRiskCountsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Okul Risk Haritası'),
        actions: [
          IconButton(
            key: const Key('print_school_risk_map'),
            tooltip: 'Yazdır',
            onPressed: _isPrinting ? null : _printSchoolRiskMap,
            icon: _isPrinting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print_outlined),
          ),
          IconButton(
            tooltip: 'Yenile',
            onPressed: () => ref.invalidate(schoolRiskCountsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Sınıflar yüklenemedi: $error')),
        data: (classState) => countsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Risk sayıları yüklenemedi: $error')),
          data: (counts) {
            final classes = classState.classes;
            if (classes.isEmpty) {
              return const Center(child: Text('Henüz sınıf eklenmedi.'));
            }
            return _buildMap(context, classes, counts, theme);
          },
        ),
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    List<SchoolClass> classes,
    SchoolRiskCounts counts,
    ThemeData theme,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1800),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableContentWidth =
                constraints.maxWidth - AppSpacing.lg * 2 - 2;
            final questionColumnWidth =
                ((availableContentWidth - _classColumnWidth - _scrollbarWidth) /
                        studentRiskQuestions.length)
                    .clamp(_minimumQuestionColumnWidth, 48.0)
                    .toDouble();

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Scrollbar(
                  key: const Key('school_risk_vertical_scrollbar'),
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: SizedBox(
                      width: availableContentWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: _classColumnWidth,
                            child: Column(
                              children: [
                                _classHeader(theme),
                                for (
                                  var index = 0;
                                  index < classes.length;
                                  index++
                                )
                                  _classRow(classes[index], index, theme),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Scrollbar(
                              key: const Key(
                                'school_risk_horizontal_scrollbar',
                              ),
                              controller: _horizontalScrollController,
                              thumbVisibility: true,
                              notificationPredicate: (notification) =>
                                  notification.depth == 0,
                              child: SingleChildScrollView(
                                key: const Key('school_risk_horizontal_scroll'),
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width:
                                      studentRiskQuestions.length *
                                      questionColumnWidth,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _questionHeaders(
                                        theme,
                                        questionColumnWidth,
                                      ),
                                      for (
                                        var index = 0;
                                        index < classes.length;
                                        index++
                                      )
                                        _countRow(
                                          classes[index].id,
                                          counts[classes[index].id],
                                          index,
                                          theme,
                                          questionColumnWidth,
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
            );
          },
        ),
      ),
    );
  }

  Future<void> _printSchoolRiskMap() async {
    final classes = ref.read(classesProvider).valueOrNull?.classes;
    final counts = ref.read(schoolRiskCountsProvider).valueOrNull;
    if (classes == null || counts == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Risk haritası yazdırmaya hazır değil.')),
      );
      return;
    }
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yazdırılacak sınıf bulunmuyor.')),
      );
      return;
    }

    setState(() => _isPrinting = true);
    try {
      await Printing.layoutPdf(
        name: 'Okul Risk Haritasi',
        format: PdfPageFormat.a4.landscape,
        onLayout: (_) async =>
            (await SchoolRiskPdf.build(classes: classes, counts: counts)).save(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Risk haritası yazdırılamadı: $error')),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Widget _classHeader(ThemeData theme) => Container(
    height: _headerHeight,
    alignment: Alignment.bottomLeft,
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: const BoxDecoration(
      color: AppColors.surfaceMuted,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Text('Sınıf', style: theme.textTheme.labelLarge),
  );

  Widget _classRow(SchoolClass schoolClass, int index, ThemeData theme) =>
      Container(
        height: _rowHeight,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: index.isEven ? AppColors.surface : AppColors.background,
          border: const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Text(
          schoolClass.displayName,
          key: Key('school_risk_class_${schoolClass.id}'),
          style: theme.textTheme.labelLarge,
        ),
      );

  Widget _questionHeaders(ThemeData theme, double questionColumnWidth) =>
      SizedBox(
        height: _headerHeight,
        child: Row(
          children: [
            for (final question in studentRiskQuestions)
              Container(
                width: questionColumnWidth,
                height: _headerHeight,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _countRow(
    int classId,
    Map<String, int>? classCounts,
    int index,
    ThemeData theme,
    double questionColumnWidth,
  ) => SizedBox(
    height: _rowHeight,
    child: Row(
      children: [
        for (final question in studentRiskQuestions)
          Container(
            width: questionColumnWidth,
            height: _rowHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: index.isEven ? AppColors.surface : AppColors.background,
              border: const Border(
                left: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: _countBadge(
              classCounts?[question.key] ?? 0,
              theme,
              classId,
              question.key,
            ),
          ),
      ],
    ),
  );

  Widget _countBadge(
    int count,
    ThemeData theme,
    int classId,
    String questionKey,
  ) => Container(
    key: Key('school_risk_count_${classId}_$questionKey'),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: count > 0
          ? theme.colorScheme.primaryContainer
          : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      '$count',
      style: theme.textTheme.labelMedium?.copyWith(
        color: count > 0
            ? theme.colorScheme.onPrimaryContainer
            : AppColors.textMuted,
      ),
    ),
  );
}

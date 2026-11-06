import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/student.dart';
import '../../domain/student_interview.dart';
import '../students_provider.dart';
import 'interview_dialog.dart';
import 'student_info_form_sheet.dart';
import 'student_info_form_status.dart';

class StudentProfilePage extends ConsumerWidget {
  const StudentProfilePage({super.key, required this.student});

  final Student student;

  static Future<void> show(BuildContext context, Student student) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentProfilePage(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 520;
    final currentStudent =
        ref
            .watch(studentsProvider)
            .valueOrNull
            ?.where((item) => item.id == student.id)
            .firstOrNull ??
        student;
    final interviews = ref.watch(studentInterviewsProvider(student.id));
    final genderColor = currentStudent.gender == 'Kız'
        ? const Color(0xFFE91E63)
        : const Color(0xFF1976D2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Profili'),
        actions: [
          if (!isWide)
            IconButton(
              tooltip: 'Bilgileri Düzenle',
              onPressed: () =>
                  StudentInfoFormSheet.show(context, currentStudent),
              icon: const Icon(Icons.edit_outlined),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            AppColors.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: genderColor.withValues(
                                  alpha: 0.12,
                                ),
                                child: Text(
                                  currentStudent.name.characters.firstOrNull
                                          ?.toUpperCase() ??
                                      'Ö',
                                  style: TextStyle(
                                    color: genderColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentStudent.fullName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      currentStudent.displayClass,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isWide)
                                FilledButton.tonalIcon(
                                  onPressed: () => StudentInfoFormSheet.show(
                                    context,
                                    currentStudent,
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Düzenle'),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _SummaryPill(
                                icon: Icons.numbers_outlined,
                                label: 'No ${currentStudent.number}',
                              ),
                              _SummaryPill(
                                icon: currentStudent.gender == 'Kız'
                                    ? Icons.female
                                    : Icons.male,
                                label: currentStudent.gender,
                              ),
                              _SummaryPill(
                                icon: Icons.hotel_outlined,
                                label: currentStudent.boardingStatus,
                              ),
                              if (currentStudent.hasChronicIllness == true ||
                                  currentStudent.usesRegularMedication == true)
                                const _SummaryPill(
                                  icon: Icons.health_and_safety_outlined,
                                  label: 'Sağlık bilgisi mevcut',
                                  isHighlighted: true,
                                ),
                              if (currentStudent.siblingCount != null)
                                _SummaryPill(
                                  icon: Icons.family_restroom_outlined,
                                  label:
                                      '${currentStudent.siblingCount} kardeş',
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: StudentInfoFormStatus(
                                  student: currentStudent,
                                  showProgressBar: true,
                                ),
                              ),
                              Text(
                                '${currentStudent.studentInfoFormCompletion}%',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _ProfileSection(
                    title: 'Temel Öğrenci Bilgileri',
                    icon: Icons.badge_outlined,
                    initialExpanded: true,
                    children: [
                      _ProfileValue('Öğrenci No', currentStudent.number),
                      _ProfileValue('Adı', currentStudent.name),
                      _ProfileValue('Soyadı', currentStudent.surname),
                      _ProfileValue('Cinsiyeti', currentStudent.gender),
                      _ProfileValue(
                        'Pansiyon Durumu',
                        currentStudent.boardingStatus,
                      ),
                      _ProfileValue('Sınıfı', currentStudent.displayClass),
                    ],
                  ),
                  _ProfileSection(
                    title: 'Öğrenci Bilgileri',
                    icon: Icons.person_outline,
                    trailingLabel: 'Öğrenci bilgi formu',
                    children: [
                      _ProfileValue('Doğum Yeri', currentStudent.birthPlace),
                      _ProfileValue(
                        'Doğum Tarihi',
                        _formatDate(currentStudent.birthDate),
                      ),
                      _ProfileValue('Adresi', currentStudent.address),
                      _ProfileValue(
                        'Okul Öncesi Eğitim',
                        _yesNo(currentStudent.preschoolEducation),
                      ),
                      _ProfileValue(
                        'Sürekli Kullandığı İlaç / Tıbbi Cihaz',
                        _yesNo(currentStudent.usesRegularMedication),
                      ),
                      _ProfileValue(
                        'İlaç / Tıbbi Cihaz Açıklaması',
                        currentStudent.medicationDetails,
                      ),
                      _ProfileValue(
                        'Sürekli Hastalığı',
                        _yesNo(currentStudent.hasChronicIllness),
                      ),
                      _ProfileValue(
                        'Sürekli Hastalık Açıklaması',
                        currentStudent.chronicIllnessDetails,
                      ),
                      _ProfileValue(
                        'Yapmaktan Hoşlandığı Şeyler',
                        currentStudent.likesActivities,
                      ),
                      _ProfileValue(
                        'Yakın Zamanda Taşınma / Okul Değişikliği',
                        _yesNo(currentStudent.hasRecentMoveOrSchoolChange),
                      ),
                      _ProfileValue(
                        'Taşınma / Okul Değişikliği Açıklaması',
                        currentStudent.moveOrSchoolChangeDetails,
                      ),
                      _ProfileValue(
                        'Ders Dışı Faaliyetleri',
                        currentStudent.extracurricularActivities,
                      ),
                      _ProfileValue(
                        'Kendisine Ait Teknolojik Cihaz',
                        _yesNo(currentStudent.hasTechnologyDevice),
                      ),
                      _ProfileValue(
                        'Günlük Teknolojik Cihaz Kullanımı',
                        _formatUsage(currentStudent.technologyUsageMinutes),
                      ),
                      _ProfileValue(
                        'Etkisinde Olduğu Bir Olay',
                        _yesNo(currentStudent.hasInfluentialEvent),
                      ),
                      _ProfileValue(
                        'Etkileyen Olay Açıklaması',
                        currentStudent.influentialEventDetails,
                      ),
                    ],
                  ),
                  _ProfileSection(
                    title: 'Anne Bilgileri',
                    icon: Icons.woman_outlined,
                    trailingLabel: 'Anne bilgileri',
                    children: [
                      _ProfileValue('Anne Adı', currentStudent.motherName),
                      _ProfileValue(
                        'Anne Soyadı',
                        currentStudent.motherSurname,
                      ),
                      _ProfileValue(
                        'Anne Doğum Yeri',
                        currentStudent.motherBirthPlace,
                      ),
                      _ProfileValue(
                        'Anne Doğum Tarihi',
                        _formatDate(currentStudent.motherBirthDate),
                      ),
                      _ProfileValue(
                        'Anne Sağ mı?',
                        _yesNo(currentStudent.motherIsAlive),
                      ),
                      _ProfileValue(
                        'Anne Öz mü?',
                        _yesNo(currentStudent.motherIsBiological),
                      ),
                      _ProfileValue(
                        'Annenin Engeli Var mı?',
                        _yesNo(currentStudent.motherHasDisability),
                      ),
                      _ProfileValue(
                        'Anne Engel Açıklaması',
                        currentStudent.motherDisabilityDetails,
                      ),
                      _ProfileValue(
                        'Anne Eğitim Durumu',
                        currentStudent.motherEducation,
                      ),
                      _ProfileValue('Anne Mesleği', currentStudent.motherJob),
                    ],
                  ),
                  _ProfileSection(
                    title: 'Baba Bilgileri',
                    icon: Icons.man_outlined,
                    trailingLabel: 'Baba bilgileri',
                    children: [
                      _ProfileValue('Baba Adı', currentStudent.fatherName),
                      _ProfileValue(
                        'Baba Soyadı',
                        currentStudent.fatherSurname,
                      ),
                      _ProfileValue(
                        'Baba Doğum Yeri',
                        currentStudent.fatherBirthPlace,
                      ),
                      _ProfileValue(
                        'Baba Doğum Tarihi',
                        _formatDate(currentStudent.fatherBirthDate),
                      ),
                      _ProfileValue(
                        'Baba Sağ mı?',
                        _yesNo(currentStudent.fatherIsAlive),
                      ),
                      _ProfileValue(
                        'Baba Öz mü?',
                        _yesNo(currentStudent.fatherIsBiological),
                      ),
                      _ProfileValue(
                        'Babanın Engeli Var mı?',
                        _yesNo(currentStudent.fatherHasDisability),
                      ),
                      _ProfileValue(
                        'Baba Engel Açıklaması',
                        currentStudent.fatherDisabilityDetails,
                      ),
                      _ProfileValue(
                        'Baba Eğitim Durumu',
                        currentStudent.fatherEducation,
                      ),
                      _ProfileValue('Baba Mesleği', currentStudent.fatherJob),
                    ],
                  ),
                  _ProfileSection(
                    title: 'Kardeş ve Hane Bilgileri',
                    icon: Icons.family_restroom_outlined,
                    trailingLabel: 'Aile bilgileri',
                    children: [
                      _ProfileValue(
                        'Kardeş Sayısı',
                        currentStudent.siblingCount?.toString(),
                      ),
                      _ProfileValue(
                        'Öğrenci Kaçıncı Çocuk?',
                        currentStudent.childOrder?.toString(),
                      ),
                      _ProfileValue(
                        'Ailesinde Sürekli Hastalığı Olan Biri Var mı?',
                        _yesNo(currentStudent.familyHasChronicIllness),
                      ),
                      _ProfileValue(
                        'Aile Üyelerinin Sürekli Hastalık Açıklaması',
                        currentStudent.householdChronicIllnessDetails,
                      ),
                      _ProfileValue(
                        'Evde Kimler Yaşıyor?',
                        currentStudent.householdMembers,
                      ),
                    ],
                  ),
                  _ProfileSection(
                    title: 'Görüşme Kayıtları',
                    icon: Icons.forum_outlined,
                    trailingLabel: interviews.valueOrNull == null
                        ? null
                        : '${interviews.valueOrNull!.length} kayıt',
                    trailing: FilledButton.tonalIcon(
                      onPressed: () => InterviewDialog.show(
                        context,
                        studentId: currentStudent.id,
                        studentName: currentStudent.fullName,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Görüşme Ekle'),
                    ),
                    fullWidth: true,
                    children: [
                      interviews.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => Text(
                          'Görüşmeler yüklenemedi: $error',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        data: (items) => items.isEmpty
                            ? const Text('Henüz görüşme kaydı bulunmuyor.')
                            : Column(
                                children: [
                                  for (final interview in items)
                                    _InterviewEntry(interview: interview),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.icon,
    this.trailing,
    this.trailingLabel,
    this.initialExpanded = false,
    this.fullWidth = false,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final String? trailingLabel;
  final bool initialExpanded;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) => _ExpandableProfileSection(
    title: title,
    icon: icon,
    trailing: trailing,
    trailingLabel: trailingLabel,
    initialExpanded: initialExpanded,
    fullWidth: fullWidth,
    children: children,
  );
}

class _ExpandableProfileSection extends StatefulWidget {
  const _ExpandableProfileSection({
    required this.title,
    required this.icon,
    required this.children,
    required this.trailing,
    required this.trailingLabel,
    required this.initialExpanded,
    required this.fullWidth,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final String? trailingLabel;
  final bool initialExpanded;
  final bool fullWidth;

  @override
  State<_ExpandableProfileSection> createState() =>
      _ExpandableProfileSectionState();
}

class _ExpandableProfileSectionState extends State<_ExpandableProfileSection> {
  late bool _expanded = widget.initialExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (!_expanded && widget.trailingLabel != null)
                          Text(
                            widget.trailingLabel!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    widget.trailing!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = widget.fullWidth
                      ? 1
                      : (constraints.maxWidth >= 620 ? 2 : 1);
                  final width =
                      (constraints.maxWidth - (columns - 1) * AppSpacing.md) /
                      columns;
                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final child in widget.children)
                        SizedBox(width: width, child: child),
                    ],
                  );
                },
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

class _ProfileValue extends StatelessWidget {
  const _ProfileValue(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();
    final isEmpty = text == null || text.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isEmpty ? AppColors.background : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isEmpty
              ? AppColors.border
              : AppColors.border.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 3),
          Text(
            isEmpty ? 'Belirtilmedi' : text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
              fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final color = isHighlighted
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _InterviewEntry extends StatelessWidget {
  const _InterviewEntry({required this.interview});

  final StudentInterview interview;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      title: Text(interview.subject),
      subtitle: Text('${interview.typeLabel} · ${_formatDate(interview.date)}'),
      children: [
        _ProfileValue('Görüşme Notları', interview.notes),
        const SizedBox(height: AppSpacing.sm),
        _ProfileValue('Takip Planı', interview.actionPlan),
      ],
    );
  }
}

String _yesNo(bool? value) => switch (value) {
  true => 'Evet',
  false => 'Hayır',
  null => 'Belirtilmedi',
};

String _formatUsage(int? minutes) {
  if (minutes == null) return 'Belirtilmedi';
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (hours == 0) return '$remainingMinutes dakika';
  if (remainingMinutes == 0) return '$hours saat';
  return '$hours saat $remainingMinutes dakika';
}

String _formatDate(String? value) {
  if (value == null || value.trim().isEmpty) return 'Belirtilmedi';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.day.toString().padLeft(2, '0')}.'
      '${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
}

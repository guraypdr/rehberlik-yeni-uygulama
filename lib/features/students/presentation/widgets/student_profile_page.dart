import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/layout/app_top_bar.dart';
import '../../../../shared/navigation/app_navigation.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              destinations: appDestinations,
              selectedId: 'students',
              onSelected: (destinationId) {
                ref.read(navigationProvider.notifier).select(destinationId);
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                child: _StudentProfileSearch(
                                  onSelected: (selectedStudent) {
                                    if (selectedStudent.id ==
                                        currentStudent.id) {
                                      return;
                                    }
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute<void>(
                                        builder: (_) => StudentProfilePage(
                                          student: selectedStudent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () => StudentInfoFormSheet.show(
                                context,
                                currentStudent,
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Düzenle'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Text(
                              'Öğrenciler',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              child: Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              'Öğrenci Profili',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _StudentProfileHeader(
                          student: currentStudent,
                          genderColor: genderColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: _StudentProfileContent(
                      student: currentStudent,
                      interviews: interviews,
                      onAddInterview: () => InterviewDialog.show(
                        context,
                        studentId: currentStudent.id,
                        studentName: currentStudent.fullName,
                      ),
                    ),
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

class _StudentProfileSearch extends ConsumerStatefulWidget {
  const _StudentProfileSearch({required this.onSelected});

  final ValueChanged<Student> onSelected;

  @override
  ConsumerState<_StudentProfileSearch> createState() =>
      _StudentProfileSearchState();
}

class _StudentProfileSearchState extends ConsumerState<_StudentProfileSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final studentsAsync = ref.read(studentsProvider);
    if (studentsAsync.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Öğrenciler aranamadı: ${studentsAsync.error}')),
      );
      return;
    }
    if (studentsAsync.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğrenci listesi yükleniyor.')),
      );
      return;
    }
    final students = studentsAsync.valueOrNull ?? const [];
    final matches = students
        .where(
          (student) =>
              student.fullName.toLowerCase().contains(query) ||
              student.number.toLowerCase().contains(query) ||
              student.displayClass.toLowerCase().contains(query),
        )
        .take(20)
        .toList();

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aramaya uygun öğrenci bulunamadı.')),
      );
      return;
    }

    if (matches.length == 1) {
      widget.onSelected(matches.single);
      return;
    }

    final selectedStudent = await showDialog<Student>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenci seçin'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final student in matches)
                ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      student.name.characters.firstOrNull?.toUpperCase() ?? 'Ö',
                    ),
                  ),
                  title: Text(student.fullName),
                  subtitle: Text(
                    'No ${student.number} · ${student.displayClass}',
                  ),
                  onTap: () => Navigator.pop(context, student),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
        ],
      ),
    );
    if (selectedStudent != null) widget.onSelected(selectedStudent);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('student_profile_search'),
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(),
      decoration: InputDecoration(
        hintText: 'Öğrenci adı, numarası veya sınıfı ara...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: IconButton(
          tooltip: 'Öğrenci Ara',
          onPressed: _search,
          icon: const Icon(Icons.arrow_forward),
        ),
        filled: true,
        fillColor: AppColors.background,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _StudentProfileHeader extends StatelessWidget {
  const _StudentProfileHeader({
    required this.student,
    required this.genderColor,
  });

  final Student student;
  final Color genderColor;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final identity = Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: genderColor.withValues(alpha: 0.12),
                child: Text(
                  student.name.characters.firstOrNull?.toUpperCase() ?? 'Ö',
                  style: TextStyle(
                    color: genderColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            student.displayClass,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
          final summary = Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeaderFact(
                icon: Icons.badge_outlined,
                label: 'Öğrenci No',
                value: student.number,
              ),
              _HeaderFact(
                icon: Icons.cake_outlined,
                label: 'Doğum Tarihi',
                value: _formatDate(student.birthDate),
              ),
              _HeaderFact(
                icon: Icons.calendar_today_outlined,
                label: 'Kayıt Tarihi',
                value: _formatDate(student.createdAt),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (compact) ...[
                identity,
                const SizedBox(height: AppSpacing.md),
                summary,
              ] else
                Row(
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 2, child: summary),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StudentInfoFormStatus(
                      student: student,
                      showProgressBar: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${student.studentInfoFormCompletion}%',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _HeaderFact extends StatelessWidget {
  const _HeaderFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 132),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ],
    ),
  );
}

class _StudentProfileContent extends StatelessWidget {
  const _StudentProfileContent({
    required this.student,
    required this.interviews,
    required this.onAddInterview,
  });

  final Student student;
  final AsyncValue<List<StudentInterview>> interviews;
  final VoidCallback onAddInterview;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      0,
      AppSpacing.xl,
      AppSpacing.lg,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 238,
                child: _StudentSummaryPanel(student: student),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StudentProfileTabs(
                  student: student,
                  interviews: interviews,
                  onAddInterview: onAddInterview,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            _StudentSummaryPanel(student: student, compact: true),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _StudentProfileTabs(
                student: student,
                interviews: interviews,
                onAddInterview: onAddInterview,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _StudentSummaryPanel extends StatelessWidget {
  const _StudentSummaryPanel({required this.student, this.compact = false});

  final Student student;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final facts = <(IconData, String, String)>[
      (Icons.meeting_room_outlined, 'Sınıf / Şube', student.displayClass),
      (Icons.badge_outlined, 'Öğrenci No', student.number),
      (Icons.cake_outlined, 'Doğum Tarihi', _formatDate(student.birthDate)),
      (Icons.wc_outlined, 'Cinsiyet', student.gender),
    ];
    final parent = [
      student.motherName,
      student.motherSurname,
    ].whereType<String>().where((name) => name.trim().isNotEmpty).join(' ');

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: compact
            ? Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final (icon, label, value) in facts)
                    _SummaryFact(icon: icon, label: label, value: value),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Özet Bilgiler',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final (icon, label, value) in facts)
                    _SummaryFact(icon: icon, label: label, value: value),
                  const Divider(height: AppSpacing.lg),
                  Text(
                    'Veli Bilgileri',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SummaryFact(
                    icon: Icons.person_outline,
                    label: 'Anne',
                    value: parent.isEmpty ? 'Belirtilmedi' : parent,
                  ),
                  _SummaryFact(
                    icon: Icons.person_outline,
                    label: 'Baba',
                    value: [student.fatherName, student.fatherSurname]
                        .whereType<String>()
                        .where((name) => name.trim().isNotEmpty)
                        .join(' '),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SummaryFact extends StatelessWidget {
  const _SummaryFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text('$label  ', style: Theme.of(context).textTheme.bodySmall),
        Flexible(
          child: Text(
            value.isEmpty ? 'Belirtilmedi' : value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    ),
  );
}

class _StudentProfileTabs extends StatefulWidget {
  const _StudentProfileTabs({
    required this.student,
    required this.interviews,
    required this.onAddInterview,
  });

  final Student student;
  final AsyncValue<List<StudentInterview>> interviews;
  final VoidCallback onAddInterview;

  @override
  State<_StudentProfileTabs> createState() => _StudentProfileTabsState();
}

class _StudentProfileTabsState extends State<_StudentProfileTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final tabLabels = [
      ('Temel Bilgiler', Icons.badge_outlined),
      ('Aile Bilgileri', Icons.family_restroom_outlined),
      ('Sağlık Bilgileri', Icons.favorite_border),
      ('Eğitim Bilgileri', Icons.school_outlined),
      ('Sosyal Bilgiler', Icons.home_outlined),
      ('Görüşme Geçmişi', Icons.history),
    ];

    return Column(
      children: [
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.border),
          ),
          child: TabBar(
            key: const Key('student_profile_tab_bar'),
            controller: _controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final (label, icon) in tabLabels)
                Tab(
                  key: Key('student_profile_tab_$label'),
                  iconMargin: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 17),
                      const SizedBox(width: AppSpacing.xs),
                      Text(label),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              _ProfileTabBody(
                key: const Key('student_profile_tab_content_0'),
                panels: [
                  _InfoPanel(
                    title: 'Kişisel Bilgiler',
                    icon: Icons.person_outline,
                    fields: [
                      ('Adı Soyadı', student.fullName),
                      ('Cinsiyet', student.gender),
                      ('Öğrenci No', student.number),
                      ('Sınıf / Şube', student.displayClass),
                      ('Doğum Yeri', student.birthPlace),
                      ('Doğum Tarihi', _formatDate(student.birthDate)),
                      ('Pansiyon Durumu', student.boardingStatus),
                      ('Adres', student.address),
                    ],
                  ),
                ],
              ),
              _ProfileTabBody(
                key: const Key('student_profile_tab_content_1'),
                panels: [
                  _InfoPanel(
                    title: 'Anne Bilgileri',
                    icon: Icons.woman_outlined,
                    fields: [
                      (
                        'Adı Soyadı',
                        _fullName(student.motherName, student.motherSurname),
                      ),
                      ('Doğum Yeri', student.motherBirthPlace),
                      ('Doğum Tarihi', _formatDate(student.motherBirthDate)),
                      ('Sağ mı?', _yesNo(student.motherIsAlive)),
                      ('Öz mü?', _yesNo(student.motherIsBiological)),
                      ('Engeli var mı?', _yesNo(student.motherHasDisability)),
                      ('Engel Açıklaması', student.motherDisabilityDetails),
                      ('Eğitim Durumu', student.motherEducation),
                      ('Mesleği', student.motherJob),
                    ],
                  ),
                  _InfoPanel(
                    title: 'Baba Bilgileri',
                    icon: Icons.man_outlined,
                    fields: [
                      (
                        'Adı Soyadı',
                        _fullName(student.fatherName, student.fatherSurname),
                      ),
                      ('Doğum Yeri', student.fatherBirthPlace),
                      ('Doğum Tarihi', _formatDate(student.fatherBirthDate)),
                      ('Sağ mı?', _yesNo(student.fatherIsAlive)),
                      ('Öz mü?', _yesNo(student.fatherIsBiological)),
                      ('Engeli var mı?', _yesNo(student.fatherHasDisability)),
                      ('Engel Açıklaması', student.fatherDisabilityDetails),
                      ('Eğitim Durumu', student.fatherEducation),
                      ('Mesleği', student.fatherJob),
                    ],
                  ),
                  _InfoPanel(
                    title: 'Hane Bilgileri',
                    icon: Icons.home_outlined,
                    fields: [
                      ('Kardeş Sayısı', student.siblingCount?.toString()),
                      ('Kaçıncı Çocuk?', student.childOrder?.toString()),
                      ('Evde Kimler Yaşıyor?', student.householdMembers),
                    ],
                  ),
                ],
              ),
              _ProfileTabBody(
                key: const Key('student_profile_tab_content_2'),
                panels: [
                  _InfoPanel(
                    title: 'Sağlık Bilgileri',
                    icon: Icons.favorite_border,
                    fields: [
                      (
                        'Sürekli Hastalığı Var mı?',
                        _yesNo(student.hasChronicIllness),
                      ),
                      ('Hastalık Açıklaması', student.chronicIllnessDetails),
                      (
                        'Sürekli İlaç / Tıbbi Cihaz Kullanıyor mu?',
                        _yesNo(student.usesRegularMedication),
                      ),
                      ('İlaç / Cihaz Açıklaması', student.medicationDetails),
                      (
                        'Ailede Sürekli Hastalık Var mı?',
                        _yesNo(student.familyHasChronicIllness),
                      ),
                      (
                        'Aile Hastalık Açıklaması',
                        student.householdChronicIllnessDetails,
                      ),
                      (
                        'Anne Engel Durumu',
                        _yesNo(student.motherHasDisability),
                      ),
                      (
                        'Baba Engel Durumu',
                        _yesNo(student.fatherHasDisability),
                      ),
                    ],
                  ),
                ],
              ),
              _ProfileTabBody(
                key: const Key('student_profile_tab_content_3'),
                panels: [
                  _InfoPanel(
                    title: 'Eğitim Bilgileri',
                    icon: Icons.school_outlined,
                    fields: [
                      (
                        'Okul Öncesi Eğitim',
                        _yesNo(student.preschoolEducation),
                      ),
                      (
                        'Yakın Zamanda Taşınma / Okul Değişikliği',
                        _yesNo(student.hasRecentMoveOrSchoolChange),
                      ),
                      (
                        'Taşınma / Okul Değişikliği Açıklaması',
                        student.moveOrSchoolChangeDetails,
                      ),
                      (
                        'Ders Dışı Faaliyetleri',
                        student.extracurricularActivities,
                      ),
                      (
                        'Teknolojik Cihazı Var mı?',
                        _yesNo(student.hasTechnologyDevice),
                      ),
                      (
                        'Günlük Cihaz Kullanımı',
                        _formatUsage(student.technologyUsageMinutes),
                      ),
                    ],
                  ),
                ],
              ),
              _ProfileTabBody(
                key: const Key('student_profile_tab_content_4'),
                panels: [
                  _InfoPanel(
                    title: 'Sosyal ve Aile Yaşamı',
                    icon: Icons.home_outlined,
                    fields: [
                      ('Yapmaktan Hoşlandığı Şeyler', student.likesActivities),
                      ('Kardeş Sayısı', student.siblingCount?.toString()),
                      ('Kaçıncı Çocuk?', student.childOrder?.toString()),
                      ('Evde Kimler Yaşıyor?', student.householdMembers),
                      (
                        'Etkisinde Olduğu Bir Olay Var mı?',
                        _yesNo(student.hasInfluentialEvent),
                      ),
                      ('Olay Açıklaması', student.influentialEventDetails),
                    ],
                  ),
                ],
              ),
              _ProfileTabBody(
                key: const Key('student_profile_tab_content_5'),
                panels: [
                  _InterviewPanel(
                    interviews: widget.interviews,
                    onAddInterview: widget.onAddInterview,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTabBody extends StatelessWidget {
  const _ProfileTabBody({super.key, required this.panels});

  final List<Widget> panels;

  @override
  Widget build(BuildContext context) => ListView(
    key: const Key('student_profile_sections'),
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    children: panels,
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.icon,
    required this.fields,
  });

  final String title;
  final IconData icon;
  final List<(String, String?)> fields;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 2 : 1;
              final spacing = AppSpacing.md;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final (label, value) in fields)
                    SizedBox(width: width, child: _ProfileValue(label, value)),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _InterviewPanel extends StatelessWidget {
  const _InterviewPanel({
    required this.interviews,
    required this.onAddInterview,
  });

  final AsyncValue<List<StudentInterview>> interviews;
  final VoidCallback onAddInterview;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Görüşme Kayıtları',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddInterview,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Görüşme Ekle'),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          interviews.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text(
              'Görüşmeler yüklenemedi: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            data: (items) => items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(
                      child: Text('Henüz görüşme kaydı bulunmuyor.'),
                    ),
                  )
                : Column(
                    children: [
                      for (final interview in items)
                        _InterviewEntry(interview: interview),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileValue extends StatelessWidget {
  const _ProfileValue(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();
    final isEmpty = text == null || text.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            isEmpty ? 'Belirtilmedi' : text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
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

String _fullName(String? name, String? surname) {
  final parts = [name, surname]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty);
  return parts.join(' ');
}

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

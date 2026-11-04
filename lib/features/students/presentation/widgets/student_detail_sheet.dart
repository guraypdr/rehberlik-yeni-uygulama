import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../classes/presentation/classes_provider.dart';
import '../students_provider.dart';
import '../../domain/student.dart';
import '../../domain/student_interview.dart';
import 'interview_dialog.dart';

/// Öğrenci Profil ve Detay Düzenleme Ekranı (Sekmeli Dialog / Sheet).
class StudentDetailSheet extends ConsumerStatefulWidget {
  const StudentDetailSheet({super.key, required this.student});

  final Student student;

  static Future<void> show(BuildContext context, Student student) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StudentDetailSheet(student: student),
    );
  }

  @override
  ConsumerState<StudentDetailSheet> createState() => _StudentDetailSheetState();
}

class _StudentDetailSheetState extends ConsumerState<StudentDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // ── 1. Genel Bilgiler Controller'ları ─────────────────────────────────
  late TextEditingController _nameCtrl;
  late TextEditingController _surnameCtrl;
  late TextEditingController _numberCtrl;
  late TextEditingController _tcCtrl;
  late TextEditingController _birthDateCtrl;
  late TextEditingController _enrollmentDateCtrl;
  late TextEditingController _transferSchoolCtrl;
  late TextEditingController _transferGradeCtrl;
  late TextEditingController _repeatReasonCtrl;
  late TextEditingController _specialStatusCtrl;
  late TextEditingController _photoPathCtrl;

  late String _gender;
  late String _status;
  late int _classId;
  late bool _hasRepeatedGrade;

  // ── 2. Aile Bilgileri Controller'ları ─────────────────────────────────
  late TextEditingController _motherNameCtrl;
  late TextEditingController _motherSurnameCtrl;
  late TextEditingController _motherJobCtrl;
  late TextEditingController _motherPhoneCtrl;
  late TextEditingController _motherAddressCtrl;
  late TextEditingController _motherDisabilityDetailsCtrl;

  late bool _motherIsBiological;
  late bool _motherIsAlive;
  late bool _motherHasDisability;

  late TextEditingController _fatherNameCtrl;
  late TextEditingController _fatherSurnameCtrl;
  late TextEditingController _fatherJobCtrl;
  late TextEditingController _fatherPhoneCtrl;
  late TextEditingController _fatherAddressCtrl;
  late TextEditingController _fatherDisabilityDetailsCtrl;

  late bool _fatherIsBiological;
  late bool _fatherIsAlive;
  late bool _fatherHasDisability;

  late String _parentsTogether;
  late String _livesWith;
  late String _guardianType;
  late TextEditingController _guardianNameCtrl;
  late TextEditingController _guardianPhoneCtrl;

  late int _siblingCount;
  late TextEditingController _siblingDetailsCtrl;
  late TextEditingController _householdMembersCtrl;
  late TextEditingController _familyNotesCtrl;
  late String _familyRiskLevel;

  // ── 3. Sağlık Controller'ları ─────────────────────────────────────────
  late bool _hasChronicIllness;
  late TextEditingController _chronicDetailsCtrl;
  late bool _usesRegularMedication;
  late TextEditingController _medicationDetailsCtrl;
  late bool _hasPsychologicalHistory;
  late TextEditingController _psychologicalDetailsCtrl;
  late TextEditingController _generalNotesCtrl;

  bool _saving = false;
  String _interviewFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final s = widget.student;

    // Genel
    _nameCtrl = TextEditingController(text: s.name);
    _surnameCtrl = TextEditingController(text: s.surname);
    _numberCtrl = TextEditingController(text: s.number);
    _tcCtrl = TextEditingController(text: s.tcNo ?? '');
    _birthDateCtrl = TextEditingController(text: s.birthDate ?? '');
    _enrollmentDateCtrl = TextEditingController(text: s.enrollmentDate ?? '');
    _transferSchoolCtrl = TextEditingController(text: s.transferSchool ?? '');
    _transferGradeCtrl = TextEditingController(text: s.transferGrade ?? '');
    _repeatReasonCtrl = TextEditingController(text: s.repeatReason ?? '');
    _specialStatusCtrl = TextEditingController(text: s.specialStatus ?? '');
    _photoPathCtrl = TextEditingController(text: s.photoPath ?? '');

    _gender = s.gender;
    _status = s.status;
    _classId = s.classId;
    _hasRepeatedGrade = s.hasRepeatedGrade;

    // Anne
    _motherNameCtrl = TextEditingController(text: s.motherName ?? '');
    _motherSurnameCtrl = TextEditingController(text: s.motherSurname ?? '');
    _motherJobCtrl = TextEditingController(text: s.motherJob ?? '');
    _motherPhoneCtrl = TextEditingController(text: s.motherPhone ?? '');
    _motherAddressCtrl = TextEditingController(text: s.motherAddress ?? '');
    _motherDisabilityDetailsCtrl =
        TextEditingController(text: s.motherDisabilityDetails ?? '');
    _motherIsBiological = s.motherIsBiological;
    _motherIsAlive = s.motherIsAlive;
    _motherHasDisability = s.motherHasDisability;

    // Baba
    _fatherNameCtrl = TextEditingController(text: s.fatherName ?? '');
    _fatherSurnameCtrl = TextEditingController(text: s.fatherSurname ?? '');
    _fatherJobCtrl = TextEditingController(text: s.fatherJob ?? '');
    _fatherPhoneCtrl = TextEditingController(text: s.fatherPhone ?? '');
    _fatherAddressCtrl = TextEditingController(text: s.fatherAddress ?? '');
    _fatherDisabilityDetailsCtrl =
        TextEditingController(text: s.fatherDisabilityDetails ?? '');
    _fatherIsBiological = s.fatherIsBiological;
    _fatherIsAlive = s.fatherIsAlive;
    _fatherHasDisability = s.fatherHasDisability;

    _parentsTogether = s.parentsTogether;
    _livesWith = s.livesWith;
    _guardianType = s.guardianType;
    _guardianNameCtrl = TextEditingController(text: s.guardianName ?? '');
    _guardianPhoneCtrl = TextEditingController(text: s.guardianPhone ?? '');

    _siblingCount = s.siblingCount;
    _siblingDetailsCtrl = TextEditingController(text: s.siblingDetails ?? '');
    _householdMembersCtrl = TextEditingController(text: s.householdMembers ?? '');
    _familyNotesCtrl = TextEditingController(text: s.familyNotes ?? '');
    _familyRiskLevel = s.familyRiskLevel;

    // Sağlık
    _hasChronicIllness = s.hasChronicIllness;
    _chronicDetailsCtrl = TextEditingController(text: s.chronicIllnessDetails ?? '');
    _usesRegularMedication = s.usesRegularMedication;
    _medicationDetailsCtrl = TextEditingController(text: s.medicationDetails ?? '');
    _hasPsychologicalHistory = s.hasPsychologicalHistory;
    _psychologicalDetailsCtrl =
        TextEditingController(text: s.psychologicalDetails ?? '');
    _generalNotesCtrl = TextEditingController(text: s.generalNotes ?? '');

    _nameCtrl.addListener(() => setState(() {}));
    _surnameCtrl.addListener(() => setState(() {}));
    _numberCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _numberCtrl.dispose();
    _tcCtrl.dispose();
    _birthDateCtrl.dispose();
    _enrollmentDateCtrl.dispose();
    _transferSchoolCtrl.dispose();
    _transferGradeCtrl.dispose();
    _repeatReasonCtrl.dispose();
    _specialStatusCtrl.dispose();
    _photoPathCtrl.dispose();
    _motherNameCtrl.dispose();
    _motherSurnameCtrl.dispose();
    _motherJobCtrl.dispose();
    _motherPhoneCtrl.dispose();
    _motherAddressCtrl.dispose();
    _motherDisabilityDetailsCtrl.dispose();
    _fatherNameCtrl.dispose();
    _fatherSurnameCtrl.dispose();
    _fatherJobCtrl.dispose();
    _fatherPhoneCtrl.dispose();
    _fatherAddressCtrl.dispose();
    _fatherDisabilityDetailsCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    _siblingDetailsCtrl.dispose();
    _householdMembersCtrl.dispose();
    _familyNotesCtrl.dispose();
    _chronicDetailsCtrl.dispose();
    _medicationDetailsCtrl.dispose();
    _psychologicalDetailsCtrl.dispose();
    _generalNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final classesState = ref.watch(classesProvider).valueOrNull;
    final classes = classesState?.classes ?? [];

    final isFemale = _gender == 'Kız';
    final genderColor = isFemale ? const Color(0xFFE91E63) : const Color(0xFF1976D2);
    final initials = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim().characters.first.toUpperCase()
        : 'Ö';
    final fullName = '${_nameCtrl.text.trim()} ${_surnameCtrl.text.trim()}'.trim();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 820),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 74,
              title: Row(
                children: [
                  // Profil Avatarı
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isFemale
                            ? [const Color(0xFFF06292), const Color(0xFFE91E63)]
                            : [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: genderColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // İsim & Bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              fullName.isNotEmpty ? fullName : 'Öğrenci Dosyası',
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '#${_numberCtrl.text.trim()}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rehberlik & Psikolojik Danışma Servisi Öğrenci Tanıma Dosyası',
                          style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Risk Rozeti
                  _RiskBadge(level: _familyRiskLevel),
                  const SizedBox(width: AppSpacing.md),
                  IconButton(
                    tooltip: 'Kapat',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: cs.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: cs.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(icon: Icon(Icons.badge_outlined, size: 18), text: 'Genel & Kayıt'),
                      Tab(icon: Icon(Icons.family_restroom_outlined, size: 18), text: 'Aile & Veli'),
                      Tab(icon: Icon(Icons.medical_services_outlined, size: 18), text: 'Sağlık Durumu'),
                      Tab(icon: Icon(Icons.forum_outlined, size: 18), text: 'Görüşme Kayıtları'),
                    ],
                  ),
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabGeneral(classes),
                  _buildTabFamily(),
                  _buildTabHealth(),
                  _buildTabInterviews(),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Text(
                    'Kayıt Tarihi: ${widget.student.createdAt.split('T').first}',
                    style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Vazgeç'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: _saving ? null : _saveAll,
                    icon: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 16),
                    label: const Text('Değişiklikleri Kaydet'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Sekme: Genel ve Kayıt Bilgileri
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTabGeneral(List<dynamic> classes) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormCard(
            title: 'Temel Kimlik ve Şube Bilgileri',
            icon: Icons.badge_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Adı *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ad zorunludur' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _surnameCtrl,
                      decoration: const InputDecoration(labelText: 'Soyadı *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Soyad zorunludur' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _numberCtrl,
                      decoration: const InputDecoration(labelText: 'Okul No *'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Numara zorunludur'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _classId,
                      decoration: const InputDecoration(labelText: 'Şube *'),
                      items: [
                        for (final c in classes)
                          DropdownMenuItem(
                            value: c.id as int,
                            child: Text('${c.gradeLevelLabel} / ${c.branch}'),
                          ),
                      ],
                      onChanged: (id) {
                        if (id != null) setState(() => _classId = id);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'Cinsiyet'),
                      items: const [
                        DropdownMenuItem(value: 'Kız', child: Text('Kız')),
                        DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                      ],
                      onChanged: (g) {
                        if (g != null) setState(() => _gender = g);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Öğrencilik Durumu'),
                      items: const [
                        DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                        DropdownMenuItem(value: 'Nakil Gitti', child: Text('Nakil Gitti')),
                        DropdownMenuItem(value: 'Mezun', child: Text('Mezun')),
                        DropdownMenuItem(value: 'Ayrıldı', child: Text('Ayrıldı')),
                      ],
                      onChanged: (s) {
                        if (s != null) setState(() => _status = s);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          _FormCard(
            title: 'Resmi Nüfus ve Kayıt Bilgileri',
            icon: Icons.assignment_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tcCtrl,
                      decoration: const InputDecoration(
                        labelText: 'T.C. Kimlik No',
                        hintText: '11 haneli TC no',
                      ),
                      maxLength: 11,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _birthDateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi',
                        hintText: 'GG.AA.YYYY',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _enrollmentDateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Okula Kayıt Tarihi',
                        hintText: 'GG.AA.YYYY',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          _FormCard(
            title: 'Eğitim Geçmişi, Nakil & Özel Durumlar',
            icon: Icons.school_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _transferSchoolCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nakil Geldiyse Önceki Okulu',
                        hintText: 'Örn. Atatürk Ortaokulu',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _transferGradeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Geldiği Sınıf Düzeyi',
                        hintText: 'Örn. 9. Sınıf 1. Dönem',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Daha önce sınıf tekrarı yapmış mı?'),
                subtitle: const Text('Devamsızlık veya akademik başarısızlık kaynaklı'),
                value: _hasRepeatedGrade,
                onChanged: (v) => setState(() => _hasRepeatedGrade = v),
              ),
              if (_hasRepeatedGrade) ...[
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _repeatReasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Sınıf Tekrarı Sebebi',
                    hintText: 'Örn. Sağlık sebebiyle devamsızlık / Akademik yetersizlik',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _specialStatusCtrl,
                decoration: const InputDecoration(
                  labelText: 'Özel Eğitim / Üstün Yetenek Tanısı',
                  hintText: 'BİLSEM, Disleksi, Otizm Spektrum, DEHB, Fiziksel Engel vb.',
                  prefixIcon: Icon(Icons.star_outline_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Sekme: Aile ve Veli Bilgileri
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTabFamily() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aile Risk Durumu Kartı
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.warning, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aile Risk Değerlendirmesi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Öğrencinin ailevi durumuna göre rehberlik öncelik seviyesi',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: _familyRiskLevel,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'Düşük', child: Text('🟢 Düşük Risk')),
                    DropdownMenuItem(value: 'Orta', child: Text('🟡 Orta Risk (Takip)')),
                    DropdownMenuItem(value: 'Yüksek', child: Text('🟠 Yüksek Risk (Öncelikli)')),
                    DropdownMenuItem(value: 'Kritik', child: Text('🔴 Kritik Durum')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _familyRiskLevel = val);
                  },
                ),
              ],
            ),
          ),

          _FormCard(
            title: 'Anne Bilgileri',
            icon: Icons.female,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _motherNameCtrl,
                      decoration: const InputDecoration(labelText: 'Anne Adı'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _motherSurnameCtrl,
                      decoration: const InputDecoration(labelText: 'Anne Soyadı'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _motherPhoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Telefon No',
                        prefixIcon: Icon(Icons.phone_outlined, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _motherJobCtrl,
                      decoration: const InputDecoration(labelText: 'Mesleği / Çalışma Durumu'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      initialValue: _motherIsBiological,
                      decoration: const InputDecoration(labelText: 'Öz / Üvey'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Öz Anne')),
                        DropdownMenuItem(value: false, child: Text('Üvey Anne')),
                      ],
                      onChanged: (v) => setState(() => _motherIsBiological = v ?? true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      initialValue: _motherIsAlive,
                      decoration: const InputDecoration(labelText: 'Hayatta mı?'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Hayatta')),
                        DropdownMenuItem(value: false, child: Text('Vefat Etmiş')),
                      ],
                      onChanged: (v) => setState(() => _motherIsAlive = v ?? true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Annenin engellilik veya kronik rahatsızlık durumu var mı?'),
                value: _motherHasDisability,
                onChanged: (v) => setState(() => _motherHasDisability = v),
              ),
              if (_motherHasDisability) ...[
                TextFormField(
                  controller: _motherDisabilityDetailsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Annenin Engel / Sağlık Açıklaması',
                  ),
                ),
              ],
            ],
          ),

          _FormCard(
            title: 'Baba Bilgileri',
            icon: Icons.male,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatherNameCtrl,
                      decoration: const InputDecoration(labelText: 'Baba Adı'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _fatherSurnameCtrl,
                      decoration: const InputDecoration(labelText: 'Baba Soyadı'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _fatherPhoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Telefon No',
                        prefixIcon: Icon(Icons.phone_outlined, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatherJobCtrl,
                      decoration: const InputDecoration(labelText: 'Mesleği / Çalışma Durumu'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      initialValue: _fatherIsBiological,
                      decoration: const InputDecoration(labelText: 'Öz / Üvey'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Öz Baba')),
                        DropdownMenuItem(value: false, child: Text('Üvey Baba')),
                      ],
                      onChanged: (v) => setState(() => _fatherIsBiological = v ?? true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      initialValue: _fatherIsAlive,
                      decoration: const InputDecoration(labelText: 'Hayatta mı?'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Hayatta')),
                        DropdownMenuItem(value: false, child: Text('Vefat Etmiş')),
                      ],
                      onChanged: (v) => setState(() => _fatherIsAlive = v ?? true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Babanın engellilik veya kronik rahatsızlık durumu var mı?'),
                value: _fatherHasDisability,
                onChanged: (v) => setState(() => _fatherHasDisability = v),
              ),
              if (_fatherHasDisability) ...[
                TextFormField(
                  controller: _fatherDisabilityDetailsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Babanın Engel / Sağlık Açıklaması',
                  ),
                ),
              ],
            ],
          ),

          _FormCard(
            title: 'Birliktelik, Yaşam ve Veli Durumu',
            icon: Icons.home_work_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _parentsTogether,
                      decoration: const InputDecoration(labelText: 'Anne-Baba Birliktelik Durumu'),
                      items: const [
                        DropdownMenuItem(value: 'Birlikte', child: Text('Birlikte')),
                        DropdownMenuItem(value: 'Ayrı / Boşanmış', child: Text('Ayrı / Boşanmış')),
                        DropdownMenuItem(value: 'Resmen Evli / Ayrı Yaşıyor', child: Text('Ayrı Yaşıyor')),
                        DropdownMenuItem(value: 'Vefat', child: Text('Ebeveyn Kaybı')),
                      ],
                      onChanged: (v) => setState(() => _parentsTogether = v ?? 'Birlikte'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _livesWith,
                      decoration: const InputDecoration(labelText: 'Öğrenci Kiminle Yaşıyor?'),
                      items: const [
                        DropdownMenuItem(value: 'Anne-Baba', child: Text('Anne ve Baba')),
                        DropdownMenuItem(value: 'Sadece Anne', child: Text('Sadece Anne')),
                        DropdownMenuItem(value: 'Sadece Baba', child: Text('Sadece Baba')),
                        DropdownMenuItem(value: 'Akraba / Büyükanne', child: Text('Akraba / Büyükanne')),
                        DropdownMenuItem(value: 'Yurt / Pansiyon', child: Text('Yurt / Pansiyon')),
                        DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
                      ],
                      onChanged: (v) => setState(() => _livesWith = v ?? 'Anne-Baba'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _guardianType,
                      decoration: const InputDecoration(labelText: 'Yasal Velisi Kim?'),
                      items: const [
                        DropdownMenuItem(value: 'Anne-Baba', child: Text('Anne ve Baba')),
                        DropdownMenuItem(value: 'Anne', child: Text('Anne')),
                        DropdownMenuItem(value: 'Baba', child: Text('Baba')),
                        DropdownMenuItem(value: 'Vasi / Diğer', child: Text('Vasi / Diğer')),
                      ],
                      onChanged: (v) => setState(() => _guardianType = v ?? 'Anne-Baba'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _guardianNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Veli Adı (Gerekirse)',
                        hintText: 'Örn. Anne veya vasi adı',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _guardianPhoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Veli İletişim Numarası',
                        prefixIcon: Icon(Icons.phone_outlined, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          _FormCard(
            title: 'Ev, Kardeş ve Aile Görüşme Notları',
            icon: Icons.people_outline,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: DropdownButtonFormField<int>(
                      initialValue: _siblingCount,
                      decoration: const InputDecoration(labelText: 'Kardeş Sayısı'),
                      items: [
                        for (int i = 0; i <= 10; i++)
                          DropdownMenuItem(value: i, child: Text('$i')),
                      ],
                      onChanged: (v) => setState(() => _siblingCount = v ?? 0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _siblingDetailsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kardeşlerin Eğitim ve Yaş Durumu',
                        hintText: 'Örn. 1 abla (üniversite), 1 küçük kardeş (ilkokul)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _householdMembersCtrl,
                decoration: const InputDecoration(
                  labelText: 'Evde Birlikte Yaşayan Kişiler',
                  hintText: 'Örn. Anne, baba, 2 kardeş ve dede',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _familyNotesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Aileyle Yapılan Görüşmeler ve Alınan Bilgiler',
                  hintText: 'Aile dinamikleri, sosyoekonomik durum, ebeveyn tutumları vb.',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Sekme: Sağlık Durumu Bilgileri
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTabHealth() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormCard(
            title: 'Kronik Hastalık ve Düzenli İlaç Kullanımı',
            icon: Icons.medical_information_outlined,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sürekli bir hastalığı var mı?'),
                subtitle: const Text('Astım, diyabet, epilepsi, alerji, kalp vb.'),
                value: _hasChronicIllness,
                onChanged: (v) => setState(() => _hasChronicIllness = v),
              ),
              if (_hasChronicIllness) ...[
                TextFormField(
                  controller: _chronicDetailsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hastalık Açıklaması ve Acil Durum Notları',
                    hintText: 'Hastalığın türü, kriz anında yapılması gerekenler...',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sürekli kullandığı bir ilaç var mı?'),
                subtitle: const Text('Düzenli alınması gereken reçeteli ilaçlar'),
                value: _usesRegularMedication,
                onChanged: (v) => setState(() => _usesRegularMedication = v),
              ),
              if (_usesRegularMedication) ...[
                TextFormField(
                  controller: _medicationDetailsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kullanılan İlaçlar ve Doz Bilgisi',
                    hintText: 'İlaç adı, kullanım saatleri, okulda alınması gerekiyor mu...',
                  ),
                ),
              ],
            ],
          ),

          _FormCard(
            title: 'Psikolojik ve Ruhsal Sağlık Geçmişi',
            icon: Icons.psychology_outlined,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Daha önce ruhsal veya psikolojik bir rahatsızlık geçirmiş mi?'),
                subtitle: const Text('Psikiyatrik tanı, travma, fobi, terapi geçmişi'),
                value: _hasPsychologicalHistory,
                onChanged: (v) => setState(() => _hasPsychologicalHistory = v),
              ),
              if (_hasPsychologicalHistory) ...[
                TextFormField(
                  controller: _psychologicalDetailsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ruhsal Durum / Tedavi Geçmişi Açıklaması',
                    hintText: 'Takip eden hekim/hastane, terapi süreci, RAM raporu vb.',
                  ),
                ),
              ],
            ],
          ),

          _FormCard(
            title: 'Genel Rehberlik ve Gözlem Notları',
            icon: Icons.notes_outlined,
            children: [
              TextFormField(
                controller: _generalNotesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Rehberlik Servisi Özel Notları',
                  hintText: 'Öğrenci hakkında rehberlik servisine özel önemli notlar ve gözlemler...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Sekme: Rehberlik Servisi Görüşme Kayıtları
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTabInterviews() {
    final interviewsAsync =
        ref.watch(studentInterviewsProvider(widget.student.id));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FilterChip(
                label: 'Tümü',
                selected: _interviewFilter == 'all',
                onSelected: () => setState(() => _interviewFilter = 'all'),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterChip(
                label: 'Bireysel (Öğrenci)',
                selected: _interviewFilter == 'student',
                onSelected: () => setState(() => _interviewFilter = 'student'),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterChip(
                label: 'Veli Görüşmeleri',
                selected: _interviewFilter == 'parent',
                onSelected: () => setState(() => _interviewFilter = 'parent'),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterChip(
                label: 'Öğretmen Görüşmeleri',
                selected: _interviewFilter == 'teacher',
                onSelected: () => setState(() => _interviewFilter = 'teacher'),
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni Görüşme Ekle'),
                onPressed: () {
                  InterviewDialog.show(
                    context,
                    studentId: widget.student.id,
                    studentName: widget.student.fullName,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: interviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Görüşmeler yüklenemedi: $e')),
              data: (list) {
                final filtered = list.where((i) {
                  if (_interviewFilter == 'all') return true;
                  return i.type == _interviewFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.speaker_notes_off_outlined,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Kayıtlı görüşme bulunmamaktadır.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('İlk Görüşmeyi Ekle'),
                          onPressed: () {
                            InterviewDialog.show(
                              context,
                              studentId: widget.student.id,
                              studentName: widget.student.fullName,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, idx) {
                    final interview = filtered[idx];
                    return _InterviewCard(
                      interview: interview,
                      onDelete: () => _confirmDeleteInterview(interview.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteInterview(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görüşmeyi Sil'),
        content: const Text('Bu görüşme kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(studentInterviewsProvider(widget.student.id).notifier)
          .deleteInterview(id);
    }
  }

  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final updated = widget.student.copyWith(
        name: _nameCtrl.text.trim(),
        surname: _surnameCtrl.text.trim(),
        number: _numberCtrl.text.trim(),
        classId: _classId,
        gender: _gender,
        status: _status,
        tcNo: _tcCtrl.text.trim().isEmpty ? null : _tcCtrl.text.trim(),
        birthDate: _birthDateCtrl.text.trim().isEmpty
            ? null
            : _birthDateCtrl.text.trim(),
        enrollmentDate: _enrollmentDateCtrl.text.trim().isEmpty
            ? null
            : _enrollmentDateCtrl.text.trim(),
        transferSchool: _transferSchoolCtrl.text.trim().isEmpty
            ? null
            : _transferSchoolCtrl.text.trim(),
        transferGrade: _transferGradeCtrl.text.trim().isEmpty
            ? null
            : _transferGradeCtrl.text.trim(),
        hasRepeatedGrade: _hasRepeatedGrade,
        repeatReason: _hasRepeatedGrade && _repeatReasonCtrl.text.trim().isNotEmpty
            ? _repeatReasonCtrl.text.trim()
            : null,
        specialStatus: _specialStatusCtrl.text.trim().isEmpty
            ? null
            : _specialStatusCtrl.text.trim(),
        photoPath: _photoPathCtrl.text.trim().isEmpty
            ? null
            : _photoPathCtrl.text.trim(),
        // Aile
        motherName: _motherNameCtrl.text.trim().isEmpty
            ? null
            : _motherNameCtrl.text.trim(),
        motherSurname: _motherSurnameCtrl.text.trim().isEmpty
            ? null
            : _motherSurnameCtrl.text.trim(),
        motherJob: _motherJobCtrl.text.trim().isEmpty
            ? null
            : _motherJobCtrl.text.trim(),
        motherPhone: _motherPhoneCtrl.text.trim().isEmpty
            ? null
            : _motherPhoneCtrl.text.trim(),
        motherAddress: _motherAddressCtrl.text.trim().isEmpty
            ? null
            : _motherAddressCtrl.text.trim(),
        motherIsBiological: _motherIsBiological,
        motherIsAlive: _motherIsAlive,
        motherHasDisability: _motherHasDisability,
        motherDisabilityDetails: _motherHasDisability &&
                _motherDisabilityDetailsCtrl.text.trim().isNotEmpty
            ? _motherDisabilityDetailsCtrl.text.trim()
            : null,
        fatherName: _fatherNameCtrl.text.trim().isEmpty
            ? null
            : _fatherNameCtrl.text.trim(),
        fatherSurname: _fatherSurnameCtrl.text.trim().isEmpty
            ? null
            : _fatherSurnameCtrl.text.trim(),
        fatherJob: _fatherJobCtrl.text.trim().isEmpty
            ? null
            : _fatherJobCtrl.text.trim(),
        fatherPhone: _fatherPhoneCtrl.text.trim().isEmpty
            ? null
            : _fatherPhoneCtrl.text.trim(),
        fatherAddress: _fatherAddressCtrl.text.trim().isEmpty
            ? null
            : _fatherAddressCtrl.text.trim(),
        fatherIsBiological: _fatherIsBiological,
        fatherIsAlive: _fatherIsAlive,
        fatherHasDisability: _fatherHasDisability,
        fatherDisabilityDetails: _fatherHasDisability &&
                _fatherDisabilityDetailsCtrl.text.trim().isNotEmpty
            ? _fatherDisabilityDetailsCtrl.text.trim()
            : null,
        parentsTogether: _parentsTogether,
        livesWith: _livesWith,
        guardianType: _guardianType,
        guardianName: _guardianNameCtrl.text.trim().isEmpty
            ? null
            : _guardianNameCtrl.text.trim(),
        guardianPhone: _guardianPhoneCtrl.text.trim().isEmpty
            ? null
            : _guardianPhoneCtrl.text.trim(),
        siblingCount: _siblingCount,
        siblingDetails: _siblingDetailsCtrl.text.trim().isEmpty
            ? null
            : _siblingDetailsCtrl.text.trim(),
        householdMembers: _householdMembersCtrl.text.trim().isEmpty
            ? null
            : _householdMembersCtrl.text.trim(),
        familyNotes: _familyNotesCtrl.text.trim().isEmpty
            ? null
            : _familyNotesCtrl.text.trim(),
        familyRiskLevel: _familyRiskLevel,
        // Sağlık
        hasChronicIllness: _hasChronicIllness,
        chronicIllnessDetails: _hasChronicIllness &&
                _chronicDetailsCtrl.text.trim().isNotEmpty
            ? _chronicDetailsCtrl.text.trim()
            : null,
        usesRegularMedication: _usesRegularMedication,
        medicationDetails: _usesRegularMedication &&
                _medicationDetailsCtrl.text.trim().isNotEmpty
            ? _medicationDetailsCtrl.text.trim()
            : null,
        hasPsychologicalHistory: _hasPsychologicalHistory,
        psychologicalDetails: _hasPsychologicalHistory &&
                _psychologicalDetailsCtrl.text.trim().isNotEmpty
            ? _psychologicalDetailsCtrl.text.trim()
            : null,
        generalNotes: _generalNotesCtrl.text.trim().isEmpty
            ? null
            : _generalNotesCtrl.text.trim(),
      );

      await ref.read(studentsProvider.notifier).updateStudent(updated);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci bilgileri başarıyla güncellendi!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Kart Yapısı ve Yardımcı Widget'lar
// ────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: cs.primary, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (level) {
      case 'Kritik':
      case 'Yüksek':
        bg = AppColors.danger.withValues(alpha: 0.15);
        fg = AppColors.danger;
        break;
      case 'Orta':
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        break;
      case 'Düşük':
      default:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$level Risk',
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.onPrimary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  const _InterviewCard({
    required this.interview,
    required this.onDelete,
  });

  final StudentInterview interview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Color badgeBg;
    Color badgeFg;
    IconData icon;

    switch (interview.type) {
      case 'parent':
        badgeBg = Colors.purple.withValues(alpha: 0.12);
        badgeFg = Colors.purple;
        icon = Icons.family_restroom_outlined;
        break;
      case 'teacher':
        badgeBg = Colors.teal.withValues(alpha: 0.12);
        badgeFg = Colors.teal;
        icon = Icons.school_outlined;
        break;
      case 'student':
      default:
        badgeBg = Colors.blue.withValues(alpha: 0.12);
        badgeFg = Colors.blue;
        icon = Icons.person_outline;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: badgeFg),
                    const SizedBox(width: 4),
                    Text(
                      interview.typeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: badgeFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                interview.date,
                style: t.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                tooltip: 'Görüşmeyi Sil',
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            interview.subject,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            interview.notes,
            style: t.bodyMedium?.copyWith(color: AppColors.textPrimary, height: 1.4),
          ),
          if (interview.actionPlan != null && interview.actionPlan!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.flag_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Karar / Takip Planı: ${interview.actionPlan}',
                      style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

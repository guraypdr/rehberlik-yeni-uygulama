import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../classes/presentation/classes_provider.dart';
import '../../../classes/domain/school_class.dart';
import '../../domain/student.dart';
import '../students_provider.dart';

enum StudentInfoSection {
  basic,
  mother,
  father,
  household,
  health,
  education,
  social,
}

class StudentInfoSectionEditor extends ConsumerStatefulWidget {
  const StudentInfoSectionEditor({
    super.key,
    required this.student,
    required this.section,
    required this.onSaved,
    required this.onCancel,
  });

  final Student student;
  final StudentInfoSection section;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<StudentInfoSectionEditor> createState() =>
      _StudentInfoSectionEditorState();
}

class _StudentInfoSectionEditorState
    extends ConsumerState<StudentInfoSectionEditor> {
  static const _educationOptions = [
    'Okuma yazma bilmiyor',
    'İlkokul',
    'Ortaokul',
    'Lise',
    'Üniversite',
  ];

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _text = {};
  final Map<String, bool?> _answers = {};
  late final TextEditingController _name;
  late final TextEditingController _surname;
  late final TextEditingController _number;
  late final TextEditingController _siblingCount;
  late final TextEditingController _childOrder;
  late final TextEditingController _usageHours;
  late final TextEditingController _usageMinutes;
  late String _gender;
  late String _boardingStatus;
  late int _classId;
  late final Student _student;
  bool _saving = false;

  static const _textInitializers = <String, String? Function(Student)>{
    'birthPlace': _birthPlace,
    'birthDate': _birthDate,
    'address': _address,
    'medicationDetails': _medicationDetails,
    'chronicIllnessDetails': _chronicIllnessDetails,
    'likesActivities': _likesActivities,
    'moveOrSchoolChangeDetails': _moveDetails,
    'extracurricularActivities': _extracurricularActivities,
    'influentialEventDetails': _influentialEventDetails,
    'motherName': _motherName,
    'motherSurname': _motherSurname,
    'motherBirthPlace': _motherBirthPlace,
    'motherBirthDate': _motherBirthDate,
    'motherDisabilityDetails': _motherDisabilityDetails,
    'motherEducation': _motherEducation,
    'motherJob': _motherJob,
    'fatherName': _fatherName,
    'fatherSurname': _fatherSurname,
    'fatherBirthPlace': _fatherBirthPlace,
    'fatherBirthDate': _fatherBirthDate,
    'fatherDisabilityDetails': _fatherDisabilityDetails,
    'fatherEducation': _fatherEducation,
    'fatherJob': _fatherJob,
    'householdChronicIllnessDetails': _householdIllnessDetails,
    'householdMembers': _householdMembers,
  };

  static String? _birthPlace(Student s) => s.birthPlace;
  static String? _birthDate(Student s) => s.birthDate;
  static String? _address(Student s) => s.address;
  static String? _medicationDetails(Student s) => s.medicationDetails;
  static String? _chronicIllnessDetails(Student s) => s.chronicIllnessDetails;
  static String? _likesActivities(Student s) => s.likesActivities;
  static String? _moveDetails(Student s) => s.moveOrSchoolChangeDetails;
  static String? _extracurricularActivities(Student s) =>
      s.extracurricularActivities;
  static String? _influentialEventDetails(Student s) =>
      s.influentialEventDetails;
  static String? _motherName(Student s) => s.motherName;
  static String? _motherSurname(Student s) => s.motherSurname;
  static String? _motherBirthPlace(Student s) => s.motherBirthPlace;
  static String? _motherBirthDate(Student s) => s.motherBirthDate;
  static String? _motherDisabilityDetails(Student s) =>
      s.motherDisabilityDetails;
  static String? _motherEducation(Student s) => s.motherEducation;
  static String? _motherJob(Student s) => s.motherJob;
  static String? _fatherName(Student s) => s.fatherName;
  static String? _fatherSurname(Student s) => s.fatherSurname;
  static String? _fatherBirthPlace(Student s) => s.fatherBirthPlace;
  static String? _fatherBirthDate(Student s) => s.fatherBirthDate;
  static String? _fatherDisabilityDetails(Student s) =>
      s.fatherDisabilityDetails;
  static String? _fatherEducation(Student s) => s.fatherEducation;
  static String? _fatherJob(Student s) => s.fatherJob;
  static String? _householdIllnessDetails(Student s) =>
      s.householdChronicIllnessDetails;
  static String? _householdMembers(Student s) => s.householdMembers;

  @override
  void initState() {
    super.initState();
    final cachedStudent = ref
        .read(studentsProvider)
        .valueOrNull
        ?.where((item) => item.id == widget.student.id)
        .firstOrNull;
    _student =
        cachedStudent != null &&
            cachedStudent.studentInfoFormCompletion >=
                widget.student.studentInfoFormCompletion
        ? cachedStudent
        : widget.student;
    for (final entry in _textInitializers.entries) {
      final value = entry.value(_student);
      _text[entry.key] = TextEditingController(
        text: _isDateField(entry.key) ? _displayDate(value) : value ?? '',
      );
    }
    _name = TextEditingController(text: _student.name);
    _surname = TextEditingController(text: _student.surname);
    _number = TextEditingController(text: _student.number);
    _siblingCount = TextEditingController(
      text: _student.siblingCount?.toString() ?? '',
    );
    _childOrder = TextEditingController(
      text: _student.childOrder?.toString() ?? '',
    );
    _usageHours = TextEditingController(
      text: _student.technologyUsageMinutes == null
          ? ''
          : (_student.technologyUsageMinutes! ~/ 60).toString(),
    );
    _usageMinutes = TextEditingController(
      text: _student.technologyUsageMinutes == null
          ? ''
          : (_student.technologyUsageMinutes! % 60).toString(),
    );
    _gender = _student.gender;
    _boardingStatus = _student.boardingStatus;
    _classId = _student.classId;
    _answers.addAll({
      'preschoolEducation': _student.preschoolEducation ?? false,
      'hasSpecialEducation': _student.hasSpecialEducation ?? false,
      'usesRegularMedication': _student.usesRegularMedication ?? false,
      'hasChronicIllness': _student.hasChronicIllness ?? false,
      'hasRecentMoveOrSchoolChange':
          _student.hasRecentMoveOrSchoolChange ?? false,
      'hasTechnologyDevice': _student.hasTechnologyDevice,
      'hasInfluentialEvent': _student.hasInfluentialEvent ?? false,
      'motherIsAlive': _student.motherIsAlive ?? true,
      'motherIsBiological': _student.motherIsBiological ?? true,
      'motherHasDisability': _student.motherHasDisability ?? false,
      'fatherIsAlive': _student.fatherIsAlive ?? true,
      'fatherIsBiological': _student.fatherIsBiological ?? true,
      'fatherHasDisability': _student.fatherHasDisability ?? false,
      'familyHasChronicIllness': _student.familyHasChronicIllness ?? false,
    });
  }

  @override
  void dispose() {
    for (final controller in _text.values) {
      controller.dispose();
    }
    _name.dispose();
    _surname.dispose();
    _number.dispose();
    _siblingCount.dispose();
    _childOrder.dispose();
    _usageHours.dispose();
    _usageMinutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(classesProvider).valueOrNull?.classes ?? [];
    final classIds = classes.map((schoolClass) => schoolClass.id).toSet();
    final selectedClassId = classIds.contains(_classId)
        ? _classId
        : (classes.isEmpty ? null : classes.first.id);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _sectionFields(classes, selectedClassId),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                TextButton(
                  key: const Key('student_info_cancel_button'),
                  onPressed: _saving ? null : widget.onCancel,
                  child: const Text('İptal'),
                ),
                const Spacer(),
                FilledButton.icon(
                  key: const Key('student_info_save_button'),
                  onPressed:
                      _saving ||
                          (widget.section == StudentInfoSection.basic &&
                              selectedClassId == null)
                      ? null
                      : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionFields(List<SchoolClass> classes, int? selectedClassId) {
    switch (widget.section) {
      case StudentInfoSection.basic:
        return Column(
          children: [
            if (MediaQuery.sizeOf(context).width < 600) ...[
              _basicField(_number, 'Öğrenci No', required: true),
              _basicField(_name, 'Adı', required: true),
              _basicField(_surname, 'Soyadı', required: true),
            ] else
              Row(
                children: [
                  Expanded(
                    child: _basicField(_number, 'Öğrenci No', required: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _basicField(_name, 'Adı', required: true)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _basicField(_surname, 'Soyadı', required: true),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedClassId,
              decoration: const InputDecoration(labelText: 'Sınıf / Şube'),
              items: [
                for (final schoolClass in classes)
                  DropdownMenuItem<int>(
                    value: schoolClass.id,
                    child: Text(schoolClass.displayName),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _classId = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Cinsiyeti'),
                    items: const [
                      DropdownMenuItem(value: 'Kız', child: Text('Kız')),
                      DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _gender = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _boardingStatus,
                    decoration: const InputDecoration(
                      labelText: 'Pansiyon Durumu',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Gündüzlü',
                        child: Text('Gündüzlü'),
                      ),
                      DropdownMenuItem(value: 'Yatılı', child: Text('Yatılı')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _boardingStatus = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _dateField('birthDate', 'Doğum Tarihi')),
                const SizedBox(width: 12),
                Expanded(child: _textField('birthPlace', 'Doğum Yeri')),
              ],
            ),
            _textField('address', 'Adresi', maxLines: 2),
          ],
        );
      case StudentInfoSection.mother:
        return _parentFields('mother');
      case StudentInfoSection.father:
        return _parentFields('father');
      case StudentInfoSection.household:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    _siblingCount,
                    'Öğrencinin kardeş sayısı',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(_childOrder, 'Öğrenci kaçıncı çocuk?'),
                ),
              ],
            ),
            _textField('householdMembers', 'Evde kimler yaşıyor?', maxLines: 2),
          ],
        );
      case StudentInfoSection.health:
        return Column(
          children: [
            _answerField(
              'usesRegularMedication',
              'Sürekli kullandığı ilaç / tıbbi cihaz var mı?',
            ),
            if (_answers['usesRegularMedication'] == true)
              _textField(
                'medicationDetails',
                'İlaç / tıbbi cihaz açıklaması',
                maxLines: 2,
              ),
            _answerField('hasChronicIllness', 'Sürekli hastalığı var mı?'),
            if (_answers['hasChronicIllness'] == true)
              _textField(
                'chronicIllnessDetails',
                'Sürekli hastalık açıklaması',
                maxLines: 2,
              ),
            _answerField(
              'familyHasChronicIllness',
              'Ailesinde sürekli hastalığı olan biri var mı?',
            ),
            if (_answers['familyHasChronicIllness'] == true)
              _textField(
                'householdChronicIllnessDetails',
                'Aile üyeleri sürekli hastalık açıklaması',
                maxLines: 2,
              ),
          ],
        );
      case StudentInfoSection.education:
        return Column(
          children: [
            _answerField('preschoolEducation', 'Okul öncesi eğitim almış mı?'),
            _answerField('hasSpecialEducation', 'Özel eğitim öğrencisi mi?'),
            _answerField(
              'hasRecentMoveOrSchoolChange',
              'Yakın zamanda taşınmış mı / okul değiştirmiş mi?',
            ),
            if (_answers['hasRecentMoveOrSchoolChange'] == true)
              _textField(
                'moveOrSchoolChangeDetails',
                'Taşınma / okul değiştirme açıklaması',
                maxLines: 2,
              ),
            _textField(
              'extracurricularActivities',
              'Ders dışı faaliyetleri',
              maxLines: 2,
            ),
            _answerField(
              'hasTechnologyDevice',
              'Kendisine ait teknolojik cihaz var mı?',
            ),
            if (_answers['hasTechnologyDevice'] == true)
              Row(
                children: [
                  Expanded(
                    child: _numberField(_usageHours, 'Günlük kullanım (saat)'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _numberField(_usageMinutes, 'Dakika (0–59)')),
                ],
              ),
          ],
        );
      case StudentInfoSection.social:
        return Column(
          children: [
            _textField(
              'likesActivities',
              'Yapmaktan hoşlandığı şeyler',
              maxLines: 2,
            ),
            _answerField(
              'hasInfluentialEvent',
              'Hâlâ etkisinde olduğu bir olay yaşamış mı?',
            ),
            if (_answers['hasInfluentialEvent'] == true)
              _textField(
                'influentialEventDetails',
                'Etkileyen olay açıklaması',
                maxLines: 3,
              ),
          ],
        );
    }
  }

  Widget _parentFields(String prefix) {
    final label = prefix == 'mother' ? 'Anne' : 'Baba';
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _textField('${prefix}Name', '$label adı')),
            const SizedBox(width: 12),
            Expanded(child: _textField('${prefix}Surname', '$label soyadı')),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _dateField('${prefix}BirthDate', '$label doğum tarihi'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _textField('${prefix}BirthPlace', '$label doğum yeri'),
            ),
          ],
        ),
        _answerField('${prefix}IsAlive', '$label sağ mı?'),
        _answerField('${prefix}IsBiological', '$label öz mü?'),
        _answerField('${prefix}HasDisability', '$label engeli var mı?'),
        if (_answers['${prefix}HasDisability'] == true)
          _textField(
            '${prefix}DisabilityDetails',
            '$label engel açıklaması',
            maxLines: 2,
          ),
        Row(
          children: [
            Expanded(
              child: _educationField(
                '${prefix}Education',
                '$label eğitim durumu',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _textField('${prefix}Job', '$label mesleği')),
          ],
        ),
      ],
    );
  }

  Widget _educationField(String key, String label) {
    final controller = _text[key]!;
    final currentValue = controller.text;
    final options = [
      ..._educationOptions,
      if (currentValue.isNotEmpty && !_educationOptions.contains(currentValue))
        currentValue,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String>(
        key: Key('${key}_dropdown'),
        initialValue: currentValue.isEmpty ? null : currentValue,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        selectedItemBuilder: (context) => [
          for (final option in options)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(option, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (value) => setState(() => controller.text = value ?? ''),
      ),
    );
  }

  Widget _basicField(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    validator: required
        ? (value) =>
              value == null || value.trim().isEmpty ? '$label zorunludur' : null
        : null,
  );

  Widget _textField(String key, String label, {int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      controller: _text[key],
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
      ),
    ),
  );

  Widget _dateField(String key, String label) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      controller: _text[key],
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
      ),
      onTap: () async {
        final initial = _parseDate(_text[key]!.text) ?? DateTime(2010);
        final selected = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (selected != null) {
          _text[key]!.text =
              '${selected.day.toString().padLeft(2, '0')}.'
              '${selected.month.toString().padLeft(2, '0')}.'
              '${selected.year}';
        }
      },
    ),
  );

  Widget _answerField(String key, String label) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: DropdownButtonFormField<bool?>(
      initialValue: _answers[key],
      key: Key('${key}_dropdown'),
      decoration: InputDecoration(labelText: label),
      items: const [
        DropdownMenuItem<bool?>(value: null, child: Text('Seçiniz')),
        DropdownMenuItem<bool?>(value: true, child: Text('Evet')),
        DropdownMenuItem<bool?>(value: false, child: Text('Hayır')),
      ],
      onChanged: (value) => setState(() => _answers[key] = value),
    ),
  );

  Widget _numberField(TextEditingController controller, String label) =>
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: label),
        ),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final minutes = _intValue(_usageMinutes.text);
    if (_answers['hasTechnologyDevice'] == true &&
        minutes != null &&
        minutes > 59) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dakika değeri 0 ile 59 arasında olmalı.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final isBasic = widget.section == StudentInfoSection.basic;
      final isMother = widget.section == StudentInfoSection.mother;
      final isFather = widget.section == StudentInfoSection.father;
      final isHousehold = widget.section == StudentInfoSection.household;
      final isHealth = widget.section == StudentInfoSection.health;
      final isEducation = widget.section == StudentInfoSection.education;
      final isSocial = widget.section == StudentInfoSection.social;
      final updated = Student(
        id: _student.id,
        classId: isBasic ? _classId : _student.classId,
        number: isBasic ? _number.text.trim() : _student.number,
        name: isBasic ? _name.text.trim() : _student.name,
        surname: isBasic ? _surname.text.trim() : _student.surname,
        gender: isBasic ? _gender : _student.gender,
        boardingStatus: isBasic ? _boardingStatus : _student.boardingStatus,
        createdAt: _student.createdAt,
        birthPlace: isBasic ? _value('birthPlace') : _student.birthPlace,
        birthDate: isBasic ? _storedDate('birthDate') : _student.birthDate,
        address: isBasic ? _value('address') : _student.address,
        preschoolEducation: isEducation
            ? _answers['preschoolEducation']
            : _student.preschoolEducation,
        hasSpecialEducation: isEducation
            ? _answers['hasSpecialEducation']
            : _student.hasSpecialEducation,
        usesRegularMedication: isHealth
            ? _answers['usesRegularMedication']
            : _student.usesRegularMedication,
        medicationDetails: isHealth
            ? _conditionalValue('usesRegularMedication', 'medicationDetails')
            : _student.medicationDetails,
        hasChronicIllness: isHealth
            ? _answers['hasChronicIllness']
            : _student.hasChronicIllness,
        chronicIllnessDetails: isHealth
            ? _conditionalValue('hasChronicIllness', 'chronicIllnessDetails')
            : _student.chronicIllnessDetails,
        likesActivities: isSocial
            ? _value('likesActivities')
            : _student.likesActivities,
        hasRecentMoveOrSchoolChange: isEducation
            ? _answers['hasRecentMoveOrSchoolChange']
            : _student.hasRecentMoveOrSchoolChange,
        moveOrSchoolChangeDetails: isEducation
            ? _conditionalValue(
                'hasRecentMoveOrSchoolChange',
                'moveOrSchoolChangeDetails',
              )
            : _student.moveOrSchoolChangeDetails,
        extracurricularActivities: isEducation
            ? _value('extracurricularActivities')
            : _student.extracurricularActivities,
        hasTechnologyDevice: isEducation
            ? _answers['hasTechnologyDevice']
            : _student.hasTechnologyDevice,
        technologyUsageMinutes: isEducation
            ? _answers['hasTechnologyDevice'] == true
                  ? (_intValue(_usageHours.text) ?? 0) * 60 + (minutes ?? 0)
                  : null
            : _student.technologyUsageMinutes,
        hasInfluentialEvent: isSocial
            ? _answers['hasInfluentialEvent']
            : _student.hasInfluentialEvent,
        influentialEventDetails: isSocial
            ? _conditionalValue(
                'hasInfluentialEvent',
                'influentialEventDetails',
              )
            : _student.influentialEventDetails,
        motherName: isMother ? _value('motherName') : _student.motherName,
        motherSurname: isMother
            ? _value('motherSurname')
            : _student.motherSurname,
        motherBirthPlace: isMother
            ? _value('motherBirthPlace')
            : _student.motherBirthPlace,
        motherBirthDate: isMother
            ? _storedDate('motherBirthDate')
            : _student.motherBirthDate,
        motherIsAlive: isMother
            ? _answers['motherIsAlive']
            : _student.motherIsAlive,
        motherIsBiological: isMother
            ? _answers['motherIsBiological']
            : _student.motherIsBiological,
        motherHasDisability: isMother
            ? _answers['motherHasDisability']
            : _student.motherHasDisability,
        motherDisabilityDetails: isMother
            ? _conditionalValue(
                'motherHasDisability',
                'motherDisabilityDetails',
              )
            : _student.motherDisabilityDetails,
        motherEducation: isMother
            ? _value('motherEducation')
            : _student.motherEducation,
        motherJob: isMother ? _value('motherJob') : _student.motherJob,
        fatherName: isFather ? _value('fatherName') : _student.fatherName,
        fatherSurname: isFather
            ? _value('fatherSurname')
            : _student.fatherSurname,
        fatherBirthPlace: isFather
            ? _value('fatherBirthPlace')
            : _student.fatherBirthPlace,
        fatherBirthDate: isFather
            ? _storedDate('fatherBirthDate')
            : _student.fatherBirthDate,
        fatherIsAlive: isFather
            ? _answers['fatherIsAlive']
            : _student.fatherIsAlive,
        fatherIsBiological: isFather
            ? _answers['fatherIsBiological']
            : _student.fatherIsBiological,
        fatherHasDisability: isFather
            ? _answers['fatherHasDisability']
            : _student.fatherHasDisability,
        fatherDisabilityDetails: isFather
            ? _conditionalValue(
                'fatherHasDisability',
                'fatherDisabilityDetails',
              )
            : _student.fatherDisabilityDetails,
        fatherEducation: isFather
            ? _value('fatherEducation')
            : _student.fatherEducation,
        fatherJob: isFather ? _value('fatherJob') : _student.fatherJob,
        siblingCount: isHousehold
            ? _intValue(_siblingCount.text)
            : _student.siblingCount,
        childOrder: isHousehold
            ? _intValue(_childOrder.text)
            : _student.childOrder,
        familyHasChronicIllness: isHealth
            ? _answers['familyHasChronicIllness']
            : _student.familyHasChronicIllness,
        householdChronicIllnessDetails: isHealth
            ? _conditionalValue(
                'familyHasChronicIllness',
                'householdChronicIllnessDetails',
              )
            : _student.householdChronicIllnessDetails,
        householdMembers: isHousehold
            ? _value('householdMembers')
            : _student.householdMembers,
      );
      await ref.read(studentsProvider.notifier).updateStudent(updated);
      if (!mounted) return;
      widget.onSaved();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öğrenci bilgileri kaydedilemedi: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _value(String key) {
    final value = _text[key]!.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _conditionalValue(String answerKey, String valueKey) =>
      _answers[answerKey] == true ? _value(valueKey) : null;

  String? _storedDate(String key) {
    final value = _value(key);
    if (value == null) return null;
    final parsed = _parseDate(value);
    if (parsed == null) return value;
    return '${parsed.year.toString().padLeft(4, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-'
        '${parsed.day.toString().padLeft(2, '0')}';
  }

  static int? _intValue(String value) =>
      value.trim().isEmpty ? null : int.tryParse(value.trim());

  static bool _isDateField(String key) =>
      key == 'birthDate' || key.endsWith('BirthDate');

  static String _displayDate(String? value) {
    if (value == null) return '';
    final parsed = _parseDate(value);
    if (parsed == null) return value;
    return '${parsed.day.toString().padLeft(2, '0')}.'
        '${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
  }

  static DateTime? _parseDate(String value) {
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    final parts = value.split('.');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}',
    );
  }
}

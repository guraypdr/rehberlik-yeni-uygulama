import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../classes/presentation/classes_provider.dart';
import '../../domain/student.dart';
import '../students_provider.dart';

class StudentInfoFormSheet extends ConsumerStatefulWidget {
  const StudentInfoFormSheet({super.key, required this.student});

  final Student student;

  static Future<void> show(BuildContext context, Student student) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StudentInfoFormSheet(student: student),
    );
  }

  @override
  ConsumerState<StudentInfoFormSheet> createState() =>
      _StudentInfoFormSheetState();
}

class _StudentInfoFormSheetState extends ConsumerState<StudentInfoFormSheet> {
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
    final student = widget.student;
    for (final entry in _textInitializers.entries) {
      final value = entry.value(student);
      _text[entry.key] = TextEditingController(
        text: _isDateField(entry.key) ? _displayDate(value) : value ?? '',
      );
    }
    _name = TextEditingController(text: student.name);
    _surname = TextEditingController(text: student.surname);
    _number = TextEditingController(text: student.number);
    _siblingCount = TextEditingController(
      text: student.siblingCount?.toString() ?? '',
    );
    _childOrder = TextEditingController(
      text: student.childOrder?.toString() ?? '',
    );
    _usageHours = TextEditingController(
      text: student.technologyUsageMinutes == null
          ? ''
          : (student.technologyUsageMinutes! ~/ 60).toString(),
    );
    _usageMinutes = TextEditingController(
      text: student.technologyUsageMinutes == null
          ? ''
          : (student.technologyUsageMinutes! % 60).toString(),
    );
    _gender = student.gender;
    _boardingStatus = student.boardingStatus;
    _classId = student.classId;
    _answers.addAll({
      'preschoolEducation': student.preschoolEducation ?? false,
      'usesRegularMedication': student.usesRegularMedication ?? false,
      'hasChronicIllness': student.hasChronicIllness ?? false,
      'hasRecentMoveOrSchoolChange':
          student.hasRecentMoveOrSchoolChange ?? false,
      'hasTechnologyDevice': student.hasTechnologyDevice,
      'hasInfluentialEvent': student.hasInfluentialEvent ?? false,
      'motherIsAlive': student.motherIsAlive ?? true,
      'motherIsBiological': student.motherIsBiological ?? true,
      'motherHasDisability': student.motherHasDisability ?? false,
      'fatherIsAlive': student.fatherIsAlive ?? true,
      'fatherIsBiological': student.fatherIsBiological ?? true,
      'fatherHasDisability': student.fatherHasDisability ?? false,
      'familyHasChronicIllness': student.familyHasChronicIllness ?? false,
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
    final screenSize = MediaQuery.sizeOf(context);
    final classes = ref.watch(classesProvider).valueOrNull?.classes ?? [];
    final classIds = classes.map((schoolClass) => schoolClass.id).toSet();
    final selectedClassId = classIds.contains(_classId)
        ? _classId
        : (classes.isEmpty ? null : classes.first.id);

    return Dialog(
      child: SizedBox(
        width: screenSize.width < 780 ? screenSize.width - 40 : 720,
        height: screenSize.height < 720
            ? screenSize.height - 40
            : screenSize.height * 0.88,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Öğrenci Bilgi Formu · ${widget.student.fullName}',
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _section('Temel Öğrenci Bilgileri'),
                        if (MediaQuery.sizeOf(context).width < 600) ...[
                          _basicField(_number, 'Öğrenci No', required: true),
                          _basicField(_name, 'Adı', required: true),
                          _basicField(_surname, 'Soyadı', required: true),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: _basicField(
                                  _number,
                                  'Öğrenci No',
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _basicField(
                                  _name,
                                  'Adı',
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _basicField(
                                  _surname,
                                  'Soyadı',
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: selectedClassId,
                          decoration: const InputDecoration(
                            labelText: 'Sınıf / Şube',
                          ),
                          items: [
                            for (final schoolClass in classes)
                              DropdownMenuItem(
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
                                decoration: const InputDecoration(
                                  labelText: 'Cinsiyeti',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Kız',
                                    child: Text('Kız'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Erkek',
                                    child: Text('Erkek'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _gender = value);
                                  }
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
                                  DropdownMenuItem(
                                    value: 'Yatılı',
                                    child: Text('Yatılı'),
                                  ),
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
                        _section('Öğrenci Bilgileri'),
                        Row(
                          children: [
                            Expanded(
                              child: _dateField('birthDate', 'Doğum Tarihi'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _textField('birthPlace', 'Doğum Yeri'),
                            ),
                          ],
                        ),
                        _textField('address', 'Adresi', maxLines: 2),
                        _answerField(
                          'preschoolEducation',
                          'Okul öncesi eğitim almış mı?',
                        ),
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
                        _answerField(
                          'hasChronicIllness',
                          'Sürekli hastalığı var mı?',
                        ),
                        if (_answers['hasChronicIllness'] == true)
                          _textField(
                            'chronicIllnessDetails',
                            'Sürekli hastalık açıklaması',
                            maxLines: 2,
                          ),
                        _textField(
                          'likesActivities',
                          'Yapmaktan hoşlandığı şeyler',
                          maxLines: 2,
                        ),
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
                                child: _numberField(
                                  _usageHours,
                                  'Günlük kullanım (saat)',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _numberField(
                                  _usageMinutes,
                                  'Dakika (0–59)',
                                ),
                              ),
                            ],
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
                        _section('Anne Bilgileri'),
                        _parentFields('mother'),
                        _section('Baba Bilgileri'),
                        _parentFields('father'),
                        _section('Kardeş ve Hane Bilgileri'),
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
                              child: _numberField(
                                _childOrder,
                                'Öğrenci kaçıncı çocuk?',
                              ),
                            ),
                          ],
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
                        _textField(
                          'householdMembers',
                          'Evde kimler yaşıyor?',
                          maxLines: 2,
                        ),
                      ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _saving || selectedClassId == null
                        ? null
                        : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Bilgileri Kaydet'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        _answerField(
          '${prefix}IsBiological',
          '$label öz mü?',
        ),
        _answerField(
          '${prefix}HasDisability',
          '$label engeli var mı?',
        ),
        if (_answers['${prefix}HasDisability'] == true)
          _textField(
            '${prefix}DisabilityDetails',
            '$label engel açıklaması',
            maxLines: 2,
          ),
        Row(
          children: [
            Expanded(
              child: _textField('${prefix}Education', '$label eğitim durumu'),
            ),
            const SizedBox(width: 12),
            Expanded(child: _textField('${prefix}Job', '$label mesleği')),
          ],
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

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
      final updated = Student(
        id: widget.student.id,
        classId: _classId,
        number: _number.text.trim(),
        name: _name.text.trim(),
        surname: _surname.text.trim(),
        gender: _gender,
        boardingStatus: _boardingStatus,
        createdAt: widget.student.createdAt,
        birthPlace: _value('birthPlace'),
        birthDate: _storedDate('birthDate'),
        address: _value('address'),
        preschoolEducation: _answers['preschoolEducation'],
        usesRegularMedication: _answers['usesRegularMedication'],
        medicationDetails: _conditionalValue(
          'usesRegularMedication',
          'medicationDetails',
        ),
        hasChronicIllness: _answers['hasChronicIllness'],
        chronicIllnessDetails: _conditionalValue(
          'hasChronicIllness',
          'chronicIllnessDetails',
        ),
        likesActivities: _value('likesActivities'),
        hasRecentMoveOrSchoolChange: _answers['hasRecentMoveOrSchoolChange'],
        moveOrSchoolChangeDetails: _conditionalValue(
          'hasRecentMoveOrSchoolChange',
          'moveOrSchoolChangeDetails',
        ),
        extracurricularActivities: _value('extracurricularActivities'),
        hasTechnologyDevice: _answers['hasTechnologyDevice'],
        technologyUsageMinutes: _answers['hasTechnologyDevice'] == true
            ? (_intValue(_usageHours.text) ?? 0) * 60 + (minutes ?? 0)
            : null,
        hasInfluentialEvent: _answers['hasInfluentialEvent'],
        influentialEventDetails: _conditionalValue(
          'hasInfluentialEvent',
          'influentialEventDetails',
        ),
        motherName: _value('motherName'),
        motherSurname: _value('motherSurname'),
        motherBirthPlace: _value('motherBirthPlace'),
        motherBirthDate: _storedDate('motherBirthDate'),
        motherIsAlive: _answers['motherIsAlive'],
        motherIsBiological: _answers['motherIsBiological'],
        motherHasDisability: _answers['motherHasDisability'],
        motherDisabilityDetails: _conditionalValue(
          'motherHasDisability',
          'motherDisabilityDetails',
        ),
        motherEducation: _value('motherEducation'),
        motherJob: _value('motherJob'),
        fatherName: _value('fatherName'),
        fatherSurname: _value('fatherSurname'),
        fatherBirthPlace: _value('fatherBirthPlace'),
        fatherBirthDate: _storedDate('fatherBirthDate'),
        fatherIsAlive: _answers['fatherIsAlive'],
        fatherIsBiological: _answers['fatherIsBiological'],
        fatherHasDisability: _answers['fatherHasDisability'],
        fatherDisabilityDetails: _conditionalValue(
          'fatherHasDisability',
          'fatherDisabilityDetails',
        ),
        fatherEducation: _value('fatherEducation'),
        fatherJob: _value('fatherJob'),
        siblingCount: _intValue(_siblingCount.text),
        childOrder: _intValue(_childOrder.text),
        familyHasChronicIllness: _answers['familyHasChronicIllness'],
        householdChronicIllnessDetails: _conditionalValue(
          'familyHasChronicIllness',
          'householdChronicIllnessDetails',
        ),
        householdMembers: _value('householdMembers'),
      );
      await ref.read(studentsProvider.notifier).updateStudent(updated);
      if (!mounted) return;
      Navigator.of(context).pop();
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

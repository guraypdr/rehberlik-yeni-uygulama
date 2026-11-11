/// Öğrenci temel kaydı ve öğrenci bilgi formu.
class Student {
  const Student({
    required this.id,
    required this.classId,
    required this.number,
    required this.name,
    required this.surname,
    required this.createdAt,
    this.gender = 'Erkek',
    this.boardingStatus = 'Gündüzlü',
    this.birthPlace,
    this.birthDate,
    this.address,
    this.preschoolEducation,
    this.hasSpecialEducation,
    this.usesRegularMedication,
    this.medicationDetails,
    this.hasChronicIllness,
    this.chronicIllnessDetails,
    this.likesActivities,
    this.hasRecentMoveOrSchoolChange,
    this.moveOrSchoolChangeDetails,
    this.extracurricularActivities,
    this.hasTechnologyDevice,
    this.technologyUsageMinutes,
    this.hasInfluentialEvent,
    this.influentialEventDetails,
    this.motherName,
    this.motherSurname,
    this.motherBirthPlace,
    this.motherBirthDate,
    this.motherIsAlive,
    this.motherIsBiological,
    this.motherHasDisability,
    this.motherDisabilityDetails,
    this.motherEducation,
    this.motherJob,
    this.fatherName,
    this.fatherSurname,
    this.fatherBirthPlace,
    this.fatherBirthDate,
    this.fatherIsAlive,
    this.fatherIsBiological,
    this.fatherHasDisability,
    this.fatherDisabilityDetails,
    this.fatherEducation,
    this.fatherJob,
    this.siblingCount,
    this.childOrder,
    this.familyHasChronicIllness,
    this.householdChronicIllnessDetails,
    this.householdMembers,
    this.className,
    this.gradeLevelLabel,
  });

  final int id;
  final int classId;
  final String number;
  final String name;
  final String surname;
  final String gender;
  final String boardingStatus;
  final String createdAt;

  final String? birthPlace;
  final String? birthDate;
  final String? address;
  final bool? preschoolEducation;
  final bool? hasSpecialEducation;
  final bool? usesRegularMedication;
  final String? medicationDetails;
  final bool? hasChronicIllness;
  final String? chronicIllnessDetails;
  final String? likesActivities;
  final bool? hasRecentMoveOrSchoolChange;
  final String? moveOrSchoolChangeDetails;
  final String? extracurricularActivities;
  final bool? hasTechnologyDevice;
  final int? technologyUsageMinutes;
  final bool? hasInfluentialEvent;
  final String? influentialEventDetails;

  final String? motherName;
  final String? motherSurname;
  final String? motherBirthPlace;
  final String? motherBirthDate;
  final bool? motherIsAlive;
  final bool? motherIsBiological;
  final bool? motherHasDisability;
  final String? motherDisabilityDetails;
  final String? motherEducation;
  final String? motherJob;

  final String? fatherName;
  final String? fatherSurname;
  final String? fatherBirthPlace;
  final String? fatherBirthDate;
  final bool? fatherIsAlive;
  final bool? fatherIsBiological;
  final bool? fatherHasDisability;
  final String? fatherDisabilityDetails;
  final String? fatherEducation;
  final String? fatherJob;

  final int? siblingCount;
  final int? childOrder;
  final bool? familyHasChronicIllness;
  final String? householdChronicIllnessDetails;
  final String? householdMembers;

  final String? className;
  final String? gradeLevelLabel;

  String get fullName => '$name $surname';
  String get displayClass =>
      className ?? (gradeLevelLabel != null ? '$gradeLevelLabel' : '-');

  int get studentInfoFormCompletion {
    final textFields = [
      birthPlace,
      birthDate,
      address,
      likesActivities,
      extracurricularActivities,
      motherName,
      motherSurname,
      motherBirthPlace,
      motherBirthDate,
      motherEducation,
      motherJob,
      fatherName,
      fatherSurname,
      fatherBirthPlace,
      fatherBirthDate,
      fatherEducation,
      fatherJob,
      householdMembers,
    ];
    final numericFields = [siblingCount, childOrder];
    final answers = [
      preschoolEducation,
      hasSpecialEducation,
      usesRegularMedication,
      hasChronicIllness,
      hasRecentMoveOrSchoolChange,
      hasTechnologyDevice,
      hasInfluentialEvent,
      motherIsAlive,
      motherIsBiological,
      motherHasDisability,
      fatherIsAlive,
      fatherIsBiological,
      fatherHasDisability,
      familyHasChronicIllness,
    ];
    final followUps = [
      (usesRegularMedication, medicationDetails),
      (hasChronicIllness, chronicIllnessDetails),
      (hasRecentMoveOrSchoolChange, moveOrSchoolChangeDetails),
      (hasInfluentialEvent, influentialEventDetails),
      (motherHasDisability, motherDisabilityDetails),
      (fatherHasDisability, fatherDisabilityDetails),
      (familyHasChronicIllness, householdChronicIllnessDetails),
    ];
    final filled =
        textFields.where((value) => value?.trim().isNotEmpty ?? false).length +
        numericFields.where((value) => value != null).length +
        answers.where((value) => value != null).length +
        followUps
            .where(
              (followUp) =>
                  followUp.$1 == true &&
                  (followUp.$2?.trim().isNotEmpty ?? false),
            )
            .length;
    final total =
        textFields.length +
        numericFields.length +
        answers.length +
        followUps.where((followUp) => followUp.$1 == true).length +
        (hasTechnologyDevice == true ? 1 : 0);
    final completedDeviceUsage =
        hasTechnologyDevice == true && technologyUsageMinutes != null ? 1 : 0;
    return ((filled + completedDeviceUsage) / total * 100).round();
  }

  Student copyWith({
    int? id,
    int? classId,
    String? number,
    String? name,
    String? surname,
    String? gender,
    String? boardingStatus,
    String? createdAt,
    String? className,
    String? gradeLevelLabel,
  }) => Student(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    number: number ?? this.number,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    gender: gender ?? this.gender,
    boardingStatus: boardingStatus ?? this.boardingStatus,
    createdAt: createdAt ?? this.createdAt,
    birthPlace: birthPlace,
    birthDate: birthDate,
    address: address,
    preschoolEducation: preschoolEducation,
    hasSpecialEducation: hasSpecialEducation,
    usesRegularMedication: usesRegularMedication,
    medicationDetails: medicationDetails,
    hasChronicIllness: hasChronicIllness,
    chronicIllnessDetails: chronicIllnessDetails,
    likesActivities: likesActivities,
    hasRecentMoveOrSchoolChange: hasRecentMoveOrSchoolChange,
    moveOrSchoolChangeDetails: moveOrSchoolChangeDetails,
    extracurricularActivities: extracurricularActivities,
    hasTechnologyDevice: hasTechnologyDevice,
    technologyUsageMinutes: technologyUsageMinutes,
    hasInfluentialEvent: hasInfluentialEvent,
    influentialEventDetails: influentialEventDetails,
    motherName: motherName,
    motherSurname: motherSurname,
    motherBirthPlace: motherBirthPlace,
    motherBirthDate: motherBirthDate,
    motherIsAlive: motherIsAlive,
    motherIsBiological: motherIsBiological,
    motherHasDisability: motherHasDisability,
    motherDisabilityDetails: motherDisabilityDetails,
    motherEducation: motherEducation,
    motherJob: motherJob,
    fatherName: fatherName,
    fatherSurname: fatherSurname,
    fatherBirthPlace: fatherBirthPlace,
    fatherBirthDate: fatherBirthDate,
    fatherIsAlive: fatherIsAlive,
    fatherIsBiological: fatherIsBiological,
    fatherHasDisability: fatherHasDisability,
    fatherDisabilityDetails: fatherDisabilityDetails,
    fatherEducation: fatherEducation,
    fatherJob: fatherJob,
    siblingCount: siblingCount,
    childOrder: childOrder,
    familyHasChronicIllness: familyHasChronicIllness,
    householdChronicIllnessDetails: householdChronicIllnessDetails,
    householdMembers: householdMembers,
    className: className ?? this.className,
    gradeLevelLabel: gradeLevelLabel ?? this.gradeLevelLabel,
  );

  Map<String, Object?> toMap() => {
    'id': id == 0 ? null : id,
    'class_id': classId,
    'number': number,
    'name': name,
    'surname': surname,
    'gender': gender,
    'boarding_status': boardingStatus,
    'created_at': createdAt,
  };

  Map<String, Object?> toInfoFormMap() => {
    'birth_place': birthPlace,
    'birth_date': birthDate,
    'address': address,
    'preschool_education': _boolToInt(preschoolEducation),
    'has_special_education': _boolToInt(hasSpecialEducation ?? false),
    'uses_regular_medication': _boolToInt(usesRegularMedication),
    'medication_details': medicationDetails,
    'has_chronic_illness': _boolToInt(hasChronicIllness),
    'chronic_illness_details': chronicIllnessDetails,
    'likes_activities': likesActivities,
    'has_recent_move_or_school_change': _boolToInt(hasRecentMoveOrSchoolChange),
    'move_or_school_change_details': moveOrSchoolChangeDetails,
    'extracurricular_activities': extracurricularActivities,
    'has_technology_device': _boolToInt(hasTechnologyDevice),
    'technology_usage_minutes': technologyUsageMinutes,
    'has_influential_event': _boolToInt(hasInfluentialEvent),
    'influential_event_details': influentialEventDetails,
    'mother_name': motherName,
    'mother_surname': motherSurname,
    'mother_birth_place': motherBirthPlace,
    'mother_birth_date': motherBirthDate,
    'mother_is_alive': _boolToInt(motherIsAlive),
    'mother_is_biological': _boolToInt(motherIsBiological),
    'mother_has_disability': _boolToInt(motherHasDisability),
    'mother_disability_details': motherDisabilityDetails,
    'mother_education': motherEducation,
    'mother_job': motherJob,
    'father_name': fatherName,
    'father_surname': fatherSurname,
    'father_birth_place': fatherBirthPlace,
    'father_birth_date': fatherBirthDate,
    'father_is_alive': _boolToInt(fatherIsAlive),
    'father_is_biological': _boolToInt(fatherIsBiological),
    'father_has_disability': _boolToInt(fatherHasDisability),
    'father_disability_details': fatherDisabilityDetails,
    'father_education': fatherEducation,
    'father_job': fatherJob,
    'sibling_count': siblingCount,
    'child_order': childOrder,
    'family_has_chronic_illness': _boolToInt(familyHasChronicIllness),
    'household_chronic_illness_details': householdChronicIllnessDetails,
    'household_members': householdMembers,
  };

  static Student fromMap(Map<String, Object?> map) => Student(
    id: map['id'] as int,
    classId: map['class_id'] as int,
    number: map['number'] as String? ?? (map['no']?.toString() ?? ''),
    name: map['name'] as String? ?? '',
    surname: map['surname'] as String? ?? '',
    gender: map['gender'] as String? ?? 'Erkek',
    boardingStatus: map['boarding_status'] as String? ?? 'Gündüzlü',
    createdAt: map['created_at'] as String? ?? '',
    birthPlace: map['birth_place'] as String?,
    birthDate: map['birth_date'] as String?,
    address: map['address'] as String?,
    preschoolEducation: _intToBool(map['preschool_education']),
    hasSpecialEducation: _intToBool(map['has_special_education']) ?? false,
    usesRegularMedication: _intToBool(map['uses_regular_medication']),
    medicationDetails: map['medication_details'] as String?,
    hasChronicIllness: _intToBool(map['has_chronic_illness']),
    chronicIllnessDetails: map['chronic_illness_details'] as String?,
    likesActivities: map['likes_activities'] as String?,
    hasRecentMoveOrSchoolChange: _intToBool(
      map['has_recent_move_or_school_change'],
    ),
    moveOrSchoolChangeDetails: map['move_or_school_change_details'] as String?,
    extracurricularActivities: map['extracurricular_activities'] as String?,
    hasTechnologyDevice: _intToBool(map['has_technology_device']),
    technologyUsageMinutes: map['technology_usage_minutes'] as int?,
    hasInfluentialEvent: _intToBool(map['has_influential_event']),
    influentialEventDetails: map['influential_event_details'] as String?,
    motherName: map['mother_name'] as String?,
    motherSurname: map['mother_surname'] as String?,
    motherBirthPlace: map['mother_birth_place'] as String?,
    motherBirthDate: map['mother_birth_date'] as String?,
    motherIsAlive: _intToBool(map['mother_is_alive']),
    motherIsBiological: _intToBool(map['mother_is_biological']),
    motherHasDisability: _intToBool(map['mother_has_disability']),
    motherDisabilityDetails: map['mother_disability_details'] as String?,
    motherEducation: map['mother_education'] as String?,
    motherJob: map['mother_job'] as String?,
    fatherName: map['father_name'] as String?,
    fatherSurname: map['father_surname'] as String?,
    fatherBirthPlace: map['father_birth_place'] as String?,
    fatherBirthDate: map['father_birth_date'] as String?,
    fatherIsAlive: _intToBool(map['father_is_alive']),
    fatherIsBiological: _intToBool(map['father_is_biological']),
    fatherHasDisability: _intToBool(map['father_has_disability']),
    fatherDisabilityDetails: map['father_disability_details'] as String?,
    fatherEducation: map['father_education'] as String?,
    fatherJob: map['father_job'] as String?,
    siblingCount: map['sibling_count'] as int?,
    childOrder: map['child_order'] as int?,
    familyHasChronicIllness: _intToBool(map['family_has_chronic_illness']),
    householdChronicIllnessDetails:
        map['household_chronic_illness_details'] as String?,
    householdMembers: map['household_members'] as String?,
    className: map['class_name'] as String?,
    gradeLevelLabel: map['grade_level_label'] as String?,
  );

  static int? _boolToInt(bool? value) => value == null ? null : (value ? 1 : 0);

  static bool? _intToBool(Object? value) {
    if (value == null) return null;
    if (value is int) return value == 1;
    if (value is bool) return value;
    return value.toString() == '1';
  }
}

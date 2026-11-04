/// Öğrenci domain modeli.
class Student {
  const Student({
    required this.id,
    required this.classId,
    required this.number,
    required this.name,
    required this.surname,
    this.gender = 'Erkek',
    this.tcNo,
    this.birthDate,
    this.photoPath,
    this.enrollmentDate,
    this.status = 'Aktif',
    this.transferSchool,
    this.transferGrade,
    this.hasRepeatedGrade = false,
    this.repeatReason,
    this.specialStatus,
    // Aile
    this.motherName,
    this.motherSurname,
    this.motherIsBiological = true,
    this.motherIsAlive = true,
    this.motherJob,
    this.motherPhone,
    this.motherAddress,
    this.motherHasDisability = false,
    this.motherDisabilityDetails,
    this.fatherName,
    this.fatherSurname,
    this.fatherIsBiological = true,
    this.fatherIsAlive = true,
    this.fatherJob,
    this.fatherPhone,
    this.fatherAddress,
    this.fatherHasDisability = false,
    this.fatherDisabilityDetails,
    this.parentsTogether = 'Birlikte',
    this.livesWith = 'Anne-Baba',
    this.guardianType = 'Anne-Baba',
    this.guardianName,
    this.guardianPhone,
    this.siblingCount = 0,
    this.siblingDetails,
    this.householdMembers,
    this.familyNotes,
    this.familyRiskLevel = 'Düşük',
    // Sağlık
    this.hasChronicIllness = false,
    this.chronicIllnessDetails,
    this.usesRegularMedication = false,
    this.medicationDetails,
    this.hasPsychologicalHistory = false,
    this.psychologicalDetails,
    // Genel
    this.generalNotes,
    required this.createdAt,
    // Joined display fields
    this.className,
    this.gradeLevelLabel,
  });

  final int id;
  final int classId;
  final String number;
  final String name;
  final String surname;
  final String gender;
  final String? tcNo;
  final String? birthDate;
  final String? photoPath;
  final String? enrollmentDate;
  final String status;
  final String? transferSchool;
  final String? transferGrade;
  final bool hasRepeatedGrade;
  final String? repeatReason;
  final String? specialStatus;

  // Aile Bilgileri
  final String? motherName;
  final String? motherSurname;
  final bool motherIsBiological;
  final bool motherIsAlive;
  final String? motherJob;
  final String? motherPhone;
  final String? motherAddress;
  final bool motherHasDisability;
  final String? motherDisabilityDetails;

  final String? fatherName;
  final String? fatherSurname;
  final bool fatherIsBiological;
  final bool fatherIsAlive;
  final String? fatherJob;
  final String? fatherPhone;
  final String? fatherAddress;
  final bool fatherHasDisability;
  final String? fatherDisabilityDetails;

  final String parentsTogether;
  final String livesWith;
  final String guardianType;
  final String? guardianName;
  final String? guardianPhone;
  final int siblingCount;
  final String? siblingDetails;
  final String? householdMembers;
  final String? familyNotes;
  final String familyRiskLevel;

  // Sağlık Bilgileri
  final bool hasChronicIllness;
  final String? chronicIllnessDetails;
  final bool usesRegularMedication;
  final String? medicationDetails;
  final bool hasPsychologicalHistory;
  final String? psychologicalDetails;

  // Genel
  final String? generalNotes;
  final String createdAt;

  // UI için şube ve düzey adı (join ile doldurulur)
  final String? className;
  final String? gradeLevelLabel;

  String get fullName => '$name $surname';
  String get displayClass => className ?? (gradeLevelLabel != null ? '$gradeLevelLabel' : '-');

  Student copyWith({
    int? id,
    int? classId,
    String? number,
    String? name,
    String? surname,
    String? gender,
    String? tcNo,
    String? birthDate,
    String? photoPath,
    String? enrollmentDate,
    String? status,
    String? transferSchool,
    String? transferGrade,
    bool? hasRepeatedGrade,
    String? repeatReason,
    String? specialStatus,
    String? motherName,
    String? motherSurname,
    bool? motherIsBiological,
    bool? motherIsAlive,
    String? motherJob,
    String? motherPhone,
    String? motherAddress,
    bool? motherHasDisability,
    String? motherDisabilityDetails,
    String? fatherName,
    String? fatherSurname,
    bool? fatherIsBiological,
    bool? fatherIsAlive,
    String? fatherJob,
    String? fatherPhone,
    String? fatherAddress,
    bool? fatherHasDisability,
    String? fatherDisabilityDetails,
    String? parentsTogether,
    String? livesWith,
    String? guardianType,
    String? guardianName,
    String? guardianPhone,
    int? siblingCount,
    String? siblingDetails,
    String? householdMembers,
    String? familyNotes,
    String? familyRiskLevel,
    bool? hasChronicIllness,
    String? chronicIllnessDetails,
    bool? usesRegularMedication,
    String? medicationDetails,
    bool? hasPsychologicalHistory,
    String? psychologicalDetails,
    String? generalNotes,
    String? createdAt,
    String? className,
    String? gradeLevelLabel,
  }) =>
      Student(
        id: id ?? this.id,
        classId: classId ?? this.classId,
        number: number ?? this.number,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        gender: gender ?? this.gender,
        tcNo: tcNo ?? this.tcNo,
        birthDate: birthDate ?? this.birthDate,
        photoPath: photoPath ?? this.photoPath,
        enrollmentDate: enrollmentDate ?? this.enrollmentDate,
        status: status ?? this.status,
        transferSchool: transferSchool ?? this.transferSchool,
        transferGrade: transferGrade ?? this.transferGrade,
        hasRepeatedGrade: hasRepeatedGrade ?? this.hasRepeatedGrade,
        repeatReason: repeatReason ?? this.repeatReason,
        specialStatus: specialStatus ?? this.specialStatus,
        motherName: motherName ?? this.motherName,
        motherSurname: motherSurname ?? this.motherSurname,
        motherIsBiological: motherIsBiological ?? this.motherIsBiological,
        motherIsAlive: motherIsAlive ?? this.motherIsAlive,
        motherJob: motherJob ?? this.motherJob,
        motherPhone: motherPhone ?? this.motherPhone,
        motherAddress: motherAddress ?? this.motherAddress,
        motherHasDisability: motherHasDisability ?? this.motherHasDisability,
        motherDisabilityDetails:
            motherDisabilityDetails ?? this.motherDisabilityDetails,
        fatherName: fatherName ?? this.fatherName,
        fatherSurname: fatherSurname ?? this.fatherSurname,
        fatherIsBiological: fatherIsBiological ?? this.fatherIsBiological,
        fatherIsAlive: fatherIsAlive ?? this.fatherIsAlive,
        fatherJob: fatherJob ?? this.fatherJob,
        fatherPhone: fatherPhone ?? this.fatherPhone,
        fatherAddress: fatherAddress ?? this.fatherAddress,
        fatherHasDisability: fatherHasDisability ?? this.fatherHasDisability,
        fatherDisabilityDetails:
            fatherDisabilityDetails ?? this.fatherDisabilityDetails,
        parentsTogether: parentsTogether ?? this.parentsTogether,
        livesWith: livesWith ?? this.livesWith,
        guardianType: guardianType ?? this.guardianType,
        guardianName: guardianName ?? this.guardianName,
        guardianPhone: guardianPhone ?? this.guardianPhone,
        siblingCount: siblingCount ?? this.siblingCount,
        siblingDetails: siblingDetails ?? this.siblingDetails,
        householdMembers: householdMembers ?? this.householdMembers,
        familyNotes: familyNotes ?? this.familyNotes,
        familyRiskLevel: familyRiskLevel ?? this.familyRiskLevel,
        hasChronicIllness: hasChronicIllness ?? this.hasChronicIllness,
        chronicIllnessDetails:
            chronicIllnessDetails ?? this.chronicIllnessDetails,
        usesRegularMedication:
            usesRegularMedication ?? this.usesRegularMedication,
        medicationDetails: medicationDetails ?? this.medicationDetails,
        hasPsychologicalHistory:
            hasPsychologicalHistory ?? this.hasPsychologicalHistory,
        psychologicalDetails: psychologicalDetails ?? this.psychologicalDetails,
        generalNotes: generalNotes ?? this.generalNotes,
        createdAt: createdAt ?? this.createdAt,
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
        'tc_no': tcNo,
        'birth_date': birthDate,
        'photo_path': photoPath,
        'enrollment_date': enrollmentDate,
        'status': status,
        'transfer_school': transferSchool,
        'transfer_grade': transferGrade,
        'has_repeated_grade': hasRepeatedGrade ? 1 : 0,
        'repeat_reason': repeatReason,
        'special_status': specialStatus,
        'mother_name': motherName,
        'mother_surname': motherSurname,
        'mother_is_biological': motherIsBiological ? 1 : 0,
        'mother_is_alive': motherIsAlive ? 1 : 0,
        'mother_job': motherJob,
        'mother_phone': motherPhone,
        'mother_address': motherAddress,
        'mother_has_disability': motherHasDisability ? 1 : 0,
        'mother_disability_details': motherDisabilityDetails,
        'father_name': fatherName,
        'father_surname': fatherSurname,
        'father_is_biological': fatherIsBiological ? 1 : 0,
        'father_is_alive': fatherIsAlive ? 1 : 0,
        'father_job': fatherJob,
        'father_phone': fatherPhone,
        'father_address': fatherAddress,
        'father_has_disability': fatherHasDisability ? 1 : 0,
        'father_disability_details': fatherDisabilityDetails,
        'parents_together': parentsTogether,
        'lives_with': livesWith,
        'guardian_type': guardianType,
        'guardian_name': guardianName,
        'guardian_phone': guardianPhone,
        'sibling_count': siblingCount,
        'sibling_details': siblingDetails,
        'household_members': householdMembers,
        'family_notes': familyNotes,
        'family_risk_level': familyRiskLevel,
        'has_chronic_illness': hasChronicIllness ? 1 : 0,
        'chronic_illness_details': chronicIllnessDetails,
        'uses_regular_medication': usesRegularMedication ? 1 : 0,
        'medication_details': medicationDetails,
        'has_psychological_history': hasPsychologicalHistory ? 1 : 0,
        'psychological_details': psychologicalDetails,
        'general_notes': generalNotes,
        'created_at': createdAt,
      };

  static Student fromMap(Map<String, Object?> map) => Student(
        id: map['id'] as int,
        classId: map['class_id'] as int,
        number: map['number'] as String? ?? (map['no']?.toString() ?? ''),
        name: map['name'] as String,
        surname: map['surname'] as String,
        gender: map['gender'] as String? ?? 'Erkek',
        tcNo: map['tc_no'] as String?,
        birthDate: map['birth_date'] as String?,
        photoPath: map['photo_path'] as String?,
        enrollmentDate: map['enrollment_date'] as String?,
        status: map['status'] as String? ?? 'Aktif',
        transferSchool: map['transfer_school'] as String?,
        transferGrade: map['transfer_grade'] as String?,
        hasRepeatedGrade: (map['has_repeated_grade'] as int? ?? 0) == 1,
        repeatReason: map['repeat_reason'] as String?,
        specialStatus: map['special_status'] as String?,
        motherName: map['mother_name'] as String?,
        motherSurname: map['mother_surname'] as String?,
        motherIsBiological: (map['mother_is_biological'] as int? ?? 1) == 1,
        motherIsAlive: (map['mother_is_alive'] as int? ?? 1) == 1,
        motherJob: map['mother_job'] as String?,
        motherPhone: map['mother_phone'] as String?,
        motherAddress: map['mother_address'] as String?,
        motherHasDisability: (map['mother_has_disability'] as int? ?? 0) == 1,
        motherDisabilityDetails: map['mother_disability_details'] as String?,
        fatherName: map['father_name'] as String?,
        fatherSurname: map['father_surname'] as String?,
        fatherIsBiological: (map['father_is_biological'] as int? ?? 1) == 1,
        fatherIsAlive: (map['father_is_alive'] as int? ?? 1) == 1,
        fatherJob: map['father_job'] as String?,
        fatherPhone: map['father_phone'] as String?,
        fatherAddress: map['father_address'] as String?,
        fatherHasDisability: (map['father_has_disability'] as int? ?? 0) == 1,
        fatherDisabilityDetails: map['father_disability_details'] as String?,
        parentsTogether: map['parents_together'] as String? ?? 'Birlikte',
        livesWith: map['lives_with'] as String? ?? 'Anne-Baba',
        guardianType: map['guardian_type'] as String? ?? 'Anne-Baba',
        guardianName: map['guardian_name'] as String?,
        guardianPhone: map['guardian_phone'] as String?,
        siblingCount: map['sibling_count'] as int? ?? 0,
        siblingDetails: map['sibling_details'] as String?,
        householdMembers: map['household_members'] as String?,
        familyNotes: map['family_notes'] as String?,
        familyRiskLevel: map['family_risk_level'] as String? ?? 'Düşük',
        hasChronicIllness: (map['has_chronic_illness'] as int? ?? 0) == 1,
        chronicIllnessDetails: map['chronic_illness_details'] as String?,
        usesRegularMedication: (map['uses_regular_medication'] as int? ?? 0) == 1,
        medicationDetails: map['medication_details'] as String?,
        hasPsychologicalHistory:
            (map['has_psychological_history'] as int? ?? 0) == 1,
        psychologicalDetails: map['psychological_details'] as String?,
        generalNotes: map['general_notes'] as String?,
        createdAt: map['created_at'] as String? ?? '',
        className: map['class_name'] as String?,
        gradeLevelLabel: map['grade_level_label'] as String?,
      );
}


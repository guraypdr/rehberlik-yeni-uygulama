class BepMeeting {
  const BepMeeting({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentNumber,
    required this.className,
    required this.studentBirthDate,
    required this.studentGender,
    required this.meetingDate,
    required this.agendaItems,
    required this.decisions,
    required this.teacherIds,
    required this.teacherNames,
    required this.createdAt,
    this.parentAttendees = const [],
    this.staffAttendees = const [],
  });

  final int id;
  final int studentId;
  final String studentName;
  final String studentNumber;
  final String className;
  final String? studentBirthDate;
  final String studentGender;
  final String meetingDate;
  final List<String> agendaItems;
  final List<String> decisions;
  final List<int> teacherIds;
  final List<String> teacherNames;

  /// Toplantıya katılan veli adları (anne ve/veya baba).
  final List<String> parentAttendees;

  /// Toplantıya katılan idareci ve psikolojik danışman adları.
  final List<String> staffAttendees;
  final String createdAt;
}

const bepMeetingAgendaItems = <String>[
  'Öğrenciye yönelik sınıf ve okul içerisinde alınabilecek tedbirlerin görüşülmesi',
  'Öğrenci ve veli ile yapılması planlanan rehberlik ve psikolojik danışma çalışmalarının Psikolojik Danışman …................................ tarafından paylaşılması ve görüşlerin alınması',
  'Tüm branş öğretmenlerinin öğrenciye ait eğitsel performanslarını sunması',
  'Tüm branşlarda öğretmenlerin eğitsel performans önerilerinin incelenerek öğrencinin eğitim-öğretim planlarının görüşülmesi',
  'Destek eğitim ihtiyacının görüşülmesi',
  'Bir sonraki toplantı tarihinin görüşülmesi',
];

const bepMeetingDecisionItems = <String>[
  'Öğrencinin eğitim performansına uygun bireyselleştirilmiş eğitim planının uygulanmasına',
  'Öğrencinin sınıf ve okul ortamında ihtiyaç duyduğu desteklerin sağlanmasına',
  'Öğrencinin gelişiminin düzenli olarak izlenmesine ve değerlendirilmesine',
  'Veli ile iş birliği ve düzenli iletişim kurulmasına',
  'Gerekli görülen destek eğitim hizmetlerinin planlanmasına',
];

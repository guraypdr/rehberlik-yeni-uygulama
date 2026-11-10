import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../students/presentation/students_provider.dart';
import '../data/school_risk_dao.dart';

class SchoolRiskCountsNotifier extends AsyncNotifier<SchoolRiskCounts> {
  @override
  Future<SchoolRiskCounts> build() async {
    final database = ref.watch(databaseProvider);
    final students = await ref.watch(studentsProvider.future);
    if (database == null) return const {};
    return SchoolRiskDao(database).fetchCounts(students);
  }
}

final schoolRiskCountsProvider =
    AsyncNotifierProvider<SchoolRiskCountsNotifier, SchoolRiskCounts>(
      SchoolRiskCountsNotifier.new,
    );

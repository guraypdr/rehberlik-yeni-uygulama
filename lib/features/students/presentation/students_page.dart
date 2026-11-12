import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/classes/presentation/classes_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../domain/student.dart';
import 'students_provider.dart';
import 'widgets/student_card.dart';

/// Öğrenciler Sayfası.
class StudentsPage extends ConsumerStatefulWidget {
  const StudentsPage({super.key});

  @override
  ConsumerState<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends ConsumerState<StudentsPage> {
  final _searchCtrl = TextEditingController();

  int? _selectedClassFilter;
  String _selectedGenderFilter = 'all'; // 'all', 'Kız', 'Erkek'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final studentsAsync = ref.watch(studentsProvider);
    final classesState = ref.watch(classesProvider).valueOrNull;
    final classes = classesState?.classes ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Başlık ──────────────────────────────────────────────
              const PageHeader(
                title: 'Öğrenciler',
                subtitle:
                    'Öğrenci profilleri ve görüşme takibi. Yeni öğrenci eklemek '
                    'için Sınıflar bölümünden bir sınıf açın.',
              ),

              // ── 2. İstatistik Sayaçları ─────────────────────────────────
              studentsAsync.when(
                data: (allStudents) {
                  final total = allStudents.length;
                  final femaleCount = allStudents
                      .where((s) => s.gender == 'Kız')
                      .length;
                  final maleCount = allStudents
                      .where((s) => s.gender == 'Erkek')
                      .length;
                  final completedForms = allStudents
                      .where((s) => s.studentInfoFormCompletion == 100)
                      .length;

                  final columns = constraints.maxWidth >= 900
                      ? 4
                      : constraints.maxWidth >= 560
                      ? 2
                      : 1;
                  const spacing = AppSpacing.md;
                  final tileWidth =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: tileWidth,
                        child: StatTile(
                          icon: Icons.people_outline,
                          label: 'Toplam Öğrenci',
                          value: '$total',
                          color: cs.primary,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: StatTile(
                          icon: Icons.female,
                          label: 'Kız',
                          value: '$femaleCount',
                          color: const Color(0xFFE91E63),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: StatTile(
                          icon: Icons.male,
                          label: 'Erkek',
                          value: '$maleCount',
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: StatTile(
                          icon: Icons.check_circle_outline,
                          label: 'Formu Tamamlanan',
                          value: '$completedForms',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 3. Arama ve Filtreleme Araç Çubuğu ───────────────────────
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Arama kutusu
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Ad, soyad veya öğrenci no ile ara...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    setState(() => _searchCtrl.clear());
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Şube Filtresi
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedClassFilter,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          prefixIcon: Icon(
                            Icons.meeting_room_outlined,
                            size: 16,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tüm Şubeler'),
                          ),
                          for (final c in classes)
                            DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.gradeLevelLabel} / ${c.branch}'),
                            ),
                        ],
                        onChanged: (id) =>
                            setState(() => _selectedClassFilter = id),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Cinsiyet Filtresi
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGenderFilter,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Tüm Cinsiyet'),
                          ),
                          DropdownMenuItem(value: 'Kız', child: Text('Kız')),
                          DropdownMenuItem(
                            value: 'Erkek',
                            child: Text('Erkek'),
                          ),
                        ],
                        onChanged: (g) =>
                            setState(() => _selectedGenderFilter = g ?? 'all'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 4. Öğrenci Listesi / Kart Izgarası ────────────────────────
              studentsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) =>
                    Center(child: Text('Öğrenciler yüklenemedi: $err')),
                data: (allStudents) {
                  final filtered = _filterStudents(allStudents);

                  if (allStudents.isEmpty) {
                    return const EmptyState(
                      icon: Icons.people_outline,
                      title: 'Henüz Öğrenci Kaydı Bulunmuyor',
                      message:
                          'Öğrencileri eklemek için Sınıflar bölümünden bir '
                          'sınıf açın. Buradan tek tek veya Excel listenizden '
                          'toplu ekleme yapabilirsiniz.',
                    );
                  }

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Sonuç bulunamadı',
                      message: 'Arama kriterlerine uygun öğrenci bulunamadı.',
                      action: TextButton(
                        onPressed: () {
                          setState(() {
                            _searchCtrl.clear();
                            _selectedClassFilter = null;
                            _selectedGenderFilter = 'all';
                          });
                        },
                        child: const Text('Filtreleri Temizle'),
                      ),
                    );
                  }

                  // 2 sütunlu duyarlı kart ızgarası
                  final crossCount = constraints.maxWidth > 800 ? 2 : 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 172,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      return StudentCard(
                        student: student,
                        onDelete: () => _confirmDelete(student),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Student> _filterStudents(List<Student> list) {
    final q = _searchCtrl.text.trim().toLowerCase();

    return list.where((s) {
      // Şube filtresi
      if (_selectedClassFilter != null && s.classId != _selectedClassFilter) {
        return false;
      }
      // Cinsiyet filtresi
      if (_selectedGenderFilter != 'all' && s.gender != _selectedGenderFilter) {
        return false;
      }
      // Arama metni
      if (q.isNotEmpty) {
        final matchName = s.fullName.toLowerCase().contains(q);
        final matchNo = s.number.toLowerCase().contains(q);
        final matchClass = s.displayClass.toLowerCase().contains(q);
        if (!matchName && !matchNo && !matchClass) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _confirmDelete(Student student) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: Text(
          '${student.fullName} (#${student.number}) isimli öğrenci kaydı ve tüm görüşmeleri silinecek. Emin misiniz?',
        ),
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
      await ref.read(studentsProvider.notifier).deleteStudent(student.id);
    }
  }
}

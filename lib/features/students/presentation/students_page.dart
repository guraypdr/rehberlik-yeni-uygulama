import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/classes/presentation/classes_provider.dart';
import '../domain/student.dart';
import 'students_provider.dart';
import 'widgets/quick_student_dialog.dart';
import 'widgets/student_card.dart';
import 'widgets/student_detail_sheet.dart';
import 'widgets/student_import_dialog.dart';

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
  String _selectedStatusFilter = 'all'; // 'all', 'Aktif', 'Nakil', 'Mezun'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

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
              // ── 1. Başlık ve Üst Butonlar ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Öğrenciler', style: t.headlineSmall),
                        const SizedBox(height: 2),
                        Text(
                          'Öğrenci profilleri, aile/veli bilgileri, sağlık durumu ve görüşme takibi',
                          style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Excel içe aktar
                  OutlinedButton.icon(
                    icon: const Icon(Icons.file_upload_outlined, size: 16),
                    label: const Text('Excel\'den İçe Aktar'),
                    onPressed: () => StudentImportDialog.show(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Yeni öğrenci ekle
                  FilledButton.icon(
                    icon: const Icon(Icons.person_add_outlined, size: 16),
                    label: const Text('Yeni Öğrenci'),
                    onPressed: () {
                      QuickStudentDialog.show(
                        context,
                        initialClassId: _selectedClassFilter,
                        onStudentCreated: (student, openDetails) {
                          if (openDetails) {
                            StudentDetailSheet.show(context, student);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 2. İstatistik Sayaçları ─────────────────────────────────
              studentsAsync.when(
                data: (allStudents) {
                  final total = allStudents.length;
                  final femaleCount =
                      allStudents.where((s) => s.gender == 'Kız').length;
                  final maleCount =
                      allStudents.where((s) => s.gender == 'Erkek').length;
                  final activeCount =
                      allStudents.where((s) => s.status == 'Aktif').length;

                  return Row(
                    children: [
                      _StatChip(
                        icon: Icons.people_outline,
                        label: 'Toplam Öğrenci',
                        value: '$total',
                        color: cs.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StatChip(
                        icon: Icons.female,
                        label: 'Kız',
                        value: '$femaleCount',
                        color: const Color(0xFFE91E63),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StatChip(
                        icon: Icons.male,
                        label: 'Erkek',
                        value: '$maleCount',
                        color: const Color(0xFF1976D2),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StatChip(
                        icon: Icons.check_circle_outline,
                        label: 'Aktif Öğrenci',
                        value: '$activeCount',
                        color: AppColors.success,
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 3. Arama ve Filtreleme Araç Çubuğu ───────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // Arama kutusu
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Ad, soyad, okul no veya TC ile ara...',
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
                          prefixIcon: Icon(Icons.meeting_room_outlined, size: 16),
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
                          DropdownMenuItem(value: 'all', child: Text('Tüm Cinsiyet')),
                          DropdownMenuItem(value: 'Kız', child: Text('Kız')),
                          DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                        ],
                        onChanged: (g) =>
                            setState(() => _selectedGenderFilter = g ?? 'all'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Durum Filtresi
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatusFilter,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tüm Durumlar')),
                          DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                          DropdownMenuItem(value: 'Nakil Gitti', child: Text('Nakil')),
                          DropdownMenuItem(value: 'Mezun', child: Text('Mezun')),
                          DropdownMenuItem(value: 'Ayrıldı', child: Text('Ayrıldı')),
                        ],
                        onChanged: (s) =>
                            setState(() => _selectedStatusFilter = s ?? 'all'),
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
                error: (err, _) => Center(
                  child: Text('Öğrenciler yüklenemedi: $err'),
                ),
                data: (allStudents) {
                  final filtered = _filterStudents(allStudents);

                  if (allStudents.isEmpty) {
                    return _EmptyStudentsView(
                      onAdd: () {
                        QuickStudentDialog.show(
                          context,
                          onStudentCreated: (s, openDetails) {
                            if (openDetails) {
                              StudentDetailSheet.show(context, s);
                            }
                          },
                        );
                      },
                      onImport: () => StudentImportDialog.show(context),
                    );
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Arama kriterlerine uygun öğrenci bulunamadı.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchCtrl.clear();
                                  _selectedClassFilter = null;
                                  _selectedGenderFilter = 'all';
                                  _selectedStatusFilter = 'all';
                                });
                              },
                              child: const Text('Filtreleri Temizle'),
                            ),
                          ],
                        ),
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
                      mainAxisExtent: 148,
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
      // Durum filtresi
      if (_selectedStatusFilter != 'all' && s.status != _selectedStatusFilter) {
        return false;
      }
      // Arama metni
      if (q.isNotEmpty) {
        final matchName = s.fullName.toLowerCase().contains(q);
        final matchNo = s.number.toLowerCase().contains(q);
        final matchTc = s.tcNo?.toLowerCase().contains(q) ?? false;
        final matchClass = s.displayClass.toLowerCase().contains(q);
        if (!matchName && !matchNo && !matchTc && !matchClass) {
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

// ────────────────────────────────────────────────────────────────────────────
// İstatistik Çipi
// ────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Boş Durum Görünümü
// ────────────────────────────────────────────────────────────────────────────

class _EmptyStudentsView extends StatelessWidget {
  const _EmptyStudentsView({
    required this.onAdd,
    required this.onImport,
  });

  final VoidCallback onAdd;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Henüz Öğrenci Kaydı Bulunmuyor',
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Okulunuzdaki öğrencileri tek tek temel bilgilerle ekleyebilir veya Excel listenizden kopyalayarak toplu içe aktarabilirsiniz.',
              textAlign: TextAlign.center,
              style: t.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_upload_outlined, size: 16),
                  label: const Text('Excel\'den Aktar'),
                  onPressed: onImport,
                ),
                const SizedBox(width: AppSpacing.md),
                FilledButton.icon(
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Öğrenci Ekle'),
                  onPressed: onAdd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

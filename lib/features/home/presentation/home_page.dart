import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/classes/presentation/classes_provider.dart';
import '../../../features/setup/domain/school_profile.dart';
import '../../../features/students/presentation/students_provider.dart';
import '../../../features/teachers/presentation/teachers_provider.dart';
import '../../../features/todos/domain/todo_item.dart';
import '../../../features/todos/presentation/todos_provider.dart';
import '../../../shared/navigation/app_navigation.dart';

String _schoolNameTitleCase(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .map((word) {
      if (word.isEmpty) return word;
      final lowercase = word
          .replaceAll('İ', 'i')
          .replaceAll('I', 'ı')
          .toLowerCase()
          .replaceAll('i\u0307', 'i');
      final characters = lowercase.runes.toList();
      final first = String.fromCharCode(characters.first);
      final capitalizedFirst = switch (first) {
        'i' => 'İ',
        'ı' => 'I',
        _ => first.toUpperCase(),
      };
      return '$capitalizedFirst${String.fromCharCodes(characters.skip(1))}';
    })
    .join(' ');

/// Ana Sayfa — Referans tasarıma uygun dashboard.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider).valueOrNull ?? const TodosState();
    final teachers = ref.watch(teachersProvider).valueOrNull ?? [];
    final classes =
        ref.watch(classesProvider).valueOrNull ?? const ClassesState();
    final students = ref.watch(studentsProvider).valueOrNull ?? [];
    final profile = ref.watch(sessionProvider).valueOrNull?.schoolProfile;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 680;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Başlık ─────────────────────────────────────────────────
              _Header(profile: profile),
              const SizedBox(height: AppSpacing.xl),

              // ── İstatistik satırı ───────────────────────────────────────
              _StatsRow(
                wide: wide,
                studentCount: students.length,
                classCount: classes.classes.length,
                teacherCount: teachers.length,
                pendingCount: todos.pendingCount,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Orta bölüm ──────────────────────────────────────────────
              if (wide)
                _WideBody(profile: profile, todos: todos)
              else
                _NarrowBody(profile: profile, todos: todos),
            ],
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Başlık
// ────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final SchoolProfile? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greet(now.hour), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                profile == null
                    ? 'Ana Sayfa'
                    : _schoolNameTitleCase(profile!.name),
                style: theme.textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _DateChip(now: now),
      ],
    );
  }

  static String _greet(int h) {
    if (h < 12) return 'Günaydın 👋';
    if (h < 17) return 'İyi günler 👋';
    return 'İyi akşamlar 👋';
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.now});
  final DateTime now;

  static const _ay = [
    '',
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];
  static const _gun = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${now.day} ${_ay[now.month]}',
            style: t.labelLarge?.copyWith(color: cs.primary),
          ),
          Text(
            _gun[(now.weekday - 1) % 7],
            style: t.bodySmall?.copyWith(color: cs.primary),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// İstatistik satırı — 4 kart (tıklanabilir)
// ────────────────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  const _StatsRow({
    required this.wide,
    required this.studentCount,
    required this.classCount,
    required this.teacherCount,
    required this.pendingCount,
  });

  final bool wide;
  final int studentCount, classCount, teacherCount, pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final cards = [
      _StatCard(
        value: '$studentCount',
        label: 'Öğrenci',
        icon: Icons.people_outline,
        color: cs.primary,
        onTap: () => ref.read(navigationProvider.notifier).select('students'),
      ),
      _StatCard(
        value: '$classCount',
        label: 'Şube',
        icon: Icons.meeting_room_outlined,
        color: const Color(0xFF7C5CBF),
        onTap: () => ref.read(navigationProvider.notifier).select('classes'),
      ),
      _StatCard(
        value: '$teacherCount',
        label: 'Öğretmen',
        icon: Icons.person_outline_rounded,
        color: const Color(0xFF2A8A5E),
        onTap: () => ref.read(navigationProvider.notifier).select('teachers'),
      ),
      _StatCard(
        value: '$pendingCount',
        label: 'Açık Görev',
        icon: Icons.checklist_rtl_outlined,
        color: const Color(0xFFD4841A),
        onTap: () => ref.read(navigationProvider.notifier).select('todos'),
      ),
    ];

    if (wide) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.4,
      children: cards,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String value, label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return MouseRegion(
      cursor: onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.md),
                  ),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(label, style: t.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Geniş/Dar orta bölümler
// ────────────────────────────────────────────────────────────────────────────

class _WideBody extends StatelessWidget {
  const _WideBody({required this.profile, required this.todos});
  final SchoolProfile? profile;
  final TodosState todos;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sol: vurgu kartı + okul bilgisi
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _HeroCard(profile: profile),
              const SizedBox(height: AppSpacing.lg),
              _SchoolInfoCard(profile: profile),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // Sağ: hızlı erişim + görev özeti
        Expanded(
          flex: 6,
          child: Column(
            children: [
              const _QuickAccessCard(),
              const SizedBox(height: AppSpacing.lg),
              _TodoSummaryCard(todos: todos),
            ],
          ),
        ),
      ],
    );
  }
}

class _NarrowBody extends StatelessWidget {
  const _NarrowBody({required this.profile, required this.todos});
  final SchoolProfile? profile;
  final TodosState todos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroCard(profile: profile),
        const SizedBox(height: AppSpacing.lg),
        const _QuickAccessCard(),
        const SizedBox(height: AppSpacing.lg),
        _SchoolInfoCard(profile: profile),
        const SizedBox(height: AppSpacing.lg),
        _TodoSummaryCard(todos: todos),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Vurgu kartı
// ────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});
  final SchoolProfile? profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, Color.lerp(cs.primary, Colors.black, 0.18)!],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: ikon + rozet
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.sm),
                  ),
                ),
                child: const Icon(
                  Icons.psychology_alt_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const Spacer(),
              _WhiteBadge(label: profile?.schoolType.label ?? 'Rehberlik'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Okul adı
          Text(
            profile == null
                ? 'Rehberlik Yönetim'
                : _schoolNameTitleCase(profile!.name),
            style: t.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Öğrenci takibi, görüşme notları ve rehberlik çalışmalarını '
            'tek ekrandan yönetin.',
            style: t.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Alt rozet satırı
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (profile != null)
                _WhiteOutlinedBadge(
                  icon: Icons.school_outlined,
                  label: profile!.schoolType.label,
                ),
              if (profile?.hasPrep == true)
                const _WhiteOutlinedBadge(
                  icon: Icons.auto_stories_outlined,
                  label: 'Hazırlık',
                ),
              if (profile?.fields.isNotEmpty == true)
                _WhiteOutlinedBadge(
                  icon: Icons.category_outlined,
                  label: '${profile!.fields.length} Alan',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteBadge extends StatelessWidget {
  const _WhiteBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WhiteOutlinedBadge extends StatelessWidget {
  const _WhiteOutlinedBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Okul bilgisi kartı
// ────────────────────────────────────────────────────────────────────────────

class _SchoolInfoCard extends ConsumerWidget {
  const _SchoolInfoCard({required this.profile});
  final SchoolProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (profile == null) return const SizedBox.shrink();

    return _DashCard(
      title: 'Okul Bilgisi',
      actionLabel: 'Ayarlar',
      onAction: () => ref.read(navigationProvider.notifier).select('settings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst: ikon + isim
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.md),
                  ),
                ),
                child: Icon(Icons.school_outlined, color: cs.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _schoolNameTitleCase(profile!.name),
                      style: t.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(profile!.schoolType.label, style: t.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Bilgi ızgarası
          Row(
            children: [
              Expanded(
                child: _InfoCell(
                  label: 'Okul Türü',
                  value: profile!.schoolType.label,
                ),
              ),
              Expanded(
                child: _InfoCell(
                  label: 'Hazırlık',
                  value: profile!.hasPrep ? 'Var' : 'Yok',
                ),
              ),
            ],
          ),
          if (profile!.fields.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoCell(label: 'Alanlar', value: profile!.fields.join(' • ')),
          ],
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: t.labelLarge?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Hızlı erişim kartı (çalışır butonlar)
// ────────────────────────────────────────────────────────────────────────────

class _QuickAccessCard extends ConsumerWidget {
  const _QuickAccessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = const [
      _QItem(
        icon: Icons.people_outline,
        label: 'Öğrenciler',
        sub: 'Öğrenci dosyaları ve görüşmeler',
        color: Color(0xFF2563EB),
        destinationId: 'students',
      ),
      _QItem(
        icon: Icons.meeting_room_outlined,
        label: 'Sınıflar',
        sub: 'Şube yönetimi',
        color: Color(0xFF7C5CBF),
        destinationId: 'classes',
      ),
      _QItem(
        icon: Icons.person_outline_rounded,
        label: 'Öğretmenler',
        sub: 'Öğretmen kayıtları',
        color: Color(0xFF0D9488),
        destinationId: 'teachers',
      ),
      _QItem(
        icon: Icons.checklist_rtl_outlined,
        label: 'Yapılacaklar',
        sub: 'Görev listesi',
        color: Color(0xFFD4841A),
        destinationId: 'todos',
      ),
    ];

    return _DashCard(
      title: 'Hızlı Erişim',
      trailingIcon: Icons.grid_view_rounded,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 48, endIndent: 0),
            _QRow(
              item: items[i],
              onTap: () => ref
                  .read(navigationProvider.notifier)
                  .select(items[i].destinationId),
            ),
          ],
        ],
      ),
    );
  }
}

class _QItem {
  const _QItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.destinationId,
  });

  final IconData icon;
  final String label, sub;
  final Color color;
  final String destinationId;
}

class _QRow extends StatefulWidget {
  const _QRow({required this.item, required this.onTap});
  final _QItem item;
  final VoidCallback onTap;

  @override
  State<_QRow> createState() => _QRowState();
}

class _QRowState extends State<_QRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: widget.item.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hov = true),
        onExit: (_) => setState(() => _hov = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: _hov ? AppColors.hover : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.item.color.withValues(alpha: 0.10),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Icon(
                    widget.item.icon,
                    size: 16,
                    color: widget.item.color,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.item.label, style: t.labelLarge),
                      Text(widget.item.sub, style: t.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: _hov ? cs.primary : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Yapılacaklar özeti kartı
// ────────────────────────────────────────────────────────────────────────────

class _TodoSummaryCard extends ConsumerWidget {
  const _TodoSummaryCard({required this.todos});
  final TodosState todos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final total = todos.pendingCount + todos.completedCount;
    final ratio = total == 0 ? 0.0 : todos.completedCount / total;
    final recent = todos.items.where((i) => !i.isCompleted).take(4).toList();

    return _DashCard(
      title: 'Yapılacaklar',
      actionLabel: '${todos.pendingCount} açık',
      onAction: () => ref.read(navigationProvider.notifier).select('todos'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İlerleme çubuğu
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.pill),
                  ),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                total == 0 ? '—' : '${todos.completedCount}/$total',
                style: t.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xs),

          // Görev listesi
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tüm görevler tamamlandı!',
                    style: t.bodyMedium?.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            )
          else
            for (final todo in recent) _TodoLine(todo: todo),
        ],
      ),
    );
  }
}

class _TodoLine extends StatelessWidget {
  const _TodoLine({required this.todo});
  final TodoItem todo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              todo.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Ortak kart çerçevesi
// ────────────────────────────────────────────────────────────────────────────

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.trailingIcon,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kart başlığı
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(title, style: t.titleSmall),
                const Spacer(),
                if (actionLabel != null)
                  MouseRegion(
                    cursor: onAction != null
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: GestureDetector(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppRadius.pill),
                          ),
                        ),
                        child: Text(
                          actionLabel!,
                          style: t.labelMedium?.copyWith(color: cs.primary),
                        ),
                      ),
                    ),
                  ),
                if (trailingIcon != null)
                  Icon(trailingIcon, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
          const Divider(height: 1),

          // İçerik
          Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
        ],
      ),
    );
  }
}

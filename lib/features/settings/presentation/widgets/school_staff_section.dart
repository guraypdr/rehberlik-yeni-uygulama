import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/school_staff.dart';
import '../school_staff_provider.dart';

/// Ayarlar sayfasındaki idari kadro (müdür, müdür yardımcısı, danışman) bölümü.
class SchoolStaffSection extends ConsumerWidget {
  const SchoolStaffSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff =
        ref.watch(schoolStaffProvider).valueOrNull ?? const <SchoolStaff>[];
    final principal = staff
        .where((member) => member.role == SchoolStaffRole.principal)
        .firstOrNull;
    final vicePrincipals = staff
        .where((member) => member.role == SchoolStaffRole.vicePrincipal)
        .toList();
    final counselors = staff
        .where((member) => member.role == SchoolStaffRole.counselor)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İdari Kadro ve Rehberlik',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _group(
                context,
                ref,
                role: SchoolStaffRole.principal,
                members: principal == null ? const [] : [principal],
                emptyText: 'Okul müdürü eklenmedi.',
              ),
              const Divider(height: AppSpacing.xl),
              _group(
                context,
                ref,
                role: SchoolStaffRole.vicePrincipal,
                members: vicePrincipals,
                emptyText: 'Müdür yardımcısı eklenmedi.',
                allowAdd: true,
              ),
              const Divider(height: AppSpacing.xl),
              _group(
                context,
                ref,
                role: SchoolStaffRole.counselor,
                members: counselors,
                emptyText: 'Psikolojik danışman eklenmedi.',
                allowAdd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tek kişilik roller (müdür) dolu ise yalnızca düzenleme yapılabilir.
  Widget _group(
    BuildContext context,
    WidgetRef ref, {
    required SchoolStaffRole role,
    required List<SchoolStaff> members,
    required String emptyText,
    bool allowAdd = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                role.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (allowAdd || members.isEmpty)
              TextButton.icon(
                key: Key('add_school_staff_${role.name}'),
                onPressed: () => _openForm(context, ref, role: role),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ekle'),
              ),
          ],
        ),
        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              emptyText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          for (final member in members) _memberRow(context, ref, member),
      ],
    );
  }

  Widget _memberRow(BuildContext context, WidgetRef ref, SchoolStaff member) {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            member.fullName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        IconButton(
          key: Key('edit_school_staff_${member.id}'),
          tooltip: 'Düzenle',
          onPressed: () =>
              _openForm(context, ref, role: member.role, member: member),
          icon: const Icon(Icons.edit_outlined, size: 18),
        ),
        IconButton(
          key: Key('delete_school_staff_${member.id}'),
          tooltip: 'Sil',
          onPressed: () => _confirmDelete(context, ref, member),
          icon: const Icon(Icons.delete_outline, size: 18),
        ),
      ],
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    required SchoolStaffRole role,
    SchoolStaff? member,
  }) async {
    final result = await showDialog<({String name, String surname})>(
      context: context,
      builder: (_) => _StaffFormDialog(role: role, member: member),
    );
    if (result == null) return;

    final notifier = ref.read(schoolStaffProvider.notifier);
    try {
      if (member == null) {
        if (role == SchoolStaffRole.principal) {
          await notifier.savePrincipal(
            name: result.name,
            surname: result.surname,
          );
        } else {
          await notifier.addMember(
            role: role,
            name: result.name,
            surname: result.surname,
          );
        }
      } else {
        await notifier.updateMember(
          id: member.id,
          name: result.name,
          surname: result.surname,
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Personel kaydedilemedi: $error')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SchoolStaff member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Personeli sil'),
        content: Text('${member.fullName} kaydı silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            key: const Key('confirm_delete_school_staff'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(schoolStaffProvider.notifier).removeMember(member.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Personel silinemedi: $error')));
      }
    }
  }
}

/// Personel ekleme/düzenleme formu.
class _StaffFormDialog extends StatefulWidget {
  const _StaffFormDialog({required this.role, this.member});

  final SchoolStaffRole role;
  final SchoolStaff? member;

  @override
  State<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<_StaffFormDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.member?.name ?? '',
  );
  late final TextEditingController _surnameController = TextEditingController(
    text: widget.member?.surname ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    if (name.isEmpty || surname.isEmpty) return;
    Navigator.of(context).pop((name: name, surname: surname));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;
    return AlertDialog(
      title: Text('${widget.role.label} ${isEditing ? 'Düzenle' : 'Ekle'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('school_staff_name'),
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Ad'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('school_staff_surname'),
            controller: _surnameController,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(labelText: 'Soyad'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        FilledButton(
          key: const Key('school_staff_form_save'),
          onPressed: _submit,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

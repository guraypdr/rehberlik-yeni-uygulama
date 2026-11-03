import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../teachers_provider.dart';

/// Yeni öğretmen ekleme alanı.
class TeacherComposer extends ConsumerStatefulWidget {
  const TeacherComposer({super.key});

  @override
  ConsumerState<TeacherComposer> createState() => _TeacherComposerState();
}

class _TeacherComposerState extends ConsumerState<TeacherComposer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    _nameController.clear();
    _surnameController.clear();
    await ref
        .read(teachersProvider.notifier)
        .addTeacher(name: name, surname: surname);
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 520;

          final nameField = TextFormField(
            key: const Key('teacher_name_input'),
            controller: _nameController,
            textInputAction: TextInputAction.next,
            validator: _required,
            decoration: const InputDecoration(
              hintText: 'Ad',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
          );

          final surnameField = TextFormField(
            key: const Key('teacher_surname_input'),
            controller: _surnameController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => unawaited(_submit()),
            validator: _required,
            decoration: const InputDecoration(
              hintText: 'Soyad',
              prefixIcon: Icon(Icons.badge_outlined, size: 20),
            ),
          );

          final addButton = FilledButton.icon(
            key: const Key('teacher_add_button'),
            onPressed: _submit,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Ekle'),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                nameField,
                const SizedBox(height: AppSpacing.sm),
                surnameField,
                const SizedBox(height: AppSpacing.sm),
                addButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: nameField),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: surnameField),
              const SizedBox(width: AppSpacing.md),
              addButton,
            ],
          );
        },
      ),
    );
  }
}

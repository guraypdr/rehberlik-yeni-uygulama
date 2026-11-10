import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../teachers_provider.dart';
import 'teacher_import_dialog.dart';

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
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _branchController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(teachersProvider.notifier)
          .addTeacher(
            name: _nameController.text,
            surname: _surnameController.text,
            branch: _branchController.text,
            email: _emailController.text,
            phone: _phoneController.text,
          );
      if (!mounted) return;
      _nameController.clear();
      _surnameController.clear();
      _branchController.clear();
      _emailController.clear();
      _phoneController.clear();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Öğretmen eklenemedi: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Geçerli bir e-posta girin';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 4
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          final fieldWidth = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth -
                    AppSpacing.md * (columns - 1)) /
                  columns;

          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _field(
                key: const Key('teacher_name_input'),
                controller: _nameController,
                label: 'Ad',
                icon: Icons.person_outline,
                validator: _required,
                width: fieldWidth,
              ),
              _field(
                key: const Key('teacher_surname_input'),
                controller: _surnameController,
                label: 'Soyad',
                icon: Icons.badge_outlined,
                validator: _required,
                width: fieldWidth,
              ),
              _field(
                key: const Key('teacher_branch_input'),
                controller: _branchController,
                label: 'Branş',
                icon: Icons.menu_book_outlined,
                validator: _required,
                width: fieldWidth,
              ),
              _field(
                key: const Key('teacher_email_input'),
                controller: _emailController,
                label: 'E-posta',
                icon: Icons.email_outlined,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                width: fieldWidth,
              ),
              _field(
                key: const Key('teacher_phone_input'),
                controller: _phoneController,
                label: 'Cep telefonu',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                width: fieldWidth,
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      key: const Key('teacher_add_button'),
                      onPressed: _isSaving ? null : _submit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Ekle'),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      key: const Key('teacher_import_button'),
                      onPressed: _isSaving
                          ? null
                          : () => TeacherImportDialog.show(context),
                      icon: const Icon(Icons.table_view_outlined, size: 18),
                      label: const Text('Excel’den Toplu Ekle'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double width,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) => SizedBox(
    width: width,
    child: TextFormField(
      key: key,
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    ),
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../todos_provider.dart';

/// Yeni görev ekleme alanı.
class TodoComposer extends ConsumerStatefulWidget {
  const TodoComposer({super.key});

  @override
  ConsumerState<TodoComposer> createState() => _TodoComposerState();
}

class _TodoComposerState extends ConsumerState<TodoComposer> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _textController.text.trim();
    if (title.isEmpty) return;
    _textController.clear();
    await ref.read(todosProvider.notifier).addTodo(title);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final field = TextField(
          key: const Key('todo_input'),
          controller: _textController,
          focusNode: _focusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => unawaited(_submit()),
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: const InputDecoration(
            hintText: 'Yeni görev yazın',
            prefixIcon: Icon(Icons.add_task_outlined, size: 20),
          ),
        );

        final addButton = FilledButton.icon(
          key: const Key('todo_add_button'),
          onPressed: _submit,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ekle'),
        );

        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field,
              const SizedBox(height: AppSpacing.sm),
              addButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: field),
            const SizedBox(width: AppSpacing.md),
            addButton,
          ],
        );
      },
    );
  }
}

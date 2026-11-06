import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/student.dart';

class StudentInfoFormStatus extends StatelessWidget {
  const StudentInfoFormStatus({
    super.key,
    required this.student,
    this.showProgressBar = false,
  });

  final Student student;
  final bool showProgressBar;

  @override
  Widget build(BuildContext context) {
    final completion = student.studentInfoFormCompletion;
    final isComplete = completion == 100;
    final color = isComplete ? AppColors.success : AppColors.warning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isComplete ? Icons.check_circle_outline : Icons.info_outline,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            isComplete
                ? 'Form tamamlandı · %$completion'
                : 'Formu tamamla · %$completion',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showProgressBar) ...[
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 42,
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 4,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              backgroundColor: color.withValues(alpha: 0.15),
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

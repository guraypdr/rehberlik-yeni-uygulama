import 'package:flutter/material.dart';

enum StudentFormAction { studentInfo }

class StudentFormMenu extends StatelessWidget {
  const StudentFormMenu({super.key, required this.onSelected});

  final ValueChanged<StudentFormAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StudentFormAction>(
      tooltip: 'Öğrenci formu aç',
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: StudentFormAction.studentInfo,
          child: Row(
            children: [
              Icon(Icons.assignment_ind_outlined),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Öğrenci Bilgi Formu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.add, size: 20),
    );
  }
}

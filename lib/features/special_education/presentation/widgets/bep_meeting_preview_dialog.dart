import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/bep_meeting_pdf.dart';
import '../../domain/bep_meeting.dart';

class BepMeetingPreviewDialog extends StatelessWidget {
  const BepMeetingPreviewDialog({
    super.key,
    required this.meeting,
    required this.meetingNumber,
  });

  final BepMeeting meeting;
  final int meetingNumber;

  static Future<void> show(
    BuildContext context, {
    required BepMeeting meeting,
    required int meetingNumber,
  }) => showDialog<void>(
    context: context,
    builder: (_) =>
        BepMeetingPreviewDialog(meeting: meeting, meetingNumber: meetingNumber),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      child: SizedBox(
        width: (size.width - 32).clamp(280.0, 900.0).toDouble(),
        height: (size.height * 0.88).clamp(320.0, 900.0).toDouble(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'BEP Toplantı Tutanağı Önizleme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    key: const Key('close_bep_meeting_preview'),
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: PdfPreview(
                key: const Key('bep_meeting_pdf_preview'),
                pdfFileName: 'BEP_Toplantı_Tutanağı_$meetingNumber.pdf',
                canChangeOrientation: false,
                canChangePageFormat: false,
                build: (_) async => (await BepMeetingPdf.build(
                  meeting: meeting,
                  meetingNumber: meetingNumber,
                )).save(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
